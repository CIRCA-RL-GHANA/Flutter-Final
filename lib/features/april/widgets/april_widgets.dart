/// APRIL Module — Shared Widgets
/// Personal Assistant & Command Core
/// Module Color: Gold 0xFFFFD700

import 'package:flutter/material.dart';
import '../models/april_models.dart';

// ──────────────────────────────────────────────
//  COLOR CONSTANTS
// ──────────────────────────────────────────────

const Color kAprilColor = Color(0xFFFFD700);
const Color kAprilColorLight = Color(0xFFFFF8E1);
const Color kAprilColorDark = Color(0xFFF5A623);
const Color kAprilAccent = Color(0xFF6750A4);
const Color kAprilVoice = Color(0xFFFF453A);
const Color kAprilSuccess = Color(0xFF0F9D58);
const Color kAprilProcessing = Color(0xFFFFB800);

// ──────────────────────────────────────────────
//  APRIL APP BAR
// ──────────────────────────────────────────────

class AprilAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const AprilAppBar({super.key, required this.title, this.actions, this.leading, this.bottom});

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? 100 : 56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: leading ??
          (Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: kAprilColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

// ──────────────────────────────────────────────
//  SECTION CARD
// ──────────────────────────────────────────────

class AprilSectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const AprilSectionCard({super.key, required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  EMPTY STATE
// ──────────────────────────────────────────────

class AprilEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const AprilEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kAprilColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: kAprilColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAprilColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(ctaLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  VOICE BUTTON
// ──────────────────────────────────────────────

class AprilVoiceButton extends StatelessWidget {
  final VoiceState state;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AprilVoiceButton({
    super.key,
    required this.state,
    this.size = 80,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = {
      VoiceState.idle: kAprilAccent,
      VoiceState.listening: kAprilVoice,
      VoiceState.processing: kAprilProcessing,
      VoiceState.success: kAprilSuccess,
      VoiceState.error: const Color(0xFFEF4444),
    };
    final icons = {
      VoiceState.idle: Icons.mic,
      VoiceState.listening: Icons.stop,
      VoiceState.processing: Icons.hourglass_top,
      VoiceState.success: Icons.check,
      VoiceState.error: Icons.error_outline,
    };

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors[state],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (colors[state] ?? kAprilAccent).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: state == VoiceState.processing
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Icon(icons[state], color: Colors.white, size: size * 0.4),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  PLUGIN CARD (Quick Access)
// ──────────────────────────────────────────────

class PluginCard extends StatelessWidget {
  final AprilPlugin plugin;
  final SyncStatus syncStatus;
  final String statusText;
  final int? badgeCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PluginCard({
    super.key,
    required this.plugin,
    required this.syncStatus,
    required this.statusText,
    this.badgeCount,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final pluginData = {
      AprilPlugin.planner: {'icon': Icons.account_balance_wallet, 'emoji': '📊', 'name': 'Planner'},
      AprilPlugin.calendar: {'icon': Icons.calendar_month, 'emoji': '📅', 'name': 'Calendar'},
      AprilPlugin.wishlist: {'icon': Icons.card_giftcard, 'emoji': '🎁', 'name': 'Wishlist'},
      AprilPlugin.statement: {'icon': Icons.description, 'emoji': '📝', 'name': 'Statement'},
    };
    final data = pluginData[plugin]!;
    final syncColors = {
      SyncStatus.synced: const Color(0xFF10B981),
      SyncStatus.pending: const Color(0xFFF59E0B),
      SyncStatus.error: const Color(0xFFEF4444),
      SyncStatus.offline: const Color(0xFF6B7280),
    };

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data['emoji'] as String, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    data['name'] as String,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Sync status dot
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: syncColors[syncStatus],
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Badge count
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  PENDING ACTION TILE
// ──────────────────────────────────────────────

class PendingActionTile extends StatelessWidget {
  final PendingAction action;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  const PendingActionTile({super.key, required this.action, this.onComplete, this.onTap});

  @override
  Widget build(BuildContext context) {
    final priorityColors = {
      ActionPriority.critical: const Color(0xFFEF4444),
      ActionPriority.high: const Color(0xFFF59E0B),
      ActionPriority.medium: kAprilColor,
      ActionPriority.low: const Color(0xFF10B981),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: priorityColors[action.priority],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                action.description,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (action.dueText != null) ...[
              const SizedBox(width: 8),
              Text(
                action.dueText!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: action.priority == ActionPriority.critical
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  NOTIFICATION CARD
// ──────────────────────────────────────────────

class AprilNotificationCard extends StatelessWidget {
  final AprilNotification notification;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const AprilNotificationCard({
    super.key,
    required this.notification,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColors = {
      AprilNotificationType.financial: kAprilColor,
      AprilNotificationType.calendar: const Color(0xFF3B82F6),
      AprilNotificationType.wishlist: const Color(0xFF8B5CF6),
      AprilNotificationType.personal: const Color(0xFF10B981),
      AprilNotificationType.system: const Color(0xFF6B7280),
    };

    return Dismissible(
      key: ValueKey(notification.id),
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: const Color(0xFFEF4444),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: typeColors[notification.type] ?? kAprilColor,
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (notification.emoji != null)
                    Text(notification.emoji!, style: const TextStyle(fontSize: 16)),
                  if (notification.emoji != null) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    _timeAgo(notification.timestamp),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              if (notification.actions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: notification.actions.take(3).map((action) {
                    final labels = {
                      NotificationAction.pay: 'Pay',
                      NotificationAction.snooze: 'Snooze',
                      NotificationAction.dismiss: 'Dismiss',
                      NotificationAction.viewDetails: 'View',
                      NotificationAction.join: 'Join',
                      NotificationAction.reschedule: 'Reschedule',
                      NotificationAction.decline: 'Decline',
                      NotificationAction.purchase: 'Buy',
                      NotificationAction.remove: 'Remove',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          labels[action] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: typeColors[notification.type] ?? kAprilColor,
                          ),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// ──────────────────────────────────────────────
//  TRANSACTION CARD
// ──────────────────────────────────────────────

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryEmojis = {
      TransactionCategory.dining: '🍔',
      TransactionCategory.groceries: '🛒',
      TransactionCategory.transport: '🚗',
      TransactionCategory.entertainment: '🎬',
      TransactionCategory.utilities: '💡',
      TransactionCategory.housing: '🏠',
      TransactionCategory.healthcare: '🏥',
      TransactionCategory.education: '📚',
      TransactionCategory.shopping: '🛍️',
      TransactionCategory.salary: '💵',
      TransactionCategory.freelance: '💻',
      TransactionCategory.investment: '📈',
      TransactionCategory.subscription: '📱',
      TransactionCategory.insurance: '🛡️',
      TransactionCategory.other: '📋',
    };
    final isIncome = transaction.type == TransactionType.income;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isIncome ? const Color(0xFF10B981) : kAprilColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  categoryEmojis[transaction.category] ?? '📋',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        transaction.category.name,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      if (transaction.isRecurring) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.repeat, size: 12, color: Color(0xFF6B7280)),
                      ],
                      if (transaction.hasReceipt) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.receipt_long, size: 12, color: Color(0xFF6B7280)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} ₵${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}';
  }
}

// ──────────────────────────────────────────────
//  BUDGET PROGRESS BAR
// ──────────────────────────────────────────────

class BudgetProgressBar extends StatelessWidget {
  final BudgetCategory budget;
  final VoidCallback? onTap;

  const BudgetProgressBar({super.key, required this.budget, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      BudgetStatus.onTrack: const Color(0xFF10B981),
      BudgetStatus.warning: const Color(0xFFF59E0B),
      BudgetStatus.overBudget: const Color(0xFFEF4444),
      BudgetStatus.completed: const Color(0xFF6B7280),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(budget.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(
                  '₵${budget.spent.toStringAsFixed(0)} / ₵${budget.limit.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColors[budget.status],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.percentage.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation(statusColors[budget.status] ?? kAprilColor),
                minHeight: 8,
              ),
            ),
            if (budget.status == BudgetStatus.overBudget) ...[
              const SizedBox(height: 4),
              Text(
                'Over by ₵${(-budget.remaining).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  CALENDAR EVENT TILE
// ──────────────────────────────────────────────

class CalendarEventTile extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback? onTap;

  const CalendarEventTile({super.key, required this.event, this.onTap});

  static const _eventColors = [
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // purple
    Color(0xFF10B981), // green
    Color(0xFFEF4444), // red
    Color(0xFFF59E0B), // amber
    Color(0xFFEC4899), // pink
  ];

  @override
  Widget build(BuildContext context) {
    final color = _eventColors[event.colorIndex % _eventColors.length];
    final typeEmojis = {
      EventType.meeting: '👥',
      EventType.call: '📞',
      EventType.personal: '🍽️',
      EventType.travel: '✈️',
      EventType.deadline: '⏰',
      EventType.reminder: '🔔',
      EventType.allDay: '📅',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Time column
            SizedBox(
              width: 55,
              child: Column(
                children: [
                  Text(
                    _formatTime(event.startTime),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                  if (!event.isAllDay)
                    Text(
                      _formatTime(event.endTime),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(typeEmojis[event.type] ?? '📅', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.location!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                  if (event.guests.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${event.guests.length} guest${event.guests.length > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString()}:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}

// ──────────────────────────────────────────────
//  WISHLIST ITEM CARD
// ──────────────────────────────────────────────

class WishlistItemCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback? onTap;

  const WishlistItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final priorityStars = {
      WishlistPriority.low: 1,
      WishlistPriority.medium: 2,
      WishlistPriority.high: 3,
      WishlistPriority.veryHigh: 4,
      WishlistPriority.critical: 5,
    };
    final availabilityColors = {
      ItemAvailability.inStock: const Color(0xFF10B981),
      ItemAvailability.outOfStock: const Color(0xFFEF4444),
      ItemAvailability.preOrder: const Color(0xFFF59E0B),
      ItemAvailability.discontinued: const Color(0xFF6B7280),
      ItemAvailability.unknown: const Color(0xFF9CA3AF),
    };
    final availabilityLabels = {
      ItemAvailability.inStock: 'In Stock',
      ItemAvailability.outOfStock: 'Out of Stock',
      ItemAvailability.preOrder: 'Pre-order',
      ItemAvailability.discontinued: 'Discontinued',
      ItemAvailability.unknown: 'Unknown',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: kAprilColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Center(
                child: Icon(Icons.image_outlined, size: 36, color: kAprilColor.withOpacity(0.4)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stars
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < (priorityStars[item.priority] ?? 1) ? Icons.star : Icons.star_border,
                      size: 14,
                      color: kAprilColor,
                    )),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.category!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '₵${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                  ),
                  // Savings progress
                  if (item.savedAmount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: item.savedPercentage / 100,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.savedPercentage.toInt()}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Availability
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (availabilityColors[item.availability] ?? const Color(0xFF9CA3AF)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      availabilityLabels[item.availability] ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: availabilityColors[item.availability],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  STATEMENT CARD WIDGET
// ──────────────────────────────────────────────

class StatementCardWidget extends StatelessWidget {
  final StatementCardData card;
  final VoidCallback? onTap;

  const StatementCardWidget({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(card.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              card.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (card.isLocked)
                            const Icon(Icons.lock, size: 16, color: Color(0xFF6B7280)),
                        ],
                      ),
                      Text(
                        card.summary,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Completion bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: card.completionPercent / 100,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation(
                        card.completionPercent >= 80
                            ? const Color(0xFF10B981)
                            : card.completionPercent >= 50
                                ? kAprilColor
                                : const Color(0xFFF59E0B),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${card.completionPercent}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            // Highlights
            if (card.highlights.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: card.highlights.map((h) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kAprilColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    h,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                  ),
                )).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Updated ${_timeAgo(card.lastUpdated)}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
