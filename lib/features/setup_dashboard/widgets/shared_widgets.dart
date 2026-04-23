/// ═══════════════════════════════════════════════════════════════════════════
/// Shared Widgets for Setup Dashboard Module
/// Reusable components: app bar, module cards, KPI badges, state cards,
/// filter chips, section titles, permission gate, context badge
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/models/rbac_models.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../models/setup_rbac.dart';
import '../providers/setup_dashboard_provider.dart';

// ─── Setup Dashboard Module Color ────────────────────────────────────────────

/// The canonical module color for Setup Dashboard (Blue)
const Color kSetupColor = Color(0xFF3B82F6);

// ─── Setup App Bar ───────────────────────────────────────────────────────────

class SetupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const SetupAppBar({
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  color: AppColors.textPrimary,
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kSetupColor,
                  ),
                ),
              ],
            )
          : leading,
      leadingWidth: showBackButton ? 70 : 56,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}

// ─── Setup Module Card (Hub Card) ────────────────────────────────────────────

class SetupModuleCard extends StatelessWidget {
  final DashboardCard card;
  final VoidCallback? onTap;

  const SetupModuleCard({
    super.key,
    required this.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = card.highlightColor ?? kSetupColor;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      child: Opacity(
        opacity: card.isViewOnly ? 0.60 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: card.hasAlerts
                ? Border.all(color: AppColors.error.withOpacity(0.4), width: 1.5)
                : card.isViewOnly
                    ? Border.all(color: AppColors.inputBorder)
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Row 1: Icon + Badge Cluster ───────────
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(card.icon, size: 18, color: accentColor),
                  ),
                  const Spacer(),
                  if (card.hasAlerts)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber, size: 10, color: AppColors.error),
                          const SizedBox(width: 2),
                          Text(
                            '${card.alertCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (card.isViewOnly)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 10, color: AppColors.textTertiary),
                          SizedBox(width: 2),
                          Text(
                            'View',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ─── Title + Subtitle ──────────────────────
              Text(
                card.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (card.subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  card.subtitle!,
                  style: TextStyle(
                    fontSize: 10,
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ─── Status Dots (fleet / staff viz) ──────
              if (card.statusDots.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: card.statusDots.map((dot) {
                    return Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: dot.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dot.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // ─── Progress Bar ─────────────────────────
              if (card.progress != null) ...[
                const SizedBox(height: 6),
                if (card.progressLabel != null)
                  Text(
                    card.progressLabel!,
                    style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
                  ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: card.progress!.clamp(0.0, 1.0),
                    backgroundColor: accentColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      card.progress! > 0.9
                          ? AppColors.error
                          : card.progress! > 0.7
                              ? AppColors.warning
                              : accentColor,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],

              const SizedBox(height: 4),

              // ─── Metrics (compact) ────────────────────
              ...card.metrics.entries.take(2).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Text(
                          e.value,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )),

              // ─── Summary Line ─────────────────────────
              if (card.summaryLine != null) ...[
                const SizedBox(height: 3),
                Text(
                  card.summaryLine!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ─── Action Labels ────────────────────────
              if (card.actionLabels.isNotEmpty) ...[
                const Spacer(),
                Row(
                  children: card.actionLabels.take(2).map((label) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: card.actionLabels.indexOf(label) == 0 &&
                                  card.actionLabels.length > 1
                              ? 4
                              : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: card.actionLabels.indexOf(label) == 0
                              ? accentColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: card.actionLabels.indexOf(label) > 0
                              ? Border.all(color: AppColors.inputBorder)
                              : null,
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: card.actionLabels.indexOf(label) == 0
                                ? accentColor
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Setup Section Card ──────────────────────────────────────────────────────

class SetupSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SetupSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: content,
      );
    }
    return content;
  }
}

// ─── Section Title ───────────────────────────────────────────────────────────

class SetupSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  const SetupSectionTitle({
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
            Icon(icon, size: 18, color: iconColor ?? kSetupColor),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── KPI Badge ───────────────────────────────────────────────────────────────

class KPIBadge extends StatelessWidget {
  final String label;
  final String value;
  final double changePercent;
  final bool isPositive;
  final IconData? icon;
  final Color? color;

  const KPIBadge({
    super.key,
    required this.label,
    required this.value,
    this.changePercent = 0,
    this.isPositive = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? kSetupColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: badgeColor),
                ),
                const Spacer(),
              ],
              if (changePercent != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 12,
                        color: isPositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${changePercent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPositive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Setup Action Tile ───────────────────────────────────────────────────────

class SetupActionTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;

  const SetupActionTile({
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
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? kSetupColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? kSetupColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron && onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip Row ─────────────────────────────────────────────────────────

class SetupFilterChipRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color? selectedColor;

  const SetupFilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? kSetupColor;
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
                color: selected ? color : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? color : AppColors.inputBorder,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
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

class SetupStatusIndicator extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const SetupStatusIndicator({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Context Badge (role-colored pill) ───────────────────────────────────────

class ContextBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const ContextBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class SetupEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SetupEmptyState({
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
                color: kSetupColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: kSetupColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: kSetupColor),
                child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Error State ─────────────────────────────────────────────────────────────

class SetupErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const SetupErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Please try again later.',
    this.onRetry,
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
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 36, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSetupColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Loading State ───────────────────────────────────────────────────────────

class SetupLoadingState extends StatelessWidget {
  final String? message;

  const SetupLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: kSetupColor,
                strokeWidth: 3,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Permission Gate ─────────────────────────────────────────────────────────

class PermissionGate extends StatelessWidget {
  final CardAccessLevel access;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.access,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (access == CardAccessLevel.hidden) {
      return fallback ??
          const SetupEmptyState(
            icon: Icons.lock,
            title: 'Access Restricted',
            subtitle: 'You do not have permission to view this section.',
          );
    }
    return child;
  }
}

// ─── Data Scope Indicator ────────────────────────────────────────────────────

class DataScopeIndicator extends StatelessWidget {
  final CardAccessLevel access;

  const DataScopeIndicator({super.key, required this.access});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (access) {
      case CardAccessLevel.fullAccess:
        label = 'Full Access';
        color = AppColors.success;
        break;
      case CardAccessLevel.branchScoped:
        label = 'Branch Scoped';
        color = kSetupColor;
        break;
      case CardAccessLevel.viewOnly:
        label = 'View Only';
        color = AppColors.textTertiary;
        break;
      case CardAccessLevel.branchViewOnly:
        label = 'Branch View';
        color = AppColors.textTertiary;
        break;
      case CardAccessLevel.personalOnly:
        label = 'Personal';
        color = AppColors.warning;
        break;
      case CardAccessLevel.ownOnly:
        label = 'Own Data';
        color = AppColors.warning;
        break;
      case CardAccessLevel.hidden:
        label = 'No Access';
        color = AppColors.error;
        break;
    }

    return SetupStatusIndicator(label: label, color: color);
  }
}

// ─── Percentage Ring ─────────────────────────────────────────────────────────

class SetupPercentageRing extends StatelessWidget {
  final double percentage;
  final Color color;
  final double size;
  final String? label;

  const SetupPercentageRing({
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
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
              strokeWidth: 5,
            ),
          ),
          Text(
            label ?? '${(percentage * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String setupTimeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}';
}

// ─── Setup Detail Tab Bar ────────────────────────────────────────────────────

/// Horizontal scrollable tab bar for detail screens
class SetupDetailTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const SetupDetailTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? kSetupColor : AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Setup Form Field ────────────────────────────────────────────────────────

/// Styled text field for setup forms
class SetupFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const SetupFormField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kSetupColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Setup Confirm Dialog ────────────────────────────────────────────────────

/// Confirmation dialog with destructive / normal actions
Future<bool> showSetupConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelText, style: const TextStyle(color: AppColors.textTertiary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? AppColors.error : kSetupColor,
          ),
          child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ─── Setup FAB ───────────────────────────────────────────────────────────────

/// Floating action button styled for setup module
class SetupFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final bool mini;

  const SetupFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.label,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: kSetupColor,
        foregroundColor: Colors.white,
        icon: Icon(icon, size: 20),
        label: Text(label!, style: const TextStyle(fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: kSetupColor,
      foregroundColor: Colors.white,
      mini: mini,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Icon(icon, size: mini ? 20 : 24),
    );
  }
}

// ─── Adaptive Grid ───────────────────────────────────────────────────────────

/// Responsive grid that adjusts columns based on available width
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minCrossAxisExtent = 160,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / minCrossAxisExtent).floor().clamp(1, 4);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}

// ─── Skeleton Loader ─────────────────────────────────────────────────────────

/// Shimmer-like skeleton loading placeholder
class SetupSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SetupSkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SetupSkeletonLoader> createState() => _SetupSkeletonLoaderState();
}

class _SetupSkeletonLoaderState extends State<SetupSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade300.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Card-shaped skeleton placeholder for list items
class SetupSkeletonCard extends StatelessWidget {
  final double height;

  const SetupSkeletonCard({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SetupSkeletonLoader(width: 120, height: 14),
          const SizedBox(height: 10),
          const SetupSkeletonLoader(height: 12),
          const SizedBox(height: 8),
          const SetupSkeletonLoader(width: 180, height: 12),
        ],
      ),
    );
  }
}

// ─── Setup Bottom Sheet ──────────────────────────────────────────────────────

/// Show a styled bottom sheet with drag handle
Future<T?> showSetupBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isDismissible = true,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(ctx).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(child: builder(ctx)),
        ],
      ),
    ),
  );
}

// ─── Setup Search Bar ────────────────────────────────────────────────────────

/// Reusable search bar for list screens
class SetupSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const SetupSearchBar({
    super.key,
    this.hint = 'Search...',
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ─── Setup Info Row ──────────────────────────────────────────────────────────

/// Key-value row for detail views
class SetupInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const SetupInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Setup Stat Card ─────────────────────────────────────────────────────────

/// Mini stat card for detail screen headers
class SetupStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const SetupStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kSetupColor;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: c,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── RBAC Gate Widget ────────────────────────────────────────────────────────

/// Wraps screen content and enforces role-based access control.
///
/// - [CardAccessLevel.hidden] → shows "No Access" placeholder.
/// - [CardAccessLevel.viewOnly] / [CardAccessLevel.branchViewOnly] → shows
///   a non-intrusive banner at the top, child remains visible but FABs and
///   edit actions should check [canEdit] separately.
/// - All other levels → child is rendered normally.
class SetupRbacGate extends StatelessWidget {
  const SetupRbacGate({
    super.key,
    required this.cardId,
    required this.child,
    this.noAccessMessage = 'You do not have access to this section.',
    this.viewOnlyMessage = 'You have view-only access.',
  });

  final String cardId;
  final Widget child;
  final String noAccessMessage;
  final String viewOnlyMessage;

  @override
  Widget build(BuildContext context) {
    final ctxProv = Provider.of<ContextProvider>(context);
    final setupProv = Provider.of<SetupDashboardProvider>(context, listen: false);
    final role = ctxProv.currentRole;
    final access = setupProv.getCardAccess(cardId, role);

    if (access == CardAccessLevel.hidden) {
      return _NoAccessView(message: noAccessMessage);
    }

    final isViewOnly =
        access == CardAccessLevel.viewOnly ||
        access == CardAccessLevel.branchViewOnly;

    if (isViewOnly) {
      return Column(
        children: [
          _ViewOnlyBanner(message: viewOnlyMessage),
          Expanded(child: child),
        ],
      );
    }

    return child;
  }
}

class _NoAccessView extends StatelessWidget {
  const _NoAccessView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Access Restricted',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Go Back'),
              style: OutlinedButton.styleFrom(foregroundColor: kSetupColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewOnlyBanner extends StatelessWidget {
  const _ViewOnlyBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E1),
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFE082), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, size: 16, color: Color(0xFFF57F17)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFF57F17),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RBAC-Aware FAB ──────────────────────────────────────────────────────────

/// A floating action button that is only shown when the current user role
/// has edit/create permissions for the given [cardId].
class SetupRbacFAB extends StatelessWidget {
  const SetupRbacFAB({
    super.key,
    required this.cardId,
    required this.onPressed,
    this.icon = Icons.add,
    this.label = 'Add',
    this.heroTag,
  });

  final String cardId;
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final ctxProv = Provider.of<ContextProvider>(context);
    final setupProv = Provider.of<SetupDashboardProvider>(context, listen: false);
    final role = ctxProv.currentRole;

    if (!setupProv.canEdit(cardId, role)) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      heroTag: heroTag ?? 'setup_rbac_fab_$cardId',
      onPressed: onPressed,
      backgroundColor: kSetupColor,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

// ─── RBAC Action Guard ───────────────────────────────────────────────────────

/// Convenience widget that shows or hides its child based on edit permission.
///
/// Use this to wrap individual edit/delete buttons inside detail screens.
class SetupActionGuard extends StatelessWidget {
  const SetupActionGuard({
    super.key,
    required this.cardId,
    required this.child,
    this.requireDelete = false,
  });

  final String cardId;
  final Widget child;
  final bool requireDelete;

  @override
  Widget build(BuildContext context) {
    final ctxProv = Provider.of<ContextProvider>(context);
    final setupProv = Provider.of<SetupDashboardProvider>(context, listen: false);
    final role = ctxProv.currentRole;

    final bool allowed = requireDelete
        ? SetupDashboardRBAC.getActionPermission(cardId, role).canDelete
        : setupProv.canEdit(cardId, role);

    return allowed ? child : const SizedBox.shrink();
  }
}

// ─── OTP Gate ────────────────────────────────────────────────────────────────

/// Wraps an action that requires OTP/PIN verification before proceeding.
///
/// Usage:
/// ```dart
/// SetupOtpGate(
///   cardId: 'staff',
///   action: 'change_role',
///   onVerified: () { /* proceed */ },
///   child: ElevatedButton(...),
/// )
/// ```
///
/// If the current role does not require OTP for this action, [onVerified] is
/// called immediately without showing the dialog.
class SetupOtpGate extends StatelessWidget {
  const SetupOtpGate({
    super.key,
    required this.cardId,
    required this.action,
    required this.child,
    required this.onVerified,
  });

  final String cardId;
  final String action;
  final Widget child;
  final VoidCallback onVerified;

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<ContextProvider>(context, listen: false).currentRole;
    final needsOtp = SetupDashboardRBAC.requiresOtpFor(cardId, action, role);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (needsOtp) {
          _showOtpDialog(context);
        } else {
          onVerified();
        }
      },
      child: child,
    );
  }

  Future<void> _showOtpDialog(BuildContext context) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: kSetupColor, size: 22),
            SizedBox(width: 10),
            Text(
              'OTP Verification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action requires administrator OTP verification. '
              'Enter the OTP sent to the admin account.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '● ● ● ● ● ●',
                hintStyle: const TextStyle(letterSpacing: 8, color: AppColors.textTertiary),
                counterText: '',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kSetupColor, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          FilledButton(
            onPressed: () {
              // In production: validate OTP via AuthService.
              // Here we accept any 6-digit code for UI purposes.
              if (controller.text.length == 6) {
                Navigator.pop(ctx, true);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: kSetupColor),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (confirmed == true) {
      HapticFeedback.lightImpact();
      onVerified();
    }
  }
}

// ─── Export Button (RBAC-gated) ───────────────────────────────────────────────

/// Export button that is only rendered when [role] is allowed to export
/// [dataType] per [SetupDashboardRBAC.canExport].
///
/// Shows an OTP dialog if the export action also requires OTP.
class SetupExportButton extends StatelessWidget {
  const SetupExportButton({
    super.key,
    required this.dataType,
    required this.cardId,
    required this.onExport,
    this.label = 'Export',
    this.icon = Icons.download_outlined,
  });

  final String dataType;
  final String cardId;
  final VoidCallback onExport;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<ContextProvider>(context, listen: false).currentRole;

    if (!SetupDashboardRBAC.canExport(dataType, role)) {
      return const SizedBox.shrink();
    }

    final needsOtp = SetupDashboardRBAC.requiresOtpFor(cardId, 'export', role);

    Widget button = OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.selectionClick();
        if (!needsOtp) onExport();
      },
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: kSetupColor,
        side: const BorderSide(color: kSetupColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
    );

    if (needsOtp) {
      button = SetupOtpGate(
        cardId: cardId,
        action: 'export',
        onVerified: onExport,
        child: button,
      );
    }

    return button;
  }
}

// ─── Redacted Data Banner ────────────────────────────────────────────────────

/// Displayed at the top of a screen when the current role sees redacted data.
/// (Spec: Monitor/BranchMonitor see audit logs with PII masked.)
class SetupRedactedBanner extends StatelessWidget {
  const SetupRedactedBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message ??
        'Redacted view — user identities and sensitive fields are masked '
        'per your role permissions.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_off_outlined, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OTP Guard (programmatic) ─────────────────────────────────────────────────

/// Programmatic OTP guard for use in [onPressed] / [onTap] callbacks
/// (e.g., FAB taps) where wrapping with [SetupOtpGate] is impractical.
///
/// If [cardId] + [action] requires OTP for the current role, an OTP dialog
/// is shown first. Otherwise [onVerified] is called immediately.
Future<void> showSetupOtpGuard(
  BuildContext context, {
  required String cardId,
  required String action,
  required VoidCallback onVerified,
}) async {
  final role = Provider.of<ContextProvider>(context, listen: false).currentRole;
  final needsOtp = SetupDashboardRBAC.requiresOtpFor(cardId, action, role);
  if (!needsOtp) {
    onVerified();
    return;
  }
  final controller = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.lock_outline, color: kSetupColor, size: 22),
          SizedBox(width: 10),
          Text(
            'OTP Verification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action requires administrator OTP verification. '
            'Enter the OTP sent to the admin account.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
            ),
            decoration: const InputDecoration(
              hintText: '● ● ● ● ● ●',
              hintStyle: TextStyle(letterSpacing: 8, color: AppColors.textTertiary),
              counterText: '',
              filled: true,
              fillColor: Color(0xFFF8F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: kSetupColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: kSetupColor, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, controller.text.length == 6),
          style: ElevatedButton.styleFrom(backgroundColor: kSetupColor),
          child: const Text('Verify', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    HapticFeedback.mediumImpact();
    onVerified();
  }
}

// ─── RBAC Tooltip Helper ─────────────────────────────────────────────────────

/// Shows a role-scoped tooltip [SnackBar] when the user taps a restricted
/// feature. Call this from [onTap] handlers of disabled buttons.
void showSetupRbacTooltip(BuildContext context, String cardId) {
  final role = Provider.of<ContextProvider>(context, listen: false).currentRole;
  final message = SetupDashboardRBAC.getTooltipMessage(cardId, role);
  if (message == null) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textSecondary,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    ),
  );
}

// ─── SOS Button ─────────────────────────────────────────────────────────────

/// Emergency SOS button — visible to Owner, Administrator, Branch Manager only.
/// Spec: Roles without access see nothing (SizedBox.shrink).
class SetupSOSButton extends StatelessWidget {
  const SetupSOSButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<ContextProvider>(context, listen: false).currentRole;
    if (!SetupDashboardRBAC.canSeeSOS(role)) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onPressed?.call();
        _showSOSDialog(context);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.emergency, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'EMERGENCY SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSOSDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF1F1),
        title: const Row(
          children: [
            Icon(Icons.emergency, color: AppColors.error, size: 24),
            SizedBox(width: 10),
            Text(
              'Emergency SOS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will alert your emergency contacts and dispatch team. '
          'Only use in genuine emergencies.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(ctx);
              // TODO: Integrate with emergency broadcast service.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS signal sent — help is on the way.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('SEND SOS', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Role Context Badge ───────────────────────────────────────────────────────

/// Compact pill showing the active role with spec-accurate color coding.
class SetupRoleBadge extends StatelessWidget {
  const SetupRoleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<ContextProvider>(context).currentRole;
    final color = RoleColors.forRole(role);
    final label = _roleShortLabel(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _roleShortLabel(UserRole role) {
    switch (role) {
      case UserRole.owner:           return 'OWNER';
      case UserRole.administrator:   return 'ADMIN';
      case UserRole.socialOfficer:   return 'SOC OFF';
      case UserRole.responseOfficer: return 'RESP OFF';
      case UserRole.monitor:         return 'MONITOR';
      case UserRole.branchManager:   return 'BR MGR';
      case UserRole.branchSocialOfficer:   return 'BR SOC';
      case UserRole.branchMonitor:         return 'BR MON';
      case UserRole.branchResponseOfficer: return 'BR RESP';
      case UserRole.driver:          return 'DRIVER';
      default:                       return 'USER';
    }
  }
}