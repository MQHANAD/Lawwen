import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the app.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lawwen',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}

/// OnboardingScreen displays multiple pages that the user can swipe through.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Example onboarding data: image asset + title + subtitle + image height.
  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/logoGif.gif',
      'title': 'Unleash Your Creativity',
      'subtitle': 'Explore handpicked color palettes and create your own masterpiece.',
      'height': "400",
    },
    {
      'image': 'assets/images/CUi.png',
      'title': 'Personalize Your Experience',
      'subtitle': 'Create Your Own Color Palettes.',
      'height': "400",
    },
    {
      'image': 'assets/images/UI.png',
      'title': 'Get Started',
      'subtitle': 'Join Us In Lawwen And Let Your Creativity Flow!',
      'height': "400",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigates to the next page or finishes onboarding.
  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Navigate to your main/home screen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onboarding finished!')),
      );
    }
  }

  /// Builds an animated image widget that scales based on the page scroll.
  Widget _buildAnimatedImage(String imageUrl, double height, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double scale = 1.0;
        if (_pageController.position.haveDimensions) {
          // Calculate the difference between current page and this page index.
          scale = _pageController.page! - index;
          // Reduce scale by 20% per page difference.
          scale = (1 - (scale.abs() * 0.2)).clamp(0.8, 1.0);
        }
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Image.asset(
        imageUrl,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removing the AppBar to eliminate skip/next buttons (except "Get Started").
      body: Stack(
        children: [
          // PageView for onboarding pages.
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(
                imageUrl: _onboardingData[index]['image']!,
                title: _onboardingData[index]['title']!,
                subtitle: _onboardingData[index]['subtitle']!,
                height: double.parse(_onboardingData[index]['height']!),
                index: index,
              );
            },
          ),

          // "Get Started" button is only visible on the final page.
          if (_currentPage == _onboardingData.length - 1)
            Positioned(
              bottom: 150,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFFB1B2FF),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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

  /// Builds a single onboarding page with an animated image, title, and subtitle.
  Widget _buildOnboardingPage({
    required String imageUrl,
    required String title,
    required String subtitle,
    required double height,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Transform.translate(
        offset: const Offset(0, -50), // Move content upward.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated image from assets.
            _buildAnimatedImage(imageUrl, height, index),
            const SizedBox(height: 20),
            // Title.
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle.
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the indicator dot for each page.
  Widget _buildIndicator(int index) {
    bool isActive = (index == _currentPage);
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
