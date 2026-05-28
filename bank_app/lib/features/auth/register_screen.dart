import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';

/// Register / Sign Up screen — glassmorphism card with animated inputs.
///
/// Animations:
///   • Radial lime glow blob (top-right) — static decorative
///   • Staggered fade + slide-up entrance (header → fields → button)
///   • Input focus: border + label + icon all pulse to [AppColors.brandLime]
///   • Sign Up button: scale 0.98 on press
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _nameFocused = false;
  bool _emailFocused = false;
  bool _phoneFocused = false;
  bool _passFocused = false;
  bool _obscurePass = true;
  bool _submitPressed = false;

  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _itemCount = 8; // title, subtitle, 4 fields, button, footer

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_itemCount, (i) {
      final start = i * 0.07;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_itemCount, (i) {
      final start = i * 0.07;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _nameFocus.addListener(() => setState(() => _nameFocused = _nameFocus.hasFocus));
    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _phoneFocus.addListener(() => setState(() => _phoneFocused = _phoneFocus.hasFocus));
    _passFocus.addListener(() => setState(() => _passFocused = _passFocus.hasFocus));

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _staggered(int index, Widget child) => FadeTransition(
        opacity: _fadeAnims[index],
        child: SlideTransition(position: _slideAnims[index], child: child),
      );

  void _onSubmit() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: navigate to next onboarding step
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        children: [
          // ── Background glow blob (top-right)
          _buildGlowBlob(),

          // ── Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title: FINTECH ELITE
                      _staggered(0, _buildBrandTitle()),
                      const SizedBox(height: 8),

                      // Subtitle: Create Account
                      _staggered(1, _buildSubtitle()),
                      const SizedBox(height: 32),

                      // Glass card
                      _buildGlassCard(),
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

  // ── Background Glow Blob ──────────────────────────────────────────────────
  Widget _buildGlowBlob() {
    return Positioned(
      top: -100,
      right: -80,
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.brandLime.withAlpha(13), // ~5% opacity
              Colors.transparent,
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildBrandTitle() {
    return Text(
      'FINTECH ELITE',
      textAlign: TextAlign.center,
      style: AppTextStyles.headlineXl().copyWith(
        letterSpacing: -1.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      LanguageManager.translate('Create Account', 'Hesap Oluştur'),
      textAlign: TextAlign.center,
      style: AppTextStyles.headlineLgMobile(
        color: const Color(0xFFE2E2E2),
      ),
    );
  }

  // ── Glass Card ────────────────────────────────────────────────────────────
  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x800C0C0C), // rgba(12,12,12,0.8)
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(102),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full Name
                _staggered(
                  2,
                  _buildField(
                    label: LanguageManager.translate('Full Name', 'Ad Soyad'),
                    hint: 'John Doe',
                    icon: Icons.person_outline_rounded,
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    focused: _nameFocused,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? LanguageManager.translate('Enter your name', 'Adınızı girin') : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Email
                _staggered(
                  3,
                  _buildField(
                    label: LanguageManager.translate('Email Address', 'E-posta Adresi'),
                    hint: 'john@example.com',
                    icon: Icons.mail_outline_rounded,
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    focused: _emailFocused,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? LanguageManager.translate('Enter a valid email', 'Geçerli bir e-posta girin') : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Phone
                _staggered(
                  4,
                  _buildField(
                    label: LanguageManager.translate('Phone Number', 'Telefon Numarası'),
                    hint: '+1 (555) 000-0000',
                    icon: Icons.call_outlined,
                    controller: _phoneCtrl,
                    focusNode: _phoneFocus,
                    focused: _phoneFocused,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    useMonoFont: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? LanguageManager.translate('Enter a valid phone', 'Geçerli bir telefon numarası girin') : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                _staggered(
                  5,
                  _buildField(
                    label: LanguageManager.translate('Password', 'Şifre'),
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    focused: _passFocused,
                    obscureText: _obscurePass,
                    textInputAction: TextInputAction.done,
                    suffixIcon: _VisibilityToggle(
                      obscure: _obscurePass,
                      onTap: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? LanguageManager.translate('Min. 6 characters', 'En az 6 karakter') : null,
                  ),
                ),
                const SizedBox(height: 28),

                // Submit button
                _staggered(6, _buildSubmitButton()),
                const SizedBox(height: 20),

                // Footer
                _staggered(7, _buildFooter()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Animated Field ────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool focused,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    bool useMonoFont = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final activeColor = AppColors.brandLime;
    final inactiveColor = AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTextStyles.labelMd(
            color: focused ? activeColor : inactiveColor,
          ),
          child: Text(label),
        ),
        const SizedBox(height: 4),

        // Animated border container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: focused ? activeColor : AppColors.surfaceBorder,
              width: focused ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              // Animated icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key: ValueKey(focused),
                  size: 20,
                  color: focused ? activeColor : inactiveColor,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  obscureText: obscureText,
                  style: useMonoFont
                      ? AppTextStyles.labelMd()
                      : AppTextStyles.bodyMd(),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMd(
                        color: const Color(0xFF353535)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 8),
                    suffixIcon: suffixIcon,
                  ),
                  validator: validator,
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _submitPressed = true),
      onTapUp: (_) {
        setState(() => _submitPressed = false);
        _onSubmit();
      },
      onTapCancel: () => setState(() => _submitPressed = false),
      child: AnimatedScale(
        scale: _submitPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _submitPressed
                ? AppColors.brandLimeDim
                : AppColors.brandLime,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LanguageManager.translate('Sign Up', 'Kayıt Ol'),
                  style: AppTextStyles.headlineMd(
                    color: Colors.black,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LanguageManager.translate('Already have an account? ', 'Zaten bir hesabınız var mı? '),
          style: AppTextStyles.bodyMd(color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            LanguageManager.translate('Login', 'Giriş Yap'),
            style: AppTextStyles.bodyMd(color: AppColors.brandLime).copyWith(
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Visibility Toggle ─────────────────────────────────────────────────────────
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscure, required this.onTap});
  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            key: ValueKey(obscure),
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
