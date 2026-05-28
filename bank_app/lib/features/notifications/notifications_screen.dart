import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/language_manager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const int _maxInitialItems = 6;

  // ── Active Filter ─────────────────────────────────────────────────────────
  String _activeFilter = 'All Activity';

  // ── Notifications Data ────────────────────────────────────────────────────
  List<_NotificationItemData> get _allNotifications => [
    _NotificationItemData(
      id: '1',
      category: 'Security',
      title: LanguageManager.translate('New Login Detected', 'Yeni Giriş Tespit Edildi'),
      time: LanguageManager.translate('Just now', 'Şimdi'),
      body: LanguageManager.translate(
        'A login occurred from a new device (MacBook Pro) in London, UK. If this wasn\'t you, secure your account immediately.',
        'Londra, Birleşik Krallık\'ta yeni bir cihazdan (MacBook Pro) giriş tespit edildi. Bu siz değilseniz, hesabınızı hemen güvenceye alın.',
      ),
      isUnread: true,
      hasActions: true,
      icon: Icons.security_rounded,
    ),
    _NotificationItemData(
      id: '2',
      category: 'Transactions',
      title: LanguageManager.translate('Deposit Confirmed', 'Yatırım Onaylandı'),
      time: LanguageManager.translate('2h ago', '2s önce'),
      body: LanguageManager.translate(
        'Your deposit of 2.4500 BTC has been successfully credited to your main trading account.',
        '2.4500 BTC tutarındaki yatırımınız ana işlem hesabınıza başarıyla yatırıldı.',
      ),
      isUnread: false,
      hasActions: false,
      icon: Icons.swap_horiz_rounded,
    ),
    _NotificationItemData(
      id: '3',
      category: 'Transactions',
      title: LanguageManager.translate('Withdrawal Initiated', 'Çekim Başlatıldı'),
      time: LanguageManager.translate('Yesterday', 'Dün'),
      body: LanguageManager.translate(
        'A withdrawal of 10,000.00 USDC is currently processing. Network confirmations pending.',
        '10.000,00 USDC tutarındaki çekim işleminiz şu anda işleniyor. Ağ onayları bekleniyor.',
      ),
      isUnread: false,
      hasActions: false,
      icon: Icons.call_made_rounded,
    ),
    _NotificationItemData(
      id: '4',
      category: 'Promotions',
      title: LanguageManager.translate('Zero-Fee Trading Weekend', 'Komisyonsuz İşlem Hafta Sonu'),
      time: LanguageManager.translate('2d ago', '2g önce'),
      body: LanguageManager.translate(
        'Enjoy zero maker fees on all Spot pairs this weekend. Elevate your portfolio strategy without the overhead.',
        'Bu hafta sonu tüm Spot çiftlerinde sıfır piyasa yapıcı komisyonunun tadını çıkarın. Portföy stratejinizi ekstra masraf olmadan yükseltin.',
      ),
      isUnread: false,
      hasActions: false,
      icon: Icons.trending_up_rounded,
    ),
  ];

  late List<_NotificationItemData> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(_allNotifications);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_maxInitialItems, (i) {
      final start = i * 0.08;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(_maxInitialItems, (i) {
      final start = i * 0.08;
      final end = (start + 0.35).clamp(0.0, 1.0);
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

  Widget _staggered(int i, Widget child) {
    if (i >= _fadeAnims.length) return child;
    return FadeTransition(
      opacity: _fadeAnims[i],
      child: SlideTransition(position: _slideAnims[i], child: child),
    );
  }

  List<_NotificationItemData> _getFilteredNotifications() {
    if (_activeFilter == 'All Activity') {
      return _notifications;
    }
    return _notifications.where((n) => n.category == _activeFilter).toList();
  }

  void _clearAll() {
    HapticFeedback.heavyImpact();
    setState(() {
      _notifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LanguageManager.translate('All notifications cleared.', 'Tüm bildirimler temizlendi.')),
        backgroundColor: AppColors.surfaceContainerHigh,
      ),
    );
  }

  void _deleteNotification(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredNotifications();
    final filters = ['All Activity', 'Security', 'Transactions', 'Promotions'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
          LanguageManager.translate('Notifications', 'Bildirimler'),
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
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: Text(
                LanguageManager.translate('Clear All', 'Temizle'),
                style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Segmented Filters Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _staggered(
                0,
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Row(
                    children: List.generate(filters.length, (i) {
                      final f = filters[i];
                      final active = f == _activeFilter;
                      String translatedLabel = f;
                      if (f == 'All Activity') {
                        translatedLabel = LanguageManager.translate('All', 'Tümü');
                      } else if (f == 'Security') {
                        translatedLabel = LanguageManager.translate('Security', 'Güvenlik');
                      } else if (f == 'Transactions') {
                        translatedLabel = LanguageManager.translate('Transactions', 'İşlemler');
                      } else if (f == 'Promotions') {
                        translatedLabel = LanguageManager.translate('Promotions', 'Fırsatlar');
                      }
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _activeFilter = f;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: active ? AppColors.primaryFixed : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              translatedLabel,
                              style: AppTextStyles.labelSm(
                                color: active ? Colors.black : AppColors.secondary,
                              ).copyWith(fontWeight: active ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notification List View
            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _staggered(
                          index + 1,
                          _NotificationCard(
                            data: item,
                            onDismiss: () => _deleteNotification(item.id),
                            onMarkRead: () {
                              setState(() {
                                item.isUnread = false;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnims[1],
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F1F1F)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryFixed.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  color: AppColors.primaryFixed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                LanguageManager.translate('No Notifications Found', 'Bildirim Bulunamadı'),
                style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                LanguageManager.translate(
                  'You\'re all caught up! We will notify you here when anything changes.',
                  'Her şey güncel! Bir değişiklik olduğunda sizi buradan bilgilendireceğiz.',
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Notification Card Widget ───────────────────────────────────────────────
class _NotificationCard extends StatefulWidget {
  const _NotificationCard({
    required this.data,
    required this.onDismiss,
    required this.onMarkRead,
  });

  final _NotificationItemData data;
  final VoidCallback onDismiss;
  final VoidCallback onMarkRead;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (widget.data.isUnread) {
          widget.onMarkRead();
        }
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: widget.data.isUnread ? 1.0 : (_pressed ? 1.0 : 0.8),
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _pressed ? AppColors.primaryFixed.withValues(alpha: 0.5) : const Color(0xFF333333),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Unread blue/green indicator bar on the left edge
                if (widget.data.isUnread)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: Container(
                      color: AppColors.primaryFixed,
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon container
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerHigh,
                          border: Border.all(color: const Color(0xFF333333)),
                        ),
                        child: Icon(
                          widget.data.icon,
                          color: widget.data.isUnread ? AppColors.primaryFixed : AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.data.title,
                                    style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                                      fontWeight: widget.data.isUnread ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.data.time,
                                  style: AppTextStyles.labelSm(color: AppColors.secondary).copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.data.body,
                              style: AppTextStyles.bodyMd(
                                color: widget.data.isUnread ? AppColors.primary : AppColors.secondary,
                              ).copyWith(fontSize: 13),
                            ),

                            // Actions
                            if (widget.data.hasActions) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      widget.onMarkRead();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(LanguageManager.translate('Reviewing security logs...', 'Güvenlik günlükleri inceleniyor...')),
                                          backgroundColor: AppColors.surfaceContainerHigh,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryFixed,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      LanguageManager.translate('Review', 'İncele'),
                                      style: AppTextStyles.labelSm(color: Colors.black).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: widget.onDismiss,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF333333)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      foregroundColor: AppColors.primary,
                                    ),
                                    child: Text(
                                      LanguageManager.translate('Ignore', 'Yoksay'),
                                      style: AppTextStyles.labelSm(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
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
}

// ── Notification Item Model ──────────────────────────────────────────────────
class _NotificationItemData {
  _NotificationItemData({
    required this.id,
    required this.category,
    required this.title,
    required this.time,
    required this.body,
    required this.isUnread,
    required this.hasActions,
    required this.icon,
  });

  final String id;
  final String category;
  final String title;
  final String time;
  final String body;
  bool isUnread;
  final bool hasActions;
  final IconData icon;
}
