import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Refined list row with optically-centered leading icon, numeral-aware
/// trailing amount, and optional swipe-to-reveal a single primary action.
///
/// Subtitle rule: carry *new* information (time, source, status) — never
/// restate the title. If title is "Ama Mensah", subtitle ≠ "@ama". Use "2m ago".
///
/// Only one swipe action is allowed per spec. Triggers [HapticFeedback.lightImpact]
/// at the dismiss threshold.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailingAmount,
    this.trailingAmountUnit,
    this.trailingLabel,
    this.onTap,
    this.swipeAction,
    this.swipeActionLabel,
    this.swipeActionColor,
    this.swipeActionIcon = Icons.delete_outline_rounded,
  });

  final String title;

  /// New information only — time, context, gateway, status.
  final String? subtitle;

  final Widget? leading;

  /// Trailing monetary amount. Renders with numeral rhythm (integer/decimal).
  final double? trailingAmount;

  /// Unit for [trailingAmount] (e.g. '\$', 'QP').
  final String? trailingAmountUnit;

  /// Non-numeric trailing string. Used when no amount is available.
  final String? trailingLabel;

  final VoidCallback? onTap;

  /// Action revealed by swiping end → start. One action only.
  final VoidCallback? swipeAction;
  final String? swipeActionLabel;
  final Color? swipeActionColor;
  final IconData? swipeActionIcon;

  @override
  Widget build(BuildContext context) {
    Widget row = _Content(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailingAmount: trailingAmount,
      trailingAmountUnit: trailingAmountUnit,
      trailingLabel: trailingLabel,
      onTap: onTap,
    );

    if (swipeAction != null) {
      row = Dismissible(
        key: ValueKey('list_row_$title'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          HapticFeedback.lightImpact();
          swipeAction!();
          return false; // action fires but row stays
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: IveTokens.s5),
          decoration: BoxDecoration(
            color: swipeActionColor ?? IveTokens.badColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(swipeActionIcon, color: Colors.white, size: 18),
              if (swipeActionLabel != null) ...[
                const SizedBox(width: IveTokens.s2),
                Text(
                  swipeActionLabel!,
                  style: IveType.bodyEmphasis.copyWith(color: Colors.white),
                ),
              ],
            ],
          ),
        ),
        child: row,
      );
    }

    return row;
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailingAmount,
    this.trailingAmountUnit,
    this.trailingLabel,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final double? trailingAmount;
  final String? trailingAmountUnit;
  final String? trailingLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: IveTokens.s5,
        vertical: IveTokens.s4,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            // 30 dp optically-centered container (Move 01)
            SizedBox(
              width: 30,
              height: 30,
              child: Center(child: leading),
            ),
            const SizedBox(width: IveTokens.s4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: IveType.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: IveType.footnote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailingAmount != null) ...[
            const SizedBox(width: IveTokens.s3),
            _NumeralTrailing(
              amount: trailingAmount!,
              unit: trailingAmountUnit,
            ),
          ] else if (trailingLabel != null) ...[
            const SizedBox(width: IveTokens.s3),
            Text(
              trailingLabel!,
              style: IveType.callout.copyWith(color: IveTokens.ink2Color),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        overlayColor: WidgetStateProperty.all(
          IveTokens.void2Color.withValues(alpha: 0.6),
        ),
        child: body,
      ),
    );
  }
}

/// Numeral-rhythm trailing amount for [ListRow].
class _NumeralTrailing extends StatelessWidget {
  const _NumeralTrailing({required this.amount, this.unit});

  final double amount;
  final String? unit;

  String _fmt(int v) {
    if (v == 0) return '0';
    final s = v.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final negative = amount < 0;
    final absVal = amount.abs();
    final intPart = absVal.truncate();
    final decPart = ((absVal - intPart) * 100).round();
    final sign = negative ? '−' : '';

    return RichText(
      textAlign: TextAlign.end,
      text: TextSpan(
        children: [
          if (unit != null)
            TextSpan(
              text: unit,
              style: IveType.caption.copyWith(color: IveTokens.muteColor),
            ),
          TextSpan(
            text: '$sign${_fmt(intPart)}',
            style: IveType.bodyEmphasis.copyWith(color: IveTokens.inkColor),
          ),
          TextSpan(
            text: '.${decPart.toString().padLeft(2, '0')}',
            style: IveType.footnote.copyWith(color: IveTokens.ink2Color),
          ),
        ],
      ),
    );
  }
}
