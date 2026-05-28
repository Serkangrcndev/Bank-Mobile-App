import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';

class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({
    super.key,
    required this.cardType,
    required this.last4,
    required this.balance,
  });

  final String cardType;
  final String last4;
  final String balance;

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen>
    with TickerProviderStateMixin {
  // ── Card Control States ───────────────────────────────────────────────────
  bool _isLocked = false;
  bool _contactlessEnabled = true;
  bool _onlineUseEnabled = true;
  double _monthlyLimit = 4500.0;
  final double _maxLimit = 10000.0;

  // ── Floating & 3D Tilt Animations ─────────────────────────────────────────
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // User-driven 3D tilt coordinates
  double _tiltX = 0.0; // Rotation around X-axis (tilt up/down)
  double _tiltY = 0.0; // Rotation around Y-axis (tilt left/right)
  bool _isTilted = false;

  // Tones of bento card hover-effect highlights
  int _hoveredTile = -1;

  @override
  void initState() {
    super.initState();

    // Floating animation (smooth sinusoidal vertical float)
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  void _onTileTap(int tileIndex, bool currentValue, ValueChanged<bool> onChanged) {
    HapticFeedback.mediumImpact();
    setState(() {
      onChanged(!currentValue);
    });
  }

  void _onChangePin() {
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
              LanguageManager.translate('PIN change instructions sent to your email', 'PIN değiştirme talimatları e-postanıza gönderildi'),
              style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontSize: 14),
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
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
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
        title: RichText(
          text: TextSpan(
            text: 'FINTECH ',
            style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(
                text: 'ELITE',
                style: TextStyle(color: AppColors.primaryFixed),
              ),
            ],
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Radial glow background layer
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withValues(alpha: 0.025),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 3D Card Display ──────────────────────────────────────────
                  _buildInteractiveCardSection(),
                  const SizedBox(height: 32),

                  // ── Bento Controls & Spend Limits ────────────────────────────
                  _buildControlsAndLimitsGrid(),
                  const SizedBox(height: 32),

                  // ── Recent Activity ──────────────────────────────────────────
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3D Floating & Interactive Tilt Card ────────────────────────────────────
  Widget _buildInteractiveCardSection() {
    return Center(
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isTilted = true;
          });
        },
        onPanUpdate: (details) {
          // Calculate relative tilt angles on finger drag
          // Limits rotation to roughly ±15 degrees (0.26 radians)
          final RenderBox box = context.findRenderObject() as RenderBox;
          final cardCenter = Offset(box.size.width / 2, 200 / 2); // approximate dimensions
          final touchOffset = details.localPosition;
          
          final dx = (touchOffset.dx - cardCenter.dx) / (box.size.width / 2);
          final dy = (touchOffset.dy - cardCenter.dy) / 100.0;

          setState(() {
            _tiltY = dx.clamp(-1.0, 1.0) * 15 * (math.pi / 180);
            _tiltX = -dy.clamp(-1.0, 1.0) * 15 * (math.pi / 180);
          });
        },
        onPanEnd: (_) {
          // Snap back smoothly when touch ends
          setState(() {
            _isTilted = false;
            _tiltX = 0.0;
            _tiltY = 0.0;
          });
        },
        child: AnimatedBuilder(
          animation: _floatAnim,
          builder: (context, child) {
            // Combine vertical float and user 3D tilt transform
            final Matrix4 transformMatrix = Matrix4.identity()
              ..setEntry(3, 2, 0.0015); // perspective factor
            
            if (_isTilted) {
              transformMatrix
                ..rotateX(_tiltX)
                ..rotateY(_tiltY);
            } else {
              transformMatrix.translateByDouble(0.0, _floatAnim.value, 0.0, 1.0);
            }

            return Transform(
              alignment: FractionalOffset.center,
              transform: transformMatrix,
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primaryFixed.withValues(alpha: 0.05),
                  blurRadius: 40,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Diagonal overlay pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: _CardPatternPainter(),
                    ),
                  ),
                ),

                // Glassmorphism reflection overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card details positioning
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Row: Elite Card Logo & Contactless Symbol
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'ELITE',
                              style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 18,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'CARD',
                                  style: TextStyle(color: AppColors.primaryFixed),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.contactless_rounded,
                            color: AppColors.primaryFixed,
                            size: 26,
                          ),
                        ],
                      ),

                      // Smart Chip Design
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildSmartChip(),
                      ),

                      // Card Numbers & Expiry
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '4920  ••••  ••••  ${widget.last4}',
                            style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
                              letterSpacing: 2.5,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LanguageManager.translate('CARD HOLDER', 'KART SAHİBİ'),
                                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)).copyWith(
                                      fontSize: 8,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    LanguageManager.translate('ELITE MEMBER', 'ELİT ÜYE'),
                                    style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LanguageManager.translate('EXPIRY', 'SON KULLANMA'),
                                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)).copyWith(
                                      fontSize: 8,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '12/28',
                                    style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              // Visa-like brand circular decals
                              _buildBrandDecals(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartChip() {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          // Gradient shine
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryFixed.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Microgrid
          GridView.builder(
            padding: const EdgeInsets.all(5),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, i) {
              if (i == 4) return const SizedBox.shrink(); // empty center
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.primaryFixed.withValues(alpha: 0.3), width: 0.5),
                    right: BorderSide(color: AppColors.primaryFixed.withValues(alpha: 0.3), width: 0.5),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrandDecals() {
    return SizedBox(
      width: 42,
      height: 26,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withValues(alpha: 0.75),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bento Controls & Spend Limits Panel ───────────────────────────────────
  Widget _buildControlsAndLimitsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Lock Card Tile
        _buildBentoControlTile(
          index: 0,
          icon: Icons.lock_rounded,
          title: LanguageManager.translate('Lock Card', 'Kartı Kilitle'),
          subtitle: LanguageManager.translate('Instantly freeze all activity', 'Tüm işlemleri anında dondur'),
          value: _isLocked,
          onChanged: (val) => _isLocked = val,
          iconColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: 12),

        // 2. Contactless Tile
        _buildBentoControlTile(
          index: 1,
          icon: Icons.wifi_tethering_rounded,
          title: LanguageManager.translate('Contactless', 'Temassız'),
          subtitle: LanguageManager.translate('Tap to pay enabled', 'Temassız ödeme aktif'),
          value: _contactlessEnabled,
          onChanged: (val) => _contactlessEnabled = val,
          iconColor: Colors.white,
        ),
        const SizedBox(height: 12),

        // 3. Online Transactions Tile
        _buildBentoControlTile(
          index: 2,
          icon: Icons.language_rounded,
          title: LanguageManager.translate('Online Use', 'İnternet Alışverişi'),
          subtitle: LanguageManager.translate('Web and app purchases', 'Web ve uygulama içi harcamalar'),
          value: _onlineUseEnabled,
          onChanged: (val) => _onlineUseEnabled = val,
          iconColor: Colors.white,
        ),
        const SizedBox(height: 24),

        // 4. Spending Limit Panel
        _buildSpendingLimitCard(),
        const SizedBox(height: 24),

        // 5. PIN Action Button
        GestureDetector(
          onTapDown: (_) => setState(() => _hoveredTile = 99),
          onTapCancel: () => setState(() => _hoveredTile = -1),
          onTapUp: (_) {
            setState(() => _hoveredTile = -1);
            _onChangePin();
          },
          child: AnimatedScale(
            scale: _hoveredTile == 99 ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryFixed.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.password_rounded, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    LanguageManager.translate('Change Card PIN', 'Kart Şifresini Değiştir'),
                    style: AppTextStyles.headlineMd(color: Colors.black).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoControlTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconColor,
  }) {
    final isPressed = _hoveredTile == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _hoveredTile = index),
      onTapCancel: () => setState(() => _hoveredTile = -1),
      onTapUp: (_) {
        setState(() => _hoveredTile = -1);
        _onTileTap(index, value, onChanged);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPressed ? const Color(0xFF393939) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPressed ? AppColors.primaryFixed.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            // Left Icon Box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),

            // Custom Switch
            _buildCustomSwitch(value, onChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          onChanged(!value);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          color: value ? AppColors.primaryFixed : AppColors.surfaceContainerHighest,
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? Colors.black : AppColors.onSurfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingLimitCard() {
    final percentage = ((_monthlyLimit / _maxLimit) * 100).round();
    final formattedLimit = '\$${_monthlyLimit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Text & Percent Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LanguageManager.translate('MONTHLY LIMIT', 'AYLIK LİMİT'),
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formattedLimit,
                        style: AppTextStyles.headlineLg(color: AppColors.primary).copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '/ \$10,000',
                        style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom visual track bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _monthlyLimit / _maxLimit,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryFixed.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Slider theme customization
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: Colors.transparent, // handeled by custom visual track above
              inactiveTrackColor: Colors.transparent,
              thumbColor: AppColors.primaryFixed,
              overlayColor: AppColors.primaryFixed.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 4,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _monthlyLimit,
              min: 0,
              max: _maxLimit,
              divisions: 100,
              onChanged: (val) {
                setState(() {
                  _monthlyLimit = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Activity Section ────────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final activities = [
      ('Nobu Downtown', LanguageManager.translate('Dining • Today, 20:45', 'Yemek • Bugün, 20:45'), '-\$340.50', Icons.restaurant_rounded, true),
      ('Apple Store', LanguageManager.translate('Electronics • Yesterday, 14:20', 'Elektronik • Dün, 14:20'), '-\$1,299.00', Icons.shopping_bag_rounded, false),
      ('Uber Trip', LanguageManager.translate('Transport • Oct 24, 09:15', 'Ulaşım • 24 Eki, 09:15'), '-\$42.10', Icons.local_taxi_rounded, false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LanguageManager.translate('Recent Activity', 'Son Harcamalar'),
              style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              LanguageManager.translate('See All', 'Tümünü Gör'),
              style: AppTextStyles.labelMd(color: AppColors.primaryFixed).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Activity list bento panel
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: List.generate(activities.length, (i) {
              final (merchant, meta, amount, icon, isHighlighted) = activities[i];
              final isLast = i == activities.length - 1;

              return Container(
                decoration: BoxDecoration(
                  border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                    },
                    borderRadius: BorderRadius.vertical(
                      top: i == 0 ? const Radius.circular(24) : Radius.zero,
                      bottom: isLast ? const Radius.circular(24) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Left Icon Circle
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Icon(
                              icon,
                              color: isHighlighted ? AppColors.primaryFixed : Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Text Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  merchant,
                                  style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  meta,
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          ),

                          // Right amount display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                amount,
                                style: AppTextStyles.labelMd(color: AppColors.primary).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                LanguageManager.translate('APPROVED', 'ONAYLANDI'),
                                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)).copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Custom Painter: Background Card Pattern ─────────────────────────────────
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1.0;

    const double spacing = 12.0;
    // Draw 45 degree repeating lines
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
