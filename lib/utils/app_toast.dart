// lib/utils/app_toast.dart

import 'package:flutter/material.dart';

/// A lightweight animated top-toast that overlays the current page
/// and disappears automatically. No FAB or nav bar interference.
class AppToast {
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Color color = const Color(0xFF2E7D32),
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        icon: icon,
        color: color,
        duration: duration,
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  // Convenience variants
  static void success(BuildContext context, String message) => show(
    context,
    message,
    icon: Icons.check_circle_rounded,
    color: const Color(0xFF2E7D32),
  );

  static void error(BuildContext context, String message) => show(
    context,
    message,
    icon: Icons.error_rounded,
    color: const Color(0xFFD32F2F),
  );

  static void warning(BuildContext context, String message) => show(
    context,
    message,
    icon: Icons.warning_amber_rounded,
    color: const Color(0xFFF57C00),
  );

  static void info(BuildContext context, String message) => show(
    context,
    message,
    icon: Icons.info_rounded,
    color: const Color(0xFF1565C0),
  );
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Duration duration;
  final VoidCallback onDone;

  const _ToastWidget({
    required this.message,
    required this.icon,
    required this.color,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    // Wait, then fade out and remove
    Future.delayed(widget.duration, () async {
      if (mounted) await _ctrl.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 12;

    return Positioned(
      top: topPadding,
      left: 24,
      right: 24,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
