import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Exchange Rates & Converter Screen
/// Implements "Exchange Rates & Converter" HTML mockup.
class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen>
    with TickerProviderStateMixin {
  // ── Entrance animation ─────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  static const int _sections = 4;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  // ── Converter state ────────────────────────────────────────────────────────
  String _inputAmount = '1250.00';
  String _fromCcy = 'USD';
  String _toCcy = 'EUR';
  bool _isExchanging = false;

  // Simulated fixed rates (USD base)
  static const Map<String, double> _rates = {
    'USD': 1.0,
    'EUR': 0.9187,
    'GBP': 0.7964,
    'BTC': 0.0000156,
    'ETH': 0.000289,
    'JPY': 153.21,
    'CHF': 0.9024,
  };

  double get _convertedAmount {
    final input = double.tryParse(_inputAmount.replaceAll(',', '')) ?? 0.0;
    final fromRate = _rates[_fromCcy] ?? 1.0;
    final toRate = _rates[_toCcy] ?? 1.0;
    return input / fromRate * toRate;
  }

  String get _convertedFormatted {
    final val = _convertedAmount;
    if (val >= 1000) {
      return val.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return val.toStringAsFixed(4);
  }

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == '⌫') {
        if (_inputAmount.isNotEmpty) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
          if (_inputAmount.isEmpty) _inputAmount = '0';
        }
      } else if (key == '.') {
        if (!_inputAmount.contains('.')) _inputAmount += '.';
      } else {
        if (_inputAmount == '0') {
          _inputAmount = key;
        } else {
          // Limit decimals to 2 places
          if (_inputAmount.contains('.')) {
            final parts = _inputAmount.split('.');
            if (parts[1].length < 2) _inputAmount += key;
          } else {
            _inputAmount += key;
          }
        }
      }
    });
  }

  void _swapCurrencies() {
    HapticFeedback.mediumImpact();
    setState(() {
      final tmp = _fromCcy;
      _fromCcy = _toCcy;
      _toCcy = tmp;
    });
  }

  Future<void> _exchange() async {
    if (_isExchanging) return;
    HapticFeedback.heavyImpact();
    setState(() => _isExchanging = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _isExchanging = false);
  }

  void _pickCurrency(bool isFrom) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CurrencyPickerSheet(
        selected: isFrom ? _fromCcy : _toCcy,
        currencies: _rates.keys.toList(),
        onSelect: (ccy) {
          setState(() {
            if (isFrom) {
              _fromCcy = ccy;
            } else {
              _toCcy = ccy;
            }
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnims = List.generate(_sections, (i) {
      final start = i * 0.12;
      final end = (start + 0.50).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entranceCtrl,
            curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });
    _slideAnims = List.generate(_sections, (i) {
      final start = i * 0.12;
      final end = (start + 0.50).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _entranceCtrl,
              curve: Interval(start, end, curve: Curves.easeOutCubic)));
    });
    _entranceCtrl.forward();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background.withValues(alpha: 0.9),
            elevation: 0,
            toolbarHeight: 64,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.80),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'FINTECH ELITE',
              style: AppTextStyles.headlineMd().copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.secondary),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryFixed, width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBwJZ9-dlXLy4L5KT1NAl9li0ZbfUesYd2850SPmN_gmPaLsin40924iB9COex_hcpmVZvhi4AqFaiQo3BN4fxFLA37nnW2f6RXMHyluntyhZOv-LtkdyQ8A6R0bA4Hb4tebtWBayVy1qVa7LnCDThV-yNsewDgO-BZLJeXXwFOLqkaSsGUIo1ji5p0S8FM29cio6_HkpZK5B9aeQVWOYt7yVC2Apibwr8EsYScQkTAEFNYawK_mCsJ3sxjjab5X1RQUYiAIKBVgMpK',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.person,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // ── Converter Section ─────────────────────────────────
                  _staggered(0, _buildConverterCard()),

                  const SizedBox(height: 28),

                  // ── Live Markets ─────────────────────────────────────
                  _staggered(1, _buildLiveMarketsHeader()),
                  const SizedBox(height: 16),
                  _staggered(2, _buildMarketGrid()),

                  const SizedBox(height: 28),

                  // ── Price Alerts ──────────────────────────────────────
                  _staggered(3, _buildPriceAlerts()),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Converter Card ─────────────────────────────────────────────────────────
  Widget _buildConverterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          // ── Send / Receive fields ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _AmountField(
                  label: 'YOU SEND',
                  value: _inputAmount,
                  currency: _fromCcy,
                  isOutput: false,
                  onCurrencyTap: () => _pickCurrency(true),
                ),
              ),
              const SizedBox(width: 12),
              // Swap button
              GestureDetector(
                onTap: _swapCurrencies,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: Color(0xFF161E00), size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AmountField(
                  label: 'THEY RECEIVE',
                  value: _convertedFormatted,
                  currency: _toCcy,
                  isOutput: true,
                  onCurrencyTap: () => _pickCurrency(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Rate hint ─────────────────────────────────────────────
          Text(
            '1 $_fromCcy = ${((_rates[_toCcy] ?? 1.0) / (_rates[_fromCcy] ?? 1.0)).toStringAsFixed(4)} $_toCcy',
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                .copyWith(letterSpacing: 0.3),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // ── Keypad ────────────────────────────────────────────────
          _buildKeypad(),

          const SizedBox(height: 20),

          // ── Exchange Now button ───────────────────────────────────
          GestureDetector(
            onTap: _exchange,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                color: _isExchanging
                    ? AppColors.primaryFixed.withValues(alpha: 0.7)
                    : AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _isExchanging
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF161E00),
                        ),
                      )
                    : Text(
                        'Exchange Now',
                        style: AppTextStyles.headlineMd().copyWith(
                          color: const Color(0xFF161E00),
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '.', '0', '⌫',
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: keys.map((k) => _KeypadButton(key: ValueKey(k), label: k, onTap: _onKeyTap)).toList(),
    );
  }

  // ── Live Markets Header ─────────────────────────────────────────────────────
  Widget _buildLiveMarketsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Live Markets',
            style: AppTextStyles.headlineLg().copyWith(fontSize: 24, letterSpacing: -0.5)),
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Row(
            children: [
              Text('View Analytics',
                  style: AppTextStyles.labelMd(color: AppColors.primaryFixed)
                      .copyWith(letterSpacing: 0.3)),
              const SizedBox(width: 4),
              const Icon(Icons.trending_up_rounded,
                  color: AppColors.primaryFixed, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ── Market Grid ─────────────────────────────────────────────────────────────
  Widget _buildMarketGrid() {
    const markets = [
      _MarketData(
        icon: Icons.euro_rounded,
        pair: 'EUR / USD',
        name: 'Euro',
        price: '1.0854',
        change: '+0.42%',
        isPositive: true,
        points: [35.0, 30.0, 32.0, 20.0, 25.0, 10.0, 5.0],
      ),
      _MarketData(
        icon: Icons.currency_bitcoin_rounded,
        pair: 'BTC / USD',
        name: 'Bitcoin',
        price: '64,281.00',
        change: '+2.84%',
        isPositive: true,
        points: [38.0, 30.0, 28.0, 20.0, 22.0, 12.0, 15.0, 5.0, 8.0],
      ),
      _MarketData(
        icon: Icons.currency_pound_rounded,
        pair: 'GBP / USD',
        name: 'British Pound',
        price: '1.2642',
        change: '-0.15%',
        isPositive: false,
        points: [5.0, 8.0, 15.0, 12.0, 25.0, 30.0, 35.0],
      ),
      _MarketData(
        icon: Icons.currency_exchange_rounded,
        pair: 'ETH / USD',
        name: 'Ethereum',
        price: '3,456.12',
        change: '+1.12%',
        isPositive: true,
        points: [30.0, 32.0, 28.0, 15.0, 18.0, 5.0, 8.0],
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.88,
      children: markets.map((m) => _MarketCard(data: m)).toList(),
    );
  }

  // ── Price Alerts ──────────────────────────────────────────────────────────
  Widget _buildPriceAlerts() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: AppColors.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRICE ALERTS',
                  style: AppTextStyles.labelMd(color: AppColors.secondary)
                      .copyWith(letterSpacing: 1.2),
                ),
                const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primaryFixed, size: 20),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1F1F1F)),
          _AlertRow(
            label: 'BTC Above 65,000 USD',
            sub: 'Triggered 2h ago',
            isActive: true,
          ),
          const Divider(height: 1, color: Color(0xFF1F1F1F)),
          _AlertRow(
            label: 'EUR/USD Drop Below 1.05',
            sub: 'Inactive',
            isActive: false,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Amount Input Field
// ══════════════════════════════════════════════════════════════════════════════
class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.label,
    required this.value,
    required this.currency,
    required this.isOutput,
    required this.onCurrencyTap,
  });
  final String label;
  final String value;
  final String currency;
  final bool isOutput;
  final VoidCallback onCurrencyTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm(color: AppColors.secondary)
              .copyWith(letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF353535)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineMd().copyWith(
                  fontSize: 18,
                  color: isOutput ? AppColors.primaryFixed : AppColors.primary,
                  fontFamily: 'JetBrains Mono',
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onCurrencyTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency,
                        style: AppTextStyles.labelMd(color: AppColors.primary)
                            .copyWith(letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.expand_more_rounded,
                          color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Keypad Button
// ══════════════════════════════════════════════════════════════════════════════
class _KeypadButton extends StatefulWidget {
  const _KeypadButton({
    super.key,
    required this.label,
    required this.onTap,
  });
  final String label;
  final ValueChanged<String> onTap;

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  bool get _isDelete => widget.label == '⌫';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) async {
        await _scaleCtrl.reverse();
        widget.onTap(widget.label);
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: _isDelete
                ? AppColors.error.withValues(alpha: 0.08)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isDelete
                  ? AppColors.error.withValues(alpha: 0.3)
                  : const Color(0xFF333333),
            ),
          ),
          child: Center(
            child: _isDelete
                ? Icon(Icons.backspace_outlined,
                    color: AppColors.error, size: 20)
                : Text(
                    widget.label,
                    style: AppTextStyles.headlineMd().copyWith(fontSize: 18),
                  ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Market Card + Sparkline
// ══════════════════════════════════════════════════════════════════════════════
class _MarketData {
  const _MarketData({
    required this.icon,
    required this.pair,
    required this.name,
    required this.price,
    required this.change,
    required this.isPositive,
    required this.points,
  });
  final IconData icon;
  final String pair;
  final String name;
  final String price;
  final String change;
  final bool isPositive;
  final List<double> points;
}

class _MarketCard extends StatefulWidget {
  const _MarketCard({required this.data});
  final _MarketData data;

  @override
  State<_MarketCard> createState() => _MarketCardState();
}

class _MarketCardState extends State<_MarketCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _sparkCtrl;
  late final Animation<double> _sparkAnim;

  @override
  void initState() {
    super.initState();
    _sparkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _sparkAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _sparkCtrl,
      curve: Curves.easeOut,
    ));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _sparkCtrl.forward();
    });
  }

  @override
  void dispose() {
    _sparkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = widget.data.isPositive ? AppColors.primaryFixed : AppColors.error;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF141414) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? (widget.data.isPositive
                    ? AppColors.primaryFixed.withValues(alpha: 0.5)
                    : AppColors.error.withValues(alpha: 0.5))
                : const Color(0xFF333333),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + pair + price ─────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.data.icon,
                          color: AppColors.primaryFixed, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.pair,
                          style: AppTextStyles.headlineMd()
                              .copyWith(fontSize: 13),
                        ),
                        Text(
                          widget.data.name,
                          style: AppTextStyles.labelSm(
                                  color: AppColors.secondary)
                              .copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Price + change ──────────────────────────────────────
            Text(
              widget.data.price,
              style: AppTextStyles.headlineMd().copyWith(
                fontSize: 16,
                fontFamily: 'JetBrains Mono',
                letterSpacing: -0.3,
              ),
            ),
            Text(
              widget.data.change,
              style: AppTextStyles.labelSm(color: lineColor)
                  .copyWith(letterSpacing: 0.3),
            ),

            const Spacer(),

            // ── Sparkline ───────────────────────────────────────────
            SizedBox(
              height: 48,
              child: AnimatedBuilder(
                animation: _sparkAnim,
                builder: (context, _) => CustomPaint(
                  painter: _SparklinePainter(
                    points: widget.data.points,
                    progress: _sparkAnim.value,
                    color: lineColor,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Sparkline Painter
// ══════════════════════════════════════════════════════════════════════════════
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.points,
    required this.progress,
    required this.color,
  });
  final List<double> points;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Normalize y-values to canvas height
    final minY = points.reduce(math.min);
    final maxY = points.reduce(math.max);
    final rangeY = (maxY - minY).clamp(1.0, double.infinity);
    final padding = 4.0;

    Offset offset(int i) {
      final x = i / (points.length - 1) * size.width;
      final y = ((points[i] - minY) / rangeY) * (size.height - padding * 2) + padding;
      return Offset(x, y);
    }

    // Build full path
    final fullPath = Path();
    fullPath.moveTo(offset(0).dx, offset(0).dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = offset(i);
      final p2 = offset(i + 1);
      final cp1 = Offset((p1.dx + p2.dx) / 2, p1.dy);
      final cp2 = Offset((p1.dx + p2.dx) / 2, p2.dy);
      fullPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    // Clip to reveal progress
    final clipRect = Rect.fromLTWH(0, 0, size.width * progress, size.height);
    canvas.clipRect(clipRect);

    // Gradient fill under the line
    final fillPath = Path.from(fullPath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullPath, linePaint);

    // End dot
    if (progress > 0.9) {
      final lastPt = offset(points.length - 1);
      canvas.drawCircle(
          lastPt,
          3.5,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          lastPt,
          5.5,
          Paint()
            ..color = color.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress || old.color != color;
}

// ══════════════════════════════════════════════════════════════════════════════
// Alert Row
// ══════════════════════════════════════════════════════════════════════════════
class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.label,
    required this.sub,
    required this.isActive,
  });
  final String label;
  final String sub;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => HapticFeedback.lightImpact(),
      splashColor: AppColors.primaryFixed.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primaryFixed : const Color(0xFF353535),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primaryFixed.withValues(alpha: 0.4),
                          blurRadius: 6,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: AppTextStyles.labelSm(
                              color: AppColors.secondary)
                          .copyWith(letterSpacing: 0.2)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Currency Picker Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════════
class _CurrencyPickerSheet extends StatelessWidget {
  const _CurrencyPickerSheet({
    required this.selected,
    required this.currencies,
    required this.onSelect,
  });
  final String selected;
  final List<String> currencies;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Color(0xFF333333)),
          left: BorderSide(color: Color(0xFF333333)),
          right: BorderSide(color: Color(0xFF333333)),
        ),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'SELECT CURRENCY',
            style: AppTextStyles.labelMd(color: AppColors.secondary)
                .copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          ...currencies.map((ccy) => InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSelect(ccy);
                  Navigator.of(context).pop();
                },
                splashColor: AppColors.primaryFixed.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ccy,
                        style: AppTextStyles.bodyMd(color: AppColors.primary)
                            .copyWith(fontFamily: 'JetBrains Mono'),
                      ),
                      if (ccy == selected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.primaryFixed, size: 18),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
