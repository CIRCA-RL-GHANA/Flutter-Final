import 'package:flutter/material.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Hairline card. The card itself contributes nothing visual beyond a 1px
/// outline — the content is the figure.
class IveCard extends StatelessWidget {
  const IveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(IveTokens.s4),
    this.onTap,
    this.color,
    this.bordered = true,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool bordered;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final shape = radius ?? IveTokens.brSm;

    // Non-interactive: keep the AnimatedContainer so state-driven color
    // changes animate smoothly.
    if (onTap == null) {
      return AnimatedContainer(
        duration: IveTokens.dMicro,
        curve: IveTokens.standard,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? IveTokens.surface,
          borderRadius: shape,
          border: bordered ? IveTokens.cardBorder : null,
        ),
        child: child,
      );
    }

    // Tappable: use Ink so the ripple is painted ON TOP of the card surface
    // instead of behind the opaque background (where it would be invisible).
    return Material(
      color: Colors.transparent,
      borderRadius: shape,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: color ?? IveTokens.surface,
          borderRadius: shape,
          border: bordered ? IveTokens.cardBorder : null,
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: IveTokens.accentSoft,
          highlightColor: IveTokens.accentSoft,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Section header: a small, restrained title above a group of rows or a card.
class IveSectionHeader extends StatelessWidget {
  const IveSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
        IveTokens.s5, IveTokens.s6, IveTokens.s5, IveTokens.s2),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: IveType.title3),
                if (subtitle != null) ...[
                  const SizedBox(height: IveTokens.s1),
                  Text(subtitle!, style: IveType.footnote),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Grouped list of [IveListTile]s on a single hairline-bordered card with
/// interior dividers. Reads as an iOS grouped table.
class IveGroupedList extends StatelessWidget {
  const IveGroupedList({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: IveTokens.s5),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      tiles.add(children[i]);
      if (i != children.length - 1) {
        tiles.add(const Padding(
          padding: EdgeInsets.only(left: IveTokens.s5),
          child: Divider(height: 1, thickness: 1, color: IveTokens.hairline),
        ));
      }
    }
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: IveTokens.brSm,
        border: IveTokens.cardBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: tiles),
    );
  }
}
