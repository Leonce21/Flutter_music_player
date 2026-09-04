import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/permissions.dart';
import '../../../../core/services/prefs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/mume_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    _spin.repeat();
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) context.go(Prefs.onboarded ? '/home' : '/onboarding');
    });
  }

  @override
  void dispose() { _spin.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Column(children: [
          const Spacer(flex: 4),
          const MumeLogo(size: 44),
          const Spacer(flex: 3),
          RotationTransition(turns: _spin,
              child: CustomPaint(size: const Size(34, 34),
                  painter: _DotSpinner())),
          const Spacer(flex: 2),
        ])),
      );
}

class _DotSpinner extends CustomPainter {
  @override
  void paint(Canvas c, Size size) {
    const n = 8;
    for (var i = 0; i < n; i++) {
      final a = (i / n) * 2 * math.pi;
      final r = size.width / 2 - 3;
      final p = Offset(size.width / 2 + r * math.cos(a),
          size.height / 2 + r * math.sin(a));
      c.drawCircle(p, 2.6, Paint()
        ..color = AppColors.primary.withValues(alpha: 0.25 + 0.75 * (i / n)));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

const _pages = [
  'User friendly mp3 music player for your device',
  'We provide a better audio experience than others',
  'Listen to the best audio & music with Mume now!',
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  final _ctl = PageController();
  int _page = 0;
  bool _busy = false;
  bool _awaitingSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctl.dispose();
    super.dispose();
  }

  /// When the user comes back from the system settings screen,
  /// re-check the permission and continue automatically.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSettings) {
      _awaitingSettings = false;
      _finish();
    }
  }

    Future<void> _finish() async {
    if (_busy) return;
    _busy = true;
    try {
      if (await PermissionsService.ensureAudioPermission()) {
        // Notification permission removed — no permission_handler dependency.
        // If you need Android 13+ notification permission later, add the
        // `app_settings` plugin and guide the user to system settings.
        Prefs.onboarded = true;
        if (mounted) context.go('/home');
        return;
      }

      // Denied or permanently denied (no system dialog will appear).
      _awaitingSettings = true;
      if (!mounted) return;
      final open = await showConfirm(
        context,
        'Music access needed',
        'Mume can\'t see your library without the "Music and audio" '
            'permission. Allow it in App info → Permissions, and we\'ll '
            'continue automatically when you come back.',
        yes: 'Open Settings',
      );
      if (open) {
        await PermissionsService.openSettings();
      } else {
        _awaitingSettings = false;
      }
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _ctl,
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          for (var i = 0; i < _pages.length; i++)
            _Page(
              headline: _pages[i],
              index: i,
              cta: i == _pages.length - 1 ? 'Get Started' : 'Next',
              onTap: () => i == _pages.length - 1
                  ? _finish()
                  : _ctl.nextPage(duration: AppTheme.dur(280),
                      curve: Curves.easeOutCubic),
            ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.headline, required this.index,
      required this.cta, required this.onTap});
  final String headline;
  final int index;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Expanded(flex: 3, child: _Art()),
      Expanded(
        flex: 2,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
          child: Column(children: [
            Text(headline, textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.lg),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < 3; i++) ...[
                AnimatedContainer(
                  duration: AppTheme.dur(200), curve: Curves.easeOutCubic,
                  width: i == index ? 16 : 5, height: 5,
                  decoration: BoxDecoration(
                    color: i == index
                        ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ]),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onTap,
              child: Container(
                width: double.infinity, height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: [BoxShadow(color: AppColors.primaryAlpha(90),
                      blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Center(
                    child: Text(cta, style: AppTextStyles.button)),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

/// Licensed-safe abstract stand-in for the stock photo: orange disc,
/// scattered dots, white note glyph.
class _Art extends StatelessWidget {
  const _Art();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (c, s) {
      return Stack(alignment: Alignment.center, children: [
        for (final d in const [
          [0.12, 0.18, 26.0], [0.82, 0.12, 14.0], [0.9, 0.4, 20.0],
          [0.08, 0.62, 12.0], [0.7, 0.75, 10.0], [0.3, 0.08, 10.0],
        ])
          Positioned(left: d[0] * s.maxWidth, top: d[1] * s.maxHeight,
              child: Container(width: d[2], height: d[2],
                  decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle))),
        Container(width: s.maxWidth * 0.62, height: s.maxWidth * 0.62,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: Icon(AppIcons.musicNote, size: s.maxWidth * 0.28,
                color: AppColors.textPrimary)),
      ]);
    });
  }
}