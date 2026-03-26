/// Alerts Module — Shared Reusable UI Components
/// Module Color: Red (0xFFEF4444)
/// Visibility: All roles EXCEPT Owner

import 'package:flutter/material.dart';
import '../models/alerts_models.dart';

// ═══════════════════════════════════════════
// COLOR CONSTANTS
// ═══════════════════════════════════════════

const kAlertsColor = Color(0xFFEF4444);
const kAlertsColorLight = Color(0xFFFEE2E2);
const kAlertsColorDark = Color(0xFFDC2626);
const kAlertsResolved = Color(0xFF10B981);
const kAlertsResolvedLight = Color(0xFFD1FAE5);
const kAlertsWarning = Color(0xFFF59E0B);
const kAlertsWarningLight = Color(0xFFFEF3C7);
const kAlertsInfo = Color(0xFF3B82F6);
const kAlertsInfoLight = Color(0xFFDBEAFE);
const kAlertsCritical = Color(0xFF7C3AED);
const kAlertsCriticalLight = Color(0xFFEDE9FE);

// ═══════════════════════════════════════════
// ALERTS APP BAR
// ═══════════════════════════════════════════

class AlertsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AlertsAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? 100 : 56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: kAlertsColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

// ═══════════════════════════════════════════
// SECTION CARD
// ═══════════════════════════════════════════

class AlertsSectionCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;

  const AlertsSectionCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════

class AlertsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AlertsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kAlertsColorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: kAlertsColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAlertsColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// ALERT CARD — Pending
// ═══════════════════════════════════════════

