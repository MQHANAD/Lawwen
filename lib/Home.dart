import 'package:flutter/material.dart';
import '../main.dart'; // for mainColor

// Palette Model
class PaletteModel {
  final String id;
  final List<String> colorHexCodes;
  final int likes;
  final DateTime createdAt; // using DateTime!

  PaletteModel({
    required this.id,
    required this.colorHexCodes,
    required this.likes,
    required this.createdAt,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Full list of palettes
  final List<PaletteModel> allPalettes = [
    PaletteModel(
      id: "1",
      colorHexCodes: ["c5c9ff", "d2d7ff", "e0e4ff"],
      likes: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PaletteModel(
      id: "2",
      colorHexCodes: ["212529", "495057", "0dcaf0"],
      likes: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PaletteModel(
      id: "3",
      colorHexCodes: ["f8c8dc", "fdfd96", "9bf6ff"],
      likes: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    PaletteModel(
      id: "4",
      colorHexCodes: ["c92a2a", "fa5252", "ffd6a5"],
      likes: 15,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    PaletteModel(
      id: "5",
      colorHexCodes: ["f9ca24", "40739e", "273c75"],
      likes: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PaletteModel(
      id: "6",
      colorHexCodes: ["00cec9", "2d3436", "ff7675"],
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

  // Sort functions
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

  // Customizable filter logic
  void showCustomizableFilterSheet() {
    int minLikes = 0;
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
                  // Likes Input
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
                  // Date Picker
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 7)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setSheetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Text(selectedDate == null
                        ? 'Pick Created After Date'
                        : 'Picked: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  const SizedBox(height: 20),
                  // Apply Button
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

  // Helper to format "x hours ago"
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Image.asset('assets/images/logo.png', height: 40),
              ),
            ),
            // Sort and Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => showSortOptions(),
                    child: Column(
                      children: const [
                        Icon(Icons.sort, size: 28),
                        SizedBox(height: 4),
                        Text('Sort', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Sorted by', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showCustomizableFilterSheet(),
                    child: Column(
                      children: const [
                        Icon(Icons.filter_alt, size: 28),
                        SizedBox(height: 4),
                        Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Custom', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Palette Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      timeAgoText: timeAgo(displayedPalettes[index].createdAt),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Popular'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  void showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
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
            title: const Text('Clear Sort/Filter'),
            onTap: () {
              resetFilters();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// PaletteCard
class PaletteCard extends StatelessWidget {
  final PaletteModel palette;
  final String timeAgoText;

  const PaletteCard({Key? key, required this.palette, required this.timeAgoText}) : super(key: key);

  Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: palette.colorHexCodes.map((hexCode) {
                  return Expanded(
                    child: Container(color: hexToColor(hexCode)),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.favorite_border, size: 20),
                  Text('${palette.likes}'),
                  Text(timeAgoText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
