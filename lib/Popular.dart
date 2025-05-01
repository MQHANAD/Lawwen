import 'package:flutter/material.dart';
import 'package:swe463project/services/firestore_service.dart';

import '../models/palette_model.dart';
import '../widgets/palette_card.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({super.key});

  @override
  State<PopularPage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<PopularPage> {
  // Full list of palettes

  List<PaletteModel> displayedPalettes = [];
  List<PaletteModel> _allPalettes = [];
  @override
  void initState() {
    super.initState();
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

  void showCustomizableFilterSheet() {
    int minLikes = 0;
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minimum Likes Input Field
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Likes',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setSheetState(() {
                        minLikes = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Date Picker Button
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().subtract(const Duration(days: 7)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      setSheetState(() {
                        selectedDate = picked;
                      });
                    },
                    child: Text(selectedDate == null
                        ? 'Pick Created After Date'
                        : 'Picked: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  const SizedBox(height: 20),
                  // Apply Filters Button
                  ElevatedButton(
                    onPressed: () {
                      applyCustomFilters(minLikes, selectedDate);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void applyCustomFilters(int minLikes, DateTime? createdAfter) {
    setState(() {
      displayedPalettes = _allPalettes.where((p) {
        bool likesOk = p.likes >= minLikes;
        bool dateOk = createdAfter == null || p.createdAt.isAfter(createdAfter);
        return likesOk && dateOk;
      }).toList();
    });
  }

  void resetFilters() {
    setState(() {
      displayedPalettes = List.from(_allPalettes);
    });
  }

  // Helper to display "x time ago"
  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void showSortOptions() {
    showModalBottomSheet(
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
        child: StreamBuilder<List<PaletteModel>>(
            stream: streamAllPalettes(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('⚠️ ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              _allPalettes = snapshot.data!;
              if (displayedPalettes.isEmpty) {
                displayedPalettes = List.from(_allPalettes);
              }
              return Column(
                children: [
                  // Top Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Image.asset('assets/images/logo.png', height: 40),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Sort and Filter Options

                  // Palettes Grid View
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(29),
                              topRight: Radius.circular(29)),
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
                              Expanded(
                                child: GridView.builder(
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
                                      palette: displayedPalettes[index],
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
              );
            }),
      ),
    );
  }
}
