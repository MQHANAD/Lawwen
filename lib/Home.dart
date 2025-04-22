// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/palette_model.dart';
import '../widgets/palette_card.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Full list of palettes
  final List<PaletteModel> allPalettes = [
    PaletteModel(
      id: "1",
      colorHexCodes: ["c5c9ff", "d2d7ff", "e0e4ff", "EEF1FF"],
      likes: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PaletteModel(
      id: "2",
      colorHexCodes: ["212529", "495057", "0dcaf0", "EEEEEE"],
      likes: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PaletteModel(
      id: "3",
      colorHexCodes: ["f8c8dc", "fdfd96", "9bf6ff", "73C7C7"],
      likes: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    PaletteModel(
      id: "4",
      colorHexCodes: ["c92a2a", "fa5252", "ffd6a5", "F6DED8"],
      likes: 15000,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    PaletteModel(
      id: "5",
      colorHexCodes: ["f9ca24", "40739e", "273c75", "00cec9"],
      likes: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PaletteModel(
      id: "6",
      colorHexCodes: ["00cec9", "2d3436", "ff7675", "00cec9"],
      likes: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  List<PaletteModel> displayedPalettes = [];

  @override
  void initState() {
    super.initState();
    displayedPalettes = List.from(allPalettes);
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
      displayedPalettes = allPalettes.where((p) {
        bool likesOk = p.likes >= minLikes;
        bool dateOk = createdAfter == null || p.createdAt.isAfter(createdAfter);
        return likesOk && dateOk;
      }).toList();
    });
  }

  void resetFilters() {
    setState(() {
      displayedPalettes = List.from(allPalettes);
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
        child: Column(
          children: [
            // Top Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Image.asset('assets/images/logo.png', height: 40),
              ),
            ),
            // Temporary Sign Out Button for Testing
            ElevatedButton(
              onPressed: () => AuthService().signout(context: context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: const Color(0xFFB1B2FF),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 20),
            // Sort and Filter Options
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => showSortOptions(),
                    child: Row(
                      children: [
                        const Icon(Icons.import_export_outlined, size: 28, color: Colors.black54),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Sort',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xff414141)),
                            ),
                            Text(
                              'Sorted by',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff4B5563)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showCustomizableFilterSheet(),
                    child: Row(
                      children: [
                        const Icon(Icons.color_lens_outlined, size: 28, color: Colors.black54),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Filters',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xff414141)),
                            ),
                            Text(
                              'Custom',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff4B5563)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
        ),
      ),
    );
  }
}

