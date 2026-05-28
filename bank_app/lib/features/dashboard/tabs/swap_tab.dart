import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/localization/language_manager.dart';
import '../../notifications/notifications_screen.dart';
import '../../assets/asset_detail_screen.dart';

class SwapTab extends StatefulWidget {
  const SwapTab({super.key});

  @override
  State<SwapTab> createState() => _SwapTabState();
}

class _SwapTabState extends State<SwapTab> with TickerProviderStateMixin {
  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _sectionCount = 5;

  // ── Capital Count-up Animation ────────────────────────────────────────────
  late final AnimationController _counterCtrl;
  late final Animation<double> _counterAnim;
  final double _targetCapital = 2459103.88;

  // ── Pulse / Glow Animations ───────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── Chart Range State ─────────────────────────────────────────────────────
  String _selectedRange = '1D';
  late final AnimationController _chartDrawCtrl;
  late final Animation<double> _chartDrawAnim;

  // ── Chart Interaction state ───────────────────────────────────────────────
  double? _touchX;
  bool _isDrawingVolume = false;

  // ── Tab press states ──────────────────────────────────────────────────────
  int _pressedCategory = -1;
  bool _buyPressed = false;
  bool _sellPressed = false;

  @override
  void initState() {
    super.initState();

    // Entrance staggered animations
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
      return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Capital count-up animation
    _counterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _counterAnim = Tween<double>(begin: 0.0, end: _targetCapital).animate(
      CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOutQuart),
    );

