import 'dart:async';
import 'package:flutter/material.dart';
import '../design/ive_tokens.dart';
import '../design/ive_text.dart';

/// Elegant floating notification system.
///
/// Replaces Material SnackBar throughout the app. Shows a pill-shaped overlay
/// that slides in from the top, holds briefly, then fades out  never a bar.
///
/// Usage:
///   AppToast.show(context, 'Saved');
///   AppToast.error(context, 'Insufficient funds. Add QP to continue.');
///   AppToast.success(context, 'Transfer complete.');
///   AppToast.info(context, 'Biometrics enabled.');
class AppToast {
  AppToast._();

  //  Convenience constructors 

  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(milliseconds: 2500),
  }) =>
      _show(context, message,
          icon: icon ?? Icons.info_outline_rounded,
          color: IveTokens.labelSecondary,
          duration: duration);

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) =>
      _show(context, message,
          icon: Icons.check_circle_outline_rounded,
          color: IveTokens.success,
          duration: duration);

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 3000),
  }) =>
      _show(context, message,
          icon: Icons.error_outline_rounded,
          color: IveTokens.danger,
          duration: duration);

  static void warn(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) =>
      _show(context, message,
          icon: Icons.warning_amber_rounded,
          color: IveTokens.warning,
          duration: duration);

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) =>
      _show(context, message,
          icon: Icons.info_outline_rounded,
          color: IveTokens.info,
          duration: duration);

  //  Core implementation 

  static OverlayEntry? _current;

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color color,
    required Duration duration,
  }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        icon: icon,
        accentColor: color,
        duration: duration,
        onDone: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.duration,
    required this.onDone,
  });

  final String message;
  final IconData icon;
  final Color accentColor;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    _holdTimer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: IveTokens.surfaceRaised,
                  borderRadius: IveTokens.brSm,
                  border: Border.all(
                    color: IveTokens.hairline2,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 18, color: widget.accentColor),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: IveType.callout.copyWith(
                          color: IveTokens.label,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
