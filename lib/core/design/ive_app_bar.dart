import 'package:flutter/material.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Page chrome. A flat translucent bar at top, a large title that the
/// scrolling content slides under and "collapses into" a small inline title
/// — the iOS Large Title pattern, but mechanical and quiet.
class IveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IveAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.transparent = false,
    this.bottom,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool transparent;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight +
            // When bottom == null we inject a 1px hairline divider as the
            // AppBar's bottom widget (height = 1). Omitting that 1px here
            // creates a layout discrepancy in SliverAppBar / CustomScrollView.
            (bottom != null ? bottom!.preferredSize.height : 1.0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor:
          transparent ? Colors.transparent : IveTokens.bg.withValues(alpha: 0.86),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      centerTitle: centerTitle,
      titleSpacing: 0,
      leading: leading,
      iconTheme: const IconThemeData(color: IveTokens.label, size: 22),
      title: title == null
          ? null
          : Text(title!,
              style: IveType.headline.copyWith(color: IveTokens.label)),
      actions: actions,
      bottom: bottom == null
          ? const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                  height: 1, thickness: 1, color: IveTokens.hairline),
            )
          : bottom,
    );
  }
}

/// Large-title hero header. Use *inside* a scroll view's slivers, or as the
/// first child of a page column. Renders the title at display size with the
/// expected -0.4 letter-spacing and tight leading.
class IveLargeTitle extends StatelessWidget {
  const IveLargeTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(
        IveTokens.s5, IveTokens.s2, IveTokens.s5, IveTokens.s4),
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

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
                Text(title, style: IveType.title1),
                if (subtitle != null) ...[
                  const SizedBox(height: IveTokens.s2),
                  Text(subtitle!, style: IveType.callout),
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
