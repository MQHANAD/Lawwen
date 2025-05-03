import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swe463project/main.dart';
import 'package:swe463project/services/firestore_service.dart';
import '../models/palette_model.dart';
import '../widgets/palette_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Essential colors used in the filter UI.
  final List<Color> essentialColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.brown,
    Colors.grey,
  ];

  // ───────────────────────────────────────── server-side filter + sort ★
  String? _filterHex;
  String  _sortField      = 'createdAt';
  bool    _sortDescending = true;
  // ─────────────────────────────────────────────────────────────────────

  List<PaletteModel> displayedPalettes = [];
  DocumentSnapshot?  lastDocument;
  bool   isLoading = false;
  bool   hasMore   = true;
  List<PaletteModel> _allPalettes = [];
  final ScrollController _scrollController = ScrollController();

  static const int _pageSize = 10;           // ★ one place to change

  @override
  void initState() {
    super.initState();
    _refreshPalettes();                    // ★ renamed for clarity
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


  // ────────────────────────────── first page / pull-to-refresh ★
  Future<void> _refreshPalettes() async {
    if (isLoading || !mounted ) return;
    setState(() => isLoading = true);

    final newPalettes = await fetchPalettes(
      filterHex:    _filterHex,
      sortField:    _sortField,
      descending:   _sortDescending,
      limit:        _pageSize,
    );

    _allPalettes = newPalettes;
    displayedPalettes = List.from(_allPalettes);
    hasMore = newPalettes.length == _pageSize;

    lastDocument = newPalettes.isNotEmpty
        ? await FirebaseFirestore.instance
        .collection('palettes')
        .doc(newPalettes.last.id)
        .get()
        : null;
    if (!mounted ) return;
    setState(() => isLoading = false);
  }

  // ────────────────────────────── pagination ★
  Future<void> _loadMorePalettes() async {
    if (!hasMore || isLoading || !mounted) return;
    setState(() => isLoading = true);

    final nextPage = await fetchPalettes(
      filterHex:    _filterHex,
      sortField:    _sortField,
      descending:   _sortDescending,
      startAfterDoc:lastDocument,
      limit:        _pageSize,
    );

    if (nextPage.isNotEmpty) {
      final lastDoc = await FirebaseFirestore.instance
          .collection('palettes')
          .doc(nextPage.last.id)
          .get();
      if (!mounted) return;
      setState(() {
        displayedPalettes.addAll(nextPage);
        lastDocument = lastDoc;
        hasMore = nextPage.length == _pageSize;
      });
    } else {
      hasMore = false;
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  // ────────────────────────────── local sort fallbacks (kept) ─
  void sortByNewest() => _applySort('createdAt');
  void sortByLikes()  => _applySort('likes');

  // ────────────────────────────── apply server sort ★
  void _applySort(String field) {
    _sortField      = field;
    _sortDescending = true;
    lastDocument    = null;
    hasMore         = true;
    _refreshPalettes();
  }

  // ────────────────────────────── apply filter ★
  void _applyFilter(Color? color) {
    if (color == null) {
      _filterHex = null;
    } else {

      _filterHex =
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    }
    lastDocument = null;
    hasMore      = true;
    _refreshPalettes();
  }

  // ────────────────────────────── bottom sheet for colors (unchanged UI) ─
  void showEssentialColorFilterSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
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
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final color = essentialColors[index];
                  return GestureDetector(
                    onTap: () {
                      _applyFilter(color);          // ★ server filter
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear),
                title: const Text('Clear Sort / Filter'),
                onTap: () {
                  _applyFilter(null);              // ★ reset filter + server refresh
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────── clear uses server refresh now ★
  void resetFilters() => _applyFilter(null);

  // ────────────────────────────── unchanged helper funcs (isColorClose, hex, timeAgo) –
  bool isColorClose(Color c1, Color c2,
      {double hueThreshold = 20,
        double saturationThreshold = 0.2,
        double lightnessThreshold = 0.2}) {
    final hsl1 = HSLColor.fromColor(c1);
    final hsl2 = HSLColor.fromColor(c2);
    var hueDiff = (hsl1.hue - hsl2.hue).abs();
    if (hueDiff > 180) hueDiff = 360 - hueDiff;
    final satDiff = (hsl1.saturation - hsl2.saturation).abs();
    final lightDiff = (hsl1.lightness - hsl2.lightness).abs();
    return hueDiff <= hueThreshold &&
        satDiff <= saturationThreshold &&
        lightDiff <= lightnessThreshold;
  }


  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ────────────────────────────── sort sheet pops server sort ★
  void showSortOptions() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) => Padding(
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
                _filterHex  = null;
                _applySort('createdAt');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────── UI build (unchanged except RefreshIndicator) ─
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPalettes,          // ★ pull-to-refresh
          child: Column(
            children: [
              if (hasMore && isLoading)
                Positioned(
                  child: Center(
                    child: CircularProgressIndicator(color: mainColor,),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Image.asset('assets/images/logo.png', height: 40),
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: showSortOptions,
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
                      onTap: showEssentialColorFilterSheet,
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
                      padding: const EdgeInsets.fromLTRB(16,16,16,0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Home",
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
                              itemBuilder: (context, index) {
                                return PaletteCard(
                                  palette:     displayedPalettes[index],
                                  timeAgoText: timeAgo(
                                      displayedPalettes[index].createdAt),
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
