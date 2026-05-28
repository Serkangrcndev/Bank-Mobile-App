import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';
import '../dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Login screen — pixel-faithful port of the Stitch HTML design.
///
/// Animations:
///   • Fade + slide-up entrance (header → form items staggered)
///   • Input focus: border pulses to [AppColors.brandLime], bg lightens
///   • Face ID button: lime glow expands on press
///   • Login button: scale 0.98 on press
///   • Passcode visibility: icon cross-fade
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Form state ──────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _emailFocused = false;
  bool _passFocused = false;
  bool _obscurePass = true;

  // ── Entrance animation ──────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  // ── FaceID glow ─────────────────────────────────────────────────────────
  bool _faceIdHovered = false;

  // ── Login button press ───────────────────────────────────────────────────
  bool _loginPressed = false;

  // Number of staggered items (logo, title, subtitle, email, pass, divider,
  // faceId, button, footer)
  static const int _itemCount = 9;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_itemCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_itemCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Focus listeners to trigger border animation
    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passFocus.addListener(() => setState(() => _passFocused = _passFocus.hasFocus));

    // Start entrance after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _emailController.dispose();
    _passController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _staggered(int index, Widget child) => FadeTransition(
        opacity: _fadeAnims[index],
        child: SlideTransition(position: _slideAnims[index], child: child),
      );

  void _onLoginTap() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo ─────────────────────────────────────────────
                    _staggered(0, _buildLogo()),
                    const SizedBox(height: 16),

                    // ── Title ─────────────────────────────────────────────
                    _staggered(1, _buildTitle()),
                    const SizedBox(height: 8),

                    // ── Subtitle ──────────────────────────────────────────
                    _staggered(2, _buildSubtitle()),
                    const SizedBox(height: 32),

                    // ── Email Field ───────────────────────────────────────
                    _staggered(3, _buildEmailField()),
                    const SizedBox(height: 16),

                    // ── Passcode Field ────────────────────────────────────
                    _staggered(4, _buildPasscodeField()),
                    const SizedBox(height: 4),

                    // ── Forgot link ───────────────────────────────────────
                    _staggered(4, _buildForgotLink()),
                    const SizedBox(height: 8),

                    // ── OR Divider ────────────────────────────────────────
                    _staggered(5, _buildDivider()),

                    // ── Face ID ───────────────────────────────────────────
                    _staggered(6, _buildFaceId()),
                    const SizedBox(height: 24),

                    // ── Login Button ──────────────────────────────────────
                    _staggered(7, _buildLoginButton()),
                    const SizedBox(height: 24),

                    // ── Footer ────────────────────────────────────────────
                    _staggered(8, _buildFooter()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Builders ─────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: const Icon(
          Icons.currency_exchange_rounded,
          size: 32,
          color: AppColors.brandLime,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      LanguageManager.translate('Welcome Back', 'Tekrar Hoş Geldiniz'),
      textAlign: TextAlign.center,
      style: AppTextStyles.headlineXl(),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      LanguageManager.translate(
        'Enter your credentials to access your terminal.',
        'Terminalinize erişmek için bilgilerinizi girin.'
      ),
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyMd(color: AppColors.textSecondary),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            LanguageManager.translate('Email Address', 'E-posta Adresi'),
            style: AppTextStyles.labelMd(color: AppColors.textSecondary),
          ),
        ),
        _AnimatedInputBorder(
          focused: _emailFocused,
          child: TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.bodyMd(),
            decoration: InputDecoration(
              hintText: 'terminal@fintech.io',
              hintStyle: AppTextStyles.bodyMd(color: AppColors.textMuted),
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
            validator: (v) =>
                (v == null || !v.contains('@')) ? LanguageManager.translate('Enter a valid email', 'Geçerli bir e-posta girin') : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPasscodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            LanguageManager.translate('Passcode', 'Şifre'),
            style: AppTextStyles.labelMd(color: AppColors.textSecondary),
          ),
        ),
        _AnimatedInputBorder(
          focused: _passFocused,
          child: TextFormField(
            controller: _passController,
            focusNode: _passFocus,
            obscureText: _obscurePass,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.labelMd().copyWith(
              letterSpacing: _obscurePass ? 6 : AppTextStyles.labelMd().letterSpacing,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: AppTextStyles.bodyMd(color: AppColors.textMuted),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              suffixIcon: _VisibilityToggle(
                obscure: _obscurePass,
                onTap: () => setState(() => _obscurePass = !_obscurePass),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? LanguageManager.translate('Enter at least 6 characters', 'En az 6 karakter girin') : null,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ForgotPasswordScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 6, right: 4),
          child: Text(
            LanguageManager.translate('Forgot passcode?', 'Şifrenizi mi unuttunuz?'),
            style: AppTextStyles.labelSm(color: AppColors.brandLime),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              LanguageManager.translate('OR', 'VEYA'),
              style: AppTextStyles.labelSm(color: AppColors.textMuted),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildFaceId() {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _faceIdHovered = true),
        onTapUp: (_) {
          setState(() => _faceIdHovered = false);
          HapticFeedback.mediumImpact();
        },
        onTapCancel: () => setState(() => _faceIdHovered = false),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _faceIdHovered
                      ? AppColors.brandLime
                      : AppColors.surfaceBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandLime.withAlpha(
                      _faceIdHovered ? 77 : 26, // 0.30 vs 0.10 opacity
                    ),
                    blurRadius: _faceIdHovered ? 25 : 15,
                    spreadRadius: _faceIdHovered ? 2 : 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                size: 32,
                color: AppColors.brandLime,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.labelSm(
                color: _faceIdHovered
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              child: const Text('Face ID'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _loginPressed = true),
      onTapUp: (_) {
        setState(() => _loginPressed = false);
        _onLoginTap();
      },
      onTapCancel: () => setState(() => _loginPressed = false),
      child: AnimatedScale(
        scale: _loginPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _loginPressed
                ? AppColors.brandLimeDim
                : AppColors.brandLime,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LanguageManager.translate('Login', 'Giriş Yap'),
                  style: AppTextStyles.headlineMd(
                    color: const Color(0xFF283500),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF283500),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LanguageManager.translate('New to the terminal? ', 'Terminalde yeni misiniz? '),
          style: AppTextStyles.bodyMd(color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RegisterScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
          child: Text(
            LanguageManager.translate('Create account', 'Hesap oluştur'),
            style: AppTextStyles.bodyMd().copyWith(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable Animated Input Border ──────────────────────────────────────────

class _AnimatedInputBorder extends StatelessWidget {
  const _AnimatedInputBorder({
    required this.focused,
    required this.child,
  });

  final bool focused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: focused
            ? const Color(0xFF131313)
            : const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.brandLime : AppColors.surfaceBorder,
          width: focused ? 1.5 : 1.0,
        ),
      ),
      child: child,
    );
  }
}

// ── Animated Visibility Toggle ───────────────────────────────────────────────

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({
    required this.obscure,
    required this.onTap,
  });

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
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
            size: 22,
          ),
        ),
      ),
    );
  }
}
