import 'package:flutter/material.dart';
import '../main.dart';
import 'Home.dart'; // for mainCo
import 'Favorite.dart';
import 'Popular.dart';
import 'PaletteCreation.dart';
import 'Profile.dart'; // lor

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    PopularPage(),
    HomeScreen(),
    FavoritePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    // We disable changing the selected tab when tapping index 2 (Add button)
    if (index == 2) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: mainColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          elevation: 10,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Home'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.whatshot_outlined), label: 'Popular'),
            BottomNavigationBarItem(
              // Custom styling for the "Add" button.
              icon: Container(
                width: 79,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xffAAC4FF),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: Offset(0, 4))
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor:
                      Colors.transparent, // Let custom container show its round corners
                      builder: (BuildContext context) {
                        return DraggableScrollableSheet(
                          initialChildSize: 0.86,
                          minChildSize: 0.5,
                          maxChildSize: 1.0,
                          builder:
                              (BuildContext context, ScrollController scrollController) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: CreatePaletteModal(),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Colors.black),
                      Text(
                        'Add',
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline), label: 'Favorite'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late List<FocusNode> focusNodes;
  List<TextEditingController> controllers =
  List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void verifyCode() async {
    String code = controllers.map((c) => c.text).join();

    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit code')),
      );
      return;
    }

    // Show loading spinner
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // TODO: Replace this with real backend API call
      await Future.delayed(
          const Duration(seconds: 2)); // simulate network delay

      Navigator.pop(context); // Remove loading spinner

      // Simulate success
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      Navigator.pop(context); // Remove loading spinner
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification failed. Please try again.')),
      );
    }
  }

  Widget buildCodeBox(int index) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainColor.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainColor, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 140),
            Image.asset('assets/images/logo.png', height: 160),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => buildCodeBox(index)),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Colors.grey.withOpacity(0.5),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
