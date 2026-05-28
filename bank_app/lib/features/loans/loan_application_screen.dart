import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/notifications/app_notification.dart';
import '../../core/localization/language_manager.dart';

/// Loan Application Screen
/// Implements "Loan Application | Fintech Elite" HTML mockup.
class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen>
    with TickerProviderStateMixin {
  // ── Entrance animations ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  static const int _sectionCount = 5;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  // ── Loan state ─────────────────────────────────────────────────────────────
  _LoanType _selectedType = _LoanType.personal;
  double _loanAmount = 50000;
  int _tenure = 24; // months
  bool _termsAccepted = false;
  bool _isApplying = false;
  bool _isDownloading = false;

  static const double _minAmount = 5000;

  static const Map<_LoanType, _LoanConfig> _configs = {
    _LoanType.personal: _LoanConfig(
      icon: Icons.person_outline_rounded,
      label: 'Personal',
      apr: 0.0425,
    ),
    _LoanType.mortgage: _LoanConfig(
      icon: Icons.home_outlined,
      label: 'Mortgage',
      apr: 0.035,
    ),
    _LoanType.auto: _LoanConfig(
      icon: Icons.directions_car_outlined,
      label: 'Auto',
      apr: 0.039,
    ),
  };

  // ── Computed values ────────────────────────────────────────────────────────
  double get _effectiveApr => _configs[_selectedType]!.apr;

  double get _monthlyPayment =>
      _loanAmount * (1 + _effectiveApr) / _tenure;

  double get _totalInterest => _loanAmount * _effectiveApr;

  String _translateLoanType(_LoanType type) {
    switch (type) {
      case _LoanType.personal:
        return 'Bireysel';
      case _LoanType.mortgage:
        return 'Konut';
      case _LoanType.auto:
        return 'Taşıt';
    }
  }

  String _formatMoney(double v) {
    if (v >= 1000) {
      final parts = v.toStringAsFixed(2).split('.');
      final intPart = int.parse(parts[0]);
      final separator = LanguageManager.translate(',', '.');
      final decimalSeparator = LanguageManager.translate('.', ',');
      final formatted = intPart.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}$separator',
          );
      return '\$$formatted$decimalSeparator${parts[1]}';
    }
    final decimalSeparator = LanguageManager.translate('.', ',');
    return '\$${v.toStringAsFixed(2).replaceAll('.', decimalSeparator)}';
  }

  String _formatAmount(double v) {
    final intPart = v.round();
    final separator = LanguageManager.translate(',', '.');
    return intPart.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}$separator',
        );
  }

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
            curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.10;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _entranceCtrl,
              curve: Interval(start, end, curve: Curves.easeOutCubic)));
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
            backgroundColor: AppColors.background.withValues(alpha: 0.85),
            elevation: 0,
            toolbarHeight: 64,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.80),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryFixed, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'FINTECH ELITE',
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
                    border: Border.all(
                        color: AppColors.primaryFixed.withValues(alpha: 0.6),
                        width: 1.5),
                    color: AppColors.surfaceContainerHigh,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAuL7abI29JTpNDTxPmobZqoiSjEOjOF-7Teyn9MF0390fbKTdBKjoG4yOl0kpKvYUp41c7R-eVO22gB4N-NAHGAFK8YI1y4KAXnVm7zuhB26o7kRnQ8NCzvc66tel9EsO2e4oI56nS8WsiWh7UeA_D9VnfuEG9ZqQYIVWy7u2cN9pkn9YsRXqRi9sbuve_OMQuD1aUD5FxRjHjogDPDnNBxcYRqoH_xAHN7rH3YPpWjVS_GPnrKlsIfJLn6Eyk2VNn0vBigJpjJxEy',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.person,
                        color: AppColors.primary, size: 18),
                  ),
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

                  // ── Hero ────────────────────────────────────────────
                  _staggered(0, _buildHero()),
                  const SizedBox(height: 24),

                  // ── Loan type grid ───────────────────────────────────
                  _staggered(1, _buildLoanTypeGrid()),
                  const SizedBox(height: 16),

                  // ── Calculator ───────────────────────────────────────
                  _staggered(2, _buildCalculator()),
                  const SizedBox(height: 16),

                  // ── Feature cards ────────────────────────────────────
                  _staggered(3, _buildFeatures()),
                  const SizedBox(height: 16),

                  // ── Summary ──────────────────────────────────────────
                  _staggered(4, _buildSummaryPanel()),
                  const SizedBox(height: 16),

                  // ── Trust badge ──────────────────────────────────────
                  _buildTrustBadge(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageManager.translate('Loan Application', 'Kredi Başvurusu'),
          style: AppTextStyles.headlineXl()
              .copyWith(color: AppColors.primary, letterSpacing: -1.5),
        ),
        const SizedBox(height: 6),
        Text(
          LanguageManager.translate('Select your preferred credit facility and customize your terms.', 'Tercih ettiğiniz kredi imkanını seçin ve şartlarınızı özelleştirin.'),
          style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // ── Loan Type Grid ─────────────────────────────────────────────────────────
  Widget _buildLoanTypeGrid() {
    return Row(
      children: _LoanType.values.map((type) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: type == _LoanType.auto ? 0 : 10),
            child: _LoanTypeCard(
              config: _configs[type]!,
              type: type,
              isSelected: _selectedType == type,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedType = type);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Calculator ─────────────────────────────────────────────────────────────
  Widget _buildCalculator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Amount slider ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                LanguageManager.translate('LOAN AMOUNT', 'KREDİ TUTARI'),
                style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                    .copyWith(letterSpacing: 0.8),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$',
                    style: AppTextStyles.labelSm(color: AppColors.primaryFixed)
                        .copyWith(letterSpacing: 0.3),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatAmount(_loanAmount),
                    style: AppTextStyles.headlineLg().copyWith(
                      color: AppColors.primaryFixed,
                      fontSize: 26,
                      letterSpacing: -0.5,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primaryFixed,
              inactiveTrackColor: const Color(0xFF333333),
              thumbColor: AppColors.primaryFixed,
              overlayColor: AppColors.primaryFixed.withValues(alpha: 0.12),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 20),
              trackHeight: 4,
            ),
            child: Slider(
              value: _loanAmount,
              min: _minAmount,
              max: 500000.0,
              divisions: 495,
              onChanged: (v) {
                setState(() => _loanAmount = (v / 1000).round() * 1000.0);
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LanguageManager.translate('\$5,000', '\$5.000'),
                  style: AppTextStyles.labelSm(
                          color: AppColors.onSurfaceVariant)
                      .copyWith(letterSpacing: 0.2)),
              Text(LanguageManager.translate('\$500,000', '\$500.000'),
                  style: AppTextStyles.labelSm(
                          color: AppColors.onSurfaceVariant)
                      .copyWith(letterSpacing: 0.2)),
            ],
          ),

          const SizedBox(height: 24),

          // ── Tenure chips ───────────────────────────────────────────
          Text(
            LanguageManager.translate('TENURE (MONTHS)', 'VADE (AY)'),
            style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                .copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [12, 24, 36, 48, 60].map((m) {
              final isSelected = m == _tenure;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _tenure = m);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryFixed.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryFixed
                          : const Color(0xFF444444),
                    ),
                  ),
                  child: Text(
                    LanguageManager.translate('${m}m', '$m Ay'),
                    style: AppTextStyles.labelMd(
                      color: isSelected
                          ? AppColors.primaryFixed
                          : AppColors.onSurfaceVariant,
                    ).copyWith(letterSpacing: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Feature cards ──────────────────────────────────────────────────────────
  Widget _buildFeatures() {
    return Row(
      children: [
        Expanded(
          child: _FeatureCard(
            icon: Icons.speed_rounded,
            title: LanguageManager.translate('Instant Approval', 'Anında Onay'),
            sub: LanguageManager.translate('Get a decision in under 60 seconds.', '60 saniyeden kısa sürede karar alın.'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FeatureCard(
            icon: Icons.lock_outline_rounded,
            title: LanguageManager.translate('Fixed Rates', 'Sabit Oranlar'),
            sub: LanguageManager.translate('Transparent pricing with no hidden fees.', 'Gizli ücret içermeyen şeffaf fiyatlandırma.'),
          ),
        ),
      ],
    );
  }

  // ── Summary Panel ──────────────────────────────────────────────────────────
  Widget _buildSummaryPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(LanguageManager.translate('Application Summary', 'Başvuru Özeti'),
                    style: AppTextStyles.headlineMd()
                        .copyWith(color: AppColors.primary)),
                const SizedBox(height: 20),
                _SummaryRow(
                  label: LanguageManager.translate('Interest Rate', 'Faiz Oranı'),
                  value: LanguageManager.translate(
                    '${(_effectiveApr * 100).toStringAsFixed(2)}% APR',
                    '%${(_effectiveApr * 100).toStringAsFixed(2)} Yıllık Faiz',
                  ),
                  valueColor: AppColors.primaryFixed,
                  isMono: true,
                ),
                const SizedBox(height: 14),
                _SummaryRow(
                  label: LanguageManager.translate('Monthly Payment', 'Aylık Ödeme'),
                  value: _formatMoney(_monthlyPayment),
                  valueColor: AppColors.primary,
                  isMono: true,
                ),
                const SizedBox(height: 14),
                _SummaryRow(
                  label: LanguageManager.translate('Total Interest', 'Toplam Faiz'),
                  value: _formatMoney(_totalInterest),
                  valueColor: AppColors.primary,
                  isMono: false,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1F1F1F)),

          // CTA area
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Terms checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _termsAccepted,
                        onChanged: (v) {
                          HapticFeedback.lightImpact();
                          setState(() => _termsAccepted = v ?? false);
                        },
                        activeColor: AppColors.primaryFixed,
                        checkColor: const Color(0xFF161E00),
                        side: const BorderSide(
                            color: Color(0xFF444444), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        LanguageManager.translate(
                          'I agree to the terms and conditions and authorize Fintech Elite to perform a soft credit check.',
                          'Şart ve koşulları kabul ediyorum ve Fintech Elite\'e ön kredi kontrolü yapma yetkisi veriyorum.',
                        ),
                        style: AppTextStyles.labelSm(
                                color: AppColors.onSurfaceVariant)
                            .copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Apply Now button
                GestureDetector(
                  onTap: _termsAccepted && !_isApplying
                      ? () async {
                          HapticFeedback.heavyImpact();
                          setState(() => _isApplying = true);

                          AppNotification.pending(
                            context,
                            title: LanguageManager.translate('Reviewing Application', 'Başvuru İnceleniyor'),
                            message: LanguageManager.translate('Running soft credit check...', 'Ön kredi kontrolü yapılıyor...'),
                            duration: const Duration(seconds: 3),
                          );

                          await Future.delayed(
                              const Duration(milliseconds: 1800));
                          if (mounted) {
                            setState(() => _isApplying = false);
                            AppNotification.success(
                              context,
                              title: LanguageManager.translate('Application Submitted', 'Başvuru Gönderildi'),
                              message: LanguageManager.translate(
                                'Your ${_configs[_selectedType]!.label} loan application is under review.',
                                'Seçtiğiniz ${_translateLoanType(_selectedType)} kredi başvurunuz inceleme altında.',
                              ),
                            );
                          }
                        }
                      : !_termsAccepted
                          ? () {
                              AppNotification.error(
                                context,
                                title: LanguageManager.translate('Terms Required', 'Şartlar Gerekli'),
                                message: LanguageManager.translate(
                                  'Please accept the terms and conditions to proceed.',
                                  'Devam etmek için lütfen şart ve koşulları kabul edin.',
                                ),
                              );
                            }
                          : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 54,
                    decoration: BoxDecoration(
                      color: _termsAccepted
                          ? (_isApplying
                              ? AppColors.primaryFixed.withValues(alpha: 0.7)
                              : AppColors.primaryFixed)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _termsAccepted && !_isApplying
                          ? [
                              BoxShadow(
                                color: AppColors.primaryFixed
                                    .withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: _isApplying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF161E00),
                              ),
                            )
                          : Text(
                              LanguageManager.translate('APPLY NOW', 'ŞİMDİ BAŞVUR'),
                              style: AppTextStyles.headlineMd().copyWith(
                                color: _termsAccepted
                                    ? const Color(0xFF161E00)
                                    : AppColors.onSurfaceVariant,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Download Quote button
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    AppNotification.info(
                      context,
                      title: LanguageManager.translate('Preparing Quote', 'Teklif Hazırlanıyor'),
                      message: LanguageManager.translate('Generating your loan quote PDF...', 'Kredi teklifi PDF\'i oluşturuluyor...'),
                      duration: const Duration(seconds: 2),
                    );
                    setState(() => _isDownloading = true);
                    await Future.delayed(
                        const Duration(milliseconds: 1200));
                    if (mounted) {
                      setState(() => _isDownloading = false);
                      AppNotification.success(
                        context,
                        title: LanguageManager.translate('Quote Ready', 'Teklif Hazır'),
                        message: LanguageManager.translate('Your loan quote has been prepared.', 'Kredi teklifiniz hazırlandı.'),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isDownloading
                            ? AppColors.primaryFixed.withValues(alpha: 0.4)
                            : AppColors.primaryFixed,
                      ),
                    ),
                    child: Center(
                      child: _isDownloading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryFixed,
                              ),
                            )
                          : Text(
                              LanguageManager.translate('DOWNLOAD QUOTE', 'TEKLİFİ İNDİR'),
                              style: AppTextStyles.labelMd(
                                      color: AppColors.primaryFixed)
                                  .copyWith(letterSpacing: 0.8),
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

  // ── Trust Badge ────────────────────────────────────────────────────────────
  Widget _buildTrustBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: Opacity(
                opacity: 0.4,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBUf2g3uf0icv5L-YZWC5LWm-1kI9Ii1c7JaZNIaCOStx0J-JN0QT77M-Ipp7x-Uva4tHyKFDNMTD_1_O2c-IU7MF4PTTn-1dEX37sjGGqXlZd41zOveKeHFrFIJ2-tAVlx-rYmzx6_GJ2NhE5UrUeq44eMYEQSn1bNbSNn9OD7G0avRxBsTaabHLIUTWbr-sywWhwAXpr2chUAcRDqIemFurTZiMm-52O_SoMiUBV9-kG_8_zbBm9wPgXRyJP8GGwfsVzGthDQSSoy',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceContainerHigh),
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            // Text overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LanguageManager.translate('ENTERPRISE SECURITY', 'KURUMSAL GÜVENLİK'),
                    style: AppTextStyles.labelSm(color: AppColors.primaryFixed)
                        .copyWith(letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LanguageManager.translate(
                      'Your data is encrypted with AES-256 bank-grade security protocols.',
                      'Verileriniz AES-256 banka düzeyinde güvenlik protokolleri ile şifrelenir.',
                    ),
                    style: AppTextStyles.bodyMd(color: AppColors.primary)
                        .copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _showSuccessSnack is now handled by AppNotification.success()
  // Kept for reference only.
}

// ══════════════════════════════════════════════════════════════════════════════
// Loan Type Enum & Config
// ══════════════════════════════════════════════════════════════════════════════
enum _LoanType { personal, mortgage, auto }

class _LoanConfig {
  const _LoanConfig({
    required this.icon,
    required this.label,
    required this.apr,
  });
  final IconData icon;
  final String label;
  final double apr;
}

// ══════════════════════════════════════════════════════════════════════════════
// Loan Type Card
// ══════════════════════════════════════════════════════════════════════════════
class _LoanTypeCard extends StatefulWidget {
  const _LoanTypeCard({
    required this.config,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });
  final _LoanConfig config;
  final _LoanType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_LoanTypeCard> createState() => _LoanTypeCardState();
}

class _LoanTypeCardState extends State<_LoanTypeCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  String _translateLoanType(_LoanType type) {
    switch (type) {
      case _LoanType.personal:
        return 'Bireysel';
      case _LoanType.mortgage:
        return 'Konut';
      case _LoanType.auto:
        return 'Taşıt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primaryFixed : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryFixed
                  : _hovered
                      ? AppColors.primaryFixed.withValues(alpha: 0.5)
                      : const Color(0xFF333333),
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryFixed.withValues(alpha: 0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.config.icon,
                color: widget.isSelected
                    ? const Color(0xFF161E00)
                    : AppColors.primaryFixed,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                LanguageManager.translate('TYPE', 'TÜR'),
                style: AppTextStyles.labelSm(
                  color: widget.isSelected
                      ? const Color(0xFF161E00).withValues(alpha: 0.6)
                      : AppColors.onSurfaceVariant,
                ).copyWith(letterSpacing: 0.8),
              ),
              const SizedBox(height: 2),
              Text(
                LanguageManager.translate(widget.config.label, _translateLoanType(widget.type)),
                style: AppTextStyles.headlineMd().copyWith(
                  color: widget.isSelected
                      ? const Color(0xFF161E00)
                      : AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Feature Card
// ══════════════════════════════════════════════════════════════════════════════
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.sub,
  });
  final IconData icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryFixed, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMd(color: AppColors.primary)
                      .copyWith(letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: AppTextStyles.labelSm(
                          color: AppColors.onSurfaceVariant)
                      .copyWith(letterSpacing: 0.1, height: 1.4),
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
// Summary Row
// ══════════════════════════════════════════════════════════════════════════════
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isMono,
  });
  final String label;
  final String value;
  final Color valueColor;
  final bool isMono;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                .copyWith(fontSize: 14)),
        Text(
          value,
          style: AppTextStyles.headlineMd().copyWith(
            color: valueColor,
            fontSize: isMono ? 18 : 14,
            fontFamily: isMono ? 'JetBrains Mono' : null,
            letterSpacing: isMono ? -0.3 : 0.2,
          ),
        ),
      ],
    );
  }
}
