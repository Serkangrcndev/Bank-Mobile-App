import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with TickerProviderStateMixin {
  // ── States ────────────────────────────────────────────────────────────────
  String _amountStr = '0.00';
  bool _isProcessing = false;
  bool _showSuccessCheck = false;

  // Recent contacts data
  final List<(_ContactItemType type, String name, String? image, String? initials)> _contacts = [
    (_ContactItemType.image, 'Elena R.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBi3hsQf2qKFGqT1FfIFAL_-FOG8uujO54ilmG2XTuiVKDzMkJI4HXNx5qRioPdBuemHcUVeweHHkDpWdxPSshjjtKSka17MnRs-BlSg3lGEbKIbBq7qn4-0bCB84yp3IRI16egXNig71Bp3ji-j0kAlFSiWzoa5SQxMXcagoUbJX7EdTIQZ5WGSxAudUV6v9KlIVLXZmxojqQE9N7nH_APn98vWnLdCjgCmccAPyOpGbCbPTwacc_U-0Yrb5ToEHxZG0Lp0LctiyfK', null),
    (_ContactItemType.image, 'Marcus T.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAPLKJdBipFznwgbCtOj1sAPyzVksiQUo0pOEqGW-ydHiuOIabC2vsnaaaJVlGsB6V8fCjVS0y96HSZufUdfZBaQZYHjYaSGegF-PiJdUP0PR90F1X2Wlk0IHwmNrAbJxCxuv2KBRE_ueIG-SYZt-06MxEcw-qWaapo5J39Ek2_TRfpmGauRBLAGFFoBYB3AOnKUhc9g0g5Hr2tYYJcKbRnm-J2RLN2hzMWSHZukMBRk8kEtjPElLVpQdBwBKAmPEDTMvOkUkJzur2g', null),
    (_ContactItemType.initials, 'Sarah J.', null, 'SJ'),
    (_ContactItemType.image, 'David W.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCRnNwNsQNGmCEw5PY6602GkMadkb70lMGY2bZpAciOPgIPiPzuoaOz6a61uuNqOG2OtDU3UbKzbP7sZ2ku63awUBKZnTYVWUfhmgP9-h0FXglsgm8fbMk_B-qrCSv2HwQJ9HsF4VSszRopxYyBJK-3ACzjc8cjw-K-Jv8f5tXJbiUYqe3ojMA7livyapnfMVVGFWKKG3RhObdasITk0SWcgU1-_Y0sPsTca7n0uvKqg0fTCB_qg4qL-pZpeVSEp5kVvqzp0POnPcBk', null),
  ];

  int _selectedContact = -1;

  // Staggered Entrance Animations
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _staggerCount = 5;

  // Amount scaling feedback
  double _amountScale = 1.0;

  // Success ripple animation controller
  late final AnimationController _rippleCtrl;
  late final Animation<double> _rippleScaleAnim;
  late final Animation<double> _rippleOpacityAnim;

  @override
  void initState() {
    super.initState();

    // Entrance animations
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Ripple success animation
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rippleScaleAnim = Tween<double>(begin: 0.8, end: 2.8).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );

    _rippleOpacityAnim = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) => FadeTransition(
        opacity: _fadeAnims[index],
        child: SlideTransition(position: _slideAnims[index], child: child),
      );

  // ── Keypad Press Logic ─────────────────────────────────────────────────────
  void _onKeyPress(String key) {
    if (_isProcessing) return;
    HapticFeedback.lightImpact();

    setState(() {
      _amountScale = 1.08;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _amountScale = 1.0);
      });

      if (_amountStr == '0.00') {
        if (key == '.') {
          _amountStr = '0.';
        } else {
          _amountStr = key;
        }
      } else {
        if (key == '.') {
          if (_amountStr.contains('.')) return;
          _amountStr += '.';
        } else {
          _amountStr += key;
        }
      }
    });
  }

  void _onBackspace() {
    if (_isProcessing) return;
    HapticFeedback.lightImpact();

    setState(() {
      _amountScale = 0.95;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _amountScale = 1.0);
      });

      if (_amountStr.length <= 1) {
        _amountStr = '0.00';
      } else {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        if (_amountStr == '0' || _amountStr.isEmpty) {
          _amountStr = '0.00';
        }
      }
    });
  }

  // ── Prestige Success Trigger ──────────────────────────────────────────────
  void _onConfirmTransfer() {
    if (_isProcessing || _amountStr == '0.00') return;

    HapticFeedback.heavyImpact();
    setState(() {
      _isProcessing = true;
    });

    // Start ripple
    _rippleCtrl.forward();

    // Simulating checking/validating transfer
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _showSuccessCheck = true;
        });
      }

      // Success feedback
      HapticFeedback.heavyImpact();

      // Navigate back with success flag after check finishes drawing
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          Navigator.of(context).pop(_amountStr);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        toolbarHeight: 64,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.surfaceContainerHighest,
          ),
        ),
        title: Text(
          'Send Money',
          style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Neon Glow behind amount
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [
                    AppColors.primaryFixed.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Area
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 300), // padding to clear custom keypad
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // 1. Amount Display Card
                _staggered(0, _buildAmountDisplayCard()),
                const SizedBox(height: 24),

                // 2. Search Bar Input
                _staggered(1, _buildSearchBar()),
                const SizedBox(height: 28),

                // 3. Recent Contacts horizontal list
                _staggered(2, _buildRecentContacts()),
                const SizedBox(height: 28),

                // 4. Source Account Card selector
                _staggered(3, _buildAccountSelector()),
              ],
            ),
          ),

          // ── Fixed Bottom Area (Keypad & Confirm Button) ─────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _staggered(4, _buildFixedBottomBar()),
          ),
        ],
      ),
    );
  }

  // ── Amount Display Card Widget ──────────────────────────────────────────────
  Widget _buildAmountDisplayCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0x661A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryFixed.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'AMOUNT TO SEND',
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withOpacity(0.6)).copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  r'$',
                  style: AppTextStyles.headlineXl(color: AppColors.primaryFixed).copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedScale(
                  scale: _amountScale,
                  duration: const Duration(milliseconds: 80),
                  child: Text(
                    _amountStr,
                    style: AppTextStyles.headlineXl(color: AppColors.primary).copyWith(
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.surfaceContainerHighest.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryFixed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'USD Balance: \$12,450.00',
                    style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.w600,
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

  // ── Search Bar Widget ──────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFocused ? AppColors.primaryFixed : AppColors.surfaceContainerHighest,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primaryFixed.withOpacity(0.08),
                          blurRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: isFocused ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 16),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: 'Name, @username, or phone',
                        hintStyle: TextStyle(color: Color(0xFF8E8E93), fontFamily: 'Inter', fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Recent Contacts Widget ─────────────────────────────────────────────────
  Widget _buildRecentContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'RECENT',
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withOpacity(0.6)).copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _contacts.length,
            itemBuilder: (context, i) {
              final (type, name, img, init) = _contacts[i];
              final isSelected = _selectedContact == i;

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedContact = isSelected ? -1 : i;
                    });
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainerHighest,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryFixed.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ]
                              : [],
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          clipBehavior: Clip.antiAlias,
                          child: type == _ContactItemType.image
                              ? Image.network(
                                  img!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.surfaceContainerHigh,
                                    alignment: Alignment.center,
                                    child: Text(
                                      name.substring(0, 1),
                                      style: AppTextStyles.headlineMd(color: AppColors.primary),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFF1A1A1A),
                                  alignment: Alignment.center,
                                  child: Text(
                                    init!,
                                    style: AppTextStyles.headlineMd(color: AppColors.primaryFixed).copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: AppTextStyles.labelSm(
                          color: isSelected ? AppColors.primaryFixed : AppColors.primary,
                        ).copyWith(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Account Selector Card Widget ───────────────────────────────────────────
  Widget _buildAccountSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            // Bank icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceContainerHighest),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: AppColors.primaryFixed,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Account details text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FROM ACCOUNT',
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withOpacity(0.5)).copyWith(
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Main Checking (...4920)',
                    style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.expand_more_rounded,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ── Custom Visual Fixed Keypad & Action Button ─────────────────────────────
  Widget _buildFixedBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black,
            Colors.black.withOpacity(0.95),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Number Pad Grid (3 x 4) ────────────────────────────────────────
          SizedBox(
            width: 300,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 16,
              children: [
                ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0'].map((digit) {
                  return InkWell(
                    onTap: () => _onKeyPress(digit),
                    borderRadius: BorderRadius.circular(999),
                    splashColor: AppColors.primaryFixed.withOpacity(0.1),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        digit,
                        style: AppTextStyles.headlineLgMobile(color: AppColors.primary).copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
                // Backspace button
                InkWell(
                  onTap: _onBackspace,
                  borderRadius: BorderRadius.circular(999),
                  splashColor: AppColors.primaryFixed.withOpacity(0.1),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.backspace_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Confirm Action Button with Prestige Success Animations ──────────
          GestureDetector(
            onTap: _onConfirmTransfer,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _showSuccessCheck
                        ? const Color(0xFFD8FF00) // success neon color
                        : AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _showSuccessCheck
                            ? const Color(0xFFD8FF00).withOpacity(0.8)
                            : AppColors.primaryFixed.withOpacity(0.2),
                        blurRadius: _showSuccessCheck ? 35 : 20,
                        spreadRadius: _showSuccessCheck ? 5 : 0,
                      ),
                    ],
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          height: 24,
                          child: _showSuccessCheck
                              ? _buildSuccessCheckmark()
                              : const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm Transfer',
                              style: AppTextStyles.headlineMd(color: Colors.black).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.black,
                              size: 18,
                            ),
                          ],
                        ),
                ),
                // 3D success ripple effect
                if (_isProcessing)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedBuilder(
                      animation: _rippleCtrl,
                      builder: (context, child) {
                        return Center(
                          child: Transform.scale(
                            scale: _rippleScaleAnim.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryFixed.withOpacity(_rippleOpacityAnim.value),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCheckmark() {
    return const Icon(
      Icons.check_rounded,
      color: Colors.black,
      size: 28,
    );
  }
}

enum _ContactItemType { image, initials }
