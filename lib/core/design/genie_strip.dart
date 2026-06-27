import 'package:flutter/material.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Genie intelligence strip  appears at most ONCE per screen.
///
/// Gold border + genie-soft background. The spark icon breathes on a
/// 4-second cycle. Slides in over 240 ms. Swipe-up or tap  to dismiss.
///
/// Rule: never place a second [GenieStrip] on the same screen. If you need
/// a second Genie element use a plain [Text] with [IveTokens.genieColor].
///
/// Usage:
/// ```dart
/// GenieStrip(
///   message: "Spending's up 12% this week.",
///   onDismiss: () {},
/// )
/// ```
class GenieStrip extends StatefulWidget {
  const GenieStrip({
    super.key,
    required this.message,
    this.onDismiss,
  });

  /// One-sentence Genie insight. Sentence-case, contractions OK.
  final String message;

  /// Called when the user dismisses the strip. If null, no dismiss control.
  final VoidCallback? onDismiss;

  @override
  State<GenieStrip> createState() => _GenieStripState();
}

class _GenieStripState extends State<GenieStrip>
    with TickerProviderStateMixin {
  late final AnimationController _sparkCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double> _sparkAnim;
  late final Animation<Offset> _slideAnim;
  bool _gone = false;

  @override
  void initState() {
    super.initState();

    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _sparkAnim = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _sparkCtrl, curve: Curves.easeInOut),
    );

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reduced = MediaQuery.of(context).disableAnimations;
      _entryCtrl.forward();
      if (!reduced) _sparkCtrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _sparkCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_gone) return;
    setState(() => _gone = true);
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnim,
      child: Dismissible(
        key: const ValueKey('genie_strip'),
        direction: DismissDirection.up,
        onDismissed: (_) => _dismiss(),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: IveTokens.s5,
            vertical: IveTokens.s2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: IveTokens.s4,
            vertical: IveTokens.s3,
          ),
          decoration: BoxDecoration(
            color: IveTokens.genieSoft,
            borderRadius: BorderRadius.circular(IveTokens.rContainer),
            border: Border.all(color: IveTokens.genieLine, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breathing spark
              AnimatedBuilder(
                animation: _sparkAnim,
                builder: (_, child) =>
                    Opacity(opacity: _sparkAnim.value, child: child),
                child: const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: IveTokens.genieColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: IveTokens.s3),
              Expanded(
                child: Text(
                  widget.message,
                  style: IveType.callout.copyWith(color: IveTokens.inkColor),
                ),
              ),
              if (widget.onDismiss != null) ...[
                const SizedBox(width: IveTokens.s2),
                GestureDetector(
                  onTap: _dismiss,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: IveTokens.muteColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
