import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../notifications/notifications_screen.dart';
import '../../cards/card_details_screen.dart';
import '../../transfers/transfer_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 4;

  // ── Pulse animation (balance chip) ────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── Press states ──────────────────────────────────────────────────────────
  int _pressedAction = -1;
  int _pressedTx = -1;

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
      return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 0, end: 1).animate(_pulseCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
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
              color: AppColors.outlineVariant,
            ),
          ),
          title: Text(
            'Fintech',
            style: AppTextStyles.headlineLgMobile().copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
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

        // ── Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Total Balance
              _staggered(0, _buildBalanceSection()),
              const SizedBox(height: 32),

              // Cards
              _staggered(1, _buildCardsSection()),
              const SizedBox(height: 32),

              // Quick Actions
              _staggered(2, _buildQuickActions()),
              const SizedBox(height: 32),

              // Recent Activity
              _staggered(3, _buildRecentActivity()),

              // Spacing at the bottom so it clears floating nav
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      children: [
        Text(
          'TOTAL BALANCE',
          style: AppTextStyles.labelMd(
            color: AppColors.onSurfaceVariant,
          ).copyWith(letterSpacing: 2.0),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$',
              style: AppTextStyles.headlineLgMobile(
                  color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 4),
            Text.rich(
              TextSpan(
                text: '124,592',
                style: AppTextStyles.headlineXl().copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
                children: [
                  TextSpan(
                    text: '.00',
                    style: AppTextStyles.headlineXl(
                      color: AppColors.onSurfaceVariant,
                    ).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Pulse chip
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            final glow = (_pulseAnim.value < 0.7
                    ? _pulseAnim.value / 0.7
                    : (1 - _pulseAnim.value) / 0.3)
                .clamp(0.0, 1.0);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryFixed.withAlpha((51 * glow).toInt()),
                    blurRadius: 10 * glow,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primaryFixed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+2.4% Today',
                    style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const _BankCard(
            type: 'Debit',
            last4: '4092',
            balanceLabel: 'Available Balance',
            balance: r'$45,200.50',
            icon: Icons.contactless_rounded,
            isPrimary: true,
          ),
          const SizedBox(width: 16),
          const _BankCard(
            type: 'Credit',
            last4: '8821',
            balanceLabel: 'Current Balance',
            balance: r'$3,400.00',
            icon: Icons.credit_card_rounded,
            isPrimary: false,
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {},
            child: const _AddCardButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (Icons.send_rounded, 'Send'),
      (Icons.arrow_downward_rounded, 'Receive'),
      (Icons.swap_horiz_rounded, 'Swap'),
      (Icons.more_horiz_rounded, 'More'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(actions.length, (i) {
          final (icon, label) = actions[i];
          final pressed = _pressedAction == i;
          return GestureDetector(
            onTapDown: (_) => setState(() => _pressedAction = i),
            onTapUp: (_) {
              setState(() => _pressedAction = -1);
              HapticFeedback.lightImpact();
              if (i == 0) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const TransferScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              }
            },
            onTapCancel: () => setState(() => _pressedAction = -1),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pressed
                        ? AppColors.primaryFixed
                        : AppColors.surfaceContainerLow,
                    border: Border.all(
                      color: pressed
                          ? AppColors.primaryFixed
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: pressed
                        ? AppColors.background
                        : AppColors.primaryFixed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTextStyles.labelSm(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final transactions = [
      const _TxData(
        icon: Icons.storefront_outlined,
        name: 'Apple Store',
        date: 'Today, 2:45 PM',
        amount: r'- $999.00',
        amountColor: AppColors.primary,
        iconColor: AppColors.onSurface,
        hasBorder: true,
      ),
      const _TxData(
        icon: Icons.south_west_rounded,
        name: 'Salary Deposit',
        date: 'Yesterday',
        amount: r'+ $4,250.00',
        amountColor: AppColors.primaryFixed,
        iconColor: AppColors.primaryFixed,
        hasBorder: true,
      ),
      const _TxData(
        icon: Icons.coffee_outlined,
        name: 'Starbucks',
        date: 'Oct 12',
        amount: r'- $6.50',
        amountColor: AppColors.primary,
        iconColor: AppColors.onSurface,
        hasBorder: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Recent Activity', style: AppTextStyles.headlineMd()),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See All',
                  style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: List.generate(transactions.length, (i) {
                final tx = transactions[i];
                final pressed = _pressedTx == i;
                return GestureDetector(
                  onTapDown: (_) => setState(() => _pressedTx = i),
                  onTapUp: (_) {
                    setState(() => _pressedTx = -1);
                    HapticFeedback.selectionClick();
                  },
                  onTapCancel: () => setState(() => _pressedTx = -1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: pressed
                          ? AppColors.surfaceContainerLow
                          : Colors.transparent,
                      border: tx.hasBorder
                          ? const Border(
                              bottom: BorderSide(
                                color: AppColors.surfaceContainer,
                              ),
                            )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceContainerHighest,
                              border: Border.all(
                                color: pressed
                                    ? AppColors.primaryFixed
                                    : AppColors.outlineVariant,
                              ),
                            ),
                            child: Icon(tx.icon,
                                size: 18, color: tx.iconColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.name,
                                  style: AppTextStyles.bodyMd().copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  tx.date,
                                  style: AppTextStyles.labelSm(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            tx.amount,
                            style: AppTextStyles.labelMd(
                              color: tx.amountColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting Home Widgets ─────────────────────────────────────────────────

class _TxData {
  final IconData icon;
  final String name;
  final String date;
  final String amount;
  final Color amountColor;
  final Color iconColor;
  final bool hasBorder;
  const _TxData({
    required this.icon,
    required this.name,
    required this.date,
    required this.amount,
    required this.amountColor,
    required this.iconColor,
    required this.hasBorder,
  });
}

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

class _BankCard extends StatefulWidget {
  const _BankCard({
    required this.type,
    required this.last4,
    required this.balanceLabel,
    required this.balance,
    required this.icon,
    required this.isPrimary,
  });

  final String type;
  final String last4;
  final String balanceLabel;
  final String balance;
  final IconData icon;
  final bool isPrimary;

  @override
  State<_BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<_BankCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CardDetailsScreen(
              cardType: widget.type,
              last4: widget.last4,
              balance: widget.balance,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedOpacity(
        opacity: widget.isPrimary ? 1.0 : (_hovered ? 1.0 : 0.70),
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 288,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered || widget.isPrimary
                  ? AppColors.primaryFixed.withAlpha(150)
                  : AppColors.outlineVariant,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.isPrimary)
                Positioned(
                  top: -24,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primaryFixed,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              if (widget.isPrimary)
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryFixed.withAlpha(13),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.isPrimary
                            ? AppColors.primaryFixed
                            : AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                      Text(
                        widget.type.toUpperCase(),
                        style: AppTextStyles.labelSm(
                          color: AppColors.onSurfaceVariant,
                        ).copyWith(letterSpacing: 2.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '**** ${widget.last4}',
                    style: AppTextStyles.labelMd().copyWith(
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.balanceLabel,
                    style: AppTextStyles.labelSm(
                        color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.balance,
                    style: AppTextStyles.headlineMd(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCardButton extends StatefulWidget {
  const _AddCardButton();

  @override
  State<_AddCardButton> createState() => _AddCardButtonState();
}

class _AddCardButtonState extends State<_AddCardButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 96,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? AppColors.primaryFixed : AppColors.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: _hovered ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              'Add',
              style: AppTextStyles.labelSm(
                color: _hovered ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
