import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AssetsTab extends StatefulWidget {
  const AssetsTab({super.key});

  @override
  State<AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends State<AssetsTab> with TickerProviderStateMixin {
  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 4;

  // ── Tab selection state ───────────────────────────────────────────────────
  String _selectedRange = '1M';

  // ── Item press states ─────────────────────────────────────────────────────
  int _pressedAsset = -1;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Wealth Summary
                _staggered(0, _buildWealthSummary()),
                const SizedBox(height: 24),

                // Chart Section
                _staggered(1, _buildChartSection()),
                const SizedBox(height: 32),

                // Assets Header & List
                _staggered(2, _buildAssetsHeader()),
                const SizedBox(height: 12),
                _staggered(3, _buildAssetsList()),

                // Space for floating nav
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWealthSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'TOTAL WEALTH',
            style: AppTextStyles.labelMd(
              color: AppColors.onSurfaceVariant,
            ).copyWith(letterSpacing: 2.0),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              r'$124,592.80',
              style: AppTextStyles.headlineXl(
                color: AppColors.primaryFixed,
              ).copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'USD',
              style: AppTextStyles.labelMd(
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.primaryFixed,
                    size: 14,
                    weight: 700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+2.4% (\$2,940.10) Today',
                    style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Subtle Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),

          // Content
          Column(
            children: [
              // Header/Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildRangeButton('1D'),
                      const SizedBox(width: 4),
                      _buildRangeButton('1W'),
                      const SizedBox(width: 4),
                      _buildRangeButton('1M'),
                      const SizedBox(width: 4),
                      _buildRangeButton('1Y'),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.fullscreen_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SVG-Faithful Bezier Line Chart
              SizedBox(
                width: double.infinity,
                height: 192, // h-48 = 192px
                child: CustomPaint(
                  painter: _ChartPainter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeButton(String range) {
    final isActive = _selectedRange == range;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedRange = range);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryFixed : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          range,
          style: AppTextStyles.labelSm(
            color: isActive ? AppColors.background : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsHeader() {
    return Text(
      'Assets',
      style: AppTextStyles.headlineMd(color: AppColors.onSurface),
    );
  }

  Widget _buildAssetsList() {
    final assets = [
      _AssetRowData(
        icon: Icons.currency_bitcoin_rounded,
        title: 'Crypto',
        subtitle: 'Bitcoin, Ethereum, +4',
        value: r'$85,320.50',
        change: '+5.2%',
        isPositive: true,
      ),
      _AssetRowData(
        icon: Icons.show_chart,
        title: 'Stocks',
        subtitle: 'AAPL, TSLA, SPY',
        value: r'$28,150.00',
        change: '+1.1%',
        isPositive: true,
      ),
      _AssetRowData(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Cash',
        subtitle: 'USD, EUR',
        value: r'$11,122.30',
        change: '0.0%',
        isPositive: false,
      ),
    ];

    return Column(
      children: List.generate(assets.length, (i) {
        final item = assets[i];
        final pressed = _pressedAsset == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressedAsset = i),
            onTapUp: (_) {
              setState(() => _pressedAsset = -1);
              HapticFeedback.selectionClick();
            },
            onTapCancel: () => setState(() => _pressedAsset = -1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: pressed
                      ? const Color(0xFF333333)
                      : AppColors.surfaceContainer,
                ),
              ),
              child: Row(
                children: [
                  // Icon Circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pressed
                          ? AppColors.surfaceContainerHighest
                          : AppColors.surfaceContainerHigh,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Icon(
                      item.icon,
                      color: pressed ? AppColors.primaryFixed : AppColors.onSurface,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.bodyLg(color: AppColors.onSurface),
                        ),
                        Text(
                          item.subtitle,
                          style: AppTextStyles.labelSm(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Values
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.value,
                        style: AppTextStyles.labelMd(color: AppColors.onSurface),
                      ),
                      Text(
                        item.change,
                        style: AppTextStyles.labelSm(
                          color: item.isPositive
                              ? AppColors.primaryFixed
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Supporting Data & Painters ───────────────────────────────────────────────

class _AssetRowData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String change;
  final bool isPositive;
  const _AssetRowData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.change,
    required this.isPositive,
  });
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const double spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Scale function from (0..100) normalized coordinates to pixel dimensions
    double sx(double x) => x * width / 100;
    double sy(double y) => y * height / 50;

    final path = Path();
    path.moveTo(sx(0), sy(45));
    path.cubicTo(sx(10), sy(40), sx(15), sy(48), sx(25), sy(35));
    path.cubicTo(sx(35), sy(22), sx(40), sy(30), sx(50), sy(20));
    path.cubicTo(sx(60), sy(10), sx(70), sy(25), sx(80), sy(15));
    path.cubicTo(sx(90), sy(5), sx(95), sy(10), sx(100), sy(2));

    // 1. Draw gradient fill under the line path
    final fillPath = Path.from(path);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFCCFF00).withOpacity(0.15),
          const Color(0xFFCCFF00).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, sy(2), 0, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw the neon lime line stroke
    final strokePaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // 3. Draw neon glow point at the end of the line (100, 2)
    final endPoint = Offset(sx(100), sy(2));

    final glowPaint = Paint()
      ..color = const Color(0xFFCCFF00).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(endPoint, 10, glowPaint);

    final dotPaint = Paint()
      ..color = AppColors.primaryFixed
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
