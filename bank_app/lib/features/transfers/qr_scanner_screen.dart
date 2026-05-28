import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';

class QrScannerScreen extends StatefulWidget {
  final int initialTab;
  const QrScannerScreen({super.key, this.initialTab = 0});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with TickerProviderStateMixin {
  // ── States ────────────────────────────────────────────────────────────────
  int _activeTab = 0; // 0 = Scan, 1 = My QR
  bool _flashlightOn = false;
  Timer? _autoScanTimer;

  // Animations
  late final AnimationController _scanLineCtrl;
  late final Animation<double> _scanLineAnim;

  late final AnimationController _tabPillCtrl;
  late final Animation<double> _tabPillAnim;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;

    // Scan line animation (y-axis translation)
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut),
    );

    // Tab switcher sliding animation
    _tabPillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.initialTab == 1 ? 1.0 : 0.0,
    );
    _tabPillAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tabPillCtrl, curve: Curves.easeOutCubic),
    );

    _startAutoScanTimer();
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _tabPillCtrl.dispose();
    _autoScanTimer?.cancel();
    super.dispose();
  }

  // ── Automatic Scan Simulation ──────────────────────────────────────────────
  void _startAutoScanTimer() {
    _autoScanTimer?.cancel();
    if (_activeTab != 0) return;

    _autoScanTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _simulateSuccessfulScan('Marcus T.');
      }
    });
  }

  void _simulateSuccessfulScan(String contactName) {
    HapticFeedback.heavyImpact();
    
    // Show a quick success dialog/overlay before popping
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryFixed, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryFixed.withValues(alpha: 0.15),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryFixed.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryFixed,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                 Text(
                  LanguageManager.translate('QR Code Scanned', 'QR Kod Tarandı'),
                  style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageManager.translate('Selected: $contactName', 'Seçilen: $contactName'),
                  style: AppTextStyles.bodyMd(color: AppColors.secondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Pop the dialog and then pop back to the transfer screen with the name
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.pop(context); // Pop dialog
        Navigator.pop(context, contactName); // Pop screen and return recipient name
      }
    });
  }

  // ── Gallery QR Pick Simulation ─────────────────────────────────────────────
  void _simulateGalleryPick() {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryFixed),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LanguageManager.translate('Analyzing image...', 'Görsel analiz ediliyor...'),
                  style: AppTextStyles.bodyMd(color: AppColors.primary),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context); // Pop loader
        _simulateSuccessfulScan('Elena R.');
      }
    });
  }

  // ── Tab Switch Logic ───────────────────────────────────────────────────────
  void _switchTab(int index) {
    if (_activeTab == index) return;
    HapticFeedback.selectionClick();

    setState(() {
      _activeTab = index;
    });

    if (index == 0) {
      _tabPillCtrl.reverse();
      _startAutoScanTimer();
    } else {
      _tabPillCtrl.forward();
      _autoScanTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        title: Text(
          'FINTECH ELITE',
          style: AppTextStyles.headlineMd().copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -1.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // ── Main Content Column
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Tab 0: Scanner Viewport
                    if (_activeTab == 0) ...[
                      // Camera Background Simulation
                      Positioned.fill(
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBh6SXuEe1CdDOyVoAn-l9XujvWywKz82AyXc5eSRgtR4rgulKY1dEh6PDw5ZeXHXZd-rcAJS4LO3MMGTwMpIkPLQWqBP3zd6T4nLTXqlS-I2cdrB-rlLDWpvLfgoJq01XV5Xz5nOQQbekg8Qx46tvLMdTFaaYPOGUI5RDFOdTitCAVVoLSMMaO9PplXthNk3-KxSH9GSSb6Kf9iJ5Z3paYO3l1n-iORkpW02i3cSHafbmYJ4bbe33mN6-uBAqxCXX4MXbAndcZiE3H',
                          fit: BoxFit.cover,
                          opacity: const AlwaysStoppedAnimation(0.4),
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF0C0C0C),
                          ),
                        ),
                      ),
                      // Dark overlay
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      // Scanner Guide Frame
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 280,
                              height: 280,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Stack(
                                children: [
                                  // Corner Brackets
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _ScannerFramePainter(color: AppColors.primaryFixed),
                                    ),
                                  ),
                                  // Animating Scan Line
                                  AnimatedBuilder(
                                    animation: _scanLineAnim,
                                    builder: (context, child) {
                                      final yPos = _scanLineAnim.value * 280;
                                      return Positioned(
                                        top: yPos,
                                        left: 8,
                                        right: 8,
                                        child: Container(
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryFixed,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryFixed.withValues(alpha: 0.8),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              LanguageManager.translate('ALIGN QR CODE WITHIN FRAME', 'QR KODU ÇERÇEVE İÇİNE HİZALAYIN'),
                              style: AppTextStyles.labelSm(color: AppColors.primaryFixed.withValues(alpha: 0.8)).copyWith(
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Tab 1: My QR Viewport
                    if (_activeTab == 1) ...[
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topCenter,
                              radius: 1.2,
                              colors: [
                                AppColors.primaryFixed.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glassmorphic Card containing QR
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  width: 300,
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: const Color(0x660F0F0F),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Glowing Frame for QR code
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryFixed.withValues(alpha: 0.2),
                                              blurRadius: 25,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: CustomPaint(
                                          painter: _MockQrCodePainter(),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Alex Mercer',
                                        style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        LanguageManager.translate('Main Checking Account', 'Ana Vadesiz Hesap'),
                                        style: AppTextStyles.bodyMd(color: AppColors.secondary),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: AppColors.surfaceContainerHighest),
                                        ),
                                        child: Text(
                                          LanguageManager.translate('Scan to pay instantly', 'Anında ödemek için tarayın'),
                                          style: AppTextStyles.labelSm(color: AppColors.primaryFixed),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Bottom Panel (Tab Switcher and Bento Grid)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                      Colors.black,
                    ],
                    stops: [0.0, 0.3, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tab Switcher
                    _buildTabSwitcher(),
                    const SizedBox(height: 24),

                    // Quick Pay Shortcuts Bento Grid
                    _buildBentoGrid(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab Switcher Widget ────────────────────────────────────────────────────
  Widget _buildTabSwitcher() {
    return Container(
      width: 240,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.surfaceContainerHighest),
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          // Sliding Indicator Pill
          AnimatedBuilder(
            animation: _tabPillAnim,
            builder: (context, child) {
              return Align(
                alignment: Alignment(-1.0 + (2.0 * _tabPillAnim.value), 0.0),
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryFixed.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchTab(0),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      LanguageManager.translate('Scan', 'Tara'),
                      style: AppTextStyles.labelMd(
                        color: _activeTab == 0 ? Colors.black : AppColors.secondary,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchTab(1),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      LanguageManager.translate('My QR', 'QR Kodum'),
                      style: AppTextStyles.labelMd(
                        color: _activeTab == 1 ? Colors.black : AppColors.secondary,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bento Grid Shortcuts ───────────────────────────────────────────────────
  Widget _buildBentoGrid() {
    return Row(
      children: [
        // Send Button
        Expanded(
          child: _buildBentoButton(
            icon: Icons.send_rounded,
            label: LanguageManager.translate('Send', 'Gönder'),
            isActive: true,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context); // Go back to TransferScreen
            },
          ),
        ),
        const SizedBox(width: 12),

        // Receive Button
        Expanded(
          child: _buildBentoButton(
            icon: Icons.download_rounded,
            label: LanguageManager.translate('Receive', 'Al'),
            isActive: true,
            onTap: () => _switchTab(1),
          ),
        ),
        const SizedBox(width: 12),

        // Flashlight Button
        Expanded(
          child: _buildBentoButton(
            icon: Icons.flashlight_on_rounded,
            label: LanguageManager.translate('Flashlight', 'Fener'),
            isActive: _flashlightOn,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _flashlightOn = !_flashlightOn;
              });
            },
          ),
        ),
        const SizedBox(width: 12),

        // Gallery Button
        Expanded(
          child: _buildBentoButton(
            icon: Icons.image_rounded,
            label: LanguageManager.translate('Gallery', 'Galeri'),
            isActive: false,
            onTap: _simulateGalleryPick,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primaryFixed.withValues(alpha: 0.3) : const Color(0xFF222222),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryFixed : AppColors.secondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSm(
                color: isActive ? AppColors.primaryFixed : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Painter to draw Scanner Frame Corner brackets ─────────────────────
class _ScannerFramePainter extends CustomPainter {
  _ScannerFramePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final length = 32.0;

    // Top Left corner
    canvas.drawLine(const Offset(0, 0), Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, length), paint);

    // Top Right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Bottom Left corner
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);

    // Bottom Right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Custom Painter to draw a mock glowing vector QR code ─────────────────────
class _MockQrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw position detection squares (Top Left, Top Right, Bottom Left)
    _drawFinderPattern(canvas, const Offset(0, 0), 45.0, paint);
    _drawFinderPattern(canvas, Offset(size.width - 45.0, 0), 45.0, paint);
    _drawFinderPattern(canvas, Offset(0, size.height - 45.0), 45.0, paint);

    // Draw some random high-fidelity grid data blocks
    final rng = List<int>.generate(80, (i) => (i * 3 + 7) % 11);
    final blockSize = size.width / 15;

    for (int col = 0; col < 15; col++) {
      for (int row = 0; row < 15; row++) {
        // Skip finder areas
        if (col < 5 && row < 5) continue;
        if (col >= 10 && row < 5) continue;
        if (col < 5 && row >= 10) continue;

        final index = (col * 15 + row) % rng.length;
        if (rng[index] % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(col * blockSize, row * blockSize, blockSize - 1, blockSize - 1),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Offset offset, double size, Paint paint) {
    // Outer square
    canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size, size), paint);
    
    // Middle white square
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + size / 7, offset.dy + size / 7, size * 5 / 7, size * 5 / 7),
      whitePaint,
    );

    // Inner square
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + size * 2 / 7, offset.dy + size * 2 / 7, size * 3 / 7, size * 3 / 7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
