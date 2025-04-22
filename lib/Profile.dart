import 'package:flutter/material.dart';
import 'models/palette_model.dart';
import 'widgets/palette_card.dart';
import 'services/auth_service.dart';

/// Displays a user profile with a list of "My Colors" palettes and a bottom navigation bar.
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfilePage> {
  // Example data for "My Colors" (your personal palettes)
  final List<PaletteModel> myPalettes = [
    PaletteModel(
      id: "1",
      colorHexCodes: ["a1c5ff", "b8d0ff", "d2dfff", "e9f2ff"],
      likes: 32618,
      // 7 years ago is ~ 2555 days, for demonstration
      createdAt: DateTime.now().subtract(const Duration(days: 2555)),
    ),
    PaletteModel(
      id: "2",
      colorHexCodes: ["2b2d42", "8d99ae", "edf2f4", "ef233c"],
      likes: 892,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    PaletteModel(
      id: "3",
      colorHexCodes: ["f72585", "7209b7", "3a0ca3", "4361ee"],
      likes: 22312,
      createdAt: DateTime.now().subtract(const Duration(days: 1000)),
    ),
    // Add more palettes if needed
  ];
  // Helper method to convert creation date to "x years", "x days" etc.
  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
      // approximate in years
      final years = (diff.inDays / 365).floor();
      return '${years}y ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We can set an AppBar OR a custom Row for the top:
      body: SafeArea(
        child: Column(
          children: [
            // -- Top Bar with Avatar, brand, hamburger menu
        Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left placeholder: same width as IconButton (typically around 48 pixels).
            const SizedBox(width: 48),

            // Center: Avatar (and optional branding)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Image.asset('assets/images/logo.png', height: 40),
                  ),
                ),
                const SizedBox(width: 10),
                // Add other branding widgets here if needed.
              ],
            ),

            // Right: Hamburger menu icon
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // TODO: Open drawer or menu
              },
            ),
          ],
        ),
      ),


        // -- User Info: Name, Email, Username
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children:  [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '100 x 100',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Muhannad Alduraywish',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Muhanad@example.com',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'ExampleUsername',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),





            // -- Palettes Grid
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
                        // Title inside the container
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'My Colors',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Grid view that fills the remaining space
                        Expanded(
                          child: GridView.builder(
                            itemCount: myPalettes.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              return PaletteCard(
                                palette: myPalettes[index],
                                timeAgoText: timeAgo(myPalettes[index].createdAt),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )



          ],
        ),
      ),
    );
  }
}