    // Chart draw animation
    _chartDrawCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _chartDrawAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartDrawCtrl, curve: Curves.easeInOutCubic),
    );

    // Pulse animation for points
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 3.0, end: 7.0).animate(_pulseCtrl);

    // Trigger entrance & animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceCtrl.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _counterCtrl.forward();
        _chartDrawCtrl.forward();
        setState(() {
          _isDrawingVolume = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _counterCtrl.dispose();
    _chartDrawCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int i, Widget child) => FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  String _formatCapital(double val) {
    final basic = val.toStringAsFixed(2);
    final parts = basic.split('.');
    final whole = parts[0];
    final decimals = parts[1];
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedWhole = whole.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '$formattedWhole.$decimals';
  }

  void _onRangeSelected(String range) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedRange = range;
      _touchX = null; // Reset tracker on filter change
    });
    _chartDrawCtrl.reset();
    _chartDrawCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Premium Dark Radial Gradient Background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF111111),
                  Colors.black,
                ],
              ),
            ),
          ),
        ),

        // Glowing Spheres decoration (mesh glow)
        Positioned(
          top: 150,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryFixed.withValues(alpha: 0.015),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox.shrink(),
            ),
          ),
        ),

        Positioned(
          bottom: 200,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryFixed.withValues(alpha: 0.01),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox.shrink(),
            ),
          ),
        ),

        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── TopAppBar
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background.withValues(alpha: 0.8),
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
                style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
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

            // ── Main Content Canvas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // 1. Capital Balance summary
                    _staggered(0, _buildCapitalSection()),
                    const SizedBox(height: 24),

                    // 2. Chart Card
                    _staggered(1, _buildChartCard()),
                    const SizedBox(height: 24),

                    // 3. Asset Categories Grid
                    _staggered(2, _buildCategoriesGrid()),
                    const SizedBox(height: 24),

                    // 4. Trade Terminal Glass Card
                    _staggered(3, _buildTradeTerminal()),
                    const SizedBox(height: 24),

                    // 5. Execution History Log
                    _staggered(4, _buildExecutionLog()),

                    // Clears bottom persistent navbar
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

  // ── Capital Summary Section ────────────────────────────────────────────────
  Widget _buildCapitalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageManager.translate('GLOBAL PORTFOLIO CAPITAL', 'KÜRESEL PORTFÖY SERMAYESİ'),
          style: AppTextStyles.labelMd(color: AppColors.secondary).copyWith(letterSpacing: 2.0),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _counterAnim,
              builder: (context, child) {
                return Text(
                  '\$${_formatCapital(_counterAnim.value)}',
                  style: AppTextStyles.headlineXl(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.0,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primaryFixed,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+4.2%',
                    style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Custom Interactive Bezier Spline Chart Card ────────────────────────────
  Widget _buildChartCard() {
    final ranges = ['1D', '1W', '1M', 'YTD', 'ALL'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        children: [
          // OHLC Header & Filter Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0E0E0E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Color(0xFF1F1F1F))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // OHLC Data
                    Row(
                      children: [
                        _buildOhlcItem('O', '2,451K'),
                        const SizedBox(width: 12),
                        _buildOhlcItem('H', '2,468K'),
                        const SizedBox(width: 12),
                        _buildOhlcItem('L', '2,442K'),
                        const SizedBox(width: 12),
                        _buildOhlcItem('C', '2,459K', isHighlight: true),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Time Range Selectors
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(ranges.length, (i) {
                    final range = ranges[i];
                    final active = range == _selectedRange;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onRangeSelected(range),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active ? AppColors.primaryFixed : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryFixed.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            range,
                            style: AppTextStyles.labelSm(
                              color: active ? Colors.black : AppColors.secondary,
                            ).copyWith(fontWeight: active ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Custom Bezier Chart Area
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _touchX = details.localPosition.dx.clamp(0.0, MediaQuery.of(context).size.width - 40);
              });
            },
            onPanEnd: (_) => setState(() => _touchX = null),
            onTapDown: (details) {
              setState(() {
                _touchX = details.localPosition.dx.clamp(0.0, MediaQuery.of(context).size.width - 40);
              });
            },
            onTapCancel: () => setState(() => _touchX = null),
            child: SizedBox(
              height: 256,
              width: double.infinity,
              child: Stack(
                children: [
                  // Painter Layer (Grid, Area Spline, Stroke, and Candlestick Points)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_chartDrawAnim, _pulseAnim]),
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _AdvancedChartPainter(
                            drawProgress: _chartDrawAnim.value,
                            pulseRadius: _pulseAnim.value,
                            touchX: _touchX,
                          ),
                        );
                      },
                    ),
                  ),

                  // Volume Indicator Bars Overlay (at the bottom)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    height: 48,
                    child: _buildVolumeIndicatorOverlay(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOhlcItem(String label, String value, {bool isHighlight = false}) {
    return RichText(
      text: TextSpan(
        text: '$label  ',
        style: AppTextStyles.labelSm(color: AppColors.secondary).copyWith(fontFamily: 'JetBrains Mono'),
        children: [
          TextSpan(
            text: value,
            style: AppTextStyles.labelSm(
              color: isHighlight ? AppColors.primaryFixed : AppColors.primary,
            ).copyWith(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeIndicatorOverlay() {
    final volumes = [0.30, 0.45, 0.25, 0.60, 0.85, 0.50, 0.40, 0.70, 0.55, 0.90];
    final activeIndices = {3, 4, 7}; // Matches HTML colored bars (lime vs dark)

    return AnimatedOpacity(
      opacity: _isDrawingVolume ? 0.40 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(volumes.length, (i) {
          final targetHeightFraction = volumes[i];
          final isActive = activeIndices.contains(i);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedFractionallySizedBox(
                duration: Duration(milliseconds: 600 + (i * 80)),
                curve: Curves.easeOutBack,
                heightFactor: _isDrawingVolume ? targetHeightFraction : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryFixed : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Bento Grid Category Cards ──────────────────────────────────────────────
  Widget _buildCategoriesGrid() {
    final categories = [
      (LanguageManager.translate('Equities', 'Hisse Senetleri'), '45%', '\$1,106,596.74', Icons.show_chart_rounded),
      (LanguageManager.translate('Digital Assets', 'Dijital Varlıklar'), '35%', '\$860,686.35', Icons.currency_bitcoin_rounded),
      (LanguageManager.translate('Alternative', 'Alternatif'), '20%', '\$491,820.79', Icons.diamond_outlined),
    ];

    return Column(
      children: List.generate(categories.length, (i) {
        final (title, percent, val, icon) = categories[i];
        final isPressed = _pressedCategory == i;

        return GestureDetector(
          onTapDown: (_) => setState(() => _pressedCategory = i),
          onTapUp: (_) {
            setState(() => _pressedCategory = -1);
            HapticFeedback.lightImpact();
          },
          onTapCancel: () => setState(() => _pressedCategory = -1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPressed ? AppColors.primaryFixed.withValues(alpha: 0.5) : const Color(0xFF1F1F1F),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryFixed,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.bodyLg(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(val, style: AppTextStyles.labelSm(color: AppColors.secondary)),
                    ],
                  ),
                ),
                Text(
                  percent,
                  style: AppTextStyles.labelMd(color: isPressed ? AppColors.primaryFixed : AppColors.secondary)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── BTC Glassmorphic Trade Terminal ────────────────────────────────────────
  Widget _buildTradeTerminal() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Terminal Header
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AssetDetailScreen(coin: 'BTC/USDT'),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'BTC',
                            style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bitcoin',
                              style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              LanguageManager.translate('INSTRUMENT: BTC/USD', 'FİNANSAL ARAÇ: BTC/USD'),
                              style: AppTextStyles.labelSm(color: AppColors.secondary).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$64,230.00',
                          style: AppTextStyles.labelMd(color: AppColors.primaryFixed).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '-0.24%',
                          style: AppTextStyles.labelSm(color: AppColors.error).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // BUY & SELL Action Buttons
              Row(
                children: [
                  // BUY Button
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _buyPressed = true),
                      onTapUp: (_) {
                        setState(() => _buyPressed = false);
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const AssetDetailScreen(coin: 'BTC/USDT', isBuy: true),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      onTapCancel: () => setState(() => _buyPressed = false),
                      child: AnimatedScale(
                        scale: _buyPressed ? 0.96 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryFixed.withValues(alpha: 0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle_outline_rounded, color: Colors.black, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                LanguageManager.translate('BUY', 'AL'),
                                style: AppTextStyles.labelMd(color: Colors.black).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // SELL Button
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _sellPressed = true),
                      onTapUp: (_) {
                        setState(() => _sellPressed = false);
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const AssetDetailScreen(coin: 'BTC/USDT', isBuy: false),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      onTapCancel: () => setState(() => _sellPressed = false),
                      child: AnimatedScale(
                        scale: _sellPressed ? 0.96 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15), // aligned border adjustment
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryFixed, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.remove_circle_outline_rounded, color: AppColors.primaryFixed, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                LanguageManager.translate('SELL', 'SAT'),
                                style: AppTextStyles.labelMd(color: AppColors.primaryFixed).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                LanguageManager.translate('Estimated spread: 0.002% • Instant Settlement', 'Tahmini makas: %0.002 • Anında Takas'),
                style: AppTextStyles.labelSm(color: AppColors.secondary.withValues(alpha: 0.6)).copyWith(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Professional Execution Log ─────────────────────────────────────────────
  Widget _buildExecutionLog() {
    final trades = [
      _LogItem(
        isBuy: false,
        title: LanguageManager.translate('Long AAPL', 'Uzun AAPL'),
        meta: 'T-ID: 8849-XA • 09:30:12',
        subtitle: '@ \$182.40',
        amount: '-\$14,500.00',
        state: LanguageManager.translate('FILLED', 'GERÇEKLEŞTİ'),
        isFilled: true,
      ),
      _LogItem(
        isBuy: true,
        title: LanguageManager.translate('Short ETH', 'Kısa ETH'),
        meta: 'T-ID: 9102-BZ • 14:15:44',
        subtitle: '@ \$3.2k',
        amount: '+\$8,240.50',
        state: LanguageManager.translate('SETTLED', 'TAKAS EDİLDİ'),
        isFilled: true,
      ),
      _LogItem(
        isBuy: null, // neutral wire
        title: LanguageManager.translate('Bank Wire Inbound', 'Gelen Banka Havalesi'),
        meta: 'Swift Ref: JPM-0021 • Oct 24',
        subtitle: '',
        amount: '+\$50,000.00',
        state: LanguageManager.translate('COMPLETED', 'TAMAMLANDI'),
        isFilled: true,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LanguageManager.translate('EXECUTION LOG', 'İŞLEM LOGU'),
                  style: AppTextStyles.labelMd(color: AppColors.secondary).copyWith(letterSpacing: 1.5),
                ),
                const Icon(Icons.history_rounded, color: AppColors.secondary, size: 16),
              ],
            ),
          ),

          // Log List
          Column(
            children: List.generate(trades.length, (i) {
              final log = trades[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Arrow state circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: log.isBuy == null
                            ? Colors.white.withValues(alpha: 0.05)
                            : (log.isBuy! ? AppColors.primaryFixed.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1)),
                      ),
                      child: Icon(
                        log.isBuy == null
                            ? Icons.account_balance_rounded
                            : (log.isBuy! ? Icons.north_east_rounded : Icons.south_west_rounded),
                        color: log.isBuy == null
                            ? AppColors.secondary
                            : (log.isBuy! ? AppColors.primaryFixed : AppColors.error),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: log.title,
                              style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                              children: [
                                if (log.subtitle.isNotEmpty)
                                  TextSpan(
                                    text: ' ${log.subtitle}',
                                    style: AppTextStyles.labelSm(color: AppColors.secondary).copyWith(fontSize: 10),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(log.meta, style: AppTextStyles.labelSm(color: AppColors.secondary).copyWith(fontSize: 10)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          log.amount,
                          style: AppTextStyles.labelMd(
                            color: log.isBuy == true ? AppColors.primaryFixed : AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          log.state,
                          style: AppTextStyles.labelSm(color: AppColors.secondary).copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),

          // Footer
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                LanguageManager.translate('VIEW ALL STATEMENTS', 'TÜM EKSTRELERİ GÖRÜNTÜLE'),
                style: AppTextStyles.labelSm(color: AppColors.secondary).copyWith(letterSpacing: 1.5, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogItem {
  const _LogItem({
    required this.isBuy,
    required this.title,
    required this.meta,
    required this.subtitle,
    required this.amount,
    required this.state,
    required this.isFilled,
  });

  final bool? isBuy;
  final String title;
  final String meta;
  final String subtitle;
  final String amount;
  final String state;
  final bool isFilled;
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

// ── Advanced Line Chart Painter ──────────────────────────────────────────────
class _AdvancedChartPainter extends CustomPainter {
  _AdvancedChartPainter({
    required this.drawProgress,
    required this.pulseRadius,
    required this.touchX,
  });

  final double drawProgress;
  final double pulseRadius;
  final double? touchX;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 1000;
    final scaleY = size.height / 200;

    // Draw Grid Lines (horizontal)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Build Spline Path (from HTML coords)
    // Coords: M0,160 C100,150 150,180 250,140 C350,100 450,120 550,80 C650,40 850,70 1000,30
    final path = Path()..moveTo(0, 160 * scaleY);
    path.cubicTo(
      100 * scaleX, 150 * scaleY,
      150 * scaleX, 180 * scaleY,
      250 * scaleX, 140 * scaleY,
    );
    path.cubicTo(
      350 * scaleX, 100 * scaleY,
      450 * scaleX, 120 * scaleY,
      550 * scaleX, 80 * scaleY,
    );
    path.cubicTo(
      650 * scaleX, 40 * scaleY,
      850 * scaleX, 70 * scaleY,
      1000 * scaleX, 30 * scaleY,
    );

    // Extract path up to progress metric (dash array effect)
    final drawPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      drawPath.addPath(
        metric.extractPath(0.0, metric.length * drawProgress),
        Offset.zero,
      );
    }

    // Paint Area Fill
    if (drawProgress > 0) {
      final fillPath = Path.from(drawPath);
      // We close the path to bottom-right, then bottom-left, then close
      final lastPointX = size.width * drawProgress;
      fillPath.lineTo(lastPointX, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryFixed.withValues(alpha: 0.20),
            AppColors.primaryFixed.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    // Paint Neon Stroke Line
    final linePaint = Paint()
      ..color = AppColors.primaryFixed
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(drawPath, linePaint);

    // Draw reference candlestick points (at 250, 550, 1000 x coordinates)
    if (drawProgress >= 0.25) {
      final p1 = Offset(250 * scaleX, 140 * scaleY);
      canvas.drawCircle(p1, 3, Paint()..color = AppColors.primaryFixed);
      canvas.drawCircle(p1, pulseRadius, Paint()..color = AppColors.primaryFixed.withValues(alpha: 0.15)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
    if (drawProgress >= 0.55) {
      final p2 = Offset(550 * scaleX, 80 * scaleY);
      canvas.drawCircle(p2, 3, Paint()..color = AppColors.primaryFixed);
      canvas.drawCircle(p2, pulseRadius, Paint()..color = AppColors.primaryFixed.withValues(alpha: 0.15)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
    if (drawProgress >= 1.0) {
      final p3 = Offset(1000 * scaleX, 30 * scaleY);
      canvas.drawCircle(p3, 4, Paint()..color = AppColors.primaryFixed);
    }

    // Draw Vertical Interaction Tracker Line (touchX)
    if (touchX != null) {
      final trackerPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.primaryFixed.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(touchX!, 0, 1, size.height))
        ..strokeWidth = 1;
      canvas.drawLine(Offset(touchX!, 0), Offset(touchX!, size.height), trackerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AdvancedChartPainter oldDelegate) {
    return oldDelegate.drawProgress != drawProgress ||
        oldDelegate.pulseRadius != pulseRadius ||
        oldDelegate.touchX != touchX;
  }
}
