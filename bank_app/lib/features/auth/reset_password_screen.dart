import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

enum PasswordStrength { none, weak, fair, good, strong }

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  // ── Form State ────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _passFocused = false;
  bool _confirmFocused = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  bool _updateHovered = false;
  bool _updatePressed = false;

  PasswordStrength _strength = PasswordStrength.none;

  // ── Entrance Animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _staggerCount = 6;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _passFocus.addListener(() => setState(() => _passFocused = _passFocus.hasFocus));
    _confirmFocus.addListener(() => setState(() => _confirmFocused = _confirmFocus.hasFocus));

    // Listen to password field changes to dynamically evaluate strength
    _passCtrl.addListener(() {
      final strength = _evaluateStrength(_passCtrl.text);
      if (strength != _strength) {
        setState(() {
          _strength = strength;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  PasswordStrength _evaluateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 4) return PasswordStrength.weak;

    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(password) || RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score == 2) return PasswordStrength.fair;
    if (score == 3) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) => FadeTransition(
        opacity: _fadeAnims[index],
        child: SlideTransition(position: _slideAnims[index], child: child),
      );

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      setState(() {
        _isLoading = true;
      });

      // Simulate password update API delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1F1F1F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.primaryFixed, size: 18),
                const SizedBox(width: 10),
                Text(
                  LanguageManager.translate(
                    'Password reset successfully! Please login with your new password.',
                    'Şifre başarıyla sıfırlandı! Lütfen yeni şifrenizle giriş yapın.',
                  ),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                ),
              ],
            ),
          ),
        );

        // Pop all back to login
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Radial background glow ──────────────────────────────────────────
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
                    AppColors.primaryFixed.withValues(alpha: 0.04),
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

          // ── Content ────────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C), // cardBg
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)), // outline
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient top border decoration
          _buildTopGradientBorder(),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Reset
                  _staggered(0, _buildIconBox()),
                  const SizedBox(height: 20),

                  // Title
                  _staggered(1, _buildTitle()),
                  const SizedBox(height: 8),

                  // Subtitle
                  _staggered(2, _buildSubtitle()),
                  const SizedBox(height: 28),

                  // New Password Field
                  _staggered(3, _buildNewPasswordField()),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  _staggered(4, _buildConfirmPasswordField()),
                  const SizedBox(height: 24),

                  // Action Button
                  _staggered(5, _buildSubmitButton()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            Color(0x4DCCFF00), // lime green at ~30%
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox() {
    return Align(
      alignment: Alignment.centerLeft,
      child: const Icon(
        Icons.lock_reset_rounded,
        color: AppColors.primaryFixed,
        size: 40,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      LanguageManager.translate('Reset Password', 'Şifreyi Sıfırla'),
      style: AppTextStyles.headlineLg(),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      LanguageManager.translate('Enter a new secure password for your account.', 'Hesabınız için yeni ve güvenli bir şifre girin.'),
      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
    );
  }

  // ── New Password Field ─────────────────────────────────────────────────────
  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageManager.translate('New Password', 'Yeni Şifre'),
          style: AppTextStyles.labelMd(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _passFocused ? AppColors.primaryFixed : const Color(0xFF333333),
              width: _passFocused ? 1.5 : 1.0,
            ),
            boxShadow: _passFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryFixed.withValues(alpha: 0.15),
                      blurRadius: 8,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.vpn_key_outlined, size: 20, color: Color(0xFFA1A1A1)),
              ),
              Expanded(
                child: TextFormField(
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.labelSm(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: LanguageManager.translate('Enter new password', 'Yeni şifre girin'),
                    hintStyle: AppTextStyles.labelSm(color: const Color(0xFF474746)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? LanguageManager.translate('Password must be at least 6 characters', 'Şifre en az 6 karakter olmalıdır')
                      : null,
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFFA1A1A1),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Strength bars
        _buildStrengthIndicator(),
      ],
    );
  }

  // ── Confirm Password Field ─────────────────────────────────────────────────
  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageManager.translate('Confirm New Password', 'Yeni Şifreyi Onayla'),
          style: AppTextStyles.labelMd(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _confirmFocused ? AppColors.primaryFixed : const Color(0xFF333333),
              width: _confirmFocused ? 1.5 : 1.0,
            ),
            boxShadow: _confirmFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryFixed.withValues(alpha: 0.15),
                      blurRadius: 8,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFFA1A1A1)),
              ),
              Expanded(
                child: TextFormField(
                  controller: _confirmCtrl,
                  focusNode: _confirmFocus,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.labelSm(color: Colors.white),
                  onFieldSubmitted: (_) => _onSubmit(),
                  decoration: InputDecoration(
                    hintText: LanguageManager.translate('Confirm new password', 'Yeni şifreyi onaylayın'),
                    hintStyle: AppTextStyles.labelSm(color: const Color(0xFF474746)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return LanguageManager.translate('Please confirm your password', 'Lütfen şifrenizi onaylayın');
                    if (v != _passCtrl.text) return LanguageManager.translate('Passwords do not match', 'Şifreler eşleşmiyor');
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFFA1A1A1),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Password Strength UI ───────────────────────────────────────────────────
  Widget _buildStrengthIndicator() {
    int activeBars = 0;
    String label = '';
    Color labelColor = AppColors.onSurfaceVariant;

    switch (_strength) {
      case PasswordStrength.none:
        activeBars = 0;
        label = '';
        break;
      case PasswordStrength.weak:
        activeBars = 1;
        label = LanguageManager.translate('Weak', 'Zayıf');
        labelColor = AppColors.error;
        break;
      case PasswordStrength.fair:
        activeBars = 2;
        label = LanguageManager.translate('Fair', 'Orta');
        labelColor = AppColors.primaryFixed;
        break;
      case PasswordStrength.good:
        activeBars = 3;
        label = LanguageManager.translate('Good', 'İyi');
        labelColor = AppColors.primaryFixed;
        break;
      case PasswordStrength.strong:
        activeBars = 4;
        label = LanguageManager.translate('Strong', 'Güçlü');
        labelColor = AppColors.primaryFixed;
        break;
    }

    return Column(
      children: [
        Row(
          children: List.generate(4, (index) {
            final active = index < activeBars;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 2,
                  right: index == 3 ? 0 : 2,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? (labelColor)
                      : const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            );
          }),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              style: AppTextStyles.labelSm(color: labelColor).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]
      ],
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _updateHovered = true),
      onExit: (_) => setState(() => _updateHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _updatePressed = true),
        onTapUp: (_) {
          setState(() => _updatePressed = false);
          _onSubmit();
        },
        onTapCancel: () => setState(() => _updatePressed = false),
        child: AnimatedScale(
          scale: _updatePressed ? 0.98 : (_updateHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _updatePressed ? AppColors.primaryFixedDim : AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryFixed.withValues(
                    alpha: _updateHovered ? 0.20 : 0.10,
                  ),
                  blurRadius: _updateHovered ? 30 : 20,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  else ...[
                    Text(
                      LanguageManager.translate('Update Password', 'Şifreyi Güncelle'),
                      style: AppTextStyles.headlineMd(color: Colors.black).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
