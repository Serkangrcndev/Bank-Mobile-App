import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';

class TransactionSuccessScreen extends StatefulWidget {
  const TransactionSuccessScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.recipient,
    required this.date,
    required this.referenceId,
    required this.transactionFee,
  });

  final String title;
  final String amount;
  final String recipient;
  final String date;
  final String referenceId;
  final String transactionFee;

  @override
  State<TransactionSuccessScreen> createState() => _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> with TickerProviderStateMixin {
  // Staggered entrance controllers
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _staggerCount = 4;

  // Checkmark draw controller
  late final AnimationController _checkmarkCtrl;
  late final Animation<double> _checkmarkAnim;

  // Pulse ring controller
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Trigger immediate heavy haptic impact for transaction success feedback
    HapticFeedback.heavyImpact();

    // Staggered Entrance Animations (900ms)
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Checkmark Drawing Animation
    _checkmarkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkmarkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkmarkCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Pulse Glow Animation for checkmark ring
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Start Animations
    _entranceCtrl.forward();
    _checkmarkCtrl.forward().then((_) {
      _pulseCtrl.repeat();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _checkmarkCtrl.dispose();
    _pulseCtrl.dispose();
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

  String _getSubtitle() {
    final titleLower = widget.title.toLowerCase();
    if (titleLower.contains('buy')) {
      return '${LanguageManager.translate('BOUGHT', 'ALINDI')} ${widget.recipient.toUpperCase()}';
    } else if (titleLower.contains('sell')) {
      return '${LanguageManager.translate('SOLD', 'SATILDI')} ${widget.recipient.toUpperCase()}';
    } else {
      return '${LanguageManager.translate('SENT TO', 'GÖNDERİLDİ:')} ${widget.recipient.toUpperCase()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // ── Decorative Center Background Glow Element
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
                      const Color(0xFFCCFF00).withValues(alpha: 0.05), // primary-container/5 i.e. 5% opacity
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Scrollable Content Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),

                      // 1. Success Circle Checkmark with Pulse Ring
                      _staggered(0, _buildSuccessCircle()),
                      const SizedBox(height: 32),

                      // 2. Headline & Subtitle & Amount
                      _staggered(1, _buildHeadline()),
                      const SizedBox(height: 32),

                      // 3. Central Glassmorphic Summary Card
                      _staggered(2, _buildSummaryCard()),
                      const SizedBox(height: 32),

                      // 4. Action Buttons
                      _staggered(3, _buildActionButtons()),
                      const SizedBox(height: 16),
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

  // ── Success Circle Widget with Pulsing Glow Ring ───────────────────────────
  Widget _buildSuccessCircle() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final glowVal = _pulseAnim.value;
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0C0C0C),
            border: Border.all(color: const Color(0xFFCCFF00), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCCFF00).withValues(alpha: 0.4 * (1.0 - glowVal)),
                blurRadius: 16 * glowVal,
                spreadRadius: 12 * glowVal,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: _CheckmarkPainter(_checkmarkAnim.value),
            ),
          ),
        );
      },
    );
  }

  // ── Headline & Subtitle Widget ─────────────────────────────────────────────
  Widget _buildHeadline() {
    return Column(
      children: [
        Text(
          widget.title,
          style: AppTextStyles.headlineLgMobile(color: Colors.white).copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getSubtitle(),
          style: AppTextStyles.labelMd(color: const Color(0xFFA1A1A1)).copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          widget.amount,
          style: AppTextStyles.headlineXl(color: Colors.white).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 40,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Central Glassmorphic Card Widget ───────────────────────────────────────
  Widget _buildSummaryCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0x661A1A1A), // rgba(26, 26, 26, 0.4)
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailRow(LanguageManager.translate('Date', 'Tarih'), widget.date),
              const Divider(color: Color(0xFF1A1A1A), height: 2),
              _buildDetailRow(LanguageManager.translate('Reference', 'Referans'), widget.referenceId, isMono: true),
              const Divider(color: Color(0xFF1A1A1A), height: 2),
              _buildDetailRow(LanguageManager.translate('Fee', 'Ücret'), widget.transactionFee),
              const Divider(color: Color(0xFF1A1A1A), height: 2),
              _buildNetworkRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)),
          ),
          Text(
            value,
            style: isMono 
                ? AppTextStyles.labelMd(color: Colors.white)
                : AppTextStyles.bodyMd(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LanguageManager.translate('Network', 'Ağ'),
            style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFCCFF00), // elite-neon
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LUMINA FAST',
                style: AppTextStyles.labelSm(color: Colors.white).copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action Buttons Widget ──────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Solid Shimmering 'Back to Dashboard' Button
        _ShimmerButton(
          label: LanguageManager.translate('Back to Dashboard', 'Panele Geri Dön'),
          onTap: () {
            // Navigate back to the dashboard home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        const SizedBox(height: 16),

        // Outlined Download Receipt Button
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFCCFF00)),
                const SizedBox(width: 12),
                Text(
                  LanguageManager.translate('Receipt downloaded successfully!', 'Dekont başarıyla indirildi!'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1B1B1B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF333333)),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCCFF00), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded, color: Color(0xFFCCFF00), size: 20),
            const SizedBox(width: 8),
            Text(
              LanguageManager.translate('Download Receipt', 'Dekontu İndir'),
              style: AppTextStyles.headlineMd(color: const Color(0xFFCCFF00)).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Painter to animate drawing the checkmark path ─────────────────────
class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCFF00) // elite-neon
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.22, size.height * 0.5);
    path.lineTo(size.width * 0.44, size.height * 0.72);
    path.lineTo(size.width * 0.78, size.height * 0.32);

    for (final PathMetric metric in path.computeMetrics()) {
      final extract = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extract, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) => oldDelegate.progress != progress;
}

// ── Custom Shimmer Button Widget ──────────────────────────────────────────────
class _ShimmerButton extends StatefulWidget {
  const _ShimmerButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onTap();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: const [
                  Color(0xFFCCFF00),
                  Color(0xFFE5FF80),
                  Color(0xFFCCFF00),
                ],
                stops: [
                  0.0,
                  _controller.value,
                  1.0,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: AppTextStyles.headlineMd(color: Colors.black).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
