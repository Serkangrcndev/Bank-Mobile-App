import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../notifications/notifications_screen.dart';
import '../transfers/transaction_success_screen.dart';
import '../../core/localization/language_manager.dart';

class LendingDashboardScreen extends StatefulWidget {
  const LendingDashboardScreen({super.key});

  @override
  State<LendingDashboardScreen> createState() => _LendingDashboardScreenState();
}

class _LendingDashboardScreenState extends State<LendingDashboardScreen> with TickerProviderStateMixin {
  // Entrance animations
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _staggerCount = 3;

  // Form states
  double _principalAmount = 50000;
  String _selectedTerm = '12M';
  bool _isSubmitting = false;

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
      return Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
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

  double get aprRate {
    switch (_selectedTerm) {
      case '12M': return 4.2;
      case '24M': return 4.5;
      case '36M': return 4.8;
      case '60M': return 5.5;
      default: return 4.2;
    }
  }

  int get termMonths {
    return int.parse(_selectedTerm.replaceAll('M', ''));
  }

  String _formatNumber(double val) {
    final whole = val.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return whole.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  String getEstPayment() {
    final monthlyRate = aprRate / 12 / 100;
    final months = termMonths;
    if (monthlyRate == 0) {
      return '${_formatNumber(_principalAmount / months)}/mo';
    }
    // payment = P * (r * (1+r)^n) / ((1+r)^n - 1)
    final powVal = math.pow(1 + monthlyRate, months);
    final val = _principalAmount * (monthlyRate * powVal) / (powVal - 1);
    return '${_formatNumber(val)}/mo';
  }

  void _submitApplication() {
    HapticFeedback.heavyImpact();
    setState(() => _isSubmitting = true);

    // Simulate 1.5 seconds processing before success routing
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final now = DateTime.now();
      final formattedDate = '${months[now.month - 1]} ${now.day}, ${now.year} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final randomRef = 'LND-${(now.millisecondsSinceEpoch ~/ 1000).toRadixString(16).toUpperCase()}';
      final fee = _principalAmount * 0.005; // 0.50%

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TransactionSuccessScreen(
            title: LanguageManager.translate('Application Approved', 'Başvuru Onaylandı'),
            amount: '${_principalAmount.toStringAsFixed(0)} USDT',
            recipient: 'Lumina Credit Facility',
            date: formattedDate,
            referenceId: randomRef,
            transactionFee: '\$${fee.toStringAsFixed(2)}',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
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
          // ── Background Glow Orb
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
                      const Color(0xFFCCFF00).withValues(alpha: 0.03),
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
                            'FINTECH ELITE',
                            style: AppTextStyles.headlineMd(color: Colors.white).copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
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
                      // Page title & subtitle (Stagger 0)
                      _staggered(0, _buildHeader()),
                      const SizedBox(height: 24),

                      // Responsive grid (Stagger 1 & 2)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isTablet = constraints.maxWidth > 800;
                          if (isTablet) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: _staggered(1, _buildLeftColumn()),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 8,
                                  child: _staggered(2, _buildRightColumn()),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _staggered(1, _buildLeftColumn()),
                                const SizedBox(height: 24),
                                _staggered(2, _buildRightColumn()),
                              ],
                            );
                          }
                        },
                      ),
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

  // ── Header Section ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageManager.translate('Lending Dashboard', 'Kredi Paneli'),
          style: AppTextStyles.headlineLgMobile(color: Colors.white).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          LanguageManager.translate('Manage facilities and request new capital.', 'Kredi imkanlarını yönetin ve yeni sermaye talep edin.'),
          style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)),
        ),
      ],
    );
  }

  // ── Left Column (Credit Score & Active Facilities) ─────────────────────────
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Credit Score Widget
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF131313), // surface
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF353535), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageManager.translate('Credit Score', 'Kredi Skoru'),
                    style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18),
                  ),
                  const Icon(Icons.speed_rounded, color: Color(0xFFCCFF00), size: 20),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CreditScoreGaugePainter(progress: 0.85),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '785',
                            style: AppTextStyles.headlineXl(color: Colors.white).copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            LanguageManager.translate('EXCELLENT', 'MÜKEMMEL'),
                            style: AppTextStyles.labelSm(color: const Color(0xFFCCFF00)).copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF353535))),
                ),
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LanguageManager.translate('Updated: Today', 'Güncellendi: Bugün'), style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1))),
                    Text(LanguageManager.translate('Bureau: Experian', 'Kurum: Experian'), style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Active Facilities Widget
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF131313),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF353535), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LanguageManager.translate('Active Facilities', 'Aktif Krediler'),
                style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF353535)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1F1F1F),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.real_estate_agent_rounded, color: Color(0xFFCCFF00), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(LanguageManager.translate('Mortgage', 'Konut Kredisi'), style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                                Text('ID: #8492', style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1))),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$420,500', style: AppTextStyles.labelMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                            Text('${LanguageManager.translate('Next', 'Sonraki')}: \$3,200', style: AppTextStyles.labelSm(color: AppColors.error)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.15,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFF00),
                            borderRadius: BorderRadius.circular(99),
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
      ],
    );
  }

  // ── Right Column (New Application Form) ────────────────────────────────────
  Widget _buildRightColumn() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353535), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LanguageManager.translate('New Application', 'Yeni Başvuru'),
            style: AppTextStyles.headlineLgMobile(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            LanguageManager.translate('Configure your facility parameters. Instant approval for eligible accounts.', 'Kredi parametrelerinizi yapılandırın. Uygun hesaplar için anında onay.'),
            style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)),
          ),
          const SizedBox(height: 32),

          // Principal Amount Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(LanguageManager.translate('Principal Amount', 'Ana Para Tutarı'), style: AppTextStyles.bodyLg(color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF353535)),
                    ),
                    child: Text(
                      '${_formatNumber(_principalAmount)} USDT',
                      style: AppTextStyles.labelMd(color: const Color(0xFFCCFF00)).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: const Color(0xFFCCFF00),
                  inactiveTrackColor: const Color(0xFF353535),
                  thumbColor: const Color(0xFFCCFF00),
                  overlayColor: const Color(0xFFCCFF00).withValues(alpha: 0.12),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: _principalAmount,
                  min: 5000,
                  max: 250000,
                  divisions: 245,
                  onChanged: (val) {
                    setState(() {
                      _principalAmount = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(LanguageManager.translate('5K MIN', '5B MİN'), style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1))),
                  Text(LanguageManager.translate('250K MAX', '250B MAKS'), style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Term Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(LanguageManager.translate('Term Duration', 'Kredi Vadesi'), style: AppTextStyles.bodyLg(color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B), // surface-container-low
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF353535)),
                ),
                child: Row(
                  children: ['12M', '24M', '36M', '60M'].map((term) {
                    final isSelected = _selectedTerm == term;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedTerm = term;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFCCFF00) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFCCFF00).withValues(alpha: 0.2),
                                      blurRadius: 10,
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            term,
                            style: AppTextStyles.labelMd(
                              color: isSelected ? Colors.black : const Color(0xFFA1A1A1),
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Summary Data Chips
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = (constraints.maxWidth - 16) / 2;
              const double cardHeight = 80.0;
              final double summaryAspectRatio = cardWidth / cardHeight;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: summaryAspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDataChip(LanguageManager.translate('Interest Rate', 'Faiz Oranı'), '${aprRate.toStringAsFixed(1)}% APR'),
                  _buildDataChip(LanguageManager.translate('Est. Payment', 'Tahmini Ödeme'), getEstPayment(), highlight: true),
                  _buildDataChip(LanguageManager.translate('Origination Fee', 'Tahsis Ücreti'), '0.50%'),
                  _buildDataChip(LanguageManager.translate('Collateral Req.', 'Teminat Gereksinimi'), LanguageManager.translate('None', 'Yok')),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Action Area
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF353535))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LanguageManager.translate('By applying, you agree to the Terms of Service and authorize a hard credit inquiry.', 'Başvurarak, Hizmet Koşullarını kabul etmiş ve resmi kredi sorgulamasına izin vermiş olursunuz.'),
                    style: const TextStyle(color: Color(0xFFA1A1A1), fontSize: 12, height: 1.5),
                  ),
                ),
                const SizedBox(width: 16),
                _isSubmitting
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
                      )
                    : GestureDetector(
                        onTap: _submitApplication,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFF00),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCCFF00).withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                LanguageManager.translate('Apply Now', 'Şimdi Başvur'),
                                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                            ],
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

  Widget _buildDataChip(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E), // surface-dim
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1))),
          const SizedBox(height: 4),
          Text(
            value,
            style: highlight
                ? AppTextStyles.labelMd(color: const Color(0xFFCCFF00)).copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.labelMd(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ── Custom Gauge Painter for Credit Score ────────────────────────────────────
class _CreditScoreGaugePainter extends CustomPainter {
  _CreditScoreGaugePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = const Color(0xFFCCFF00) // primary-container / elite-neon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Background semi-circle track
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    // Active progress arc
    canvas.drawArc(rect, math.pi, math.pi * progress, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _CreditScoreGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
