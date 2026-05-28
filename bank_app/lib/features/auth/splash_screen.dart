import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // ── Entrance Animation Controller ──────────────────────────────────────────
  late final AnimationController _entranceCtrl;

  // Staggered Animation parts
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _loadingBarOpacity;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Custom Bezier curve: cubic-bezier(0.16, 1, 0.3, 1)
    const customCurve = Cubic(0.16, 1.0, 0.3, 1.0);

    // Staggered intervals:
    // Logo starts at 300ms -> ends at 1300ms (0.167 to 0.722)
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.167, 0.722, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.167, 0.722, curve: customCurve),
      ),
    );

    // Title starts at 600ms -> ends at 1400ms (0.333 to 0.778)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.333, 0.778, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.333, 0.778, curve: customCurve),
      ),
    );

    // Subtitle starts at 800ms -> ends at 1600ms (0.444 to 0.889)
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.444, 0.889, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.444, 0.889, curve: customCurve),
      ),
    );

    // Loading bar fade in
    _loadingBarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.555, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start staggered entrance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceCtrl.forward();
    });

    // Automatically navigate to OnboardingScreen after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Radial Glow Background ──────────────────────────────────────────
          const Positioned.fill(child: _GlowEffect()),

          // ── Main Content ───────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),

                  // Center Content: Logo, Title, Subtitle
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Container
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: SlideTransition(
                          position: _logoSlide,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.outlineVariant),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryFixed.withValues(alpha: 0.1),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.currency_exchange_rounded,
                                size: 48,
                                color: AppColors.primaryFixed,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App Title
                      FadeTransition(
                        opacity: _titleOpacity,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: Text(
                            'Fintech Elite',
                            style: AppTextStyles.headlineXl(color: AppColors.primary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // App Subtitle
                      FadeTransition(
                        opacity: _subtitleOpacity,
                        child: SlideTransition(
                          position: _subtitleSlide,
                          child: Text(
                            LanguageManager.translate('INSTITUTIONAL GRADE TRADING', 'KURUMSAL DÜZEYDE TİCARET'),
                            style: AppTextStyles.labelMd(
                              color: AppColors.onSurfaceVariant,
                            ).copyWith(
                              letterSpacing: 0.2 * 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Content: Progress loading bar and status text
                  FadeTransition(
                    opacity: _loadingBarOpacity,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Custom neon loader
                          const _LoadingBar(),
                          const SizedBox(height: 16),

                          // Status text
                          _PulseText(
                            text: LanguageManager.translate('INITIALIZING SECURE CONNECTION', 'GÜVENLİ BAĞLANTI BAŞLATILIYOR'),
                            style: AppTextStyles.labelSm(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glow Effect Widget ───────────────────────────────────────────────────────
class _GlowEffect extends StatefulWidget {
  const _GlowEffect();

  @override
  State<_GlowEffect> createState() => _GlowEffectState();
}

class _GlowEffectState extends State<_GlowEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _opacity = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0x26C3F400), // rgba(195, 244, 0, 0.15)
                    Color(0x00131313), // transparent
                  ],
                  stops: [0.0, 0.7],
                  radius: 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Indeterminate Loading Bar ───────────────────────────────────────────────
class _LoadingBar extends StatefulWidget {
  const _LoadingBar();

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LoadingBarPainter(_ctrl.value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingBarPainter extends CustomPainter {
  _LoadingBarPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryFixed
      ..style = PaintingStyle.fill;

    // Smooth moving indeterminate progress bar
    final w = size.width * 0.35;
    final x = -w + (size.width + w) * progress;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, w, size.height),
        const Radius.circular(2),
      ),
      paint,
    );

    // Subtle glow overlay
    final shadowPaint = Paint()
      ..color = AppColors.primaryFixed.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, w, size.height),
        const Radius.circular(2),
      ),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoadingBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ── Pulse Text Widget ────────────────────────────────────────────────────────
class _PulseText extends StatefulWidget {
  const _PulseText({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  State<_PulseText> createState() => _PulseTextState();
}

class _PulseTextState extends State<_PulseText> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
