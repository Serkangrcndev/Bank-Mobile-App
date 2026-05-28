import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../notifications/notifications_screen.dart';
import '../../settings/settings_screen.dart';
import '../../auth/login_screen.dart';
import '../../support/support_screen.dart';
import '../../kyc/kyc_verification_screen.dart';

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
  static const int _sectionCount = 4;

  @override
  void initState() {
    super.initState();

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
      return Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int i, Widget child) => FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  void _navigateToSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSupport() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SupportScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToKyc() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const KycVerificationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _handleSignOut() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: AppTextStyles.headlineMd()),
        content: Text(
          'Are you sure you want to log out of your elite session?',
          style: AppTextStyles.bodyMd(color: AppColors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.labelMd(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
                (route) => false,
              );
            },
            child: Text('Sign Out', style: AppTextStyles.labelMd(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Background Glows ──────────────────────────────────────────────────
        Positioned(
          top: -100,
          left: -100,
          width: 350,
          height: 350,
          child: _AmbientGlow(
            color: AppColors.primaryFixed.withValues(alpha: 0.08),
            delay: Duration.zero,
          ),
        ),
        Positioned(
          bottom: 150,
          right: -100,
          width: 300,
          height: 300,
          child: _AmbientGlow(
            color: AppColors.primaryFixed.withValues(alpha: 0.04),
            delay: const Duration(seconds: 2),
          ),
        ),

        // ── Main Content Scroll View ──────────────────────────────────────────
        CustomScrollView(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // 1. Profile Header Section
                    _staggered(0, _buildHeaderSection()),
                    const SizedBox(height: 24),

                    // 2. Account Tier Card
                    _staggered(1, _buildTierCard()),
                    const SizedBox(height: 28),

                    // 3. Preferences Section
                    _staggered(2, _buildPreferencesSection()),
                    const SizedBox(height: 24),

                    // 4. Logout Button
                    _staggered(3, _LogoutButton(onTap: _handleSignOut)),

                    // Bottom padding to clear the persistent navbar
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Profile Header Section ──────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    return Column(
      children: [
        _PulsingAvatar(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA3UtoRTSa6Su4JWkXG0dbxPsSeozWnlnWkhTCg8HSRqT7dM5r6wEfK3uetKxhucYkj1KW7GgShkMcLaugIqvsbtKEDr2CoyH6AMBaGBbSFvVoNC9MytOVJG0j8brK0SNPTD-1NCh4mKG92oJb8UiepleNxkrCbH-Bb-T6SFabkZ-kYTMGz6Arip-wkSsHiNbLqP7OuRQOTQilhqhJFnUC19px0uIdLdsy-gypFiXLV1AmJPyCcMgw3_i8ovIEMKdGyV-oFR0qztHMm',
          onEditTap: () {
            HapticFeedback.selectionClick();
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Alex Mercer',
          style: AppTextStyles.headlineLgMobile(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Elite Member Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.surfaceContainerHighest),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primaryFixed,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'ELITE MEMBER',
                style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Account Tier Glassmorphic Card ──────────────────────────────────────────
  Widget _buildTierCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: AppColors.primaryFixed.withValues(alpha: 0.05),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              // Radial blur inside card
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryFixed.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT TIER',
                            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6))
                                .copyWith(letterSpacing: 1.0, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Volume Alpha',
                            style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.diamond_rounded,
                          color: AppColors.primaryFixed,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Progress Bar Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trading Fee Discount',
                            style: AppTextStyles.labelSm(color: AppColors.secondary).copyWith(fontSize: 12),
                          ),
                          Text(
                            '45%',
                            style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Custom drawn progress bar
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.45,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryFixed.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Next Tier
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Next Tier: Omega',
                        style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8)).copyWith(fontSize: 12),
                      ),
                      Text(
                        '\$124K Vol Required',
                        style: AppTextStyles.labelSm(color: AppColors.primary.withValues(alpha: 0.9)).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Preferences Section ─────────────────────────────────────────────────────
  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'PREFERENCES',
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PreferenceTile(
          icon: Icons.person_outline_rounded,
          title: 'Personal Information',
          subtitle: 'Update identity & contact details',
          onTap: _navigateToSettings,
        ),
        const SizedBox(height: 8),
        _PreferenceTile(
          icon: Icons.verified_user_outlined,
          title: 'Identity Verification',
          subtitle: 'KYC — Unlock premium trading features',
          onTap: _navigateToKyc,
        ),
        const SizedBox(height: 8),
        _PreferenceTile(
          icon: Icons.lock_outline_rounded,
          title: 'Security & Biometrics',
          subtitle: '2FA, Passkeys, Login history',
          onTap: _navigateToSettings,
        ),
        const SizedBox(height: 8),
        _PreferenceTile(
          icon: Icons.notifications_active_outlined,
          title: 'Notification Preferences',
          subtitle: 'Alerts, Marketing, Price updates',
          onTap: _navigateToSettings,
        ),
        const SizedBox(height: 8),
        _PreferenceTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQ, Contact Elite Desk',
          onTap: _navigateToSupport,
        ),
      ],
    );
  }
}

// ── Background Glow ──────────────────────────────────────────────────────────
class _AmbientGlow extends StatefulWidget {
  const _AmbientGlow({
    required this.color,
    required this.delay,
  });
  final Color color;
  final Duration delay;

  @override
  State<_AmbientGlow> createState() => _AmbientGlowState();
}

class _AmbientGlowState extends State<_AmbientGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0.7, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Pulsing Avatar Widget ────────────────────────────────────────────────────
class _PulsingAvatar extends StatefulWidget {
  const _PulsingAvatar({required this.imageUrl, required this.onEditTap});
  final String imageUrl;
  final VoidCallback onEditTap;

  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowVal = _glowAnimation.value;
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryFixed.withValues(alpha: 0.5 + 0.5 * glowVal),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryFixed.withValues(alpha: 0.15 + 0.15 * glowVal),
                blurRadius: 15 * glowVal,
                spreadRadius: 2 * glowVal,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(Icons.person, size: 40, color: AppColors.secondary),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: widget.onEditTap,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceContainerHighest,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Reusable Preferences Tile ────────────────────────────────────────────────
class _PreferenceTile extends StatefulWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_PreferenceTile> createState() => _PreferenceTileState();
}

class _PreferenceTileState extends State<_PreferenceTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.surfaceContainerHigh.withValues(alpha: 0.6)
                : AppColors.surfaceContainerLow.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed
                  ? AppColors.primaryFixed.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer.withValues(alpha: 0.6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable Logout Button ───────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.heavyImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _pressed ? AppColors.error.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed ? AppColors.error : AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'LOGOUT',
                style: AppTextStyles.labelMd(color: AppColors.error).copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting Shared Header Widgets ──────────────────────────────────────────
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
            color: _pressed ? AppColors.surfaceContainerHighest : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: AppColors.onSurfaceVariant, size: 24),
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
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
          ),
        );
      },
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
                color: _pressed ? AppColors.surfaceContainerHighest : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant, size: 24),
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
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
