import 'package:flutter/material.dart';
import 'ive_button.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Restrained empty state.
///
/// One warm line of context + one clear action. No "No Data" generic text.
/// Structure: one text (warm, conversational) + one [IveButton.primary].
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
                color: IveTokens.surfaceColor,
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
                border: Border.all(color: IveTokens.hairColor, width: 1),
              ),
              child: Icon(icon, size: 24, color: IveTokens.muteColor),
            ),
            const SizedBox(height: IveTokens.s4),
            Text(
              title,
              style: IveType.title3,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: IveTokens.s2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  message!,
                  style: IveType.callout,
                  textAlign: TextAlign.center,
                ),
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

/// Error state.
///
/// Structure: [cause]  what went wrong. [fixLabel] + [onFix]  the remedy.
/// Never says "Something went wrong". Always names the cause and the fix.
class IveErrorState extends StatelessWidget {
  const IveErrorState({
    super.key,
    required this.cause,
    required this.fixLabel,
    required this.onFix,
  });

  /// Short cause statement. E.g. "Connection lost."
  final String cause;

  /// Label for the fix action. E.g. "Retry" or "Check connection."
  final String fixLabel;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IveTokens.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: IveTokens.badColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(IveTokens.rContainer),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 22,
                color: IveTokens.badColor,
              ),
            ),
            const SizedBox(height: IveTokens.s4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                cause,
                style: IveType.title3,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: IveTokens.s4),
            IveButton.text(
              label: fixLabel,
              onPressed: onFix,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder for a single element.
///
/// A shimmer-animated rectangle that mirrors the dimensions of deferred
/// content. Dissolves into real content with a cross-fade (wrap in
/// [AnimatedSwitcher] at the call site).
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
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: IveTokens.surfaceColor,
          borderRadius: widget.radius ?? BorderRadius.circular(IveTokens.rAtom),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            IveTokens.surfaceColor,
            IveTokens.raisedColor,
            _c.value,
          ),
          borderRadius:
              widget.radius ?? BorderRadius.circular(IveTokens.rAtom),
        ),
      ),
    );
  }
}

/// Layout-level loading skeleton.
///
/// Renders a column of skeleton bars that match the shape of a typical
/// list or card content block. Cross-fade into real content at the call site
/// using [AnimatedSwitcher].
class IveListSkeleton extends StatelessWidget {
  const IveListSkeleton({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: rows,
      separatorBuilder: (_, __) => const SizedBox(height: IveTokens.s3),
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: IveTokens.s5),
        child: Row(
          children: [
            IveSkeleton(
              width: 40,
              height: 40,
              radius: BorderRadius.circular(IveTokens.rContainer),
            ),
            const SizedBox(width: IveTokens.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IveSkeleton(
                    width: double.infinity,
                    height: 14,
                    radius: BorderRadius.circular(IveTokens.rAtom),
                  ),
                  const SizedBox(height: IveTokens.s2),
                  IveSkeleton(
                    width: 120,
                    height: 11,
                    radius: BorderRadius.circular(IveTokens.rAtom),
                  ),
                ],
              ),
            ),
            const SizedBox(width: IveTokens.s4),
            IveSkeleton(
              width: 56,
              height: 14,
              radius: BorderRadius.circular(IveTokens.rAtom),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card-grid loading skeleton. Renders placeholder tiles in a [crossAxisCount]
/// grid for deferred card-based content.
class IveCardSkeleton extends StatelessWidget {
  const IveCardSkeleton({
    super.key,
    this.count = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.4,
  });

  final int count;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(IveTokens.s5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: IveTokens.s3,
        mainAxisSpacing: IveTokens.s3,
      ),
      itemCount: count,
      itemBuilder: (_, __) => IveSkeleton(
        width: double.infinity,
        height: double.infinity,
        radius: BorderRadius.circular(IveTokens.rContainer),
      ),
    );
  }
}
