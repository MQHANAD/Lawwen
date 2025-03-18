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

  // Example onboarding data: image URL + title + subtitle
  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'https://via.placeholder.com/300x200.png?text=Welcome+1',
      'title': 'Welcome to Lawwen',
      'subtitle': 'Swipe to discover more.'
    },
    {
      'image': 'https://via.placeholder.com/300x200.png?text=Welcome+2',
      'title': 'Personalize Your Experience',
      'subtitle': 'Choose your style and colors.'
    },
    {
      'image': 'https://via.placeholder.com/300x200.png?text=Welcome+3',
      'title': 'Get Started',
      'subtitle': 'Click below to begin using Lawwen.'
    },
  ];

  /// Builds the little dots at the bottom to indicate the current page.
  Widget _buildIndicator(int index) {
    bool isActive = (index == _currentPage);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Navigates to the next page or finishes onboarding.
  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Navigate to your main/home screen
      // For now, just print a message or pop
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onboarding finished!')),
      );
    }
  }

  /// Skips all onboarding pages and finishes immediately.
  void _skipOnboarding() {
    // TODO: Navigate to your main/home screen
    // For now, just print a message or pop
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onboarding skipped!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional skip button on the top-right corner
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text('Skip', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Expanded(
            // PageView to swipe through onboarding pages
            child: PageView.builder(
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
                );
              },
            ),
          ),
          // Indicator dots

          const SizedBox(height: 26),
          // Next / Get Started button
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _currentPage == _onboardingData.length - 1
                  ? ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Get Started'),
                    )
                  : Text(""),
            ),
          ),
          Positioned(
            bottom: 200,
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds a single onboarding page with an image, title, and subtitle.
  Widget _buildOnboardingPage({
    required String imageUrl,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Image.network(
            imageUrl,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
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
    );
  }
}
