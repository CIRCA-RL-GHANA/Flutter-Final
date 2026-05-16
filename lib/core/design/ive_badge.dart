import 'package:flutter/material.dart';
import 'ive_text.dart';
import 'ive_tokens.dart';

/// Tiny, restrained pill. Used for status (Active, Pending), counts, or tags.
class IveBadge extends StatelessWidget {
  const IveBadge({
    super.key,
    required this.label,
    this.tone = IveBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final IveBadgeTone tone;
  final IconData? icon;

  Color get _fg {
    switch (tone) {
      case IveBadgeTone.neutral:  return IveTokens.labelSecondary;
      case IveBadgeTone.accent:   return IveTokens.accent;
      case IveBadgeTone.success:  return IveTokens.success;
      case IveBadgeTone.warning:  return IveTokens.warning;
      case IveBadgeTone.danger:   return IveTokens.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: IveTokens.s2, vertical: 3),
      decoration: BoxDecoration(
        color: _fg.withValues(alpha: 0.10),
        border: Border.all(color: _fg.withValues(alpha: 0.32)),
        borderRadius: IveTokens.brXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: _fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: IveType.caption.copyWith(color: _fg)),
        ],
      ),
    );
  }
}

enum IveBadgeTone { neutral, accent, success, warning, danger }
