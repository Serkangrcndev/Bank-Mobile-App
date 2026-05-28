import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// KYC Identity Verification Screen
/// Implements the "Identity Verification | FINTECH ELITE" HTML mockup.
class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen>
    with TickerProviderStateMixin {
  // ── Scan-line animation ────────────────────────────────────────────────────
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;

  // ── Entrance stagger ───────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 5;

  // ── Pulse for SYSTEM READY dot ─────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── Step state ─────────────────────────────────────────────────────────────
  int _currentStep = 0; // 0 = Documents, 1 = Biometric, 2 = Address

  // ── Hover / press for scanning area ───────────────────────────────────────
  bool _imageHovered = false;

  @override
  void initState() {
    super.initState();

    // Scan line: loops 0→1 over 3s
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );

    // Pulse for SYSTEM READY badge
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Entrance stagger
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
      return Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int i, Widget child) => FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  // ── Step label ─────────────────────────────────────────────────────────────
  static final List<_KycStep> _steps = [
    _KycStep(icon: Icons.description_outlined, label: 'DOCUMENTS'),
    _KycStep(icon: Icons.face_outlined, label: 'BIOMETRIC'),
    _KycStep(icon: Icons.location_on_outlined, label: 'ADDRESS'),
  ];

  // ── Navigate to next step (simulated) ─────────────────────────────────────
  void _onStartVerification() {
    HapticFeedback.mediumImpact();
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.primaryFixed, size: 18),
              const SizedBox(width: 10),
              Text(
                _currentStep == 1
                    ? 'Documents submitted — proceeding to Biometrics'
                    : 'Biometrics verified — proceeding to Address',
                style: AppTextStyles.labelMd(color: AppColors.primary),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // All done
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.verified, color: AppColors.primaryFixed, size: 22),
              const SizedBox(width: 8),
              Text('Verification Complete', style: AppTextStyles.headlineMd()),
            ],
          ),
          content: Text(
            'Your identity has been verified successfully. Premium trading features are now unlocked.',
            style: AppTextStyles.bodyMd(color: AppColors.secondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pop();
              },
              child: Text('Done', style: AppTextStyles.labelMd(color: AppColors.primaryFixed)),
            ),
          ],
        ),
      );
    }
  }

  // ── Step instructions per step ─────────────────────────────────────────────
  static const Map<int, _StepContent> _stepContents = {
    0: _StepContent(
      title: 'Document Setup',
      icon: Icons.verified_user,
      instructions: [
        _Instruction(
          title: 'Valid ID Card or Passport',
          subtitle: 'Ensure all four corners are visible in the frame.',
        ),
        _Instruction(
          title: 'High Resolution',
          subtitle: 'Text must be clear and readable without glare.',
        ),
      ],
    ),
    1: _StepContent(
      title: 'Biometric Scan',
      icon: Icons.face_retouching_natural,
      instructions: [
        _Instruction(
          title: 'Center Your Face',
          subtitle: 'Position your face within the circular guide.',
        ),
        _Instruction(
          title: 'Good Lighting',
          subtitle: 'Ensure your face is evenly lit with no shadows.',
        ),
      ],
    ),
    2: _StepContent(
      title: 'Address Proof',
      icon: Icons.home_work_outlined,
      instructions: [
        _Instruction(
          title: 'Utility Bill or Bank Statement',
          subtitle: 'Must be issued within the last 3 months.',
        ),
        _Instruction(
          title: 'Full Address Visible',
          subtitle: 'Your name and address must be clearly legible.',
        ),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final content = _stepContents[_currentStep]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background ambient glow ──────────────────────────────────────
          Positioned(
            top: -120,
            left: -80,
            width: 340,
            height: 340,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryFixed.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Main scaffold ────────────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ──────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                toolbarHeight: 64,
                surfaceTintColor: Colors.transparent,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 1, color: AppColors.surfaceContainerHighest),
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
                  'FINTECH ELITE',
                  style: AppTextStyles.headlineMd().copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                  ),
                ),
                centerTitle: true,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: AppColors.primary),
                      onPressed: () {},
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

                      // ── Section Header ─────────────────────────────────
                      _staggered(
                        0,
                        Column(
                          children: [
                            Text(
                              'Identity Verification',
                              style: AppTextStyles.headlineMd().copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete these steps to unlock premium trading features.',
                              style: AppTextStyles.bodyMd(color: AppColors.secondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Step indicator ─────────────────────────────────
                      _staggered(1, _buildStepper()),

                      const SizedBox(height: 28),

                      // ── Scanning area ──────────────────────────────────
                      _staggered(2, _buildScanningArea()),

                      const SizedBox(height: 24),

                      // ── Instructions card ──────────────────────────────
                      _staggered(3, _buildInstructionsCard(content)),

                      const SizedBox(height: 20),

                      // ── Action buttons ─────────────────────────────────
                      _staggered(
                        4,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Primary CTA
                            GestureDetector(
                              onTap: _onStartVerification,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryFixed.withValues(alpha: 0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentStep < 2 ? 'Start Verification' : 'Submit & Finish',
                                      style: AppTextStyles.labelMd(
                                        color: const Color(0xFF161E00),
                                      ).copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      _currentStep < 2
                                          ? Icons.arrow_forward_rounded
                                          : Icons.check_rounded,
                                      color: const Color(0xFF161E00),
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Secondary: Continue Later
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.surfaceContainerHighest,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Continue Later',
                                    style: AppTextStyles.bodyMd(color: AppColors.secondary)
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stepper ───────────────────────────────────────────────────────────────
  Widget _buildStepper() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Connecting line
        Positioned(
          left: 0,
          right: 0,
          top: 20,
          child: Container(height: 1, color: AppColors.surfaceContainerHighest),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_steps.length, (i) {
            final isActive = i == _currentStep;
            final isDone = i < _currentStep;
            return _buildStepNode(
              icon: isDone ? Icons.check_rounded : _steps[i].icon,
              label: _steps[i].label,
              isActive: isActive,
              isDone: isDone,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepNode({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    final Color bgColor = (isActive || isDone)
        ? AppColors.primaryFixed
        : AppColors.surfaceContainerHigh;
    final Color iconColor =
        (isActive || isDone) ? const Color(0xFF161E00) : AppColors.secondary;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: (!isActive && !isDone)
                ? Border.all(color: AppColors.surfaceContainerHighest)
                : null,
            boxShadow: (isActive || isDone)
                ? [
                    BoxShadow(
                      color: AppColors.primaryFixed.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.labelSm(
            color: (isActive || isDone)
                ? AppColors.primaryFixed
                : AppColors.secondary,
          ).copyWith(letterSpacing: 1.0),
        ),
      ],
    );
  }

  // ── Scanning Area ─────────────────────────────────────────────────────────
  Widget _buildScanningArea() {
    return MouseRegion(
      onEnter: (_) => setState(() => _imageHovered = true),
      onExit: (_) => setState(() => _imageHovered = false),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceContainerHighest),
            ),
            child: Stack(
              children: [
                // Background image with hover grayscale toggle
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _imageHovered ? 0.65 : 0.40,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        _imageHovered
                            ? _identityMatrix
                            : _grayscaleMatrix,
                      ),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDjkPkCqUqOSuDDf8fhoBf1Hsa5Ul07gWbb4Yf7XoXQhN5DK-XAqRA4W7rlSBLNTgqcw7uDgQ84QWcQQo9rdHZnOQHji73r1fynh7JcKvGIvtGhVyDo-UFVPRAIEERMQQy6IphvSqe8l0gdtcKCGKlHW1nhgJn1qW4JnTYNTPJiWR_x9Ixi69Vyh5PM6HTL2slcnUk6YfN61RJnAynZF6Qs5k21pI2i9uCUEQl6_-mdBesC2aMSV6WfdfVua9bZ-GzJSOvvHsaunSvO',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(Icons.document_scanner_outlined,
                              size: 64, color: AppColors.secondary),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Scan-line overlay ──────────────────────────────────
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boxH = constraints.maxHeight;
                      final boxW = constraints.maxWidth;

                      // Dashed frame (3/4 size, centered)
                      final frameW = boxW * 0.75;
                      final frameH = boxH * 0.75;
                      final frameLeft = (boxW - frameW) / 2;
                      final frameTop = (boxH - frameH) / 2;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Dashed border frame
                          Positioned(
                            left: frameLeft,
                            top: frameTop,
                            width: frameW,
                            height: frameH,
                            child: ClipRect(
                              child: Stack(
                                children: [
                                  // Dashed border
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.primaryFixed
                                            .withValues(alpha: 0.35),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  // Animated scan line
                                  AnimatedBuilder(
                                    animation: _scanAnim,
                                    builder: (_, _) {
                                      final opacity = _scanAnim.value < 0.05 || _scanAnim.value > 0.95
                                          ? (1.0 - ((_scanAnim.value - 0.5).abs() * 2 - 0.9).clamp(0.0, 1.0))
                                          : 1.0;
                                      return Positioned(
                                        top: _scanAnim.value * frameH - 1,
                                        left: 0,
                                        right: 0,
                                        child: Opacity(
                                          opacity: opacity.clamp(0.0, 1.0),
                                          child: Container(
                                            height: 2,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryFixed,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primaryFixed
                                                      .withValues(alpha: 0.8),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                                BoxShadow(
                                                  color: AppColors.primaryFixed
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 30,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Corner accent — top-left
                          Positioned(
                            left: frameLeft - 1,
                            top: frameTop - 1,
                            child: _CornerAccent(corner: Corner.topLeft),
                          ),
                          // Corner accent — top-right
                          Positioned(
                            right: frameLeft - 1,
                            top: frameTop - 1,
                            child: _CornerAccent(corner: Corner.topRight),
                          ),
                          // Corner accent — bottom-left
                          Positioned(
                            left: frameLeft - 1,
                            bottom: frameTop - 1,
                            child: _CornerAccent(corner: Corner.bottomLeft),
                          ),
                          // Corner accent — bottom-right
                          Positioned(
                            right: frameLeft - 1,
                            bottom: frameTop - 1,
                            child: _CornerAccent(corner: Corner.bottomRight),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // ── SYSTEM READY badge (top-left) ──────────────────────
                Positioned(
                  top: 12,
                  left: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E0E0E).withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primaryFixed.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, _) => Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryFixed
                                      .withValues(alpha: _pulseAnim.value),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'SYSTEM READY',
                              style: AppTextStyles.labelSm(
                                      color: AppColors.primaryFixed)
                                  .copyWith(
                                letterSpacing: 0.8,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── KYC_SECURE_V4.0 watermark (bottom-right) ──────────
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Text(
                    'KYC_SECURE_V4.0',
                    style: AppTextStyles.labelMd(
                            color: AppColors.secondary.withValues(alpha: 0.4))
                        .copyWith(
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Instructions glass card ───────────────────────────────────────────────
  Widget _buildInstructionsCard(_StepContent content) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: ClipRRect(
        key: ValueKey(_currentStep),
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C).withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header
                Row(
                  children: [
                    Icon(content.icon,
                        color: AppColors.primaryFixed, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      content.title,
                      style: AppTextStyles.headlineMd().copyWith(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Instruction items
                ...content.instructions.map(
                  (instr) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.primaryFixed, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                instr.title,
                                style: AppTextStyles.bodyMd(
                                    color: AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                instr.subtitle,
                                style: AppTextStyles.labelSm(
                                        color: AppColors.secondary)
                                    .copyWith(letterSpacing: 0.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Color matrices ────────────────────────────────────────────────────────
  static const List<double> _grayscaleMatrix = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  static const List<double> _identityMatrix = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

// ── Corner Accent Widget ────────────────────────────────────────────────────
enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerAccent extends StatelessWidget {
  const _CornerAccent({required this.corner});
  final Corner corner;

  @override
  Widget build(BuildContext context) {
    const size = 18.0;
    const thickness = 2.5;
    const color = AppColors.primaryFixed;

    final top = corner == Corner.topLeft || corner == Corner.topRight;
    final left = corner == Corner.topLeft || corner == Corner.bottomLeft;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          bottom: !top
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          left: left
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          right: !left
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
        ),
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────
class _KycStep {
  const _KycStep({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _Instruction {
  const _Instruction({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

class _StepContent {
  const _StepContent({
    required this.title,
    required this.icon,
    required this.instructions,
  });
  final String title;
  final IconData icon;
  final List<_Instruction> instructions;
}
