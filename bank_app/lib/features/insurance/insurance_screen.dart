import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/notifications/app_notification.dart';
import '../../core/localization/language_manager.dart';

/// Insurance Portfolio Screen
/// Implements "Fintech Elite | Insurance Portfolio" HTML mockup.
class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen>
    with TickerProviderStateMixin {
  // ── Entrance stagger ───────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 5;

  // ── New Quote button loading state ─────────────────────────────────────────
  bool _isQuoteLoading = false;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.10;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.10;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int i, Widget child) => FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  // ── New Quote button ───────────────────────────────────────────────────────
  Future<void> _onGetNewQuote() async {
    if (_isQuoteLoading) return;
    HapticFeedback.mediumImpact();
    setState(() => _isQuoteLoading = true);

    AppNotification.pending(
      context,
      title: LanguageManager.translate('Fetching Quote', 'Teklif Alınyor'),
      message: LanguageManager.translate('Calculating your personalized premium...', 'Kişiselleştirilmiş priminiz hesaplanıyor...'),
      duration: const Duration(seconds: 3),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isQuoteLoading = false);
      AppNotification.success(
        context,
        title: LanguageManager.translate('Quote Ready', 'Teklif Hazır'),
        message: LanguageManager.translate('Your updated insurance quote has been generated.', 'Güncel sigorta teklifiniz oluşturuldu.'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background.withValues(alpha: 0.9),
            elevation: 0,
            toolbarHeight: 64,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.80),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'Fintech Elite',
              style: AppTextStyles.headlineMd().copyWith(
                color: AppColors.primaryFixed,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.onSurfaceVariant),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerHigh,
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // ── Dashboard Header ─────────────────────────────────
                  _staggered(
                    0,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageManager.translate('Insurance Portfolio', 'Sigorta Portföyü'),
                                style: AppTextStyles.headlineXl().copyWith(
                                  letterSpacing: -1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                LanguageManager.translate('Manage your premium protection and coverage assets.', 'Premium koruma ve teminat varlıklarınızı yönetin.'),
                                style:
                                    AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _GetQuoteButton(
                          isLoading: _isQuoteLoading,
                          onTap: _onGetNewQuote,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Stats Bento (3 cards) ────────────────────────────
                  _staggered(1, _buildStatsBento()),

                  const SizedBox(height: 28),

                  // ── Portfolio Grid ───────────────────────────────────
                  _staggered(2, _buildPortfolioGrid()),

                  const SizedBox(height: 28),

                  // ── Payment History ──────────────────────────────────
                  _staggered(3, _buildPaymentHistory()),

                  const SizedBox(height: 12),

                  // ── View Full History link ───────────────────────────
                  _staggered(
                    4,
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surfaceContainerHigh,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content: Row(
                                children: [
                                  const Icon(Icons.history_rounded,
                                      color: AppColors.primaryFixed, size: 18),
                                  const SizedBox(width: 10),
                                  Text(LanguageManager.translate('Full history coming soon', 'Tüm geçmiş yakında eklenecek'),
                                      style: AppTextStyles.labelMd(
                                          color: AppColors.primary)),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LanguageManager.translate('View Full Transaction History', 'Tüm İşlem Geçmişini Görüntüle'),
                              style: AppTextStyles.labelMd(
                                      color: AppColors.onSurfaceVariant)
                                  .copyWith(letterSpacing: 0.3),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 16, color: AppColors.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3 Summary stat cards ─────────────────────────────────────────────────
  Widget _buildStatsBento() {
    return Column(
      children: [
        _StatCard(
          label: LanguageManager.translate('TOTAL ANNUAL PREMIUM', 'TOPLAM YILLIK PRİM'),
          icon: Icons.payments_outlined,
          value: '\$12,450.00',
          sub: LanguageManager.translate('2.4% vs last year', 'geçen yıla göre %2.4'),
          subIcon: Icons.trending_up_rounded,
          subColor: AppColors.primaryFixed,
          useMono: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: LanguageManager.translate('ACTIVE POLICIES', 'AKTİF POLİÇELER'),
                icon: Icons.verified_outlined,
                value: '04',
                sub: LanguageManager.translate('All systems functional', 'Tüm sistemler aktif'),
                subIcon: null,
                subColor: AppColors.onSurfaceVariant,
                useMono: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: LanguageManager.translate('NEXT PAYMENT', 'SONRAKİ ÖDEME'),
                icon: Icons.calendar_today_outlined,
                value: LanguageManager.translate('OCT 24', '24 EKİM'),
                sub: LanguageManager.translate('6 days remaining', '6 gün kaldı'),
                subIcon: Icons.warning_amber_rounded,
                subColor: AppColors.error,
                useMono: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 4 policy cards ──────────────────────────────────────────────────────
  Widget _buildPortfolioGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        // 2-col wrap
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
          children: [
            _PolicyCard(
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD_BtjLoXfVSO2dOm1vn_PDZQblDYvZQHh5Blm6AdgNpheclxB82_42xoQfuJ5rjRpjXmghtkz_98RcyFTkdhHFPLAcYPvSSnUhHMdDbkXIhiCxVa3U0r_uT21d5yCOFEP98UUdQNo8pXi4ljMZxxbCvZZnpMU_sbGyXyX7_yvjIEQrt5cIurtTNRbS4t50UmJ4XI_3YuxxnD6H19r64zVCoe_rRLH18Yzt4scxdj-Z6Yx1-ZOGE-37djgKhprgEU8t4Hgiw3BUH4Ks',
              categoryIcon: Icons.medical_services_outlined,
              categoryLabel: LanguageManager.translate('Health', 'Sağlık'),
              policyNumber: '${LanguageManager.translate('Policy', 'Poliçe')} #HE-9920',
              isActive: true,
              coverageLabel: LanguageManager.translate('Coverage', 'Teminat'),
              coverageValue: '\$2,000,000',
              periodLabel: LanguageManager.translate('Monthly', 'Aylık'),
              periodValue: '\$420.00',
            ),
            _PolicyCard(
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA1wQnNlCpu3m05fnPeQspyRCF3WsnXkcQs0Dx75G6hYGIBuUxD0L6-oxiWYaxBXi057rG5ukXQIdTCrQzvFvU0jDgyKGMbXHOp7uyne5eGeUL119zXWemP0xBaWgyqq86ZvYhxoKV02_5j-qQDJLfvqgsfgc_t0MwGGs7VOt7dw4bOAkQzmatW9B2LffUf_Hs_YkwzVmHI5eiUQorEIaYaNgZUoV7turUSjJSOIED6O2giT6Y2ZorcBoiZuw9NMPq0tfa5WlO0yLvL',
              categoryIcon: Icons.family_restroom_outlined,
              categoryLabel: LanguageManager.translate('Life', 'Hayat'),
              policyNumber: '${LanguageManager.translate('Policy', 'Poliçe')} #LI-4412',
              isActive: true,
              coverageLabel: LanguageManager.translate('Coverage', 'Teminat'),
              coverageValue: '\$5,000,000',
              periodLabel: LanguageManager.translate('Quarterly', 'Üç Aylık'),
              periodValue: '\$1,150.00',
            ),
            _PolicyCard(
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA8jpjMabghJut3B8j2q7DrUmVjse8St08EOblyVXTzosQxLV6vFvc_k9GHdFo5rx_GpEnLyT9yR98xbmjgvOFGTlXtG8JPBemQdMy9uHpepjayxqrv6B3KcqfDJSLIhOlPRorHOXSMKi56sv3EoeKD3RJ1jhvbK0iUtDki1Cgs5mvEmJSm1AR87AZXwzploLILk-Tz5vsDAoGS-30398ztesx0NCnecPfQ5XOdah7HOkgVrIQAWhNMjX8XSboKs4dM5Af7QXNRJEEV',
              categoryIcon: Icons.home_work_outlined,
              categoryLabel: LanguageManager.translate('Home', 'Konut'),
              policyNumber: '${LanguageManager.translate('Policy', 'Poliçe')} #HO-3301',
              isActive: true,
              coverageLabel: LanguageManager.translate('Coverage', 'Teminat'),
              coverageValue: '\$1,200,000',
              periodLabel: LanguageManager.translate('Annual', 'Yıllık'),
              periodValue: '\$3,400.00',
            ),
            const _TravelPolicyCard(),
          ],
        ),
      ],
    );
  }

  // ── Payment History ─────────────────────────────────────────────────────
  Widget _buildPaymentHistory() {
    final payments = [
      _Payment(
        icon: Icons.health_and_safety_outlined,
        title: LanguageManager.translate('Monthly Premium: Health', 'Aylık Prim: Sağlık'),
        subtitle: '${LanguageManager.translate('Sep 24, 2023', '24 Eyl 2023')} • VISA **** 9012',
        amount: '\$420.00',
        status: LanguageManager.translate('Processed', 'Gerçekleşti'),
      ),
      _Payment(
        icon: Icons.favorite_outline_rounded,
        title: LanguageManager.translate('Quarterly Premium: Life', 'Üç Aylık Prim: Hayat'),
        subtitle: '${LanguageManager.translate('Aug 15, 2023', '15 Ağu 2023')} • AMEX **** 0005',
        amount: '\$1,150.00',
        status: LanguageManager.translate('Processed', 'Gerçekleşti'),
      ),
      _Payment(
        icon: Icons.home_outlined,
        title: LanguageManager.translate('Annual Premium: Home', 'Yıllık Prim: Konut'),
        subtitle: '${LanguageManager.translate('Jan 02, 2023', '02 Oca 2023')} • ${LanguageManager.translate('Bank Transfer', 'Banka Havalesi')}',
        amount: '\$3,400.00',
        status: LanguageManager.translate('Processed', 'Gerçekleşti'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanguageManager.translate('Payment History', 'Ödeme Geçmişi'), style: AppTextStyles.headlineMd()),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: payments
                .map((p) => _PaymentRow(payment: p))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Get New Quote Button
// ══════════════════════════════════════════════════════════════════════════════
class _GetQuoteButton extends StatelessWidget {
  const _GetQuoteButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryFixed.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF161E00),
                    ),
                  )
                : const Icon(Icons.add_circle_outline_rounded,
                    color: Color(0xFF161E00), size: 18),
            const SizedBox(width: 8),
            Text(
              isLoading ? LanguageManager.translate('Requesting...', 'İsteniyor...') : LanguageManager.translate('Get New Quote', 'Yeni Teklif Al'),
              style: AppTextStyles.labelMd(color: const Color(0xFF161E00))
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Stat Card
// ══════════════════════════════════════════════════════════════════════════════
class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.sub,
    required this.subColor,
    required this.useMono,
    this.subIcon,
  });
  final String label;
  final IconData icon;
  final String value;
  final String sub;
  final IconData? subIcon;
  final Color subColor;
  final bool useMono;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF141414) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? AppColors.primaryFixed : const Color(0xFF333333),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.labelSm(
                            color: AppColors.onSurfaceVariant)
                        .copyWith(letterSpacing: 0.8),
                  ),
                ),
                Icon(widget.icon,
                    color: AppColors.primaryFixed, size: 22),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.value,
              style: AppTextStyles.headlineLg().copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                fontFamily: widget.useMono ? 'JetBrains Mono' : null,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (widget.subIcon != null) ...[
                  Icon(widget.subIcon, color: widget.subColor, size: 14),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    widget.sub,
                    style: AppTextStyles.labelSm(color: widget.subColor)
                        .copyWith(letterSpacing: 0.2),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Policy Card (active)
// ══════════════════════════════════════════════════════════════════════════════
class _PolicyCard extends StatefulWidget {
  const _PolicyCard({
    required this.imageUrl,
    required this.categoryIcon,
    required this.categoryLabel,
    required this.policyNumber,
    required this.isActive,
    required this.coverageLabel,
    required this.coverageValue,
    required this.periodLabel,
    required this.periodValue,
  });
  final String imageUrl;
  final IconData categoryIcon;
  final String categoryLabel;
  final String policyNumber;
  final bool isActive;
  final String coverageLabel;
  final String coverageValue;
  final String periodLabel;
  final String periodValue;

  @override
  State<_PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<_PolicyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF141414) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? AppColors.primaryFixed : const Color(0xFF333333),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            // ── Image header ─────────────────────────────────────────
            SizedBox(
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _hovered ? 0.80 : 0.60,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.surfaceContainerHigh,
                      ),
                    ),
                  ),
                  // Bottom gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.cardBg,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category label
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Row(
                      children: [
                        Icon(widget.categoryIcon,
                            color: AppColors.primaryFixed, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.categoryLabel,
                          style: AppTextStyles.headlineMd()
                              .copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Card body ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Policy number + status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.policyNumber,
                          style: AppTextStyles.labelSm(
                                  color: AppColors.onSurfaceVariant)
                              .copyWith(letterSpacing: 0.3),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusBadge(isActive: widget.isActive),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Coverage / period rows
                  _DetailRow(label: widget.coverageLabel, value: widget.coverageValue),
                  const SizedBox(height: 4),
                  _DetailRow(label: widget.periodLabel, value: widget.periodValue, mono: true),
                  const SizedBox(height: 12),

                  // View Details button
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _hovered
                              ? AppColors.primaryFixed
                              : AppColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          LanguageManager.translate('View Details', 'Detayları Gör'),
                          style: AppTextStyles.labelMd(
                            color: _hovered
                                ? AppColors.primaryFixed
                                : AppColors.primary,
                          ).copyWith(letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Travel (Expired) Card
// ══════════════════════════════════════════════════════════════════════════════
class _TravelPolicyCard extends StatelessWidget {
  const _TravelPolicyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 2,
          style: BorderStyle.solid, // dashed not directly supported; use solid thin
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Empty image area ───────────────────────────────────────
          Expanded(
            child: Container(
              color: AppColors.surfaceContainerLow,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flight_takeoff_rounded,
                        size: 40,
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                    const SizedBox(height: 6),
                    Text(
                      LanguageManager.translate('No active travel plan', 'Aktif seyahat planı yok'),
                      style: AppTextStyles.labelSm(
                              color: AppColors.onSurfaceVariant)
                          .copyWith(letterSpacing: 0.3),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Card body ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${LanguageManager.translate('Coverage', 'Teminat')}: Global',
                        style: AppTextStyles.labelSm(
                                color: AppColors.onSurfaceVariant)
                            .copyWith(letterSpacing: 0.3),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        LanguageManager.translate('EXPIRED', 'SÜRESİ DOLDU'),
                        style: AppTextStyles.labelSm(
                                color: AppColors.onSurfaceVariant)
                            .copyWith(fontSize: 10, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageManager.translate('Secure your next international journey in minutes.', 'Bir sonraki yurt dışı seyahatinizi dakikalar içinde güvenceye alın.'),
                  style: AppTextStyles.labelSm(
                          color: AppColors.onSurfaceVariant)
                      .copyWith(
                          fontStyle: FontStyle.italic, letterSpacing: 0.2),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => HapticFeedback.mediumImpact(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryFixed.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        LanguageManager.translate('Renew Protection', 'Korumayı Yenile'),
                        style: AppTextStyles.labelMd(
                                color: AppColors.primaryFixed)
                            .copyWith(letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Small reusable widgets
// ══════════════════════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryFixed.withValues(alpha: 0.10)
            : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryFixed.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Text(
        isActive ? LanguageManager.translate('ACTIVE', 'AKTİF') : LanguageManager.translate('EXPIRED', 'SÜRESİ DOLDU'),
        style: AppTextStyles.labelSm(
          color: isActive ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
        ).copyWith(fontSize: 10, letterSpacing: 0.8),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
              .copyWith(letterSpacing: 0.2),
        ),
        Text(
          value,
          style: (mono
              ? AppTextStyles.labelSm(color: AppColors.primary)
                  .copyWith(fontFamily: 'JetBrains Mono', letterSpacing: 0.2)
              : AppTextStyles.labelSm(color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});
  final _Payment payment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFF1A1A1A)),
        ),
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Icon(payment.icon, color: AppColors.primaryFixed, size: 20),
          ),
          const SizedBox(width: 14),

          // Title / subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.title,
                    style: AppTextStyles.bodyMd(color: AppColors.primary)
                        .copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(payment.subtitle,
                    style: AppTextStyles.labelSm(
                            color: AppColors.onSurfaceVariant)
                        .copyWith(letterSpacing: 0.2)),
              ],
            ),
          ),

          // Amount / status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment.amount,
                style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                    fontFamily: 'JetBrains Mono', fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                payment.status,
                style: AppTextStyles.labelSm(color: AppColors.primaryFixed)
                    .copyWith(letterSpacing: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Data classes
// ══════════════════════════════════════════════════════════════════════════════
class _Payment {
  const _Payment({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String status;
}
