import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import 'tabs/home_tab.dart';
import 'tabs/swap_tab.dart';
import 'tabs/assets_tab.dart';
import 'tabs/profile_tab.dart';
import '../settings/settings_screen.dart';
import 'spending_insights_screen.dart';
import '../lending/lending_dashboard_screen.dart';
import '../support/support_screen.dart';
import '../limits/limits_screen.dart';
import '../locator/locator_screen.dart';
import '../kyc/kyc_verification_screen.dart';
import '../insurance/insurance_screen.dart';
import '../exchange/exchange_screen.dart';
import '../loans/loan_application_screen.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';

/// Dashboard Shell Container.
///
/// Manages the active page tab state and holds the persistent
/// floating blurred Bottom Navigation Bar.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;

  // ── Entrance animation for Bottom Nav ──────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.48, 0.90, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.48, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _buildActivePage() {
    switch (_navIndex) {
      case 0:
        return HomeTab(
          onTabChanged: (index) {
            setState(() => _navIndex = index);
          },
        );
      case 1:
        return const SwapTab();
      case 2:
        return const AssetsTab();
      case 3:
        return const ProfileTab();
      default:
        return HomeTab(
          onTabChanged: (index) {
            setState(() => _navIndex = index);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: AppColors.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Color(0xFF333333), width: 1),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drawer Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF333333)),
                            ),
                            child: const Icon(
                              Icons.currency_exchange_rounded,
                              size: 16,
                              color: AppColors.primaryFixed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'FINTECH ELITE',
                            style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // User profile snapshot
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF333333)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAjfg2sC30yWHJQL4PQVPqtdHnCL8sasuBTxJL4KturJOj4uYNnbyRlKujh87jJJTP4cra-5XcR9Ef5KHUbdLzVDN840b3WsMyzThWje6Nn8H7JFQ6lRLxEloyPircUOfXQTWnHS9WnDnqRRTBGVl5cwLNK_zLRLJ5dC_Wwnr671pxKwQIVu8CsXAROy86U7_sLpgOQ_bNPl0qojILbvTt5zGwEwppXLl5YIyx040wqjXrExbiHIxQotAHb-x-xAI2PHQfTIdj8QS-h',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.surfaceContainerHigh,
                                  child: const Icon(Icons.person, size: 24, color: AppColors.secondary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alex Mercer',
                                  style: AppTextStyles.bodyMd(color: AppColors.primary)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'a.mercer@fintech-elite.io',
                                  style: AppTextStyles.labelSm(color: AppColors.secondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFF1A1A1A)),

                // Drawer items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      _DrawerItem(
                        icon: Icons.home_rounded,
                        title: LanguageManager.translate('Home', 'Ana Sayfa'),
                        selected: _navIndex == 0,
                        onTap: () {
                          setState(() => _navIndex = 0);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.swap_vert_rounded,
                        title: LanguageManager.translate('Trade & Swap', 'Alım-Satım ve Takas'),
                        selected: _navIndex == 1,
                        onTap: () {
                          setState(() => _navIndex = 1);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: LanguageManager.translate('Wealth & Assets', 'Varlıklar ve Portföy'),
                        selected: _navIndex == 2,
                        onTap: () {
                          setState(() => _navIndex = 2);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.tune_rounded,
                        title: LanguageManager.translate('Limits & Usage', 'Limitler ve Kullanım'),
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // Close drawer
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const LimitsScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.insights_rounded,
                        title: LanguageManager.translate('Spending Insights', 'Harcama Analizleri'),
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // Close drawer
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const SpendingInsightsScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.real_estate_agent_outlined,
                        title: LanguageManager.translate('Loans & Lending', 'Krediler ve Borç Verme'),
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // Close drawer
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const LendingDashboardScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.map_rounded,
                        title: LanguageManager.translate('ATM & Branch Locator', 'ATM ve Şube Bulucu'),
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // Close drawer
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const LocatorScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.verified_user_outlined,
                        title: LanguageManager.translate('Identity Verification', 'Kimlik Doğrulama'),
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const KycVerificationScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                       const SizedBox(height: 8),
                       _DrawerItem(
                         icon: Icons.health_and_safety_outlined,
                         title: LanguageManager.translate('Insurance Portfolio', 'Sigorta Portföyü'),
                         selected: false,
                         onTap: () {
                           Navigator.of(context).pop();
                           Navigator.of(context).push(
                             PageRouteBuilder(
                               pageBuilder: (context, animation, secondaryAnimation) =>
                                   const InsuranceScreen(),
                               transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                 return FadeTransition(opacity: animation, child: child);
                               },
                               transitionDuration: const Duration(milliseconds: 300),
                             ),
                           );
                         },
                       ),
                       const SizedBox(height: 8),
                       _DrawerItem(
                         icon: Icons.currency_exchange_rounded,
                         title: LanguageManager.translate('Exchange & Rates', 'Döviz ve Kurlar'),
                         selected: false,
                         onTap: () {
                           Navigator.of(context).pop();
                           Navigator.of(context).push(
                             PageRouteBuilder(
                               pageBuilder: (context, animation, secondaryAnimation) =>
                                   const ExchangeScreen(),
                               transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                 return FadeTransition(opacity: animation, child: child);
                               },
                               transitionDuration: const Duration(milliseconds: 300),
                             ),
                           );
                         },
                       ),
                       const SizedBox(height: 8),
                       _DrawerItem(
                         icon: Icons.account_balance_outlined,
                         title: LanguageManager.translate('Loan Application', 'Kredi Başvurusu'),
                         selected: false,
                         onTap: () {
                           Navigator.of(context).pop();
                           Navigator.of(context).push(
                             PageRouteBuilder(
                               pageBuilder: (context, animation, secondaryAnimation) =>
                                   const LoanApplicationScreen(),
                               transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                 return FadeTransition(opacity: animation, child: child);
                               },
                               transitionDuration: const Duration(milliseconds: 300),
                             ),
                           );
                         },
                       ),
                       const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.person_outline_rounded,
                        title: LanguageManager.translate('Profile Settings', 'Profil Ayarları'),
                        selected: _navIndex == 3,
                        onTap: () {
                          setState(() => _navIndex = 3);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.help_outline_rounded,
                        title: LanguageManager.translate('Help & Support', 'Yardım ve Destek'),
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // Close drawer
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const SupportScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFF1A1A1A)),
                      const SizedBox(height: 8),
                      _DrawerItem(
                        icon: Icons.settings_outlined,
                        title: LanguageManager.translate('App Settings', 'Uygulama Ayarları'),
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // Close drawer
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Version stamp
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    LanguageManager.translate('FINTECH ELITE v2.4.1', 'SEÇKİN FİNTEK v2.4.1'),
                    style: AppTextStyles.labelSm(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Active Page content
          Positioned.fill(
            child: _buildActivePage(),
          ),

          // Floating Bottom Nav
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh.withAlpha(204), // ~80%
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(77),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      index: 0,
                      activeIndex: _navIndex,
                      onTap: (i) => setState(() => _navIndex = i),
                    ),
                    _NavItem(
                      icon: Icons.swap_vert_rounded,
                      index: 1,
                      activeIndex: _navIndex,
                      onTap: (i) => setState(() => _navIndex = i),
                    ),
                    _NavItem(
                      icon: Icons.account_balance_wallet_outlined,
                      index: 2,
                      activeIndex: _navIndex,
                      onTap: (i) => setState(() => _navIndex = i),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      index: 3,
                      activeIndex: _navIndex,
                      onTap: (i) => setState(() => _navIndex = i),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Nav Item ───────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.index,
    required this.activeIndex,
    required this.onTap,
  });

  final IconData icon;
  final int index;
  final int activeIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(26),
                    blurRadius: 20,
                  )
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 22,
          color: isActive
              ? const Color(0xFF283500)
              : const Color(0xFFB7B5B4),
        ),
      ),
    );
  }
}

// ── Drawer Menu Item ──────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1A1A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.3), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primaryFixed : AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMd(
                  color: selected ? AppColors.primary : AppColors.secondary,
                ).copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryFixed,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
