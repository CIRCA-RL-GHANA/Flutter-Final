/// ──────────────────────────────────────────────────────────────────────────
/// Shared Widgets for Utility Module
/// Reusable components: metric cards, section headers, utility tiles,
/// filter chips, status indicators, info panels
/// ──────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design/ive.dart';

// ─── Utility Module Color ────────────────────────────────────────────────────

const Color kUtilityColor = Color(0xFF64748B);

// ─── Utility App Bar ─────────────────────────────────────────────────────────

class UtilityAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const UtilityAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: IveTokens.voidColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: IveTokens.inkColor,
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kUtilityColor,
                  ),
                ),
              ],
            )
          : leading,
      leadingWidth: showBackButton ? 70 : 56,
      title: Text(title, style: IveType.title3),
      centerTitle: true,
      actions: actions,
    );
  }
}

// ─── Metric Card ─────────────────────────────────────────────────────────────

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? percentage;
  final Widget? trailing;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.percentage,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(IveTokens.rAtom),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: IveType.headline),
          const SizedBox(height: 2),
          Text(label, style: IveType.caption.copyWith(color: IveTokens.muteColor, fontWeight: FontWeight.w500)),
          if (percentage != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percentage!.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Utility Section Card ────────────────────────────────────────────────────

class UtilitySectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  const UtilitySectionCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: IveTokens.raisedColor,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: borderColor ?? IveTokens.hairColor, width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: card,
      );
    }
    return card;
  }
}

// ─── Section Title ───────────────────────────────────────────────────────────

class UtilitySectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  const UtilitySectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconColor ?? kUtilityColor),
            const SizedBox(width: 8),
          ],
          Text(title, style: IveType.callout.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Utility Action Tile ─────────────────────────────────────────────────────

class UtilityActionTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;

  const UtilityActionTile({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      borderRadius: BorderRadius.circular(IveTokens.rContainer),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? kUtilityColor).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(IveTokens.rAtom),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? kUtilityColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: IveType.callout.copyWith(fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!, style: IveType.caption.copyWith(color: IveTokens.muteColor)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron && onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.chevron_right, size: 18, color: IveTokens.muteColor),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Utility Toggle Tile ─────────────────────────────────────────────────────

class UtilityToggleTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color? activeColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const UtilityToggleTile({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    this.activeColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? kUtilityColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (value ? color : IveTokens.muteColor).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(IveTokens.rAtom),
            ),
            child: Icon(icon, size: 18, color: value ? color : IveTokens.muteColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: IveType.callout.copyWith(fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!, style: IveType.caption.copyWith(color: IveTokens.muteColor)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeThumbColor: color,
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip Row ─────────────────────────────────────────────────────────

class UtilityFilterChipRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color? selectedColor;

  const UtilityFilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? kUtilityColor;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? color : IveTokens.raisedColor,
                borderRadius: BorderRadius.circular(IveTokens.rChip),
                border: Border.all(
                  color: selected ? color : IveTokens.hairColor,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? IveTokens.inkColor : IveTokens.ink2Color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Status Indicator ────────────────────────────────────────────────────────

class UtilityStatusIndicator extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool pulse;

  const UtilityStatusIndicator({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(IveTokens.rAtom),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class UtilityEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const UtilityEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kUtilityColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: kUtilityColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: IveType.headline, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle, style: IveType.caption.copyWith(color: IveTokens.muteColor), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: kUtilityColor),
                child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Percentage Ring ─────────────────────────────────────────────────────────

class PercentageRing extends StatelessWidget {
  final double percentage;
  final Color color;
  final double size;
  final String? label;

  const PercentageRing({
    super.key,
    required this.percentage,
    required this.color,
    this.size = 60,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              strokeWidth: 5,
            ),
          ),
          Text(
            label ?? '${(percentage * 100).toStringAsFixed(0)}%',
            style: TextStyle(fontSize: size * 0.22, fontWeight: FontWeight.w700, color: IveTokens.inkColor),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Grid Item ──────────────────────────────────────────────────

class QuickActionGridItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int? badgeCount;
  final VoidCallback? onTap;

  const QuickActionGridItem({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.badgeCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: IveTokens.raisedColor,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          border: Border.all(color: IveTokens.hairColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(IveTokens.rContainer),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: IveTokens.badColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount! > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(color: IveTokens.inkColor, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: IveType.caption.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
