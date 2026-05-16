import 'package:flutter/material.dart';
import 'ive_button.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Restrained empty state. A single mark, a single sentence, an optional
/// action. Used for "no items", "no results", and "first run".
class IveEmptyState extends StatelessWidget {
  const IveEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IveTokens.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: IveTokens.surface,
                border: IveTokens.cardBorder,
                borderRadius: IveTokens.brSm,
              ),
              child: Icon(icon, size: 24, color: IveTokens.labelTertiary),
            ),
            const SizedBox(height: IveTokens.s4),
            Text(title, style: IveType.title3, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: IveTokens.s2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(message!,
                    style: IveType.callout, textAlign: TextAlign.center),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: IveTokens.s5),
              IveButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder. A hairline-bordered rectangle with a slow shimmer.
/// Use to mask deferred content without flashing layout.
class IveSkeleton extends StatefulWidget {
  const IveSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius,
  });

  final double? width;
  final double height;
  final BorderRadius? radius;

  @override
  State<IveSkeleton> createState() => _IveSkeletonState();
}

class _IveSkeletonState extends State<IveSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
              IveTokens.surface, IveTokens.surfaceRaised, _c.value),
          borderRadius: widget.radius ?? IveTokens.brXs,
        ),
      ),
    );
  }
}
