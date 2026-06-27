import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ive_button.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Shows the VerifySheet modal and returns `true` on confirm, `false` on cancel.
///
/// The sheet title MUST match the trigger button's label exactly  this is
/// enforced by the caller passing the same string to both.
///
/// [onConfirm] should return `null` on success or an error string on failure.
/// On success: [HapticFeedback.heavyImpact] + gold checkmark, auto-dismiss.
/// On failure: [HapticFeedback.heavyImpact] + shake + error reason displayed.
///
/// Example:
/// ```dart
/// final confirmed = await showVerifySheet(
///   context,
///   title: 'Transfer to Ama',
///   confirmLabel: 'Transfer to Ama',
///   onConfirm: () async {
///     final err = await transferService.send(...);
///     return err; // null = success
///   },
/// );
/// ```
Future<bool> showVerifySheet(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? subtitle,
  bool isDestructive = false,
  Future<String?> Function()? onConfirm,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _VerifySheet(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
      onConfirm: onConfirm,
    ),
  ).then((v) => v ?? false);
}

class _VerifySheet extends StatefulWidget {
  const _VerifySheet({
    required this.title,
    this.subtitle,
    required this.confirmLabel,
    this.isDestructive = false,
    this.onConfirm,
  });

  final String title;
  final String? subtitle;
  final String confirmLabel;
  final bool isDestructive;
  final Future<String?> Function()? onConfirm;

  @override
  State<_VerifySheet> createState() => _VerifySheetState();
}

class _VerifySheetState extends State<_VerifySheet>
    with TickerProviderStateMixin {
  bool _loading = false;
  String? _error;
  bool _success = false;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  late final AnimationController _successCtrl;
  late final Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(_shakeCtrl);

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _successAnim = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    if (widget.onConfirm == null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _success = true;
        _loading = false;
      });
      _successCtrl.forward();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    final err = await widget.onConfirm!();
    if (!mounted) return;

    if (err == null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _success = true;
        _loading = false;
      });
      _successCtrl.forward();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = err;
        _loading = false;
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          IveTokens.s5,
          IveTokens.s4,
          IveTokens.s5,
          IveTokens.s5 + bottomPad,
        ),
        decoration: const BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IveTokens.rContainer),
          ),
          border: Border(
            top: BorderSide(color: IveTokens.hairColor, width: 1),
            left: BorderSide(color: IveTokens.hairColor, width: 1),
            right: BorderSide(color: IveTokens.hairColor, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: IveTokens.s4),
                decoration: BoxDecoration(
                  color: IveTokens.muteColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(IveTokens.rChip),
                ),
              ),
            ),
            // Title  must match trigger button text exactly
            Text(widget.title, style: IveType.title3),
            if (widget.subtitle != null) ...[
              const SizedBox(height: IveTokens.s2),
              Text(widget.subtitle!, style: IveType.callout),
            ],
            // Error reason
            if (_error != null) ...[
              const SizedBox(height: IveTokens.s3),
              Text(
                _error!,
                style: IveType.callout.copyWith(color: IveTokens.badColor),
              ),
            ],
            // Success state
            if (_success) ...[
              const SizedBox(height: IveTokens.s6),
              Center(
                child: ScaleTransition(
                  scale: _successAnim,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: IveTokens.genieColor,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: IveTokens.s6),
            ] else ...[
              const SizedBox(height: IveTokens.s6),
              IveButton.primary(
                label: widget.confirmLabel,
                onPressed: _loading ? null : _handleConfirm,
                isLoading: _loading,
                isDestructive: widget.isDestructive,
              ),
              const SizedBox(height: IveTokens.s3),
              Center(
                child: IveButton.text(
                  label: 'Cancel',
                  onPressed: _loading ? null : () => Navigator.of(context).pop(false),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
