import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Notification Type
// ══════════════════════════════════════════════════════════════════════════════
enum AppNotificationType { success, error, pending, info }

// ══════════════════════════════════════════════════════════════════════════════
// App Notification — Global overlay-based toast system
//
// Usage:
//   AppNotification.show(
//     context,
//     type: AppNotificationType.success,
//     title: 'Transfer Successful',
//     message: '\$1,250 sent to Elena R.',
//   );
// ══════════════════════════════════════════════════════════════════════════════
class AppNotification {
  static const int _maxVisible = 3;
  static final List<_NotificationEntry> _queue = [];

  /// Show a notification toast in the current navigator's overlay.
  static void show(
    BuildContext context, {
    required AppNotificationType type,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
  }) {
    HapticFeedback.lightImpact();

    final overlay = Overlay.of(context, rootOverlay: true);

    // Cap simultaneous toasts
    if (_queue.length >= _maxVisible) {
      _queue.first.dismiss();
    }

    late OverlayEntry entry;
    late _NotificationEntry notifEntry;
    final controller = AnimationController(
      vsync: _OverlayTickerProvider(),
      duration: const Duration(milliseconds: 380),
    );

    void dismiss() {
      controller.reverse().then((_) {
        if (entry.mounted) entry.remove();
        _queue.removeWhere((e) => e.overlayEntry == entry);
        controller.dispose();
      });
    }

    entry = OverlayEntry(
      builder: (context) => _NotificationToast(
        type: type,
        title: title,
        message: message,
        controller: controller,
        onDismiss: dismiss,
        index: _queue.length,
      ),
    );

    notifEntry = _NotificationEntry(
      overlayEntry: entry,
      dismiss: dismiss,
    );
    _queue.add(notifEntry);

    overlay.insert(entry);
    controller.forward();

    Timer(duration, () {
      if (entry.mounted) dismiss();
    });
  }

  // ── Convenience helpers ───────────────────────────────────────────────────

  static void success(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
  }) =>
      show(context,
          type: AppNotificationType.success,
          title: title,
          message: message,
          duration: duration);

  static void error(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 5),
  }) =>
      show(context,
          type: AppNotificationType.error,
          title: title,
          message: message,
          duration: duration);

  static void pending(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
  }) =>
      show(context,
          type: AppNotificationType.pending,
          title: title,
          message: message,
          duration: duration);

  static void info(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(context,
          type: AppNotificationType.info,
          title: title,
          message: message,
          duration: duration);

  /// Show a notification using a pre-captured [OverlayState].
  /// Use this instead of [show] when calling after an async gap to avoid
  /// use_build_context_synchronously warnings.
  static void showOnOverlay(
    OverlayState overlay, {
    required AppNotificationType type,
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
  }) {
    HapticFeedback.lightImpact();

    if (_queue.length >= _maxVisible) {
      _queue.first.dismiss();
    }

    late OverlayEntry entry;
    late _NotificationEntry notifEntry;
    final controller = AnimationController(
      vsync: _OverlayTickerProvider(),
      duration: const Duration(milliseconds: 380),
    );

    void dismiss() {
      controller.reverse().then((_) {
        if (entry.mounted) entry.remove();
        _queue.removeWhere((e) => e.overlayEntry == entry);
        controller.dispose();
      });
    }

    entry = OverlayEntry(
      builder: (context) => _NotificationToast(
        type: type,
        title: title,
        message: message,
        controller: controller,
        onDismiss: dismiss,
        index: _queue.length,
      ),
    );

    notifEntry = _NotificationEntry(overlayEntry: entry, dismiss: dismiss);
    _queue.add(notifEntry);

    overlay.insert(entry);
    controller.forward();

    Timer(duration, () {
      if (entry.mounted) dismiss();
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Internal queue entry
// ══════════════════════════════════════════════════════════════════════════════
class _NotificationEntry {
  _NotificationEntry({required this.overlayEntry, required this.dismiss});
  OverlayEntry overlayEntry;
  final VoidCallback dismiss;
}

// ══════════════════════════════════════════════════════════════════════════════
// Toast Widget
// ══════════════════════════════════════════════════════════════════════════════
class _NotificationToast extends StatefulWidget {
  const _NotificationToast({
    required this.type,
    required this.title,
    this.message,
    required this.controller,
    required this.onDismiss,
    required this.index,
  });

  final AppNotificationType type;
  final String title;
  final String? message;
  final AnimationController controller;
  final VoidCallback onDismiss;
  final int index;

  @override
  State<_NotificationToast> createState() => _NotificationToastState();
}

class _NotificationToastState extends State<_NotificationToast> {
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  // ── Type config helpers ───────────────────────────────────────────────────

  Color get _accentColor {
    switch (widget.type) {
      case AppNotificationType.success:
        return AppColors.primaryFixed; // #C3F400 neon green
      case AppNotificationType.error:
        return const Color(0xFFFF4444);
      case AppNotificationType.pending:
        return const Color(0xFFFFB800);
      case AppNotificationType.info:
        return const Color(0xFFC8C6C5);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AppNotificationType.success:
        return Icons.check_circle_outline_rounded;
      case AppNotificationType.error:
        return Icons.error_outline_rounded;
      case AppNotificationType.pending:
        return Icons.hourglass_top_rounded;
      case AppNotificationType.info:
        return Icons.info_outline_rounded;
    }
  }

  String get _typeLabel {
    switch (widget.type) {
      case AppNotificationType.success:
        return 'SUCCESS';
      case AppNotificationType.error:
        return 'ERROR';
      case AppNotificationType.pending:
        return 'PENDING';
      case AppNotificationType.info:
        return 'INFO';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPadding = mq.padding.top + 72 + (widget.index * 8.0);

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onTap: widget.onDismiss,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -100) {
                widget.onDismiss();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0C0C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _accentColor.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.12),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Left Accent Bar
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Icon ─────────────────────────────────────────
                          widget.type == AppNotificationType.pending
                              ? _SpinningIcon(color: _accentColor)
                              : Icon(
                                  _icon,
                                  color: _accentColor,
                                  size: 22,
                                ),
                          const SizedBox(width: 12),

                          // ── Text ─────────────────────────────────────────
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _typeLabel,
                                      style: AppTextStyles.labelSm(
                                              color: _accentColor)
                                          .copyWith(
                                              letterSpacing: 1.0, fontSize: 10),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.close_rounded,
                                        size: 14,
                                        color: AppColors.onSurfaceVariant
                                            .withValues(alpha: 0.5)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.title,
                                  style: AppTextStyles.labelMd(
                                          color: AppColors.primary)
                                      .copyWith(
                                          letterSpacing: 0.1,
                                          fontWeight: FontWeight.w600),
                                ),
                                if (widget.message != null &&
                                    widget.message!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.message!,
                                    style: AppTextStyles.labelSm(
                                            color: AppColors.onSurfaceVariant)
                                        .copyWith(
                                            letterSpacing: 0.1,
                                            height: 1.4,
                                            fontSize: 11),
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
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Spinning icon for pending state
// ══════════════════════════════════════════════════════════════════════════════
class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon({required this.color});
  final Color color;

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Icon(Icons.hourglass_top_rounded, color: widget.color, size: 22),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Ticker Provider shim for overlay-created AnimationControllers
// ══════════════════════════════════════════════════════════════════════════════
class _OverlayTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
