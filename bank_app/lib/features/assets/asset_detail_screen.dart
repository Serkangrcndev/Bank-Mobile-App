import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({super.key, required this.coin, this.isBuy});

  final String coin;
  final bool? isBuy;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen>
    with TickerProviderStateMixin {
  // ── States ────────────────────────────────────────────────────────────────
  String _selectedRange = '1D';
  bool _isFavorite = false;

  // Scrubber interactive coordinates (Normalized to 800 x 240 coordinate space)
  double _scrubberX = 600.0;

  // Staggered Entrance Animations
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _staggerCount = 6;

  @override
  void initState() {
    super.initState();

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

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) => FadeTransition(
        opacity: _fadeAnims[index],
        child: SlideTransition(position: _slideAnims[index], child: child),
      );

  // ── Math: Exact Cubic Bezier Y coordinates calculation at X ────────────────
  double _getYAtX(double targetX) {
    if (targetX <= 0) return 180;
    if (targetX >= 800) return 50;

    double t;
    Offset p0, p1, p2, p3;

    if (targetX < 150) {
      t = targetX / 150;
      p0 = const Offset(0, 180);
      p1 = const Offset(50, 150);
      p2 = const Offset(100, 210);
      p3 = const Offset(150, 170);
    } else if (targetX < 300) {
      t = (targetX - 150) / 150;
      p0 = const Offset(150, 170);
      p1 = const Offset(200, 130);
      p2 = const Offset(250, 190);
      p3 = const Offset(300, 140);
    } else if (targetX < 450) {
      t = (targetX - 300) / 150;
      p0 = const Offset(300, 140);
      p1 = const Offset(350, 90);
      p2 = const Offset(400, 160);
      p3 = const Offset(450, 120);
    } else if (targetX < 600) {
      t = (targetX - 450) / 150;
      p0 = const Offset(450, 120);
      p1 = const Offset(500, 80);
      p2 = const Offset(550, 130);
      p3 = const Offset(600, 90);
    } else if (targetX < 750) {
      t = (targetX - 600) / 150;
      p0 = const Offset(600, 90);
      p1 = const Offset(650, 50);
      p2 = const Offset(700, 110);
      p3 = const Offset(750, 70);
    } else {
      // Linear segment from 750 to 800
      final ratio = (targetX - 750) / 50;
      return 70 + (50 - 70) * ratio;
    }

    // Cubic Bezier evaluation
    final y = (1 - t) * (1 - t) * (1 - t) * p0.dy +
        3 * (1 - t) * (1 - t) * t * p1.dy +
        3 * (1 - t) * t * t * p2.dy +
        t * t * t * p3.dy;
    return y;
  }

  // Calculate dynamic price based on Scrubber Y coordinates
  double _getPriceAtY(double y) {
    // Mapping y=50 to ~ $65,500 and y=210 to ~ $61,500
    // Dynamic price interpolation:
    return 65000.0 - (y / 240.0) * 3500.0;
  }

  // Calculate dynamic time string based on Scrubber X coordinates
  String _getTimeAtX(double x) {
    // 0 is 09:00 AM, 800 is 16:20 PM
    final totalMinutes = (x / 800) * 440; // 440 minutes = 7h 20m
    final totalMinInt = totalMinutes.floor();
    final hour = 9 + (totalMinInt ~/ 60);
    final minute = totalMinInt % 60;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final dispHour = hour > 12 ? hour - 12 : hour;
    final minStr = minute < 10 ? '0$minute' : '$minute';
    return '$dispHour:$minStr $ampm';
  }

  void _onTradeAction(bool isBuy) {
    HapticFeedback.heavyImpact();
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
              isBuy ? 'Buy order submitted for BTC' : 'Sell order submitted for BTC',
              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
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
          widget.coin,
          style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isFavorite ? AppColors.primaryFixed : Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // ── Scrollable Body Content ─────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Price Header Section ─────────────────────────────────────
                  _staggered(0, _buildPriceHeader()),
                  const SizedBox(height: 24),

                  // ── Chart Section ────────────────────────────────────────────
                  _staggered(1, _buildChartCard()),
                  const SizedBox(height: 24),

                  // ── Bento Stats Grid ─────────────────────────────────────────
                  _staggered(2, _buildStatsGrid()),
                  const SizedBox(height: 24),

                  // ── Key Events ───────────────────────────────────────────────
                  _staggered(3, _buildEventsSection()),
                ],
              ),
            ),
          ),

          // ── Fixed Bottom Action Bar ─────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  // ── Price Header Widget ────────────────────────────────────────────────────
  Widget _buildPriceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHigh,
                border: Border.all(color: AppColors.surfaceContainerHighest),
              ),
              alignment: Alignment.center,
              child: Text(
                'BTC',
                style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Bitcoin',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '\$64,230.50',
          style: AppTextStyles.headlineXl(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.trending_up_rounded,
              color: AppColors.primaryFixed,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '+2.45%',
              style: AppTextStyles.labelMd(color: AppColors.primaryFixed).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Past 24h',
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  // ── Chart Bento Card Widget ────────────────────────────────────────────────
  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Range selectors
          _buildRangeSelectors(),
          const SizedBox(height: 20),

          // Interactivity Canvas area
          LayoutBuilder(
            builder: (context, constraints) {
              final containerWidth = constraints.maxWidth;
              const containerHeight = 240.0;

              // Compute Y based on current Scrubber X
              final scrubberY = _getYAtX(_scrubberX);

              // Map coordinates to pixel offset inside container
              final pixelX = (_scrubberX / 800.0) * containerWidth;
              final pixelY = (scrubberY / 240.0) * containerHeight;

              final tooltipPrice = _getPriceAtY(scrubberY);
              final tooltipTime = _getTimeAtX(_scrubberX);

              return GestureDetector(
                onPanStart: (details) {
                  _updateScrubberPos(details.localPosition, containerWidth);
                },
                onPanUpdate: (details) {
                  _updateScrubberPos(details.localPosition, containerWidth);
                },
                onPanEnd: (_) {},
                child: SizedBox(
                  height: containerHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Grid Dots painter
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GridDotsPainter(),
                        ),
                      ),

                      // Chart line and gradient fill
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DetailChartPainter(),
                        ),
                      ),

                      // Dotted Scrubber line
                      Positioned(
                        left: pixelX,
                        top: 0,
                        bottom: 0,
                        child: CustomPaint(
                          size: const Size(1, double.infinity),
                          painter: _DashedLinePainter(color: AppColors.primaryFixed),
                        ),
                      ),

                      // Glowing handle dot
                      Positioned(
                        left: pixelX - 6,
                        top: pixelY - 6,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryFixed,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryFixed.withOpacity(0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Tooltip
                      Positioned(
                        left: (pixelX - 60).clamp(0, containerWidth - 120),
                        top: (pixelY - 72).clamp(0, containerHeight - 64),
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primaryFixed.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tooltipTime,
                                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(
                                  fontSize: 8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${tooltipPrice.toStringAsFixed(2)}',
                                style: AppTextStyles.labelMd(color: AppColors.primaryFixed).copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _updateScrubberPos(Offset localPos, double width) {
    // Map pixel X back to 0..800 range
    final x = (localPos.dx / width) * 800.0;
    setState(() {
      _scrubberX = x.clamp(0.0, 800.0);
    });
  }

  Widget _buildRangeSelectors() {
    final ranges = ['1H', '1D', '1W', '1M', '1Y', 'ALL'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x661A1A1A),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0x80333333)),
      ),
      child: Row(
        children: List.generate(ranges.length, (i) {
          final range = ranges[i];
          final active = range == _selectedRange;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedRange = range;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryFixed : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primaryFixed.withOpacity(0.4),
                            blurRadius: 15,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  range,
                  style: AppTextStyles.labelSm(
                    color: active ? Colors.black : AppColors.onSurfaceVariant,
                  ).copyWith(
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Bento Stats Grid ───────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    final stats = [
      ('Market Cap', '\$1.2T'),
      ('Volume (24h)', '\$34.5B'),
      ('24h High', '\$65,100.00'),
      ('24h Low', '\$62,800.00'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final (label, value) = stats[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.labelMd(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Key Events Section ─────────────────────────────────────────────────────
  Widget _buildEventsSection() {
    final events = [
      ('ETF Inflow Reaches Record High', '2 hours ago • News', Icons.article_outlined),
      ('Resistance Broken at \$63,500', '5 hours ago • Analysis', Icons.show_chart_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Key Events',
              style: AppTextStyles.headlineMd(color: AppColors.primary),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'SEE ALL',
                style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(events.length, (i) {
            final (title, meta, icon) = events[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceContainerHighest),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHigh,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryFixed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta,
                          style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Bottom Fixed Action Bar Widget ─────────────────────────────────────────
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1A1A),
        border: const Border(
          top: BorderSide(color: Color(0xFF333333)),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Sell button (Outlined style)
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTradeAction(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryFixed),
                    ),
                    child: Text(
                      'Sell',
                      style: AppTextStyles.headlineMd(color: AppColors.primaryFixed).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Buy button (Filled style)
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTradeAction(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Buy',
                      style: AppTextStyles.headlineMd(color: Colors.black).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Painter: Dot Grid Backing ────────────────────────────────────────────────
class _GridDotsPainter extends CustomPainter {
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

// ── Painter: Enhanced Bezier Curve ───────────────────────────────────────────
class _DetailChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Normalizing ranges (0..800, 0..240) to pixel bounds
    double sx(double x) => x * w / 800.0;
    double sy(double y) => y * h / 240.0;

    final path = Path();
    path.moveTo(sx(0), sy(180));
    path.cubicTo(sx(50), sy(150), sx(100), sy(210), sx(150), sy(170));
    path.cubicTo(sx(200), sy(130), sx(250), sy(190), sx(300), sy(140));
    path.cubicTo(sx(350), sy(90), sx(400), sy(160), sx(450), sy(120));
    path.cubicTo(sx(500), sy(80), sx(550), sy(130), sx(600), sy(90));
    path.cubicTo(sx(650), sy(50), sx(700), sy(110), sx(750), sy(70));
    path.lineTo(sx(800), sy(50));

    // 1. Draw Shading Gradient Fill
    final fillPath = Path.from(path);
    fillPath.lineTo(w, h);
    fillPath.lineTo(0, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFCCFF00).withOpacity(0.25),
          const Color(0xFFCCFF00).withOpacity(0.05),
          const Color(0xFFCCFF00).withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(0, sy(50), 0, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw Main Path Stroke
    final strokePaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Painter: Custom Dashed Line ──────────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    const double dashHeight = 4.0;
    const double dashSpace = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
