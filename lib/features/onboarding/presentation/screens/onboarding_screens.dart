// lib/features/onboarding/presentation/screens/onboarding_screens.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/services/permissions.dart';
import '../../../../core/services/prefs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/dialogs.dart';

// ── ONBOARDING CONTENT ──────────────────────────────────────
class OnboardingPageData {
  const OnboardingPageData({
    required this.illustration,
    required this.title,
    required this.description,
    this.backgroundColor = AppColors.surface,
  });

  final String illustration;
  final String title;
  final String description;
  final Color backgroundColor;
}

const _onboardingPages = [
  OnboardingPageData(
    illustration: 'assets/illustrations/enjoy_music.svg',
    title: 'Enjoy your music',
    description:
        'High-quality audio playback with a beautiful, intuitive interface.',
    backgroundColor: Color(0xFFFFB347),
  ),
  OnboardingPageData(
    illustration: 'assets/illustrations/no_ads.svg',
    title: 'No advertisements',
    description: 'Pure music experience without interruptions or distractions.',
     backgroundColor: Color(0xFF4ECDC4),
   
  ),
  OnboardingPageData(
    illustration: 'assets/illustrations/share_playlist.svg',
    title: 'Share your playlist',
    description: 'Create and share your favorite playlists with friends.',
    backgroundColor: Color(0xFFFF6B6B),
  ),
];

// ── SPLASH SCREEN ──────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        context.go(Prefs.onboarded ? '/home' : '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ REPLACED: Music note icon with app logo
                Container(
                  width: isSmallScreen ? 100 : 140,
                  height: isSmallScreen ? 100 : 140,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 60 / 255),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      'assets/icon/sonora_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                Text(
                  'Sonora',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: isSmallScreen ? 32 : 42,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Your music, beautifully',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 13 : 15,
                  ),
                ),
                if (!isSmallScreen) ...[
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── ONBOARDING SCREEN ──────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final hasPermission = await PermissionsService.ensureAudioPermission();
      if (hasPermission || !mounted) {
        Prefs.onboarded = true;
        if (mounted) {
          context.go('/home');
        }
      } else if (mounted) {
        final openSettings = await showConfirm(
          context,
          'Music access needed',
          'Sonora needs permission to access your music library. '
              'Allow it in Settings to continue.',
          yes: 'Open Settings',
        );
        if (openSettings && mounted) {
          await PermissionsService.openSettings();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: AppTheme.dur(300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isSmallScreen = screenSize.height < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _onboardingPages.length,
              itemBuilder: (context, index) {
                return _OnboardingPage(
                  data: _onboardingPages[index],
                  isLastPage: index == _onboardingPages.length - 1,
                );
              },
            ),

            if (_currentPage < _onboardingPages.length - 1)
              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: _isLoading ? null : _completeOnboarding,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: AppSpacing.screenH,
                  right: AppSpacing.screenH,
                  bottom: bottomPadding > 0 ? bottomPadding : AppSpacing.lg,
                  top: AppSpacing.lg,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x0017171E),
                      Color(0xE617171E),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _onboardingPages.length,
                      effect: WormEffect(
                        dotHeight: isSmallScreen ? 8 : 10,
                        dotWidth: isSmallScreen ? 8 : 10,
                        spacing: 12,
                        activeDotColor: AppColors.primary,
                        dotColor: AppColors.divider,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 32),

                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 52 : 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.textPrimary,
                                  ),
                                ),
                              )
                            else ...[
                              Text(
                                _currentPage == _onboardingPages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: AppTextStyles.button.copyWith(
                                  fontSize: isSmallScreen ? 15 : 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _onboardingPages.length - 1
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ONBOARDING PAGE WIDGET ─────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.isLastPage,
  });

  final OnboardingPageData data;
  final bool isLastPage;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    final illustrationSize = isSmallScreen 
        ? screenSize.width * 0.85
        : screenSize.width * 0.75;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            flex: isSmallScreen ? 2 : 3,
            child: Center(
              child: Container(
                width: illustrationSize,
                height: illustrationSize,
                decoration: BoxDecoration(
                  color: data.backgroundColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.3,
                        child: CustomPaint(
                          painter: _MusicNotePattern(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SvgPicture.asset(
                        data.illustration,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ FIXED: Increased bottom padding to 160 to prevent overlap with dots
          Expanded(
            flex: isSmallScreen ? 3 : 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.screenH,
                right: AppSpacing.screenH,
                top: isSmallScreen ? 24 : 4,
                bottom: 200, // ✅ INCREASED from 120 to 160
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.h1.copyWith(
                      fontSize: isSmallScreen ? 26 : 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    data.description,
                    style: AppTextStyles.body.copyWith(
                      fontSize: isSmallScreen ? 14 : 15,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── DECORATIVE MUSIC NOTE PATTERN ──────────────────────────
class _MusicNotePattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final positions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.6),
    ];

    for (final pos in positions) {
      _drawMusicNote(canvas, pos, paint);
    }
  }

  void _drawMusicNote(Canvas canvas, Offset offset, Paint paint) {
    final path = Path();
    path.moveTo(offset.dx, offset.dy);
    path.lineTo(offset.dx + 15, offset.dy);
    path.lineTo(offset.dx + 15, offset.dy - 25);
    path.lineTo(offset.dx + 25, offset.dy - 30);
    path.lineTo(offset.dx + 25, offset.dy - 5);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}