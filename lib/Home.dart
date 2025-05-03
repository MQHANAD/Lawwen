// lib/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swe463project/main.dart';              // mainColor
import 'package:swe463project/services/firestore_service.dart';
import '../models/palette_model.dart';
import '../widgets/palette_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─────────────────────────────  UI constants
  final List<Color> essentialColors = [
    Colors.red, Colors.orange, Colors.yellow,
    Colors.green, Colors.blue, Colors.indigo,
    Colors.purple, Colors.brown, Colors.grey,
  ];

  // ─────────────────────────────  query state
  Color? _filterColor;
  String _sortField = 'createdAt';
  bool   _sortDescending = true;

  // ─────────────────────────────  paging state
  List<PaletteModel> displayedPalettes = [];
  DocumentSnapshot? lastDocument;            // for unfiltered paging
  bool   isLoading = false;
  bool   hasMore   = true;
  static const int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenIds = <String>{};   // global de-dup

  // extra hue-window paging vars
  late List<double> _hueWindow;              // 31 doubles
  int   _hueOffset   = 0;                    // 0,10,20…
  DocumentSnapshot? _chunkCursor;            // inside bucket

  // ─────────────────────────────  lifecycle
  @override
  void initState() {
    super.initState();
    _refreshPalettes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMorePalettes();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────  Firestore helpers
  PaletteModel _docToPalette(QueryDocumentSnapshot<Map<String,dynamic>> doc) {
    final d = doc.data();
    return PaletteModel(
      id: doc.id,
      colorHexCodes: List<String>.from(d['colors']),
      likes: d['likes'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: d['createdBy'] ?? 'Lawwen',
      userName : d['userName']  ?? 'Lawwen',
      hues: (d['hues'] as List<dynamic>)
          .map((e) => (e as num).toDouble()).toList(),
    );
  }

  // fetch next page *within* hue window buckets
  Future<List<PaletteModel>> _nextHuePage() async {
    final List<PaletteModel> out = [];

    while (out.length < _pageSize && _hueOffset < _hueWindow.length) {
      final bucket = _hueWindow.skip(_hueOffset).take(10).toList();

      Query<Map<String,dynamic>> q = FirebaseFirestore.instance
          .collection('palettes')
          .where('hues', arrayContainsAny: bucket)
          .orderBy('likes', descending: true)
          .limit(_pageSize - out.length);

      if (_chunkCursor != null) q = q.startAfterDocument(_chunkCursor!);

      final snap = await q.get();
      final docs = snap.docs.map(_docToPalette).toList();

      // de-dup across whole session
      docs.retainWhere((p) => !_seenIds.contains(p.id));
      _seenIds.addAll(docs.map((e) => e.id));
      out.addAll(docs);

      if (snap.size < (_pageSize - out.length)) {
        // bucket exhausted → move to next bucket
        _hueOffset += 10;
        _chunkCursor = null;
      } else {
        _chunkCursor = snap.docs.last;
      }
    }
    return out;
  }

  // ─────────────────────────────  refresh & paging
  Future<void> _refreshPalettes() async {
    if (isLoading || !mounted) return;
    setState(() => isLoading = true);

    try {
      _seenIds.clear();
      if (_filterColor == null) {
        final first = await fetchPalettes(
          sortField:  _sortField,
          descending: _sortDescending,
          limit:      _pageSize,
        );
        displayedPalettes = first;
        _seenIds.addAll(first.map((e) => e.id));
        hasMore      = first.length == _pageSize;
        lastDocument = first.isNotEmpty
            ? await FirebaseFirestore.instance
            .collection('palettes')
            .doc(first.last.id).get()
            : null;
      } else {
        // reset hue state then page
        final h = HSLColor.fromColor(_filterColor!).hue.round();
        _hueWindow  = List<double>.generate(
            31, (i) => ((h - 15 + i + 360) % 360).toDouble());
        _hueOffset   = 0;
        _chunkCursor = null;

        displayedPalettes = await _nextHuePage();
        hasMore = displayedPalettes.length == _pageSize;
      }
    } catch (e,s) {
      debugPrint('Refresh error ➜ $e\n$s');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadMorePalettes() async {
    if (!hasMore || isLoading || !mounted) return;
    setState(() => isLoading = true);

    try {
      List<PaletteModel> more;
      if (_filterColor == null) {
        more = await fetchPalettes(
          sortField:     _sortField,
          descending:    _sortDescending,
          startAfterDoc: lastDocument,
          limit:         _pageSize,
        );
        more.retainWhere((p) => !_seenIds.contains(p.id));
        _seenIds.addAll(more.map((e) => e.id));
        if (more.isNotEmpty) {
          lastDocument = await FirebaseFirestore.instance
              .collection('palettes')
              .doc(more.last.id).get();
        }
      } else {
        more = await _nextHuePage();
      }

      setState(() {
        displayedPalettes.addAll(more);
        hasMore = more.length == _pageSize;
      });
    } catch (e) {
      debugPrint('Load-more error ➜ $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ─────────────────────────────  sorting / filter
  void _applySort(String field) {
    _sortField = field;
    _sortDescending = true;
    lastDocument = null;
    hasMore      = true;
    _refreshPalettes();
  }

  Future<void> _applyFilter(Color? color) async {
    if (color == null) {
      _filterColor = null;
      return _refreshPalettes();
    }

    _filterColor  = color;
    displayedPalettes.clear();
    lastDocument  = null;
    hasMore       = true;
    _seenIds.clear();
    setState(() => isLoading = true);

    try {
      // build hue window state
      final h = HSLColor.fromColor(color).hue.round();
      _hueWindow  = List<double>.generate(
          31, (i) => ((h - 15 + i + 360) % 360).toDouble());
      _hueOffset   = 0;
      _chunkCursor = null;

      displayedPalettes = await _nextHuePage();
      hasMore = displayedPalettes.length == _pageSize;
    } catch (e) {
      debugPrint('Filter error ➜ $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ─────────────────────────────  helper utils & UI helpers (unchanged)
  String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ─────────────────────────────────────────────────────────  UI helpers
  void _showColorFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a Filter Color',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: essentialColors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, idx) {
                final color = essentialColors[idx];
                return GestureDetector(
                  onTap: () {
                    _applyFilter(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title:  const Text('Clear Sort / Filter'),
              onTap: () {
                _applyFilter(null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title:  const Text('Sort by Newest'),
              onTap:  () { Navigator.pop(context); _applySort('createdAt'); },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title:  const Text('Sort by Most Liked'),
              onTap:  () { Navigator.pop(context); _applySort('likes'); },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title:  const Text('Clear Sort / Filter'),
              onTap:  () {
                Navigator.pop(context);
                _filterColor = null;
                _applySort('createdAt');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────  BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPalettes,
          edgeOffset: -300, // keeps indicator off-screen
          color: mainColor,
          child: Column(
            children: [
              // Header or loading
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Image.asset('assets/images/logo.png', height: 40),
                  ),
                ),
              const SizedBox(height: 20),
              // Sort & Filter row
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _showSortSheet,
                      child: Row(
                        children: [
                          const Icon(Icons.import_export_outlined,
                              size: 28, color: Colors.black54),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Sort',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xff414141))),
                              Text('Sorted by',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xff4B5563))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _showColorFilterSheet,
                      child: Row(
                        children: [
                          const Icon(Icons.color_lens_outlined,
                              size: 28, color: Colors.black54),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Filters',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xff414141))),
                              Text('Custom',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xff4B5563))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Grid of palettes
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(29),
                        topRight: Radius.circular(29),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              controller: _scrollController,
                              itemCount: displayedPalettes.length,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              itemBuilder: (context, idx) {
                                final p = displayedPalettes[idx];
                                return PaletteCard(
                                  palette: p,
                                  timeAgoText: timeAgo(p.createdAt),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

