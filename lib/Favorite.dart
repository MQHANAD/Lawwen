import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swe463project/services/firestore_service.dart';

import '../models/palette_model.dart';
import '../widgets/palette_card.dart';
import 'main.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<FavoritePage> {

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
  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (hasMore && isLoading)
              Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: mainColor),
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