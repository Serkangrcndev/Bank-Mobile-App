import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/notifications/app_notification.dart';
import '../notifications/notifications_screen.dart';
import '../../core/localization/language_manager.dart';

class LimitsScreen extends StatefulWidget {
  const LimitsScreen({super.key});

  @override
  State<LimitsScreen> createState() => _LimitsScreenState();
}

class _LimitsScreenState extends State<LimitsScreen> with TickerProviderStateMixin {
  // Entrance animation controllers
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _staggerCount = 4;

  // Toggle State for Daily/Monthly limits
  bool _isDailySelected = true;

  // Simulated Limit Request State
  double _requestedIncrease = 15000.0;
  bool _isSubmittingRequest = false;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(
        position: _slideAnims[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E), // surface-container-lowest
      body: Stack(
        children: [
          // ── Ambient Glow Orb
          Positioned(
            top: (size.height / 2) - 400,
            left: (size.width / 2) - 400,
            child: IgnorePointer(
              child: Container(
                width: 800,
                height: 800,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFCCFF00).withValues(alpha: 0.025),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Sticky Header (Custom AppBar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 12,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131313).withValues(alpha: 0.1),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF353535), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'LUMINA BANK',
                            style: AppTextStyles.labelMd(color: Colors.white).copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2 * 14,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim, secAnim) => const NotificationsScreen(),
                              transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Scrollable Body Content
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + 60,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Title (Stagger 0)
                      _staggered(0, _buildHeroTitle()),
                      const SizedBox(height: 32),

                      // Bento Grid: Monthly Spending Power & Security Health (Stagger 1)
                      _staggered(1, _buildBentoOverviewGrid()),
                      const SizedBox(height: 40),

                      // Daily Category Limits (Stagger 2)
                      _staggered(2, _buildCategoryLimitsSection()),
                      const SizedBox(height: 40),

                      // Recent Limit Activity (Stagger 3)
                      _staggered(3, _buildLimitActivitySection()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Title Section ─────────────────────────────────────────────────────
  Widget _buildHeroTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          LanguageManager.translate('Limits & Usage', 'Limitler ve Kullanım'),
          style: AppTextStyles.headlineLgMobile(color: Colors.white).copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LanguageManager.translate('Monitor your spending power and manage transaction thresholds across your Elite accounts.', 'Seçkin hesaplarınızdaki harcama gücünüzü takip edin ve işlem limitlerini yönetin.'),
          style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)),
        ),
      ],
    );
  }

  // ── Bento Grid: Spending Power & Security ──────────────────────────────────
  Widget _buildBentoOverviewGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 800;
        if (isTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: _buildSpendingPowerCard(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: _buildSecurityHealthCard(192.0), // match estimated card height
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSpendingPowerCard(),
              const SizedBox(height: 20),
              _buildSecurityHealthCard(180.0),
            ],
          );
        }
      },
    );
  }

  Widget _buildSpendingPowerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 550;
          final cardContent = [
            // Circular Progress Ring
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _ProgressRingPainter(
                    percentage: 0.75,
                    activeColor: const Color(0xFFCCFF00),
                    trackColor: const Color(0xFF1F1F1F),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LanguageManager.translate('USED', 'KULLANILAN'),
                          style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '75%',
                          style: AppTextStyles.headlineLg(color: Colors.white).copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!isCompact) const SizedBox(width: 32),
            if (isCompact) const SizedBox(height: 24),
            // Right Side Details
            Expanded(
              flex: isCompact ? 0 : 1,
              child: Column(
                crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanguageManager.translate('Monthly Spending Power', 'Aylık Harcama Gücü'),
                        style: AppTextStyles.headlineMd(color: Colors.white).copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: isCompact ? TextAlign.center : TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LanguageManager.translate('PREMIUM TIER ACTIVE', 'PREMIUM SEVİYE AKTİF'),
                        style: AppTextStyles.labelSm(color: const Color(0xFFCCFF00)).copyWith(
                          letterSpacing: 1.5,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E0E0E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageManager.translate('USED', 'KULLANILAN'),
                                style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 9),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$37,500.00',
                                style: AppTextStyles.labelMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E0E0E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageManager.translate('REMAINING', 'KALAN'),
                                style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 9),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$12,500.00',
                                style: AppTextStyles.labelMd(color: const Color(0xFFCCFF00)).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCFF00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _showLimitIncreaseBottomSheet,
                      child: Text(
                        LanguageManager.translate('REQUEST LIMIT INCREASE', 'LİMİT ARTIŞI TALEP ET'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];

          return isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cardContent,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: cardContent,
                );
        },
      ),
    );
  }

  Widget _buildSecurityHealthCard(double minHeight) {
    return Container(
      height: minHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBGVtiOhz8RcYJXT3EfChZgiBc3-XZswjqmEUKjGlsEUM_JU7Mz_LF3OtJn6xyBr4q5VsCP7l48RvR2YXBQ4XBA-AT9sJ2oCAczIDoYwH09LIFXD-fCE5G0BerDLuHJ9d-lPIU6qIJCTrMBNQAqZ_wOEtaiy1E1Su_GflMoM-YFIEGbgVKg2NVade4tiJhXzEcDieey1BxLF3qyieR6YUIfJ9NasVl6TE3XoizQbjTEWUR9fmCSoTOl_FChyeAYPSqqWU84Yf_sD9nN',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
              ),
            ),
            // Black gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            // Card details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Color(0xFFCCFF00), size: 36),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'ELITE',
                          style: AppTextStyles.labelSm(color: const Color(0xFFCCFF00)).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanguageManager.translate('Security Health', 'Güvenlik Durumu'),
                        style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        LanguageManager.translate('Your account limits are protected by multi-factor hardware keys.', 'Hesap limitleriniz çok faktörlü donanım anahtarları ile korunmaktadır.'),
                        style: AppTextStyles.bodyMd(color: const Color(0xFFC8C6C5)).copyWith(fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Daily Category Limits Section ──────────────────────────────────────────
  Widget _buildCategoryLimitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LanguageManager.translate('Daily Category Limits', 'Günlük Kategori Limitleri'),
              style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isDailySelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isDailySelected ? const Color(0xFFCCFF00) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        LanguageManager.translate('DAILY', 'GÜNLÜK'),
                        style: TextStyle(
                          color: _isDailySelected ? Colors.black : const Color(0xFFA1A1A1),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isDailySelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: !_isDailySelected ? const Color(0xFFCCFF00) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        LanguageManager.translate('MONTHLY', 'AYLIK'),
                        style: TextStyle(
                          color: !_isDailySelected ? Colors.black : const Color(0xFFA1A1A1),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 800;
            if (isTablet) {
              return Row(
                children: [
                  Expanded(child: _buildLimitCategoryCard(
                    category: LanguageManager.translate('TRANSFERS', 'TRANSFERLER'),
                    limit: _isDailySelected
                        ? LanguageManager.translate('\$25,000.00 Limit', '\$25.000,00 Limit')
                        : LanguageManager.translate('\$500,000.00 Limit', '\$500.000,00 Limit'),
                    used: _isDailySelected ? '\$12,400' : '\$320,000',
                    percent: _isDailySelected ? 0.496 : 0.64,
                    icon: Icons.swap_horiz_rounded,
                    footerText: _isDailySelected
                        ? LanguageManager.translate('Reset in 14h 22m', '14s 22dk içinde sıfırlanacak')
                        : LanguageManager.translate('Resets on June 1st', '1 Haziran\'da sıfırlanacak'),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLimitCategoryCard(
                    category: LanguageManager.translate('ATM CASH', 'ATM NAKİT'),
                    limit: _isDailySelected
                        ? LanguageManager.translate('\$2,500.00 Limit', '\$2.500,00 Limit')
                        : LanguageManager.translate('\$50,000.00 Limit', '\$50.000,00 Limit'),
                    used: _isDailySelected ? '\$2,100' : '\$12,000',
                    percent: _isDailySelected ? 0.84 : 0.24,
                    icon: Icons.account_balance_wallet_outlined,
                    isWarning: _isDailySelected, // Warning only in Daily ATM
                    footerText: _isDailySelected
                        ? LanguageManager.translate('Approaching limit', 'Limite yaklaşıyor')
                        : LanguageManager.translate('Healthy Status', 'Güvenli Durum'),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLimitCategoryCard(
                    category: LanguageManager.translate('CARD SPEND', 'KART HARCAMA'),
                    limit: _isDailySelected
                        ? LanguageManager.translate('\$15,000.00 Limit', '\$15.000,00 Limit')
                        : LanguageManager.translate('\$300,000.00 Limit', '\$300.000,00 Limit'),
                    used: _isDailySelected ? '\$3,200' : '\$84,000',
                    percent: _isDailySelected ? 0.213 : 0.28,
                    icon: Icons.credit_card_rounded,
                    footerText: LanguageManager.translate('Status: Healthy', 'Durum: Güvenli'),
                  )),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildLimitCategoryCard(
                    category: LanguageManager.translate('TRANSFERS', 'TRANSFERLER'),
                    limit: _isDailySelected
                        ? LanguageManager.translate('\$25,000.00 Limit', '\$25.000,00 Limit')
                        : LanguageManager.translate('\$500,000.00 Limit', '\$500.000,00 Limit'),
                    used: _isDailySelected ? '\$12,400' : '\$320,000',
                    percent: _isDailySelected ? 0.496 : 0.64,
                    icon: Icons.swap_horiz_rounded,
                    footerText: _isDailySelected
                        ? LanguageManager.translate('Reset in 14h 22m', '14s 22dk içinde sıfırlanacak')
                        : LanguageManager.translate('Resets on June 1st', '1 Haziran\'da sıfırlanacak'),
                  ),
                  const SizedBox(height: 16),
                  _buildLimitCategoryCard(
                    category: LanguageManager.translate('ATM CASH', 'ATM NAKİT'),
                    limit: _isDailySelected
                        ? LanguageManager.translate('\$2,500.00 Limit', '\$2.500,00 Limit')
                        : LanguageManager.translate('\$50,000.00 Limit', '\$50.000,00 Limit'),
                    used: _isDailySelected ? '\$2,100' : '\$12,000',
                    percent: _isDailySelected ? 0.84 : 0.24,
                    icon: Icons.account_balance_wallet_outlined,
                    isWarning: _isDailySelected,
                    footerText: _isDailySelected
                        ? LanguageManager.translate('Approaching limit', 'Limite yaklaşıyor')
                        : LanguageManager.translate('Healthy Status', 'Güvenli Durum'),
                  ),
                  const SizedBox(height: 16),
                  _buildLimitCategoryCard(
                    category: LanguageManager.translate('CARD SPEND', 'KART HARCAMA'),
                    limit: _isDailySelected
                        ? LanguageManager.translate('\$15,000.00 Limit', '\$15.000,00 Limit')
                        : LanguageManager.translate('\$300,000.00 Limit', '\$300.000,00 Limit'),
                    used: _isDailySelected ? '\$3,200' : '\$84,000',
                    percent: _isDailySelected ? 0.213 : 0.28,
                    icon: Icons.credit_card_rounded,
                    footerText: LanguageManager.translate('Status: Healthy', 'Durum: Güvenli'),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildLimitCategoryCard({
    required String category,
    required String limit,
    required String used,
    required double percent,
    required IconData icon,
    required String footerText,
    bool isWarning = false,
  }) {
    final displayPercent = (percent * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: const Color(0xFFCCFF00), size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    category,
                    style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    limit,
                    style: AppTextStyles.labelMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${LanguageManager.translate('Used', 'Kullanılan')}: $used',
                style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)),
              ),
              Text(
                '$displayPercent%',
                style: AppTextStyles.labelSm(
                  color: isWarning ? AppColors.error : const Color(0xFFCCFF00),
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  color: isWarning ? AppColors.error : const Color(0xFFCCFF00),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: (isWarning ? AppColors.error : const Color(0xFFCCFF00)).withValues(alpha: 0.25),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isWarning)
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14),
                const SizedBox(width: 6),
                Text(
                  footerText,
                  style: AppTextStyles.labelSm(color: AppColors.error).copyWith(fontSize: 11),
                ),
              ],
            )
          else
            Text(
              footerText,
              style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  // ── Recent Limit Activity Table/List ───────────────────────────────────────
  Widget _buildLimitActivitySection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LanguageManager.translate('Limit History & Activity', 'Limit Geçmişi ve Hareketleri'),
                  style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18),
                ),
                GestureDetector(
                  onTap: () => HapticFeedback.selectionClick(),
                  child: const Icon(Icons.tune_rounded, color: Color(0xFFA1A1A1), size: 20),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF222222), height: 1),

          // Items list
          _buildActivityItem(
            title: LanguageManager.translate('Monthly Limit Increased', 'Aylık Limit Artırıldı'),
            subtitle: LanguageManager.translate('Oct 12, 2023 • Auto-approved', '12 Eki 2023 • Otomatik Onaylandı'),
            value: '+\$10,000.00',
            valueSubtitle: LanguageManager.translate('New: \$50k', 'Yeni: \$50k'),
            icon: Icons.trending_up_rounded,
            isGreenValue: true,
          ),
          const Divider(color: Color(0xFF151515), height: 1),
          _buildActivityItem(
            title: LanguageManager.translate('ATM Limit Alert', 'ATM Limit Uyarısı'),
            subtitle: LanguageManager.translate('Today, 10:45 AM', 'Bugün, 10:45'),
            value: LanguageManager.translate('84% Used', '%84 Kullanıldı'),
            icon: Icons.notifications_active_outlined,
            tag: LanguageManager.translate('HIGH', 'YÜKSEK'),
          ),
          const Divider(color: Color(0xFF151515), height: 1),
          _buildActivityItem(
            title: LanguageManager.translate('Temporary Travel Limit', 'Geçici Seyahat Limiti'),
            subtitle: LanguageManager.translate('Expires in 3 days', '3 gün içinde sona eriyor'),
            value: LanguageManager.translate('Active', 'Aktif'),
            valueSubtitle: LanguageManager.translate('Tokyo, JP', 'Tokyo, Japonya'),
            icon: Icons.lock_open_rounded,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String value,
    String? valueSubtitle,
    required IconData icon,
    bool isGreenValue = false,
    String? tag,
  }) {
    return InkWell(
      onTap: () => HapticFeedback.lightImpact(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF1B1B1B),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: isGreenValue ? const Color(0xFFCCFF00) : Colors.white, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodyMd(
                    color: isGreenValue ? const Color(0xFFCCFF00) : Colors.white,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (valueSubtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    valueSubtitle,
                    style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 11),
                  ),
                ],
                if (tag != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.errorContainer.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.labelSm(color: AppColors.error).copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Show Limit Increase request Bottom Sheet ──────────────────────────────
  void _showLimitIncreaseBottomSheet() {
    HapticFeedback.heavyImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131313).withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2A2A2A),
                            ),
                            child: const Icon(Icons.tune_rounded, color: Color(0xFFCCFF00), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            LanguageManager.translate('Request Limit Increase', 'Limit Artışı Talep Et'),
                            style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LanguageManager.translate(
                          'Requesting an increase to your monthly spending power. Auto-approval runs for requests up to \$100k.',
                          'Aylık harcama gücünüz için artış talebi. \$100k\'a kadar olan talepler için otomatik onay çalışır.',
                        ),
                        style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 28),

                      // Requested Amount Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LanguageManager.translate('Requested Limit:', 'Talep Edilen Limit:'),
                            style: AppTextStyles.bodyLg(color: Colors.white),
                          ),
                          Text(
                            '\$${_requestedIncrease.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: AppTextStyles.headlineMd(color: const Color(0xFFCCFF00)).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Slider
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          activeTrackColor: const Color(0xFFCCFF00),
                          inactiveTrackColor: const Color(0xFF333333),
                          thumbColor: const Color(0xFFCCFF00),
                          overlayColor: const Color(0xFFCCFF00).withValues(alpha: 0.12),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: _requestedIncrease,
                          min: 15000.0,
                          max: 150000.0,
                          divisions: 27,
                          onChanged: (val) {
                            setSheetState(() {
                              _requestedIncrease = val;
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LanguageManager.translate('\$15K min', 'En az \$15K'), style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 10)),
                          Text(LanguageManager.translate('\$150K max', 'En çok \$150K'), style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Apply button
                      _isSubmittingRequest
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
                              ),
                            )
                          : SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCCFF00),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  setSheetState(() {
                                    _isSubmittingRequest = true;
                                  });

                                  final overlay = Overlay.of(context, rootOverlay: true);
                                  final navigator = Navigator.of(context);

                                  // Show pending immediately (sync — before any await)
                                  AppNotification.pending(
                                    context,
                                    title: LanguageManager.translate('Reviewing Request', 'Talep İnceleniyor'),
                                    message: LanguageManager.translate('Running auto-approval check...', 'Otomatik onay kontrolü yapılıyor...'),
                                    duration: const Duration(seconds: 3),
                                  );

                                  // Simulate API Approval
                                  Future.delayed(const Duration(milliseconds: 1500), () {
                                    if (!mounted) return;
                                    navigator.pop(); // Close bottom sheet
                                    setState(() {
                                      _isSubmittingRequest = false;
                                    });
                                    HapticFeedback.heavyImpact();

                                    // Directly use captured overlay — no BuildContext post-async
                                    AppNotification.showOnOverlay(
                                      overlay,
                                      type: AppNotificationType.success,
                                      title: LanguageManager.translate('Limit Increase Approved', 'Limit Artışı Onaylandı'),
                                      message: LanguageManager.translate(
                                        'Monthly spending power set to \$${_requestedIncrease.toStringAsFixed(0)}.',
                                        'Aylık harcama gücü \$${_requestedIncrease.toStringAsFixed(0)} olarak ayarlandı.',
                                      ),
                                      duration: const Duration(seconds: 5),
                                    );
                                  });
                                },
                                child: Text(
                                  LanguageManager.translate('SUBMIT REQUEST', 'TALEBİ GÖNDER'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Custom painter for radial progress ring ──────────────────────────────────
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.percentage,
    required this.activeColor,
    required this.trackColor,
  });

  final double percentage;
  final Color activeColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw active progress arc
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Sweep angle is 360 degrees * percentage. Start angle is -90 degrees (top center).
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * percentage, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
