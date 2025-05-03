import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:swe463project/Login.dart';

import 'Favorite.dart';
import 'Home.dart';
import 'PaletteCreation.dart';
import 'Popular.dart';
import 'Profile.dart';
import 'firebase_config.dart';

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

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;
  void _onItemTapped(int index) {
    if (!_isLoggedIn && index == 4) {
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
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: LoginPage(),
              );
            },
          );
        },
      );
      return;
    }
    // We disable changing the selected tab when tapping index 2 (Add button)
    else if (index == 2) return;
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
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: ClipRect(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: mainColor,
                unselectedItemColor: Colors.grey,
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.normal),
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
                          if (_isLoggedIn) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors
                                  .transparent, // Let custom container show its round corners
                              builder: (BuildContext context) {
                                return DraggableScrollableSheet(
                                  initialChildSize: 0.86,
                                  minChildSize: 0.5,
                                  maxChildSize: 1.0,
                                  builder: (BuildContext context,
                                      ScrollController scrollController) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      child: CreatePaletteModal(),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors
                                  .transparent, // Let custom container show its round corners
                              builder: (BuildContext context) {
                                return DraggableScrollableSheet(
                                  initialChildSize: 0.86,
                                  minChildSize: 0.5,
                                  maxChildSize: 1.0,
                                  builder: (BuildContext context,
                                      ScrollController scrollController) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      child: LoginPage(),
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, color: Colors.black),
                            // Text(
                            //   'Add',
                            //   style: TextStyle(color: Colors.black, fontSize: 10),
                            // ),
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
          ),
        ),
      ),
    );
  }
}

const Color mainColor = Color(0xFFB1B2FF);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Initialize Firebase conditionally based on platform
  if (Firebase.apps.isEmpty) {
    if (kIsWeb || Platform.isIOS) {
      await Firebase.initializeApp(
        options: getFirebaseOptions(),
      );
    } else {
      await Firebase.initializeApp(
        name: 'lawwenApp',
        options: getFirebaseOptions(),
      );
    }
  }
  runApp(const MyApp());
}

/// Root widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Global background
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return const MainScreen(); //  User is logged in
          } else {
            return const OnboardingScreen(); //  User is NOT logged in
          }
        },
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/logoGif.gif',
      'title': 'Unleash Your Creativity',
      'subtitle':
          'Explore handpicked color palettes and create your own masterpiece.',
      'height': "400",
      'bottom': "310",
    },
    {
      'image': 'assets/images/CUi.png',
      'title': 'Personalize Your Experience',
      'subtitle': 'Create Your Own Color Palettes.\n',
      'height': "700",
      'bottom': "160",
    },
    {
      'image': 'assets/images/UI.png',
      'title': 'Get Started',
      'subtitle': 'Join Us In Lawwen And Let Your Creativity Flow!\n',
      'height': "700",
      'bottom': "160",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  Widget _buildAnimatedImage(String imageUrl, double height, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double scale = 1.0;
        if (_pageController.position.haveDimensions) {
          scale = _pageController.page! - index;
          scale = (1 - (scale.abs() * 0.2)).clamp(0.8, 1.0);
        }
        return Transform.scale(scale: scale, child: child);
      },
      child: Image.asset(imageUrl, height: height, fit: BoxFit.contain),
    );
  }

  Widget _buildOnboardingPage({
    required String imageUrl,
    required double height,
    required int index,
    required double bottom,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        return Stack(
          children: [
            Positioned(
              bottom: bottom,
              left: 10,
              right: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildAnimatedImage(imageUrl, height, index),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.4,
              child: Opacity(
                opacity: 0.97,
                child: Container(
                  decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _buildOnboardingPage(
                imageUrl: _onboardingData[index]['image']!,
                height: double.parse(_onboardingData[index]['height']!),
                index: index,
                bottom: double.parse(_onboardingData[index]['bottom']!),
              );
            },
          ),
          Positioned(
            bottom: 200,
            left: 24,
            right: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey<int>(_currentPage),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _onboardingData[_currentPage]['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _onboardingData[_currentPage]['subtitle']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          // "Get Started" button on the final page.
          if (_currentPage == _onboardingData.length - 1)
            Positioned(
              bottom: 120,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: const Color(0xFFB1B2FF),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Get Started'),
              ),
            ),
          // Indicator dots.
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => _buildIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indicator dot widget.
  Widget _buildIndicator(int index) {
    final bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFB1B2FF) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