class PendingAlertCard extends StatelessWidget {
  final AlertItem alert;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDelegate;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const PendingAlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onAccept,
    this.onDelegate,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = _priorityColor(alert.priority);
    final isHigh = alert.priority == AlertPriority.high || alert.priority == AlertPriority.critical;
    final height = isHigh ? 140.0 : 120.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? kAlertsColorLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: borderColor, width: 4),
            top: BorderSide(color: isSelected ? kAlertsColor : const Color(0xFFE5E7EB)),
            right: BorderSide(color: isSelected ? kAlertsColor : const Color(0xFFE5E7EB)),
            bottom: BorderSide(color: isSelected ? kAlertsColor : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row — priority chip + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.priorityLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: borderColor),
                  ),
                ),
                Text(_timeAgo(alert.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
            const SizedBox(height: 6),

            // Issue ID + Title
            Row(
              children: [
                Text(alert.categoryEmoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text('#${alert.id}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: borderColor)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Bottom row — assignee + actions
            Row(
              children: [
                if (alert.assigneeName != null) ...[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: kAlertsInfo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(alert.assigneeName![0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kAlertsInfo))),
                  ),
                  const SizedBox(width: 6),
                  Text('${alert.assigneeName}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ] else
                  const Text('Unassigned', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontStyle: FontStyle.italic)),
                const Spacer(),
                if (alert.slaInfo != null)
                  _SlaChip(sla: alert.slaInfo!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(AlertPriority p) {
    switch (p) {
      case AlertPriority.critical: return kAlertsCritical;
      case AlertPriority.high: return kAlertsColor;
      case AlertPriority.medium: return kAlertsWarning;
      case AlertPriority.low: return kAlertsInfo;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// ═══════════════════════════════════════════
// ALERT CARD — Resolved
// ═══════════════════════════════════════════

class ResolvedAlertCard extends StatelessWidget {
  final AlertItem alert;
  final VoidCallback? onTap;

  const ResolvedAlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: kAlertsResolved, width: 4),
            top: const BorderSide(color: Color(0xFFE5E7EB)),
            right: const BorderSide(color: Color(0xFFE5E7EB)),
            bottom: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row — status + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(alert.categoryEmoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('#${alert.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kAlertsResolved)),
                  ],
                ),
                if (alert.resolution != null)
                  _VerificationBadge(status: alert.resolution!.verificationStatus),
              ],
            ),
            const SizedBox(height: 6),
            Text(alert.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),

            // Resolver + method
            Row(
              children: [
                if (alert.resolution != null) ...[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: kAlertsResolved.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(alert.resolution!.resolverName[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kAlertsResolved))),
                  ),
                  const SizedBox(width: 6),
                  Text(alert.resolution!.resolverName, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                    child: Text(alert.resolution!.methodLabel, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  ),
                ],
                const Spacer(),
                Text(_timeAgo(alert.updatedAt), style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// ═══════════════════════════════════════════
// SLA CHIP
// ═══════════════════════════════════════════

class _SlaChip extends StatelessWidget {
  final AlertSlaInfo sla;
  const _SlaChip({required this.sla});

  @override
  Widget build(BuildContext context) {
    final color = sla.status == SlaStatus.onTrack
        ? kAlertsResolved
        : sla.status == SlaStatus.atRisk
            ? kAlertsWarning
            : kAlertsColor;
    final remaining = sla.remainingTime;
    final label = remaining.isNegative
        ? 'Overdue'
        : remaining.inHours > 0
            ? '${remaining.inHours}h ${remaining.inMinutes % 60}m left'
            : '${remaining.inMinutes}m left';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// VERIFICATION BADGE
// ═══════════════════════════════════════════

class _VerificationBadge extends StatelessWidget {
  final VerificationStatus status;
  const _VerificationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status == VerificationStatus.verified ? '✅ Verified' : '📋 Pending Review';
    final color = status == VerificationStatus.verified ? kAlertsResolved : kAlertsInfo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ═══════════════════════════════════════════
// PRIORITY FILTER PILL
// ═══════════════════════════════════════════

class PriorityFilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PriorityFilterPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kAlertsColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? kAlertsColor : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// ACTIVITY TIMELINE EVENT
// ═══════════════════════════════════════════

class ActivityTimelineEvent extends StatelessWidget {
  final ActivityEvent event;
  final bool isLast;

  const ActivityTimelineEvent({
    super.key,
    required this.event,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _eventColor(event.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(event.typeEmoji, style: const TextStyle(fontSize: 13))),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: const Color(0xFFE5E7EB))),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Event content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(event.actorName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(_timeAgo(event.timestamp), style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(event.description, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  if (event.details != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(event.details!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _eventColor(ActivityEventType t) {
    switch (t) {
      case ActivityEventType.created: return kAlertsInfo;
      case ActivityEventType.assigned: return kAlertsInfo;
      case ActivityEventType.commented: return const Color(0xFF6B7280);
      case ActivityEventType.statusChanged: return kAlertsWarning;
      case ActivityEventType.fileAttached: return const Color(0xFF6B7280);
      case ActivityEventType.escalated: return kAlertsColor;
      case ActivityEventType.resolved: return kAlertsResolved;
      case ActivityEventType.verified: return kAlertsResolved;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// ═══════════════════════════════════════════
// KNOWLEDGE BASE ITEM CARD
// ═══════════════════════════════════════════

class KnowledgeItemCard extends StatelessWidget {
  final KnowledgeBaseItem item;
  final VoidCallback? onTap;

  const KnowledgeItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _KbTypeBadge(type: item.type),
                const SizedBox(width: 8),
                Expanded(child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: kAlertsResolved.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('${(item.similarityScore * 100).toInt()}% match', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kAlertsResolved)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.thumb_up, size: 12, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text('${item.helpfulCount}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                if (item.source != null) ...[
                  const Spacer(),
                  Text(item.source!, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KbTypeBadge extends StatelessWidget {
  final KnowledgeItemType type;
  const _KbTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final data = {
      KnowledgeItemType.article: ('📚', 'Article', kAlertsInfo),
      KnowledgeItemType.pastResolution: ('✅', 'Past Fix', kAlertsResolved),
      KnowledgeItemType.communitySolution: ('🌐', 'Community', kAlertsCritical),
    };
    final d = data[type]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: d.$3.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text('${d.$1} ${d.$2}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: d.$3)),
    );
  }
}

// ═══════════════════════════════════════════
// TEMPLATE CARD
// ═══════════════════════════════════════════

class AlertTemplateCard extends StatelessWidget {
  final AlertTemplate template;
  final VoidCallback? onTap;

  const AlertTemplateCard({super.key, required this.template, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(template.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                Text(template.typeLabel, style: const TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              template.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (template.variables.isNotEmpty) ...[
                  const Icon(Icons.data_object, size: 12, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text('${template.variables.length} vars', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.repeat, size: 12, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text('${template.usageCount} uses', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                const Spacer(),
                Text('by ${template.createdBy}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// RESOLVER LEADERBOARD TILE
// ═══════════════════════════════════════════

class ResolverLeaderboardTile extends StatelessWidget {
  final ResolverStats resolver;
  final int rank;

  const ResolverLeaderboardTile({super.key, required this.resolver, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank <= 3 ? kAlertsWarning.withOpacity(0.15) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
                style: TextStyle(fontSize: rank <= 3 ? 14 : 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resolver.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(resolver.role, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${resolver.resolvedCount} resolved', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 12, color: kAlertsWarning),
                  const SizedBox(width: 2),
                  Text('${resolver.satisfactionScore}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// STAFF PICKER TILE
// ═══════════════════════════════════════════

class StaffPickerTile extends StatelessWidget {
  final AlertStaffMember staff;
  final bool isSelected;
  final VoidCallback? onTap;

  const StaffPickerTile({super.key, required this.staff, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? kAlertsColorLight : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? kAlertsColor : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kAlertsColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(staff.name[0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kAlertsColor))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Text(staff.role, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      if (staff.branch != null) ...[
                        const Text(' • ', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                        Text(staff.branch!, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: staff.isAvailable ? kAlertsResolved : kAlertsColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${staff.activeAlerts} active', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// MINI DONUT CHART (for widget)
// ═══════════════════════════════════════════

class MiniDonutChart extends StatelessWidget {
  final List<IssueDistribution> data;
  final double size;

  const MiniDonutChart({super.key, required this.data, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DonutPainter(data)),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<IssueDistribution> data;
  _DonutPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;
    final colors = [kAlertsColor, kAlertsWarning, kAlertsInfo, kAlertsResolved, const Color(0xFF9CA3AF)];

    double startAngle = -1.5708; // -π/2
    for (int i = 0; i < data.length && i < colors.length; i++) {
      final sweepAngle = (data[i].percentage / 100) * 6.2832; // 2π
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
