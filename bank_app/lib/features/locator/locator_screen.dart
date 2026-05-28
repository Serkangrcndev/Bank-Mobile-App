import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../notifications/notifications_screen.dart';

class LocatorScreen extends StatefulWidget {
  const LocatorScreen({super.key});

  @override
  State<LocatorScreen> createState() => _LocatorScreenState();
}

class _LocatorScreenState extends State<LocatorScreen> with TickerProviderStateMixin {
  // ── Animation Controllers
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _staggerCount = 3;

  // Map Pan-Zoom Animation Controllers
  late final TransformationController _transformationController;
  late final AnimationController _mapAnimCtrl;
  Animation<Matrix4>? _mapMatrixAnim;

  // ── States
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  String _activeFilter = 'ALL'; // ALL, BRANCH, ATM, OPEN
  _LocatorLocation? _selectedLocation;
  bool _isCalculatingRoute = false;

  // Simulated Locations Database
  final List<_LocatorLocation> _allLocations = [
    const _LocatorLocation(
      id: 'wall_street',
      title: 'Wall Street Flagship',
      type: 'BRANCH',
      distance: '0.4 miles away',
      isOpen: true,
      openLabel: 'Open',
      address: '11 Wall St, New York, NY 10005',
      services: ['Cash Deposit', 'Advisory'],
      serviceIcons: [Icons.payments_outlined, Icons.support_agent_rounded],
      x: 400.0,
      y: 350.0,
    ),
    const _LocatorLocation(
      id: 'broadway_atm',
      title: 'Broadway Hub ATM',
      type: 'ATM',
      distance: '1.2 miles away',
      isOpen: true,
      openLabel: 'Open 24/7',
      address: '120 Broadway, New York, NY 10271',
      services: ['Multi-Currency'],
      serviceIcons: [Icons.currency_exchange_rounded],
      x: 580.0,
      y: 520.0,
    ),
    const _LocatorLocation(
      id: 'battery_park',
      title: 'Battery Park Branch',
      type: 'BRANCH',
      distance: '2.8 miles away',
      isOpen: false,
      openLabel: 'Closed',
      address: '17 Battery Pl, New York, NY 10004',
      services: ['Advisory'],
      serviceIcons: [Icons.support_agent_rounded],
      x: 320.0,
      y: 720.0,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Stagger entrance animations
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_staggerCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.40).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Map control
    _transformationController = TransformationController();
    _mapAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initial position of the map (centered, slight zoom)
    final double initialZoom = 1.25;
    _transformationController.value = Matrix4.identity()
      ..setEntry(0, 3, -220.0)
      ..setEntry(1, 3, -180.0)
      ..scaleByDouble(initialZoom, initialZoom, 1.0, 1.0);

    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text;
      });
    });

    // Start entrance
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _transformationController.dispose();
    _mapAnimCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
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

  // ── Pan and Zoom Map to Coordinates
  void _animateMapTo(double x, double y, double zoom) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    
    // Coordinates targeting viewport center
    final double viewW = isDesktop ? size.width - 380 : size.width;
    final double viewH = size.height - 80;

    final targetX = viewW / 2 - x * zoom;
    // slightly offset Y so bottom sheet on mobile doesn't cover targeted marker completely
    final targetY = (isDesktop ? viewH / 2 : viewH / 2.8) - y * zoom;

    final Matrix4 startMatrix = _transformationController.value;
    final Matrix4 endMatrix = Matrix4.identity()
      ..setEntry(0, 3, targetX)
      ..setEntry(1, 3, targetY)
      ..scaleByDouble(zoom, zoom, 1.0, 1.0);

    _mapAnimCtrl.reset();
    _mapMatrixAnim = Matrix4Tween(begin: startMatrix, end: endMatrix).animate(
      CurvedAnimation(parent: _mapAnimCtrl, curve: Curves.easeInOutCubic),
    )..addListener(() {
        _transformationController.value = _mapMatrixAnim!.value;
      });

    _mapAnimCtrl.forward();
  }

  // ── Select Location handler
  void _selectLocation(_LocatorLocation loc) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedLocation = loc;
    });
    // Smooth scroll map to center on location pin, with zoom level 2.0
    _animateMapTo(loc.x, loc.y, 2.0);
  }

  // ── Get Directions
  void _calculateDirections(_LocatorLocation loc) {
    HapticFeedback.heavyImpact();
    setState(() {
      _isCalculatingRoute = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isCalculatingRoute = false;
      });

      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0C0C0C),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFCCFF00), width: 1.0),
          ),
          content: Row(
            children: [
              const Icon(Icons.navigation_rounded, color: Color(0xFFCCFF00)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Route generated to ${loc.title}. Navigating via Apple/Google Maps...',
                  style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    // Filter database
    final filteredList = _allLocations.where((loc) {
      // Keyword match
      final queryLower = _query.toLowerCase();
      final matchKeyword = loc.title.toLowerCase().contains(queryLower) ||
          loc.address.toLowerCase().contains(queryLower) ||
          loc.services.any((s) => s.toLowerCase().contains(queryLower));

      if (!matchKeyword) return false;

      // Category filter match
      if (_activeFilter == 'BRANCH') return loc.type == 'BRANCH';
      if (_activeFilter == 'ATM') return loc.type == 'ATM';
      if (_activeFilter == 'OPEN') return loc.isOpen;

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Map Canvas (Fills the behind)
          Positioned.fill(
            child: _buildMapCanvas(filteredList),
          ),

          // ── Custom sticky header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildStickyAppBar(),
          ),

          // ── Search Overlay & Filter Chips (Stagger 0)
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 20,
            right: isDesktop ? 400 : 20,
            child: _staggered(0, _buildSearchAndFilterSection()),
          ),

          // ── Locations List Layout (Responsive)
          if (isDesktop)
            // Desktop floating sidebar
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              right: 20,
              bottom: 24,
              width: 360,
              child: _staggered(1, _buildLocationsSidebar(filteredList)),
            )
          else
            // Mobile bottom sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _staggered(1, _buildLocationsBottomSheet(filteredList)),
            ),

          // Route calculating spinner
          if (_isCalculatingRoute)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFCCFF00)),
                      SizedBox(height: 16),
                      Text(
                        'CALCULATING ROUTE...',
                        style: TextStyle(color: Color(0xFFCCFF00), fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Map Canvas Widget
  Widget _buildMapCanvas(List<_LocatorLocation> list) {
    return GestureDetector(
      onTap: () {
        // Clear focus from search field
        _searchFocus.unfocus();
      },
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 3.5,
        boundaryMargin: const EdgeInsets.all(500),
        child: SizedBox(
          width: 1000,
          height: 1000,
          child: Stack(
            children: [
              // Aerial dark night grid NYC background map
              Positioned.fill(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA9BkRcU4XPSkHdtUU66fiUlD2c3kC6HLNmjg0zTXUJIG3eICnuPX4voATkod0L1icVpsJ2Gk1qcNxzRu0C_eW0_yYkkc8ODSlC_AsFdj1rQKVA1q1D_HHSVKv03feZM5BZ0QApkSiJ0YGV4R9qDGM4TTz65begu3Y_vDL4jTJ1JYpVHdqt2ESIjVLzO79z6N4gfsESxrm9ItRa-kKDqiJmpiEBBXbreAp0Zgl-Lf2jijzlGFADybZYMYtAkROmVISIMEcYE95MRw6n',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F0F0F)),
                ),
              ),

              // Cyber-punk lighting / grid dark overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.85,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // Interactive Markers (Map Pins)
              for (final loc in list) _buildMapMarker(loc),
            ],
          ),
        ),
      ),
    );
  }

  // Map pin item renderer
  Widget _buildMapMarker(_LocatorLocation loc) {
    final isSelected = _selectedLocation?.id == loc.id;

    return Positioned(
      left: loc.x - 20,
      top: loc.y - 20,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Pulse halo animation for selected pins
          if (isSelected)
            _PulseHaloWidget(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
                ),
              ),
            ),

          // Marker button itself
          GestureDetector(
            onTap: () => _selectLocation(loc),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 40 : 32,
              height: isSelected ? 40 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: loc.type == 'BRANCH' ? const Color(0xFFCCFF00) : const Color(0xFF131313),
                border: Border.all(
                  color: const Color(0xFFCCFF00),
                  width: loc.type == 'BRANCH' ? 0.0 : 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                    blurRadius: isSelected ? 12 : 6,
                    spreadRadius: isSelected ? 2 : 0,
                  )
                ],
              ),
              child: Icon(
                loc.type == 'BRANCH' ? Icons.account_balance : Icons.atm,
                color: loc.type == 'BRANCH' ? Colors.black : const Color(0xFFCCFF00),
                size: isSelected ? 20 : 16,
              ),
            ),
          ),

          // Hover / Tap Tooltip above pin
          if (isSelected)
            Positioned(
              bottom: 48,
              child: _staggered(
                0,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C0C).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc.title,
                        style: AppTextStyles.labelMd(color: const Color(0xFFCCFF00)).copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.address.split(',')[0], // show street only
                        style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Top Sticky App Bar
  Widget _buildStickyAppBar() {
    return ClipRRect(
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
            color: const Color(0xFF131313).withValues(alpha: 0.1),
            border: const Border(
              bottom: BorderSide(color: Color(0xFF353535), width: 1),
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
                  Text(
                    'FINTECH ELITE',
                    style: AppTextStyles.labelMd(color: Colors.white).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2 * 14,
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
                  alignment: Alignment.center,
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search & Filter Section Widget
  Widget _buildSearchAndFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Search Input Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFFA1A1A1), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  cursorColor: const Color(0xFFCCFF00),
                  style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Search city, zip, or branch name...',
                    hintStyle: AppTextStyles.bodyMd(color: const Color(0xFF474746)),
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _searchCtrl.clear();
                  },
                  child: const Icon(Icons.close_rounded, color: Color(0xFFA1A1A1), size: 18),
                ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                height: 24,
                width: 1.5,
                color: const Color(0xFF333333),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  // Simulate GPS locate near me
                  _animateMapTo(480.0, 520.0, 1.6);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF0C0C0C),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFCCFF00), width: 1.0),
                      ),
                      content: Row(
                        children: [
                          const Icon(Icons.my_location_rounded, color: Color(0xFFCCFF00)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Centered to your GPS location (New York, NY)',
                              style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Text(
                  'NEAR ME',
                  style: AppTextStyles.labelSm(color: const Color(0xFFCCFF00)).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Filter Chips Row
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildFilterChip(id: 'ALL', label: 'All Locations', icon: Icons.tune_rounded),
              _buildFilterChip(id: 'BRANCH', label: 'Branches'),
              _buildFilterChip(id: 'ATM', label: 'ATMs'),
              _buildFilterChip(id: 'OPEN', label: 'Open Now'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({required String id, required String label, IconData? icon}) {
    final isActive = _activeFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _activeFilter = id;
            // Clear selected if it is filtered out
            if (id != 'ALL' && _selectedLocation != null) {
              final loc = _selectedLocation!;
              if (id == 'BRANCH' && loc.type != 'BRANCH') _selectedLocation = null;
              if (id == 'ATM' && loc.type != 'ATM') _selectedLocation = null;
              if (id == 'OPEN' && !loc.isOpen) _selectedLocation = null;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFCCFF00) : const Color(0xFF0C0C0C).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isActive ? const Color(0xFFCCFF00) : const Color(0xFF333333),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: isActive ? Colors.black : Colors.white, size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isActive ? Colors.black : const Color(0xFFA1A1A1),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Responsive: Locations Sidebar Layout (Desktop)
  Widget _buildLocationsSidebar(List<_LocatorLocation> list) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPanelHeader(list.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, idx) => _buildLocationCard(list[idx]),
                ),
              ),
              _buildPanelFooter(list),
            ],
          ),
        ),
      ),
    );
  }

  // ── Responsive: Locations Bottom Sheet Layout (Mobile)
  Widget _buildLocationsBottomSheet(List<_LocatorLocation> list) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 350,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C).withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              _buildPanelHeader(list.length),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, idx) => Container(
                    margin: const EdgeInsets.only(right: 16),
                    width: 280,
                    child: _buildLocationCard(list[idx]),
                  ),
                ),
              ),
              _buildPanelFooter(list),
            ],
          ),
        ),
      ),
    );
  }

  // ── Panel Components
  Widget _buildPanelHeader(int resultsCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nearby Locations',
            style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$resultsCount Results',
              style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelFooter(List<_LocatorLocation> list) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCCFF00),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (list.isNotEmpty) {
              // Get nearest
              _calculateDirections(list.first);
            }
          },
          child: const Text(
            'DIRECTIONS TO NEAREST',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  // ── Individual Card Widget
  Widget _buildLocationCard(_LocatorLocation loc) {
    final isSelected = _selectedLocation?.id == loc.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectLocation(loc),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF131313) : const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFCCFF00) : const Color(0xFF333333),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.title,
                          style: AppTextStyles.labelMd(
                            color: isSelected ? const Color(0xFFCCFF00) : Colors.white,
                          ).copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.distance,
                          style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: loc.isOpen
                          ? const Color(0xFFCCFF00).withValues(alpha: 0.1)
                          : AppColors.errorContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      loc.openLabel.toUpperCase(),
                      style: TextStyle(
                        color: loc.isOpen ? const Color(0xFFCCFF00) : AppColors.error,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                loc.address,
                style: AppTextStyles.bodyMd(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(loc.services.length, (idx) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B1B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(loc.serviceIcons[idx], size: 10, color: const Color(0xFFA1A1A1)),
                        const SizedBox(width: 4),
                        Text(
                          loc.services[idx],
                          style: AppTextStyles.labelSm(color: const Color(0xFFA1A1A1)).copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Model Class
class _LocatorLocation {
  const _LocatorLocation({
    required this.id,
    required this.title,
    required this.type,
    required this.distance,
    required this.isOpen,
    required this.openLabel,
    required this.address,
    required this.services,
    required this.serviceIcons,
    required this.x,
    required this.y,
  });

  final String id;
  final String title;
  final String type; // BRANCH, ATM
  final String distance;
  final bool isOpen;
  final String openLabel;
  final String address;
  final List<String> services;
  final List<IconData> serviceIcons;
  final double x;
  final double y;
}

// ── Animated Pulse Halo widget
class _PulseHaloWidget extends StatefulWidget {
  const _PulseHaloWidget({required this.child});
  final Widget child;

  @override
  State<_PulseHaloWidget> createState() => _PulseHaloWidgetState();
}

class _PulseHaloWidgetState extends State<_PulseHaloWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _anim = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: widget.child,
    );
  }
}
