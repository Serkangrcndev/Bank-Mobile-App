import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with TickerProviderStateMixin {
  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 5;

  // ── Pulsing green dot animation ───────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── Form Controllers ──────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController(text: 'Alexander James Mercer');
  final _emailCtrl = TextEditingController(text: 'a.mercer@fintech-elite.io');
  final _phoneCtrl = TextEditingController(text: '555-019-8372');
  final _addressCtrl = TextEditingController(text: '4820 Skyline Blvd, Suite 400, Neo-SF, CA 94101');

  // ── Focus Nodes ───────────────────────────────────────────────────────────
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Entrance
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
      return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    // Pulse dot
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(_pulseCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Widget _staggered(int i, Widget child) => FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── TopAppBar
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.background,
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
            'FINTECH ELITE',
            style: AppTextStyles.headlineMd().copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -1.0,
            ),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => _AppBarIconButton(
              icon: Icons.menu_rounded,
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            _NotificationButton(),
            const SizedBox(width: 8),
          ],
        ),

        // ── Scrollable Bento Layout
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 1. Header & KYC Status Row
                _staggered(0, _buildHeaderSection()),
                const SizedBox(height: 24),

                // 2. Avatar Card (Left Bento Box 1)
                _staggered(1, _buildAvatarCard()),
                const SizedBox(height: 16),

                // 3. Security Card (Left Bento Box 2)
                _staggered(2, _buildSecurityCard()),
                const SizedBox(height: 24),

                // 4. Form Fields Card (Right Bento Box)
                _staggered(3, _buildFormCard()),
                const SizedBox(height: 24),

                // 5. Action Buttons (Save/Discard)
                _staggered(4, _buildActionButtons()),

                // Bottom padding to clear the persistent navbar
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Header & KYC Badge ─────────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Settings',
          style: AppTextStyles.headlineXl(),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your identity verification and contact details.',
          style: AppTextStyles.bodyMd(color: AppColors.secondary),
        ),
        const SizedBox(height: 16),

        // KYC Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: AppColors.primaryFixed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KYC STATUS',
                    style: AppTextStyles.labelSm(color: AppColors.primaryFixed)
                        .copyWith(letterSpacing: 1.5, height: 1.0),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Level 3 Verified',
                    style: AppTextStyles.bodyMd(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.bold, height: 1.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Avatar Card ────────────────────────────────────────────────────────────
  Widget _buildAvatarCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Positioned(
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withOpacity(0.08),
              ),
            ),
          ),

          // Main Column
          Column(
            children: [
              // Avatar Circle
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAjfg2sC30yWHJQL4PQVPqtdHnCL8sasuBTxJL4KturJOj4uYNnbyRlKujh87jJJTP4cra-5XcR9Ef5KHUbdLzVDN840b3WsMyzThWje6Nn8H7JFQ6lRLxEloyPircUOfXQTWnHS9WnDnqRRTBGVl5cwLNK_zLRLJ5dC_Wwnr671pxKwQIVu8CsXAROy86U7_sLpgOQ_bNPl0qojILbvTt5zGwEwppXLl5YIyx040wqjXrExbiHIxQotAHb-x-xAI2PHQfTIdj8QS-h',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.person, size: 48, color: AppColors.secondary),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                'Alex Mercer',
                style: AppTextStyles.headlineMd(color: AppColors.primary),
              ),
              const SizedBox(height: 6),

              // Active Badge with Pulsing dot
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _pulseAnim,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryFixed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE ACCOUNT',
                      style: AppTextStyles.labelSm(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Update Photo Button
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFF333333)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: Text(
                  'Update Photo',
                  style: AppTextStyles.labelMd(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Security Summary Card ──────────────────────────────────────────────────
  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'SECURITY',
                style: AppTextStyles.labelMd(color: AppColors.secondary)
                    .copyWith(letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF1A1A1A)),
          const SizedBox(height: 12),

          // 2FA Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2FA App',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Enabled',
                  style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Last Login Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last Login',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              Text(
                'Today, 08:42',
                style: AppTextStyles.labelSm(color: AppColors.secondary)
                    .copyWith(fontFamily: 'JetBrains Mono'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Identity Details Form Card ─────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primaryFixed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Identity Details',
                    style: AppTextStyles.headlineMd(color: AppColors.primary),
                  ),
                ],
              ),
              const Icon(
                Icons.edit_note_rounded,
                color: Color(0xFF333333),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Legal Full Name
          _StitchFormField(
            controller: _nameCtrl,
            focusNode: _nameFocus,
            labelText: 'Legal Full Name',
            hintText: 'Government ID Name',
            caption: 'Matches government ID',
          ),
          const SizedBox(height: 32),

          // Email
          _StitchFormField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            labelText: 'Primary Email',
            hintText: 'email@domain.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),

          // Mobile Number
          _StitchFormField(
            controller: _phoneCtrl,
            focusNode: _phoneFocus,
            labelText: 'Mobile Number',
            hintText: '555-019-8372',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),

          // Residential Address
          _StitchFormField(
            controller: _addressCtrl,
            focusNode: _addressFocus,
            labelText: 'Residential Address',
            hintText: 'Street, Suite, State, ZIP',
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A1A)),
        ),
      ),
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _nameCtrl.text = 'Alexander James Mercer';
                _emailCtrl.text = 'a.mercer@fintech-elite.io';
                _phoneCtrl.text = '555-019-8372';
                _addressCtrl.text = '4820 Skyline Blvd, Suite 400, Neo-SF, CA 94101';
              });
            },
            child: Text(
              'Discard Changes',
              style: AppTextStyles.labelMd(color: const Color(0xFFA1A1A1)),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile saved successfully!'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryFixed.withAlpha(38), // 15%
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Save Profile',
                style: AppTextStyles.headlineMd(color: const Color(0xFF000000))
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stitch Form Field with overlapping label ───────────────────────────────
class _StitchFormField extends StatefulWidget {
  const _StitchFormField({
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.hintText,
    this.caption,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String hintText;
  final String? caption;
  final TextInputType keyboardType;

  @override
  State<_StitchFormField> createState() => _StitchFormFieldState();
}

class _StitchFormFieldState extends State<_StitchFormField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _isFocused ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isFocused ? AppColors.primaryFixed : const Color(0xFF333333),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  if (widget.keyboardType == TextInputType.phone)
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        border: Border(
                          right: BorderSide(
                            color: _isFocused ? AppColors.primaryFixed : const Color(0xFF333333),
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+1',
                        style: AppTextStyles.labelMd(color: AppColors.secondary),
                      ),
                    ),
                  Expanded(
                    child: TextFormField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      keyboardType: widget.keyboardType,
                      style: widget.keyboardType == TextInputType.phone
                          ? AppTextStyles.labelMd(color: AppColors.primary).copyWith(fontFamily: 'JetBrains Mono')
                          : (widget.labelText == 'Legal Full Name'
                              ? AppTextStyles.bodyLg(color: AppColors.primary)
                              : AppTextStyles.bodyMd(color: AppColors.primary)),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: AppTextStyles.bodyMd(color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              top: -8,
              child: Container(
                color: AppColors.cardBg,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.labelText,
                  style: AppTextStyles.labelSm(
                    color: _isFocused ? AppColors.primaryFixed : AppColors.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.caption != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF474746)),
              const SizedBox(width: 4),
              Text(
                widget.caption!,
                style: AppTextStyles.labelSm(color: const Color(0xFF474746)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Reusable Local Widgets ───────────────────────────────────────────────────

class _AppBarIconButton extends StatefulWidget {
  const _AppBarIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_AppBarIconButton> createState() => _AppBarIconButtonState();
}

class _AppBarIconButtonState extends State<_AppBarIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.surfaceContainerHighest
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon,
              color: AppColors.onSurfaceVariant, size: 24),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatefulWidget {
  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _pressed
                    ? AppColors.surfaceContainerHighest
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.onSurfaceVariant, size: 24),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
