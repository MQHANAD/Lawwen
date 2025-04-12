import 'package:flutter/material.dart';
import '../main.dart'; // to use mainColor

// Step 1: Create a PaletteModel
class PaletteModel {
  final String id;
  final List<String> colorHexCodes;
  final int likes;
  final String createdAt; // You can parse it to DateTime later if needed

  PaletteModel({
    required this.id,
    required this.colorHexCodes,
    required this.likes,
    required this.createdAt,
  });
}

// Step 2: HomeScreen
class HomeScreen extends StatelessWidget {
  // Example palettes (later you fetch from database)
  final List<PaletteModel> palettes = [
    PaletteModel(
      id: "1",
      colorHexCodes: ["c5c9ff", "d2d7ff", "e0e4ff"],
      likes: 2,
      createdAt: "2 hours",
    ),
    PaletteModel(
      id: "2",
      colorHexCodes: ["212529", "495057", "0dcaf0"],
      likes: 1,
      createdAt: "3 hours",
    ),
    PaletteModel(
      id: "3",
      colorHexCodes: ["f8c8dc", "fdfd96", "9bf6ff"],
      likes: 5,
      createdAt: "5 hours",
    ),
    PaletteModel(
      id: "4",
      colorHexCodes: ["c92a2a", "fa5252", "ffd6a5"],
      likes: 15,
      createdAt: "10 hours",
    ),
    PaletteModel(
      id: "5",
      colorHexCodes: ["f9ca24", "40739e", "273c75"],
      likes: 8,
      createdAt: "12 hours",
    ),
    PaletteModel(
      id: "6",
      colorHexCodes: ["00cec9", "2d3436", "ff7675"],
      likes: 7,
      createdAt: "1 day",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Centered Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Image.asset('assets/images/otherLogo.png', height: 40),
              ),
            ),
            // Sort and Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: const [
                      Icon(Icons.sort, size: 28),
                      SizedBox(height: 4),
                      Text('Sort', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Sorted by most recent', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(Icons.filter_alt, size: 28),
                      SizedBox(height: 4),
                      Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('1 filter applied', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            // Palettes Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: palettes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    return PaletteCard(palette: palettes[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
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
          // Handle navigation here
        },
      ),
    );
  }
}

// Step 3: PaletteCard updated
class PaletteCard extends StatelessWidget {
  final PaletteModel palette;

  const PaletteCard({Key? key, required this.palette}) : super(key: key);

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
                  Text(palette.createdAt),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
