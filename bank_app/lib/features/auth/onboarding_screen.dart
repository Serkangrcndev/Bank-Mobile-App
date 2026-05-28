import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';
import 'login_screen.dart';

/// Onboarding Screen — "Fintech Elite | Onboarding"
/// Shown once on first-run between the SplashScreen and LoginScreen.
/// 3 slides: Elite Wealth / Steel-Clad Security / Global Access
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // ── Page state ─────────────────────────────────────────────────────────────
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  // ── Page enter animation ───────────────────────────────────────────────────
  late final AnimationController _slideCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Ambient glow pulse ─────────────────────────────────────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Exit animation (body fade-out on navigate) ─────────────────────────────
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitAnim;

  // ── Onboarding data ────────────────────────────────────────────────────────
  static final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDKDg8vq-WFUPfU7ZD7My-rMQdhSHQBMwoClZxhMT4ZmSUHNAK0f3wIlOVVlE2dqgHD_fjdFBwX-Ii19VwoxEDehm87uQZDYQ31lIUosCp8ocXWL4Z6ZhYLGiyNodC9Vxj5336YXjS-pP4k2JPPF8-WNIhoOlUUqZcEKV2Gc-0ZYC4Fjm3AseTEtKC14F9uaQJQYDbMSW-y6P27y34ZARzGPXA0r42KRvVAjM04iA-Iptv7i3xfGsbZ2_jo0Zy8TmuojxpStqNgR2K4',
      title: 'Elite Wealth',
      description:
          'Institutional-grade investment tools designed for the modern high-net-worth individual.',
    ),
    _OnboardingPage(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDpef6tAA2u-XPxbQoCwHWKZh7vxsegARc3Z39kMWuHi_yWfdOyLMFZFrquBMi8iRKSMDGsrZpf4_QoqJKQQFoqz96zbNU9UmXZfgCRyYCcZtuSs19UxWo1TQG4NoVdfX9TYTT5OKLEMougdHrhsMqizgl9G76zeBqhWZ9y8NCASzXkPC1pWjIJVE3AnaELE1XNeFJlkg2wDjhv-g9A4L-0CdXkRIJCofQRtKFbw2iDVvUpWricV8k_PDlaiiPMJ2J5_zgxMqG56fkJ',
      title: 'Steel-Clad Security',
      description:
          'Multi-sig biometric authentication and military-grade encryption for your peace of mind.',
    ),
    _OnboardingPage(
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBpDzPU161e_HvWSS7vlUhBj_A_abSmdC6FIL8F8phXLsF6QuUz37218o4JsuYnJZJinoM_q4eZFjH4uyPgRx8MpCy5dTCSBiJjHia8t2akdCcv-_Lq23kkky9UZIN4eG0suvHAzdjltVEYN0P6cGgrdM4Mn0IukuCJy-SN7Fdo9L4pDJVi8vg44qpbcYTr2Ym_rEkegL12P2kB8V0ZOUCNRB05EY_ZbMHAotvYk58qeBQi70a-TQ13T4yumagA__jKCv-dHNVtHe9x',
      title: 'Global Access',
      description:
          'Transact seamlessly across borders with instant settlement and zero-fee FX conversions.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Slide/fade for page content entrance
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic),
    );

    // Ambient glow pulse
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.05, end: 0.15).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // Exit fade-out controller
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _slideCtrl.dispose();
    _glowCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _enterTheApp() async {
    HapticFeedback.mediumImpact();
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    // Re-trigger entrance animation on each page change
    _slideCtrl.reset();
    _slideCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _totalPages - 1;

    return AnimatedBuilder(
      animation: _exitAnim,
      builder: (context, child) => Opacity(
        opacity: _exitAnim.value,
        child: child,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Ambient background glows ─────────────────────────────────
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, _) {
                return Stack(
                  children: [
                    // Top-left lime glow
                    Positioned(
                      top: -100,
                      left: -150,
                      width: 600,
                      height: 600,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryFixed
                                  .withValues(alpha: _glowAnim.value * 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom-right lime glow (brighter)
                    Positioned(
                      bottom: -100,
                      right: -150,
                      width: 600,
                      height: 600,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryFixed
                                  .withValues(alpha: _glowAnim.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // ── Header: Brand + Skip ─────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 0),
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fintech Elite',
                        style: AppTextStyles.headlineMd().copyWith(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: _enterTheApp,
                        child: Text(
                          LanguageManager.translate('SKIP', 'GEÇ'),
                          style: AppTextStyles.labelMd(
                                  color: AppColors.onSurfaceVariant)
                              .copyWith(letterSpacing: 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Page View ────────────────────────────────────────────────
            Positioned.fill(
              top: 64,
              bottom: 160,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: _onPageChanged,
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return _buildPage(index);
                },
              ),
            ),

            // ── Footer: dots + CTA buttons ───────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pagination dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_totalPages, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryFixed
                                  : AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // CTA button
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 390),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: isLastPage
                              ? _buildCtaButton(
                                  key: const ValueKey('enter'),
                                  label: LanguageManager.translate('ENTER THE ELITE', 'SEÇKİNLERE KATIL'),
                                  onTap: _enterTheApp,
                                )
                              : _buildCtaButton(
                                  key: const ValueKey('continue'),
                                  label: LanguageManager.translate('CONTINUE', 'DEVAM ET'),
                                  onTap: _nextPage,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Individual onboarding page ─────────────────────────────────────────────
  Widget _buildPage(int index) {
    final page = _pages[index];
    final String title = index == 0 
        ? LanguageManager.translate('Elite Wealth', 'Elit Servet')
        : index == 1
            ? LanguageManager.translate('Steel-Clad Security', 'Çelik Zırhlı Güvenlik')
            : LanguageManager.translate('Global Access', 'Küresel Erişim');
    final String description = index == 0
        ? LanguageManager.translate('Institutional-grade investment tools designed for the modern high-net-worth individual.', 'Modern yüksek net değerli bireyler için tasarlanmış kurumsal düzeyde yatırım araçları.')
        : index == 1
            ? LanguageManager.translate('Multi-sig biometric authentication and military-grade encryption for your peace of mind.', 'İçinizin rahat etmesi için çoklu imzalı biyometrik kimlik doğrulama ve askeri düzeyde şifreleme.')
            : LanguageManager.translate('Transact seamlessly across borders with instant settlement and zero-fee FX conversions.', 'Anında takas ve sıfır ücretli döviz çevrimi ile sınırlar ötesinde sorunsuz işlem yapın.');

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Illustration ─────────────────────────────────────────
              SizedBox(
                width: 256,
                height: 256,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing glow behind image
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (_, _) => Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryFixed
                                  .withValues(alpha: _glowAnim.value * 1.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        page.imageUrl,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.currency_exchange_rounded,
                            size: 64,
                            color: AppColors.primaryFixed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // ── Title ─────────────────────────────────────────────────
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 40,
                  height: 1.2,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ── Description ───────────────────────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  description,
                  style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CTA button ─────────────────────────────────────────────────────────────
  Widget _buildCtaButton({
    required Key key,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryFixed.withValues(alpha: 0.20),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMd(
              color: const Color(0xFF161E00),
            ).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _OnboardingPage {
  const _OnboardingPage({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
  final String imageUrl;
  final String title;
  final String description;
}
