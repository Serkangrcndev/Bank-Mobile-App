import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 5;

  // ── Preferences State ─────────────────────────────────────────────────────
  bool _biometricEnabled = true;
  bool _pushNotificationsEnabled = true;
  bool _darkThemeEnabled = true;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.10;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.10;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
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

  void _showChangePasswordDialog() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Password', style: AppTextStyles.headlineMd()),
            const SizedBox(height: 8),
            Text(
              'A password reset link will be sent to your primary email address: a.mercer@fintech-elite.io',
              style: AppTextStyles.bodyMd(color: AppColors.secondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: AppTextStyles.labelMd(color: AppColors.secondary)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent!'),
                        backgroundColor: AppColors.surfaceContainerHigh,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryFixed,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Send Link', style: AppTextStyles.labelMd(color: Colors.black).copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignOut() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
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
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
        leading: _AppBarIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
        actions: [
          _NotificationButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _staggered(0, _buildHeaderSection()),
            const SizedBox(height: 32),

            // Bento Content Column (or Row on large tablets, but stacked for mobile layout)
            Column(
              children: [
                // 1. Account Security
                _staggered(1, _buildSecuritySection()),
                const SizedBox(height: 24),

                // 2. Payment Settings
                _staggered(2, _buildPaymentSection()),
                const SizedBox(height: 24),

                // 3. App Preferences
                _staggered(3, _buildPreferencesSection()),
                const SizedBox(height: 24),

                // 4. Legal & Support
                _staggered(4, _buildLegalSection()),
                const SizedBox(height: 32),

                // Sign Out Button
                _staggered(
                  4,
                  OutlinedButton(
                    onPressed: _handleSignOut,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: AppColors.error,
                    ),
                    child: Text(
                      'Sign Out',
                      style: AppTextStyles.headlineMd(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.headlineXl()),
              const SizedBox(height: 4),
              Text(
                'Manage your elite account preferences.',
                style: AppTextStyles.bodyMd(color: AppColors.secondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primaryFixed,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Elite Member',
                style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _GlassPanel(
      child: Column(
        children: [
          const _SectionHeader(title: 'Account Security'),
          _SettingsTile(
            icon: Icons.password_rounded,
            title: 'Change Password',
            onTap: _showChangePasswordDialog,
          ),
          _SettingsTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Login',
            trailing: _StitchSwitch(
              value: _biometricEnabled,
              onChanged: (val) => setState(() => _biometricEnabled = val),
            ),
            onTap: () => setState(() => _biometricEnabled = !_biometricEnabled),
          ),
          _SettingsTile(
            icon: Icons.verified_user_rounded,
            title: 'Two-Factor Authentication',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'Enabled',
                style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
              ),
            ),
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _GlassPanel(
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Payment Settings',
            trailing: Icon(Icons.bolt_rounded, color: AppColors.primaryFixed, size: 16),
          ),
          _SettingsTile(
            icon: Icons.account_balance_rounded,
            title: 'Linked Bank Accounts',
            subtitle: '2 Active',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.credit_card_rounded,
            title: 'Default Payment Method',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Visa ending in 4242',
                  style: AppTextStyles.labelSm(color: AppColors.secondary),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit_rounded, color: AppColors.secondary, size: 14),
              ],
            ),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.tune_rounded,
            title: 'Transaction Limits',
            trailing: Text(
              '\$100k / Day',
              style: AppTextStyles.labelSm(color: AppColors.secondary),
            ),
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return _GlassPanel(
      child: Column(
        children: [
          const _SectionHeader(title: 'App Preferences'),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Theme',
            trailing: _StitchSwitch(
              value: _darkThemeEnabled,
              onChanged: (val) {},
              disabled: true,
            ),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            trailing: Text(
              'English (US)',
              style: AppTextStyles.labelSm(color: AppColors.secondary),
            ),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_active_rounded,
            title: 'Push Notifications',
            trailing: _StitchSwitch(
              value: _pushNotificationsEnabled,
              onChanged: (val) => setState(() => _pushNotificationsEnabled = val),
            ),
            onTap: () => setState(() => _pushNotificationsEnabled = !_pushNotificationsEnabled),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    return _GlassPanel(
      child: Column(
        children: [
          const _SectionHeader(title: 'Legal & Support'),
          _SettingsTile(
            icon: Icons.policy_rounded,
            title: 'Privacy Policy',
            trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.secondary, size: 16),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.gavel_rounded,
            title: 'Terms of Service',
            trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.secondary, size: 16),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_rounded,
            title: 'About FINTECH ELITE',
            trailing: Text(
              'v2.4.1',
              style: AppTextStyles.labelSm(color: AppColors.secondary),
            ),
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ── Custom Glassmorphic Panel ────────────────────────────────────────────────
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Custom Switched Button ───────────────────────────────────────────────────
class _StitchSwitch extends StatelessWidget {
  const _StitchSwitch({
    required this.value,
    required this.onChanged,
    this.disabled = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primaryFixed;
    final inactiveColor = const Color(0xFF333333);

    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              onChanged(!value);
            },
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: value ? activeColor : inactiveColor,
          ),
          padding: const EdgeInsets.all(2),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0C0C),
        border: Border(
          bottom: BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.labelMd(color: AppColors.secondary)
                .copyWith(letterSpacing: 1.5),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Interactive List Item ────────────────────────────────────────────────────
class _SettingsTile extends StatefulWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF1A1A1A) : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1),
                ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: _hovered ? AppColors.primaryFixed : AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles.bodyMd(color: AppColors.primary),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: AppTextStyles.labelSm(color: AppColors.secondary),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
}

// ── Reusable Local Icon Buttons ──────────────────────────────────────────────
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
