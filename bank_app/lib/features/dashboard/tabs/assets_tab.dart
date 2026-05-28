import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/localization/language_manager.dart';
import '../../notifications/notifications_screen.dart';
import '../../assets/asset_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      return Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0B0B0B),
      child: Stack(
        children: [
          // ── Ambient Depth Background (Top-Left and Bottom-Right Orbs)
          Positioned(
            top: -150,
            left: -150,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFCCFF00).withValues(alpha: 0.06), // ~15% opacity primary container glow
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFCCFF00).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Scrollable content
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── TopAppBar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: const Color(0xFF0B0B0B).withValues(alpha: 0.8),
                  elevation: 0,
                  toolbarHeight: 64,
                  surfaceTintColor: Colors.transparent,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  title: Text(
                    'Fintech',
                    style: AppTextStyles.headlineLgMobile().copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.white,
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

                // ── Content Canvas
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // 1. Wealth Summary (Total Wealth Card)
                        _staggered(0, _buildWealthSummaryCard()),
                        const SizedBox(height: 24),

                        // 2. Chart Section (Glassmorphism Card)
                        _staggered(1, _buildChartSection()),
                        const SizedBox(height: 32),

                        // 3. Asset Breakdown List Header & Items
                        _staggered(2, _buildAssetsHeader()),
                        const SizedBox(height: 16),
                        _staggered(3, _buildAssetsList()),

                        // Space at the bottom
                        const SizedBox(height: 120),
                      ],
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

  // ── Wealth Summary Card (Total Wealth Glass Card with Sheen) ────────────────
  Widget _buildWealthSummaryCard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: _SheenCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageManager.translate('Total Wealth', 'Toplam Varlık'),
                style: AppTextStyles.labelMd(color: const Color(0xFFA1A1A1)).copyWith(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    r'$124,592.80',
                    style: AppTextStyles.headlineXl(color: const Color(0xFFCCFF00)).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'USD',
                    style: AppTextStyles.labelMd(color: const Color(0xFFA1A1A1)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFFCCFF00),
                      size: 14,
                      weight: 700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      LanguageManager.translate('+2.4% (\$2,940.10) Today', 'Bugün +%2.4 (\$2,940.10)'),
                      style: AppTextStyles.labelSm(color: const Color(0xFFCCFF00)).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Chart Section (Glassmorphism Card) ──────────────────────────────────────
  Widget _buildChartSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Subtle grid dots
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),

          // Content Column
          Column(
            children: [
              // Header tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildRangeButton('1D'),
                      const SizedBox(width: 6),
                      _buildRangeButton('1W'),
                      const SizedBox(width: 6),
                      _buildRangeButton('1M'),
                      const SizedBox(width: 6),
                      _buildRangeButton('1Y'),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.fullscreen_rounded,
                      color: Color(0xFFA1A1A1),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Animated SVG-Faithful Bezier Chart
              AnimatedBuilder(
                animation: _entranceCtrl,
                builder: (context, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 192,
                    child: CustomPaint(
                      painter: _ChartPainter(_entranceCtrl.value),
                    ),
                  );
                },
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
          color: isActive ? const Color(0xFFCCFF00) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                    blurRadius: 15,
                  )
                ]
              : [],
        ),
        child: Text(
          range,
          style: AppTextStyles.labelSm(
            color: isActive ? Colors.black : const Color(0xFFA1A1A1),
          ),
        ),
      ),
    );
  }

  // ── Asset Breakdown List Header & Items ─────────────────────────────────────
  Widget _buildAssetsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LanguageManager.translate('Assets', 'Varlıklar'),
          style: AppTextStyles.headlineMd(color: Colors.white).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageManager.translate('View All', 'Tümünü Gör'),
                style: AppTextStyles.labelSm(color: const Color(0xFFCCFF00)).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCFF00), size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsList() {
    return Column(
      children: [
        _AssetListItem(
          icon: Icons.currency_bitcoin_rounded,
          title: LanguageManager.translate('Crypto', 'Kripto'),
          subtitle: 'Bitcoin, Ethereum, +4',
          value: r'$85,320.50',
          change: '+5.2%',
          isPositive: true,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const AssetDetailScreen(coin: 'BTC/USDT'),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _AssetListItem(
          icon: Icons.show_chart_rounded,
          title: LanguageManager.translate('Stocks', 'Hisse Senetleri'),
          subtitle: 'AAPL, TSLA, SPY',
          value: r'$28,150.00',
          change: '+1.1%',
          isPositive: true,
          onTap: () {
            HapticFeedback.selectionClick();
          },
        ),
        const SizedBox(height: 12),
        _AssetListItem(
          icon: Icons.account_balance_wallet_rounded,
          title: LanguageManager.translate('Cash', 'Nakit'),
          subtitle: 'USD, EUR',
          value: r'$11,122.30',
          change: '0.0%',
          isPositive: false,
          onTap: () {
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }
}

// ── Reusable Component Widgets & Painters ────────────────────────────────────

class _SheenCard extends StatefulWidget {
  const _SheenCard({required this.child});
  final Widget child;

  @override
  State<_SheenCard> createState() => _SheenCardState();
}

class _SheenCardState extends State<_SheenCard> with SingleTickerProviderStateMixin {
  late final AnimationController _sheenCtrl;

  @override
  void initState() {
    super.initState();
    _sheenCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _sheenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sheenCtrl,
      builder: (context, child) {
        final value = _sheenCtrl.value;
        final alignmentStart = Alignment(-2.5 + (value * 5.0), -1.5);
        final alignmentEnd = Alignment(-1.5 + (value * 5.0), 1.5);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 64,
                offset: const Offset(0, 32),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: alignmentStart,
                              end: alignmentEnd,
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    widget.child,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AssetListItem extends StatefulWidget {
  const _AssetListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String change;
  final bool isPositive;
  final VoidCallback onTap;

  @override
  State<_AssetListItem> createState() => _AssetListItemState();
}

class _AssetListItemState extends State<_AssetListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xE61C1C1C), // rgba(28, 28, 28, 0.9)
                Color(0xFF0C0C0C), // rgba(12, 12, 12, 1)
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.7 : 0.4),
                blurRadius: _isHovered ? 24 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon block
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF2A2A2A),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  color: _isHovered ? const Color(0xFFCCFF00) : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.bodyLg(color: Colors.white).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)),
                    ),
                  ],
                ),
              ),

              // Price and Trend
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.value,
                    style: AppTextStyles.labelMd(color: Colors.white).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.change,
                    style: AppTextStyles.labelSm(
                      color: widget.isPositive ? const Color(0xFFCCFF00) : const Color(0xFFA1A1A1),
                    ).copyWith(
                      fontWeight: FontWeight.bold,
                      shadows: widget.isPositive
                          ? [
                              Shadow(
                                color: const Color(0xFFCCFF00).withValues(alpha: 0.2),
                                blurRadius: 8,
                              )
                            ]
                          : [],
                    ),
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    const double spacing = 24.0;
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
  _ChartPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Scale functions
    double sx(double x) => x * width / 100;
    double sy(double y) => y * height / 50;

    final path = Path();
    path.moveTo(sx(0), sy(45));
    path.cubicTo(sx(10), sy(40), sx(15), sy(48), sx(25), sy(35));
    path.cubicTo(sx(35), sy(22), sx(40), sy(30), sx(50), sy(20));
    path.cubicTo(sx(60), sy(10), sx(70), sy(25), sx(80), sy(15));
    path.cubicTo(sx(90), sy(5), sx(95), sy(10), sx(100), sy(2));

    // 1. Draw dynamic progressive drawing of line using PathMetric (drawLine animation)
    final drawPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      final extract = metric.extractPath(0.0, metric.length * progress);
      drawPath.addPath(extract, Offset.zero);
    }

    // 2. Draw Area Fill gradient underneath the animated path
    if (progress > 0.0) {
      final fillPath = Path.from(drawPath);
      // Retrieve the last point drawn on the path to close the fill box properly
      final lastPoint = drawPath.computeMetrics().last.extractPath(
            drawPath.computeMetrics().last.length - 1,
            drawPath.computeMetrics().last.length,
          ).getBounds().center;

      fillPath.lineTo(lastPoint.dx, height);
      fillPath.lineTo(0, height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFCCFF00).withValues(alpha: 0.15),
            const Color(0xFFCCFF00).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(0, sy(2), 0, height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // 3. Draw neon lime line stroke
    final strokePaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(drawPath, strokePaint);

    // 4. Draw glowing end indicator point at the current animation tip
    if (progress > 0.0) {
      final metrics = path.computeMetrics().first;
      final tangent = metrics.getTangentForOffset(metrics.length * progress);
      if (tangent != null) {
        final currentPoint = tangent.position;

        final glowPaint = Paint()
          ..color = const Color(0xFFCCFF00).withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(currentPoint, 10, glowPaint);

        final dotPaint = Paint()
          ..color = const Color(0xFFCCFF00)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(currentPoint, 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => oldDelegate.progress != progress;
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
            color: _pressed ? AppColors.surfaceContainerHighest : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: Colors.white, size: 24),
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
          PageRouteBuilder(
            pageBuilder: (context, anim, secAnim) => const NotificationsScreen(),
            transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 300),
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
              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0B0B0B),
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
