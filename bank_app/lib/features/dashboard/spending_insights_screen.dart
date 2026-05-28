import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../notifications/notifications_screen.dart';
import '../search/global_search_screen.dart';

class SpendingInsightsScreen extends StatefulWidget {
  const SpendingInsightsScreen({super.key});

  @override
  State<SpendingInsightsScreen> createState() => _SpendingInsightsScreenState();
}

class _SpendingInsightsScreenState extends State<SpendingInsightsScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _staggerCount = 3;

  int _hoveredCategory = -1;
  bool _hoveredViewAll = false;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.15;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.15;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(
        position: _slideAnims[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Decorative background radial glow
          Positioned(
            top: (size.height / 2) - 400,
            left: (size.width / 2) - 400,
            child: IgnorePointer(
              child: Container(
                width: 800,
                height: 800,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFCCFF00).withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Sticky Header (Custom AppBar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 12,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    border: const Border(
                      bottom: BorderSide(color: Colors.white10, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF333333)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAj43pSTeZkPGSDBzEukaI6wlz4Uu5zmevjp5iVW-O4h9mOFRvexD3deoHJWjyNt8oGr0GKFlyfYD2wIhwrNUNZ05QAecvJMMWRyIAitcXyoHb__-m198K9Qfdo27pdFcc9Qh7jBOXTAx3bS7Kr7HBfDBoY6Lo05byLwa6u3MdbElQLBhc5CCbMBnV_S1jfR9fDLPO9K3kW2PxCoT2dnhfZnVqbdiOFKbPpkZ9o1CByg-1Ben4rqt_vSDSlLrK1V_g20dEtG47VG8rs',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.surfaceContainerHigh,
                                  child: const Icon(Icons.person, size: 16, color: AppColors.secondary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'LUMINA BANK',
                            style: AppTextStyles.labelMd(color: Colors.white).copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim, secAnim) => const NotificationsScreen(),
                              transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Scrollable Body Content
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + 60,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Page Header (Stagger 0)
                      _staggered(0, _buildHeader()),
                      const SizedBox(height: 28),

                      // 2. Total Spent Donut Chart Card (Stagger 1)
                      _staggered(1, _buildDonutChartCard()),
                      const SizedBox(height: 20),

                      // 3. Budget vs Actual Card (Stagger 1)
                      _staggered(1, _buildBudgetCard()),
                      const SizedBox(height: 20),

                      // 4. Top Categories Card (Stagger 2)
                      _staggered(2, _buildTopCategoriesCard()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header Section ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: AppTextStyles.headlineXl(color: Colors.white).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your spending landscape for October',
          style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)),
        ),
      ],
    );
  }

  // ── Total Spent & Donut Chart Card ─────────────────────────────────────────
  Widget _buildDonutChartCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TOTAL SPENT',
            style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Custom Paint Donut Chart
          const Center(
            child: _DonutChart(
              shoppingValue: 0.45,
              foodValue: 0.30,
              transportValue: 0.15,
              utilitiesValue: 0.10,
              centerTextTop: 'Oct 1-31',
              centerTextBottom: r'$4,250',
            ),
          ),
          const SizedBox(height: 32),

          // Legend grid mapping conically colored items
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildLegendItem(const Color(0xFFCCFF00), 'Shopping (45%)'),
              _buildLegendItem(const Color(0xFF666666), 'Food (30%)'),
              _buildLegendItem(const Color(0xFF333333), 'Transport (15%)'),
              _buildLegendItem(const Color(0xFF1A1A1A), 'Utilities (10%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSm(color: color == const Color(0xFFCCFF00) ? Colors.white : const Color(0xFFA1A1A1)).copyWith(
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Budget Card Section ────────────────────────────────────────────────────
  Widget _buildBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget vs Actual',
                style: AppTextStyles.bodyMd(color: Colors.white).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '85% utilized',
                style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar Container
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(99),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00), // neon yeşil
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: r'$4,250 ',
                  style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontSize: 13),
                  children: const [
                    TextSpan(
                      text: 'spent',
                      style: TextStyle(color: Color(0xFFA1A1A1), fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: r'$5,000 ',
                  style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 13),
                  children: const [
                    TextSpan(
                      text: 'limit',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Top Categories List Card ───────────────────────────────────────────────
  Widget _buildTopCategoriesCard() {
    final categories = [
      (
        icon: Icons.shopping_bag_outlined,
        title: 'Shopping',
        count: '12 Transactions',
        amount: r'$1,912.50',
        change: '+12% vs last mo',
        accentColor: const Color(0xFFCCFF00)
      ),
      (
        icon: Icons.restaurant_rounded,
        title: 'Food & Dining',
        count: '28 Transactions',
        amount: r'$1,275.00',
        change: '-5% vs last mo',
        accentColor: const Color(0xFF666666)
      ),
      (
        icon: Icons.commute_rounded,
        title: 'Transport',
        count: '45 Transactions',
        amount: r'$637.50',
        change: '-- vs last mo',
        accentColor: const Color(0xFF333333)
      ),
      (
        icon: Icons.bolt_rounded,
        title: 'Utilities',
        count: '3 Transactions',
        amount: r'$425.00',
        change: '+2% vs last mo',
        accentColor: const Color(0xFF1A1A1A)
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TOP CATEGORIES',
            style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Categories List
          Column(
            children: List.generate(categories.length, (i) {
              final cat = categories[i];
              final isHovered = _hoveredCategory == i;

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredCategory = i),
                onExit: (_) => setState(() => _hoveredCategory = -1),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _hoveredCategory = i),
                  onTapCancel: () => setState(() => _hoveredCategory = -1),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    // Go to search pre-filtered with the category name
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, anim, secAnim) => const GlobalSearchScreen(),
                        transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isHovered ? const Color(0xFF1A1A1A) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        bottom: BorderSide(
                          color: i == categories.length - 1 ? Colors.transparent : const Color(0xFF1A1A1A),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Section: Icon & Info
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2A2A2A),
                                border: Border.all(
                                  color: isHovered ? cat.accentColor : const Color(0xFF353535),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                cat.icon,
                                color: isHovered && cat.accentColor == const Color(0xFFCCFF00)
                                    ? const Color(0xFFCCFF00)
                                    : const Color(0xFFA1A1A1),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.title,
                                  style: AppTextStyles.bodyMd(color: isHovered && cat.accentColor == const Color(0xFFCCFF00) ? const Color(0xFFCCFF00) : Colors.white).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cat.count,
                                  style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right Section: Amounts & Comparisons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              cat.amount,
                              style: AppTextStyles.bodyMd(color: Colors.white).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cat.change,
                              style: AppTextStyles.labelSm(
                                color: cat.change.startsWith('+') ? const Color(0xFFCCFF00) : const Color(0xFFA1A1A1),
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
          ),
          const SizedBox(height: 20),

          // VIEW ALL TRANSACTIONS Button
          MouseRegion(
            onEnter: (_) => setState(() => _hoveredViewAll = true),
            onExit: (_) => setState(() => _hoveredViewAll = false),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _hoveredViewAll = true),
              onTapCancel: () => setState(() => _hoveredViewAll = false),
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim, secAnim) => const GlobalSearchScreen(),
                    transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _hoveredViewAll ? const Color(0xFF262626) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333), width: 1),
                ),
                child: Text(
                  'VIEW ALL TRANSACTIONS',
                  style: AppTextStyles.labelMd(color: Colors.white).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Donut Chart Widget ────────────────────────────────────────────────
class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.shoppingValue,
    required this.foodValue,
    required this.transportValue,
    required this.utilitiesValue,
    required this.centerTextTop,
    required this.centerTextBottom,
  });

  final double shoppingValue;
  final double foodValue;
  final double transportValue;
  final double utilitiesValue;
  final String centerTextTop;
  final String centerTextBottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _DonutChartPainter(
              shoppingValue: shoppingValue,
              foodValue: foodValue,
              transportValue: transportValue,
              utilitiesValue: utilitiesValue,
            ),
          ),
          Container(
            width: 156,
            height: 156,
            decoration: const BoxDecoration(
              color: Color(0xFF0C0C0C),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  centerTextTop,
                  style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  centerTextBottom,
                  style: AppTextStyles.headlineLg(color: Colors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter to conically fill Donut slices ────────────────────────────
class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.shoppingValue,
    required this.foodValue,
    required this.transportValue,
    required this.utilitiesValue,
  });

  final double shoppingValue;
  final double foodValue;
  final double transportValue;
  final double utilitiesValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Start angle at top of circle (-pi/2)
    double startAngle = -3.1415926535 / 2;

    // 1. Shopping (45% - Color: #CCFF00)
    final sweepAngle1 = 2 * 3.1415926535 * shoppingValue;
    paint.color = const Color(0xFFCCFF00);
    canvas.drawArc(rect, startAngle, sweepAngle1, true, paint);
    startAngle += sweepAngle1;

    // 2. Food (30% - Color: #666666)
    final sweepAngle2 = 2 * 3.1415926535 * foodValue;
    paint.color = const Color(0xFF666666);
    canvas.drawArc(rect, startAngle, sweepAngle2, true, paint);
    startAngle += sweepAngle2;

    // 3. Transport (15% - Color: #333333)
    final sweepAngle3 = 2 * 3.1415926535 * transportValue;
    paint.color = const Color(0xFF333333);
    canvas.drawArc(rect, startAngle, sweepAngle3, true, paint);
    startAngle += sweepAngle3;

    // 4. Utilities (10% - Color: #1A1A1A)
    final sweepAngle4 = 2 * 3.1415926535 * utilitiesValue;
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawArc(rect, startAngle, sweepAngle4, true, paint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.shoppingValue != shoppingValue ||
        oldDelegate.foodValue != foodValue ||
        oldDelegate.transportValue != transportValue ||
        oldDelegate.utilitiesValue != utilitiesValue;
  }
}
