import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Forgot Password screen.
///
/// Animations:
///   • Back button: arrow icon slides left on hover/press
///   • Entrance: fade + slide-up staggered (icon → title → input → button)
///   • Email input: real-time validation — border + icon turn lime when
///     a valid email is detected (even before submit)
///   • Button: scale 1.02 on hover, 0.98 on press + lime glow shadow
///   • Card: subtle gradient highlight on top edge
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _emailFocus = FocusNode();

  bool _emailFocused = false;
  bool _emailValid = false;   // real-time validation flag
  bool _backHovered = false;
  bool _submitPressed = false;
  bool _submitHovered = false;

  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _itemCount = 6; // header, icon, title, subtitle, input, button

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnims = List.generate(_itemCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_itemCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _emailFocus.addListener(
        () => setState(() => _emailFocused = _emailFocus.hasFocus));

    _emailCtrl.addListener(() {
      final val = _emailCtrl.text;
      final valid = val.length > 5 && val.contains('@') && val.contains('.');
      if (valid != _emailValid) setState(() => _emailValid = valid);
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _staggered(int index, Widget child) => FadeTransition(
        opacity: _fadeAnims[index],
        child: SlideTransition(position: _slideAnims[index], child: child),
      );

  Color get _inputBorderColor {
    if (_emailValid) return AppColors.brandLime;
    if (_emailFocused) return AppColors.brandLime;
    return AppColors.surfaceBorder;
  }

  Color get _iconColor {
    if (_emailValid || _emailFocused) return AppColors.brandLime;
    return AppColors.textSecondary;
  }

  void _onSubmit() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: trigger password reset flow
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F1F1F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.brandLime, size: 18),
              const SizedBox(width: 10),
              Text(
                'Instructions sent to ${_emailCtrl.text}',
                style: AppTextStyles.labelMd(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background glow blob ─────────────────────────────────────────
          Positioned(
            top: -200,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandLime.withAlpha(8), // ~3% opacity
                    Colors.transparent,
                  ],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button header
                _staggered(0, _buildBackButton()),

                // Main content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: _buildCard(),
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

  // ── Back Button ───────────────────────────────────────────────────────────
  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _backHovered = true),
        onTapUp: (_) {
          setState(() => _backHovered = false);
          Navigator.of(context).pop();
        },
        onTapCancel: () => setState(() => _backHovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated sliding arrow
            AnimatedSlide(
              offset: _backHovered
                  ? const Offset(-0.25, 0)
                  : Offset.zero,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _backHovered
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 20,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.labelMd(
                color: _backHovered
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ).copyWith(letterSpacing: 2.0),
              child: const Text('BACK TO LOGIN'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────
  Widget _buildCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E), // surface-container-lowest
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF353535)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(128),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient top border
              _buildTopGradientBorder(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      _staggered(1, _buildIconBox()),
                      const SizedBox(height: 16),

                      // Title
                      _staggered(2, _buildTitle()),
                      const SizedBox(height: 8),

                      // Subtitle
                      _staggered(3, _buildSubtitle()),
                      const SizedBox(height: 24),

                      // Email input
                      _staggered(4, _buildEmailInput()),
                      const SizedBox(height: 16),

                      // Submit button
                      _staggered(5, _buildSubmitButton()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // SECURE_SYS_V2 decoration chip (bottom-right)
        Positioned(
          bottom: 12,
          right: 16,
          child: Opacity(
            opacity: 0.30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: AppColors.brandLime,
                ),
                const SizedBox(width: 4),
                Text(
                  'SECURE_SYS_V2',
                  style: AppTextStyles.labelSm(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Gradient top border ───────────────────────────────────────────────────
  Widget _buildTopGradientBorder() {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0x4DCCFF00), // brandLime at ~30%
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ── Icon box ──────────────────────────────────────────────────────────────
  Widget _buildIconBox() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        color: AppColors.brandLime,
        size: 26,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Forgot Password',
      style: AppTextStyles.headlineXl(),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Enter your email to receive reset instructions. Ensure you use the address linked to your account.',
      style: AppTextStyles.bodyMd(color: AppColors.textSecondary),
    );
  }

  // ── Email Input ───────────────────────────────────────────────────────────
  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL ADDRESS',
          style: AppTextStyles.labelSm(color: AppColors.textSecondary)
              .copyWith(letterSpacing: 1.5),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _emailFocused || _emailValid
                ? const Color(0xFF1B1B1B)
                : const Color(0xFF1B1B1B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _inputBorderColor,
              width: (_emailFocused || _emailValid) ? 1.5 : 1.0,
            ),
            boxShadow: (_emailFocused || _emailValid)
                ? [
                    BoxShadow(
                      color: AppColors.brandLime.withAlpha(20),
                      blurRadius: 8,
                      spreadRadius: 0,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    key: ValueKey(_emailValid || _emailFocused),
                    size: 20,
                    color: _iconColor,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyMd(),
                  onFieldSubmitted: (_) => _onSubmit(),
                  decoration: InputDecoration(
                    hintText: 'name@domain.com',
                    hintStyle: AppTextStyles.bodyMd(
                        color: const Color(0xFF353535)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                  ),
                  validator: (v) => (v == null ||
                          v.length < 5 ||
                          !v.contains('@'))
                      ? 'Enter a valid email address'
                      : null,
                ),
              ),
              // Valid check indicator
              if (_emailValid)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedOpacity(
                    opacity: _emailValid ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.brandLime,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _submitHovered = true),
      onExit: (_) => setState(() => _submitHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _submitPressed = true),
        onTapUp: (_) {
          setState(() => _submitPressed = false);
          _onSubmit();
        },
        onTapCancel: () => setState(() => _submitPressed = false),
        child: AnimatedScale(
          scale: _submitPressed ? 0.98 : (_submitHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _submitPressed
                  ? AppColors.brandLimeDim
                  : AppColors.brandLime,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandLime.withAlpha(
                    _submitHovered ? 51 : 26, // 0.20 vs 0.10
                  ),
                  blurRadius: _submitHovered ? 30 : 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Send Instructions',
                    style: AppTextStyles.headlineMd(
                      color: const Color(0xFF161E00),
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF161E00),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
