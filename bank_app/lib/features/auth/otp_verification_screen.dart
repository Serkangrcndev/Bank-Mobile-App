import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  // ── OTP Input Fields ──────────────────────────────────────────────────────
  static const int _otpLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_otpLength, (_) => FocusNode());

  // ── States ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _backHovered = false;
  bool _verifyHovered = false;
  bool _verifyPressed = false;

  // ── Entrance Animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _staggerCount = 6;

  // ── Resend Code Counter ───────────────────────────────────────────────────
  int _timerSeconds = 30;
  bool _canResend = false;
  late final AnimationController _resendCtrl;

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

    // Start timer for resending OTP code
    _startResendTimer();

    // Listen to changes for auto focus redirection
    for (int i = 0; i < _otpLength; i++) {
      _controllers[i].addListener(() {
        final text = _controllers[i].text;
        if (text.length == 1) {
          if (i < _otpLength - 1) {
            _focusNodes[i + 1].requestFocus();
          } else {
            _focusNodes[i].unfocus();
          }
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  void _startResendTimer() {
    setState(() {
      _timerSeconds = 30;
      _canResend = false;
    });

    _resendCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _resendCtrl.addListener(() {
      final currentSec = 30 - (_resendCtrl.value * 30).floor();
      if (currentSec != _timerSeconds) {
        setState(() {
          _timerSeconds = currentSec;
        });
      }
    });

    _resendCtrl.forward().then((_) {
      setState(() {
        _canResend = true;
      });
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _resendCtrl.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _staggered(int index, Widget child) => FadeTransition(
        opacity: _fadeAnims[index],
        child: SlideTransition(position: _slideAnims[index], child: child),
      );

  // ── Clipboard Paste Action ────────────────────────────────────────────────
  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (text.length >= _otpLength) {
      HapticFeedback.mediumImpact();
      for (int i = 0; i < _otpLength; i++) {
        _controllers[i].text = text[i];
      }
      _focusNodes[_otpLength - 1].requestFocus();
    }
  }

  // ── Submission Action ─────────────────────────────────────────────────────
  void _onSubmit() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < _otpLength) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageManager.translate('Please enter a 6-digit code.', 'Lütfen 6 haneli kodu girin.')),
          backgroundColor: AppColors.surfaceContainerHigh,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    // Simulate API call for validation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Show success snackbar
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
                LanguageManager.translate('Identity verified successfully!', 'Kimlik başarıyla doğrulandı!'),
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
              ),
            ],
          ),
        ),
      );

      // Transition to ResetPasswordScreen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ResetPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  void _onResend() {
    if (!_canResend) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LanguageManager.translate('New verification code sent to your email.', 'Yeni doğrulama kodu e-postanıza gönderildi.')),
        backgroundColor: AppColors.surfaceContainerHigh,
      ),
    );
    _startResendTimer();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button header
                _staggered(0, _buildBackButton()),

                // Main card
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  // ── Back Button ────────────────────────────────────────────────────────────
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
            AnimatedSlide(
              offset: _backHovered ? const Offset(-0.25, 0) : Offset.zero,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _backHovered ? AppColors.primary : AppColors.secondary,
                  fontSize: 20,
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.labelMd(
                color: _backHovered ? AppColors.primary : AppColors.secondary,
              ).copyWith(letterSpacing: 2.0),
              child: Text(LanguageManager.translate('BACK', 'GERİ')),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Bento Card ────────────────────────────────────────────────────────
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon Box
                    _staggered(1, _buildIconBox()),
                    const SizedBox(height: 20),

                    // Title
                    _staggered(2, _buildTitle()),
                    const SizedBox(height: 8),

                    // Subtitle & Email info
                    _staggered(3, _buildSubtitle()),
                    const SizedBox(height: 24),

                    // OTP Inputs Box
                    _staggered(4, _buildOtpInputs()),
                    const SizedBox(height: 20),

                    // Resend trigger
                    _staggered(4, _buildResendRow()),
                    const SizedBox(height: 24),

                    // Submit Button
                    _staggered(5, _buildSubmitButton()),
                  ],
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
                  color: AppColors.primaryFixed,
                ),
                const SizedBox(width: 4),
                Text(
                  'SECURE_VERIFICATION',
                  style: AppTextStyles.labelSm(
                    color: AppColors.secondary,
                  ).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
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
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F), // surface-container
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF353535)),
        ),
        child: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.primaryFixed,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      LanguageManager.translate('Verify Identity', 'Kimliği Doğrula'),
      style: AppTextStyles.headlineXl(),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text(
          LanguageManager.translate('We sent a code to your email', 'E-posta adresinize bir kod gönderdik'),
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          style: AppTextStyles.labelSm(color: AppColors.primary.withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── OTP Fields Row ─────────────────────────────────────────────────────────
  Widget _buildOtpInputs() {
    return GestureDetector(
      onLongPress: _handlePaste, // Long press row to paste code from clipboard
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_otpLength, (index) {
          return Container(
            width: 48,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B), // surface-container-low
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _focusNodes[index].hasFocus
                    ? AppColors.primaryFixed
                    : const Color(0xFF353535),
                width: _focusNodes[index].hasFocus ? 1.5 : 1.0,
              ),
              boxShadow: _focusNodes[index].hasFocus
                  ? [
                      BoxShadow(
                        color: AppColors.primaryFixed.withValues(alpha: 0.15),
                        blurRadius: 8,
                      )
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: KeyboardListener(
              focusNode: FocusNode(), // Dummy key listener focus node
              onKeyEvent: (event) {
                // If Backspace is pressed and field is empty, move back
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    _controllers[index].text.isEmpty &&
                    index > 0) {
                  _controllers[index - 1].clear();
                  _focusNodes[index - 1].requestFocus();
                }
              },
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMd(color: AppColors.primary).copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  if (val.isEmpty && index > 0) {
                    // Handled by key listener too, but safe redundancy
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Resend Code Row ────────────────────────────────────────────────────────
  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LanguageManager.translate("Didn't receive code? ", "Kod gelmedi mi? "),
          style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
        ),
        GestureDetector(
          onTap: _canResend ? _onResend : null,
          child: Text(
            _canResend 
                ? LanguageManager.translate('Resend Code', 'Kodu Tekrar Gönder')
                : LanguageManager.translate('Resend in ${_timerSeconds}s', '$_timerSeconds sn içinde tekrar gönder'),
            style: AppTextStyles.labelSm(
              color: _canResend ? AppColors.primaryFixed : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ).copyWith(
              fontWeight: FontWeight.bold,
              decoration: _canResend ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  // ── Verify / Submit Button ─────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _verifyHovered = true),
      onExit: (_) => setState(() => _verifyHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _verifyPressed = true),
        onTapUp: (_) {
          setState(() => _verifyPressed = false);
          _onSubmit();
        },
        onTapCancel: () => setState(() => _verifyPressed = false),
        child: AnimatedScale(
          scale: _verifyPressed ? 0.98 : (_verifyHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _verifyPressed ? AppColors.primaryFixedDim : AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryFixed.withValues(
                    alpha: _verifyHovered ? 0.20 : 0.10,
                  ),
                  blurRadius: _verifyHovered ? 30 : 20,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        LanguageManager.translate('Verify', 'Doğrula'),
                        style: AppTextStyles.headlineMd(color: Colors.black).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
