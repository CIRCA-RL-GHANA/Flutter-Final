import 'package:flutter/material.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Generous, iOS-feel list row. Trailing chevron is implicit when [onTap]
/// is provided.
class IveListTile extends StatelessWidget {
  const IveListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.value,
    this.onTap,
    this.destructive = false,
    this.dense = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  /// Right-aligned value text (e.g. "On", "$12.50"). Replaces the chevron's
  /// neighbour but never the chevron itself.
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? IveTokens.danger : IveTokens.label;
    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: IveTokens.s5,
        vertical: dense ? IveTokens.s3 : IveTokens.s4,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            SizedBox(width: 28, height: 28, child: Center(child: leading)),
            const SizedBox(width: IveTokens.s4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: IveType.headline.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: IveType.footnote,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: IveTokens.s3),
            Text(value!, style: IveType.callout),
          ],
          if (trailing != null) ...[
            const SizedBox(width: IveTokens.s2),
            trailing!,
          ],
          if (onTap != null && trailing == null) ...[
            const SizedBox(width: IveTokens.s2),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: IveTokens.labelTertiary),
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: IveTokens.accentSoft,
        highlightColor: IveTokens.accentSoft,
        child: Semantics(button: true, label: title, child: row),
      ),
    );
  }
}
