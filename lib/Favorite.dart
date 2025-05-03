// lib/screens/favorite_page.dart
import 'package:flutter/material.dart';
import 'package:swe463project/services/firestore_service.dart';
import '../models/palette_model.dart';
import '../widgets/palette_card.dart';
import 'main.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<PaletteModel> favorites = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  Future<void> _refreshFavorites() async {
    if (isLoading || !mounted) return;
    setState(() => isLoading = true);
    try {
      favorites = await fetchFavoritePalettes();
    } catch (e, s) {
      debugPrint('Favorite fetch error ➜ $e\n$s');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: mainColor,
          onRefresh: _refreshFavorites,
          child: Column(
            children: [
              // Header / spinner
              if (isLoading && favorites.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.asset('assets/images/logo.png', height: 40),
                ),
              const SizedBox(height: 20),

              // Main card container
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Scrollable area (works even if empty)
                          Expanded(
                            child: favorites.isEmpty && !isLoading
                            // Empty-state list that can always scroll
                                ? ListView(
                              physics:
                              const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Text('No favorites yet'),
                                  ),
                                ),
                              ],
                            )
                            // Grid of favourite palettes
                                : GridView.builder(
                              physics:
                              const AlwaysScrollableScrollPhysics(),
                              itemCount: favorites.length,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              itemBuilder: (context, i) {
                                final p = favorites[i];
                                return PaletteCard(
                                  palette: p,
                                  timeAgoText: _timeAgo(p.createdAt),
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