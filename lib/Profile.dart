import 'package:flutter/material.dart';
import 'models/palette_model.dart';
import 'widgets/palette_card.dart';
import 'services/auth_service.dart';

/// Displays a user profile with a list of "My Colors" palettes and a right-side slide-out drawer.
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Example data for "My Colors"
  final List<PaletteModel> myPalettes = [
    PaletteModel(
      id: "1",
      colorHexCodes: ["a1c5ff", "b8d0ff", "d2dfff", "e9f2ff"],
      likes: 32618,
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
  ];

  late final AnimationController _drawerAnimationController;
  late final Animation<Offset> _drawerSlide;

  @override
  void initState() {
    super.initState();
    _drawerAnimationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _drawerSlide = Tween<Offset>(
      begin: const Offset(1, 0),  // slide in from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
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

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
    _drawerAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: true,
      endDrawer: SlideTransition(
        position: _drawerSlide,
        child: Drawer(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white.withOpacity(0.95),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DrawerHeader(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Muhannad Alduraywish',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      Text(
                        'ExampleUsername',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  onTap: () {},
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red, backgroundColor: Colors.grey.withOpacity(0.15),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      AuthService().signout(context: context);
                      // Navigate to login or landing page
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: _openEndDrawer,  // open right-side drawer
                  ),
                ],
              ),
            ),

            // User Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
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
                  const SizedBox(height: 18),
                  const Text(
                    'Muhannad Alduraywish',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Muhanad@example.com',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'ExampleUsername',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Palettes Grid
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
                            'My Colors',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: GridView.builder(
                            itemCount: myPalettes.length,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              return PaletteCard(
                                palette: myPalettes[index],
                                timeAgoText:
                                timeAgo(myPalettes[index].createdAt),
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