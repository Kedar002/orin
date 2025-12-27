import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../auth/login_screen.dart';

/// Onboarding screens (max 3)
/// Focus on value, not features
/// Large typography, minimal design
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Stay informed,\nnot overwhelmed',
      subtitle:
          'See what matters. Your spaces, monitored with intelligence.',
      imagePath: 'assets/images/onboarding_1.jpeg',
      alignment: Alignment.bottomCenter,
      textAlign: TextAlign.left,
      titleColor: Colors.black,
      subtitleColor: Colors.black,
      showShadow: false,
      padding: EdgeInsets.only(left: 24, right: 70, bottom: 50),
    ),
    OnboardingPage(
      title: 'Your virtual\nGuards watch',
      subtitle: 'AI-powered agents notify you of important moments only.',
      imagePath: 'assets/images/onboarding_2.jpeg',
      alignment: Alignment.bottomLeft,
      textAlign: TextAlign.left,
      titleColor: Colors.white,
      subtitleColor: Colors.white,
      showShadow: true,
      padding: EdgeInsets.only(left: 32, right: 80, top: 40, bottom: 40),
    ),
    OnboardingPage(
      title: 'Complete peace\nof mind',
      subtitle: 'Everything you need to feel in control, nothing you don\'t.',
      imagePath: 'assets/images/onboarding_3.jpeg',
      alignment: Alignment.centerRight,
      textAlign: TextAlign.right,
      titleColor: Colors.white,
      subtitleColor: Colors.white,
      showShadow: true,
      padding: EdgeInsets.only(left: 80, right: 15, top: 40, bottom: 250),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen PageView with images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(context, _pages[index], index);
            },
          ),

          // UI overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Skip button - top left
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: _navigateToLogin,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: _pages[_currentPage].titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Round continue button - bottom right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _pages[_currentPage].buttonColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _navigateToLogin();
                          }
                        },
                        icon: Icon(
                          Icons.arrow_forward,
                          color: _pages[_currentPage].buttonIconColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPage page, int index) {
    final theme = Theme.of(context);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image - full screen
          Image.asset(
            page.imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Content overlay
          SafeArea(
            child: Align(
              alignment: page.alignment,
              child: Padding(
                padding: page.padding ??
                    const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: page.textAlign == TextAlign.left
                      ? CrossAxisAlignment.start
                      : page.textAlign == TextAlign.right
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      page.title,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: page.titleColor,
                        fontWeight: FontWeight.bold,
                        shadows: page.showShadow
                            ? [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ]
                            : null,
                      ),
                      textAlign: page.textAlign,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Subtitle
                    Text(
                      page.subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: page.subtitleColor,
                        shadows: page.showShadow
                            ? [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ]
                            : null,
                      ),
                      textAlign: page.textAlign,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String imagePath;
  final Alignment alignment;
  final TextAlign textAlign;
  final Color titleColor;
  final Color subtitleColor;
  final bool showShadow;
  final EdgeInsets? padding;
  final Color buttonColor;
  final Color buttonIconColor;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.alignment = Alignment.center,
    this.textAlign = TextAlign.center,
    this.titleColor = Colors.white,
    this.subtitleColor = Colors.white,
    this.showShadow = true,
    this.padding,
    this.buttonColor = Colors.black,
    this.buttonIconColor = Colors.white,
  });
}
