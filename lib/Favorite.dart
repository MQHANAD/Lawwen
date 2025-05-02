import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swe463project/services/firestore_service.dart';

import '../models/palette_model.dart';
import '../widgets/palette_card.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<FavoritePage> {
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

  List<PaletteModel> displayedPalettes = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;
  List<PaletteModel> _allPalettes = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialPalettes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMorePalettes();
      }
    });
  }

  Future<void> _loadInitialPalettes() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final newPalettes = await fetchPalettes();

    _allPalettes = newPalettes;
    displayedPalettes = List.from(_allPalettes);
    hasMore = newPalettes.length == 6;

    if (newPalettes.isNotEmpty) {
      lastDocument = await FirebaseFirestore.instance
          .collection('palettes')
          .doc(newPalettes.last.id)
          .get();
    }else {
      hasMore = false;
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadMorePalettes() async {
    if (!hasMore || isLoading) return;
    setState(() => isLoading = true);

    final snapshots = await fetchPalettes(startAfterDoc: lastDocument);

    if (snapshots.isNotEmpty) {
      final lastDoc = await FirebaseFirestore.instance
          .collection('palettes')
          .doc(snapshots.last.id)
          .get();

      setState(() {
        displayedPalettes.addAll(snapshots);
        lastDocument = lastDoc;
        hasMore = snapshots.length == 6;
      });
    }else {
      hasMore = false;
    }
    setState(() => isLoading = false);
  }

  void sortByNewest() {
    setState(() {
      displayedPalettes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  void sortByLikes() {
    setState(() {
      displayedPalettes.sort((a, b) => b.likes.compareTo(a.likes));
    });
  }

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
              const Text(
                'Select a Filter Color',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
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
                itemBuilder: (context, index) {
                  final color = essentialColors[index];
                  return GestureDetector(
                    onTap: () {
                      applyEssentialColorFilter(color);
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
                  resetFilters();
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

  void applyEssentialColorFilter(Color? filterColor) {
    setState(() {
      if (filterColor == null) {
        displayedPalettes = List.from(_allPalettes);
      } else {
        displayedPalettes = _allPalettes.where((palette) {
          for (final hex in palette.colorHexCodes) {
            final paletteColor = _hexToColor(hex);
            if (isColorClose(paletteColor, filterColor)) return true;
          }
          return false;
        }).toList();
      }
    });
  }

  bool isColorClose(Color c1, Color c2, {
    double hueThreshold = 20,
    double saturationThreshold = 0.2,
    double lightnessThreshold = 0.2,
  }) {
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

  Color _hexToColor(String hex) {
    final sanitized = hex.replaceAll('#', '').trim();
    return Color(int.parse('FF$sanitized', radix: 16));
  }

  void resetFilters() {
    setState(() {
      displayedPalettes = List.from(_allPalettes);
    });
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

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
              title: const Text('Sort by Newest'),
              onTap: () {
                sortByNewest();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Sort by Most Liked'),
              onTap: () {
                sortByLikes();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Sort / Filter'),
              onTap: () {
                resetFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                        const Icon(Icons.import_export_outlined, size: 28, color: Colors.black54),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Sort', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xff414141))),
                            Text('Sorted by', style: TextStyle(fontSize: 12, color: Color(0xff4B5563))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: showEssentialColorFilterSheet,
                    child: Row(
                      children: [
                        const Icon(Icons.color_lens_outlined, size: 28, color: Colors.black54),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xff414141))),
                            Text('Custom', style: TextStyle(fontSize: 12, color: Color(0xff4B5563))),
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Favorite",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (displayedPalettes.isEmpty && isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    controller: _scrollController,
                                    itemCount: displayedPalettes.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.7,
                                    ),
                                    itemBuilder: (context, index) {
                                      return PaletteCard(
                                        palette: displayedPalettes[index],
                                        timeAgoText: timeAgo(displayedPalettes[index].createdAt),
                                      );
                                    },
                                  ),
                                ),
                                if (hasMore && isLoading)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                          )

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}