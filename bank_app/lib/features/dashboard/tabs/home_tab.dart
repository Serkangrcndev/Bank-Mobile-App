import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/localization/language_manager.dart';
import '../../notifications/notifications_screen.dart';
import '../../cards/card_details_screen.dart';
import '../../transfers/transfer_screen.dart';
import '../../search/global_search_screen.dart';
import '../spending_insights_screen.dart';
import '../../lending/lending_dashboard_screen.dart';
import '../../transfers/qr_scanner_screen.dart';
import '../../settings/settings_screen.dart';
import '../../locator/locator_screen.dart';
import '../../insurance/insurance_screen.dart';
import '../../exchange/exchange_screen.dart';
import '../../loans/loan_application_screen.dart';

class HomeTab extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;
  const HomeTab({super.key, this.onTabChanged});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 4;

  // ── Pulse animation (balance chip) ────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── Press states ──────────────────────────────────────────────────────────
  int _pressedAction = -1;
  int _pressedTx = -1;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 0, end: 1).animate(_pulseCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int i, Widget child) => FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── TopAppBar
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          toolbarHeight: 64,
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.outlineVariant,
            ),
          ),
          title: Text(
            'Fintech',
            style: AppTextStyles.headlineLgMobile().copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => _AppBarIconButton(
              icon: Icons.menu_rounded,
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            const _SearchButton(),
            _NotificationButton(),
            const SizedBox(width: 8),
          ],
        ),

        // ── Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Total Balance
              _staggered(0, _buildBalanceSection()),
              const SizedBox(height: 32),

              // Cards
              _staggered(1, _buildCardsSection()),
              const SizedBox(height: 32),

              // Quick Actions
              _staggered(2, _buildQuickActions()),
              const SizedBox(height: 32),

              // Recent Activity
              _staggered(3, _buildRecentActivity()),

              // Spacing at the bottom so it clears floating nav
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      children: [
        Text(
          LanguageManager.translate('TOTAL BALANCE', 'TOPLAM BAKİYE'),
          style: AppTextStyles.labelMd(
            color: AppColors.onSurfaceVariant,
          ).copyWith(letterSpacing: 2.0),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$',
              style: AppTextStyles.headlineLgMobile(
                  color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 4),
            Text.rich(
              TextSpan(
                text: '124,592',
                style: AppTextStyles.headlineXl().copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
                children: [
                  TextSpan(
                    text: '.00',
                    style: AppTextStyles.headlineXl(
                      color: AppColors.onSurfaceVariant,
                    ).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Pulse chip
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            final glow = (_pulseAnim.value < 0.7
                    ? _pulseAnim.value / 0.7
                    : (1 - _pulseAnim.value) / 0.3)
                .clamp(0.0, 1.0);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryFixed.withAlpha((51 * glow).toInt()),
                    blurRadius: 10 * glow,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primaryFixed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    LanguageManager.translate('+2.4% Today', 'Bugün +%2.4'),
                    style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _BankCard(
            type: LanguageManager.translate('Debit', 'Banka Kartı'),
            last4: '4092',
            balanceLabel: LanguageManager.translate('Available Balance', 'Kullanılabilir Bakiye'),
            balance: r'$45,200.50',
            icon: Icons.contactless_rounded,
            isPrimary: true,
          ),
          const SizedBox(width: 16),
          _BankCard(
            type: LanguageManager.translate('Credit', 'Kredi Kartı'),
            last4: '8821',
            balanceLabel: LanguageManager.translate('Current Balance', 'Güncel Bakiye'),
            balance: r'$3,400.00',
            icon: Icons.credit_card_rounded,
            isPrimary: false,
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {},
            child: const _AddCardButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (Icons.send_rounded, LanguageManager.translate('Send', 'Gönder')),
      (Icons.arrow_downward_rounded, LanguageManager.translate('Receive', 'Al')),
      (Icons.swap_horiz_rounded, LanguageManager.translate('Swap', 'Takas')),
      (Icons.more_horiz_rounded, LanguageManager.translate('More', 'Daha Fazla')),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(actions.length, (i) {
          final (icon, label) = actions[i];
          final pressed = _pressedAction == i;
          return GestureDetector(
            onTapDown: (_) => setState(() => _pressedAction = i),
            onTapUp: (_) {
              setState(() => _pressedAction = -1);
              HapticFeedback.lightImpact();
              if (i == 0) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const TransferScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              } else if (i == 1) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const QrScannerScreen(initialTab: 1),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              } else if (i == 2) {
                widget.onTabChanged?.call(1); // Switch to SwapTab (Index 1)
              } else if (i == 3) {
                _showMoreServicesBottomSheet(context);
              }
            },
            onTapCancel: () => setState(() => _pressedAction = -1),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pressed
                        ? AppColors.primaryFixed
                        : AppColors.surfaceContainerLow,
                    border: Border.all(
                      color: pressed
                          ? AppColors.primaryFixed
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: pressed
                        ? AppColors.background
                        : AppColors.primaryFixed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTextStyles.labelSm(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final transactions = [
      _TxData(
        icon: Icons.storefront_outlined,
        name: 'Apple Store',
        date: LanguageManager.translate('Today, 2:45 PM', 'Bugün, 14:45'),
        amount: r'- $999.00',
        amountColor: AppColors.primary,
        iconColor: AppColors.onSurface,
        hasBorder: true,
      ),
      _TxData(
        icon: Icons.south_west_rounded,
        name: 'Salary Deposit',
        date: LanguageManager.translate('Yesterday', 'Dün'),
        amount: r'+ $4,250.00',
        amountColor: AppColors.primaryFixed,
        iconColor: AppColors.primaryFixed,
        hasBorder: true,
      ),
      _TxData(
        icon: Icons.coffee_outlined,
        name: 'Starbucks',
        date: 'Oct 12',
        amount: r'- $6.50',
        amountColor: AppColors.primary,
        iconColor: AppColors.onSurface,
        hasBorder: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                LanguageManager.translate('Recent Activity', 'Son İşlemler'),
                style: AppTextStyles.headlineMd(),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const GlobalSearchScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: Text(
                  LanguageManager.translate('See All', 'Tümünü Gör'),
                  style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: List.generate(transactions.length, (i) {
                final tx = transactions[i];
                final pressed = _pressedTx == i;
                return GestureDetector(
                  onTapDown: (_) => setState(() => _pressedTx = i),
                  onTapUp: (_) {
                    setState(() => _pressedTx = -1);
                    HapticFeedback.selectionClick();
                  },
                  onTapCancel: () => setState(() => _pressedTx = -1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: pressed
                          ? AppColors.surfaceContainerLow
                          : Colors.transparent,
                      border: tx.hasBorder
                          ? const Border(
                              bottom: BorderSide(
                                color: AppColors.surfaceContainer,
                              ),
                            )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceContainerHighest,
                              border: Border.all(
                                color: pressed
                                    ? AppColors.primaryFixed
                                    : AppColors.outlineVariant,
                              ),
                            ),
                            child: Icon(tx.icon,
                                size: 18, color: tx.iconColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.name,
                                  style: AppTextStyles.bodyMd().copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  tx.date,
                                  style: AppTextStyles.labelSm(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            tx.amount,
                            style: AppTextStyles.labelMd(
                              color: tx.amountColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreServicesBottomSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF131313).withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    LanguageManager.translate('More Services', 'Daha Fazla Hizmet'),
                    style: AppTextStyles.headlineMd(color: Colors.white).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LanguageManager.translate(
                      'Access elite features and lending facilities.',
                      'Seçkin özelliklere ve kredi imkanlarına erişin.'
                    ),
                    style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)),
                  ),
                  const SizedBox(height: 24),
                  _buildBottomSheetItem(
                    context,
                    icon: Icons.real_estate_agent_outlined,
                    title: LanguageManager.translate('Loans & Lending', 'Krediler ve Borç Verme'),
                    description: LanguageManager.translate(
                      'Principal up to 250K USDT • Instant Approval',
                      '250 Bin USDT\'ye kadar anapara • Anında Onay'
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const LendingDashboardScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBottomSheetItem(
                    context,
                    icon: Icons.insights_rounded,
                    title: LanguageManager.translate('Spending Insights', 'Harcama Analizleri'),
                    description: LanguageManager.translate(
                      'Analyze expenses, limits, and transactions',
                      'Giderleri, limitleri ve işlemleri analiz edin'
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const SpendingInsightsScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBottomSheetItem(
                    context,
                    icon: Icons.qr_code_scanner_rounded,
                    title: LanguageManager.translate('QR Scan & Pay', 'QR Tarat ve Öde'),
                    description: LanguageManager.translate(
                      'Scan merchant QR codes to settle transactions',
                      'Ödeme yapmak için üye işyeri QR kodlarını tarayın'
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const QrScannerScreen(initialTab: 0),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBottomSheetItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: LanguageManager.translate('App Settings', 'Uygulama Ayarları'),
                    description: LanguageManager.translate(
                      'Configure notifications, API keys, and theme',
                      'Bildirimleri, API anahtarlarını ve temayı yapılandırın'
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBottomSheetItem(
                    context,
                    icon: Icons.map_rounded,
                    title: LanguageManager.translate('ATM & Branch Locator', 'ATM ve Şube Bulucu'),
                    description: LanguageManager.translate(
                      'Find nearest branches and ATMs on the map',
                      'Haritada en yakın şubeleri ve ATM\'leri bulun'
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const LocatorScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBottomSheetItem(
                    context,
                    icon: Icons.health_and_safety_outlined,
                    title: LanguageManager.translate('Insurance Portfolio', 'Sigorta Portföyü'),
                    description: LanguageManager.translate(
                      'Manage policies, coverage, and premium payments',
                      'Poliçeleri, kapsamları ve prim ödemelerini yönetin'
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const InsuranceScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBottomSheetItem(
                    context,
                    icon: Icons.currency_exchange_rounded,
                    title: LanguageManager.translate('Exchange & Rates', 'Döviz ve Kurlar'),
                    description: LanguageManager.translate(
                      'Convert currencies and view live market rates',
                      'Para birimlerini dönüştürün ve canlı piyasa kurlarını görüntüleyin'
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const ExchangeScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildBottomSheetItem(
                    context,
                    icon: Icons.account_balance_outlined,
                    title: LanguageManager.translate('Loan Application', 'Kredi Başvurusu'),
                    description: LanguageManager.translate(
                      'Apply for personal, mortgage, or auto loans',
                      'Bireysel, konut veya taşıt kredilerine başvurun'
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const LoanApplicationScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2A2A),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: const Color(0xFFCCFF00), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFA1A1A1), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Supporting Home Widgets ─────────────────────────────────────────────────

class _TxData {
  final IconData icon;
  final String name;
  final String date;
  final String amount;
  final Color amountColor;
  final Color iconColor;
  final bool hasBorder;
  const _TxData({
    required this.icon,
    required this.name,
    required this.date,
    required this.amount,
    required this.amountColor,
    required this.iconColor,
    required this.hasBorder,
  });
}

class _AppBarIconButton extends StatefulWidget {
  const _AppBarIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_AppBarIconButton> createState() => _AppBarIconButtonState();
}

class _AppBarIconButtonState extends State<_AppBarIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.surfaceContainerHighest
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon,
              color: AppColors.onSurfaceVariant, size: 24),
        ),
      ),
    );
  }
}

class _SearchButton extends StatefulWidget {
  const _SearchButton();

  @override
  State<_SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<_SearchButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const GlobalSearchScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.surfaceContainerHighest
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.search_rounded,
              color: AppColors.onSurfaceVariant, size: 24),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatefulWidget {
  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _pressed
                    ? AppColors.surfaceContainerHighest
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.onSurfaceVariant, size: 24),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankCard extends StatefulWidget {
  const _BankCard({
    required this.type,
    required this.last4,
    required this.balanceLabel,
    required this.balance,
    required this.icon,
    required this.isPrimary,
  });

  final String type;
  final String last4;
  final String balanceLabel;
  final String balance;
  final IconData icon;
  final bool isPrimary;

  @override
  State<_BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<_BankCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CardDetailsScreen(
              cardType: widget.type,
              last4: widget.last4,
              balance: widget.balance,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedOpacity(
        opacity: widget.isPrimary ? 1.0 : (_hovered ? 1.0 : 0.70),
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 288,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered || widget.isPrimary
                  ? AppColors.primaryFixed.withAlpha(150)
                  : AppColors.outlineVariant,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.isPrimary)
                Positioned(
                  top: -24,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primaryFixed,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              if (widget.isPrimary)
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryFixed.withAlpha(13),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.isPrimary
                            ? AppColors.primaryFixed
                            : AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                      Text(
                        widget.type.toUpperCase(),
                        style: AppTextStyles.labelSm(
                          color: AppColors.onSurfaceVariant,
                        ).copyWith(letterSpacing: 2.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '**** ${widget.last4}',
                    style: AppTextStyles.labelMd().copyWith(
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.balanceLabel,
                    style: AppTextStyles.labelSm(
                        color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.balance,
                    style: AppTextStyles.headlineMd(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCardButton extends StatefulWidget {
  const _AddCardButton();

  @override
  State<_AddCardButton> createState() => _AddCardButtonState();
}

class _AddCardButtonState extends State<_AddCardButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 96,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? AppColors.primaryFixed : AppColors.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: _hovered ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              LanguageManager.translate('Add', 'Ekle'),
              style: AppTextStyles.labelSm(
                color: _hovered ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
