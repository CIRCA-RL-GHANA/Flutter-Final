/// APRIL Module  Shared Widgets
/// Personal Assistant & Command Core
/// Module Color: Gold (IveTokens.moduleApril / IveTokens.genie)
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../models/april_models.dart';

// 
//  COLOR CONSTANTS
//  APRIL EXCEPTION: multiple gold/genie tokens are intentional here.
// 

// All APRIL colors use IveTokens directly — no local constants needed.
// APRIL exception: multiple gold/genie tokens are intentional here.

// 
//  APRIL APP BAR
// 

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
      backgroundColor: IveTokens.surface,
      foregroundColor: IveTokens.ink,
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
              color: IveTokens.genie,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: IveTokens.ink,
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

// 
//  SECTION CARD
// 

class AprilSectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const AprilSectionCard({super.key, required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: IveTokens.brSm,
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: IveTokens.ink),
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

// 
//  EMPTY STATE
// 

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
                color: IveTokens.genieSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: IveTokens.genie),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: IveTokens.ink)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: IveTokens.mute, height: 1.4),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 20),
              IveButton.primary(
                label: ctaLabel!,
                onPressed: onCta,
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

// 
//  VOICE BUTTON
// 

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
      VoiceState.idle: IveTokens.accent,
      VoiceState.listening: IveTokens.danger,
      VoiceState.processing: IveTokens.warning,
      VoiceState.success: IveTokens.success,
      VoiceState.error: IveTokens.danger,
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
        ),
        child: state == VoiceState.processing
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: IveTokens.ink, strokeWidth: 3),
              )
            : Icon(icons[state], color: IveTokens.ink, size: size * 0.4),
      ),
    );
  }
}

// 
//  PLUGIN CARD (Quick Access)
// 

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
      AprilPlugin.planner: {'icon': Icons.account_balance_wallet, 'emoji': '', 'name': 'Planner'},
      AprilPlugin.calendar: {'icon': Icons.calendar_month, 'emoji': '', 'name': 'Calendar'},
      AprilPlugin.wishlist: {'icon': Icons.card_giftcard, 'emoji': '', 'name': 'Wishlist'},
      AprilPlugin.statement: {'icon': Icons.description, 'emoji': '', 'name': 'Statement'},
    };
    final data = pluginData[plugin]!;
    final syncColors = {
      SyncStatus.synced: IveTokens.success,
      SyncStatus.pending: IveTokens.warning,
      SyncStatus.error: IveTokens.danger,
      SyncStatus.offline: IveTokens.mute,
    };

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: IveTokens.brSm,
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
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: const TextStyle(fontSize: 11, color: IveTokens.mute),
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
                    color: IveTokens.danger,
                    borderRadius: IveTokens.brSm,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: IveTokens.ink),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 
//  PENDING ACTION TILE
// 

class PendingActionTile extends StatelessWidget {
  final PendingAction action;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  const PendingActionTile({super.key, required this.action, this.onComplete, this.onTap});

  @override
  Widget build(BuildContext context) {
    final priorityColors = {
      ActionPriority.critical: IveTokens.danger,
      ActionPriority.high: IveTokens.warning,
      ActionPriority.medium: IveTokens.genie,
      ActionPriority.low: IveTokens.success,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: IveTokens.surfaceRaised,
          borderRadius: IveTokens.brSm,
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
                style: const TextStyle(fontSize: 13, color: IveTokens.ink2),
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
                      ? IveTokens.danger
                      : IveTokens.mute,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 
//  NOTIFICATION CARD
// 

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
      AprilNotificationType.financial: IveTokens.genie,
      AprilNotificationType.calendar: IveTokens.accent,
      AprilNotificationType.wishlist: IveTokens.genieBright,
      AprilNotificationType.personal: IveTokens.success,
      AprilNotificationType.system: IveTokens.mute,
    };

    return Dismissible(
      key: ValueKey(notification.id),
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: IveTokens.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: IveTokens.ink),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: IveTokens.surface,
            border: Border(
              left: BorderSide(
                color: typeColors[notification.type] ?? IveTokens.genie,
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.ink),
                    ),
                  ),
                  Text(
                    _timeAgo(notification.timestamp),
                    style: const TextStyle(fontSize: 11, color: IveTokens.ink2),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: const TextStyle(fontSize: 13, color: IveTokens.mute),
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
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(labels[action] ?? action.name))),
                        child: Text(
                          labels[action] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: typeColors[notification.type] ?? IveTokens.genie,
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

// 
//  TRANSACTION CARD
// 

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryEmojis = {
      TransactionCategory.dining: '',
      TransactionCategory.groceries: '',
      TransactionCategory.transport: '',
      TransactionCategory.entertainment: '',
      TransactionCategory.utilities: '',
      TransactionCategory.housing: '',
      TransactionCategory.healthcare: '',
      TransactionCategory.education: '',
      TransactionCategory.shopping: '',
      TransactionCategory.salary: '',
      TransactionCategory.freelance: '',
      TransactionCategory.investment: '',
      TransactionCategory.subscription: '',
      TransactionCategory.insurance: '',
      TransactionCategory.other: '',
    };
    final isIncome = transaction.type == TransactionType.income;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: IveTokens.brSm,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isIncome
                    ? IveTokens.success.withValues(alpha: 0.1)
                    : IveTokens.genieSoft,
                borderRadius: IveTokens.brSm,
              ),
              child: Center(
                child: Text(
                  categoryEmojis[transaction.category] ?? '',
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
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.ink),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        transaction.category.name,
                        style: const TextStyle(fontSize: 12, color: IveTokens.mute),
                      ),
                      if (transaction.isRecurring) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.repeat, size: 12, color: IveTokens.mute),
                      ],
                      if (transaction.hasReceipt) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.receipt_long, size: 12, color: IveTokens.mute),
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
                  '${isIncome ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isIncome ? IveTokens.success : IveTokens.danger,
                  ),
                ),
                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(fontSize: 11, color: IveTokens.ink2),
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

// 
//  BUDGET PROGRESS BAR
// 

class BudgetProgressBar extends StatelessWidget {
  final BudgetCategory budget;
  final VoidCallback? onTap;

  const BudgetProgressBar({super.key, required this.budget, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      BudgetStatus.onTrack: IveTokens.success,
      BudgetStatus.warning: IveTokens.warning,
      BudgetStatus.overBudget: IveTokens.danger,
      BudgetStatus.completed: IveTokens.mute,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: IveTokens.brSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(budget.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.ink)),
                Text(
                  '${budget.spent.toStringAsFixed(0)} / ${budget.limit.toStringAsFixed(0)}',
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
              borderRadius: IveTokens.brXs,
              child: LinearProgressIndicator(
                value: budget.percentage.clamp(0.0, 1.0),
                backgroundColor: IveTokens.hairline2,
                valueColor: AlwaysStoppedAnimation(statusColors[budget.status] ?? IveTokens.genie),
                minHeight: 8,
              ),
            ),
            if (budget.status == BudgetStatus.overBudget) ...[
              const SizedBox(height: 4),
              Text(
                'Over by ${(-budget.remaining).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: IveTokens.danger, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 
//  CALENDAR EVENT TILE
// 

class CalendarEventTile extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback? onTap;

  const CalendarEventTile({super.key, required this.event, this.onTap});

  static const _eventColors = [
    IveTokens.accent,    // blue
    IveTokens.genieBright, // gold-bright (APRIL exception)
    IveTokens.success,   // green
    IveTokens.danger,    // red
    IveTokens.warning,   // amber
    IveTokens.genie,     // gold (APRIL exception)
  ];

  @override
  Widget build(BuildContext context) {
    final color = _eventColors[event.colorIndex % _eventColors.length];
    final typeEmojis = {
      EventType.meeting: '',
      EventType.call: '',
      EventType.personal: '',
      EventType.travel: '',
      EventType.deadline: '',
      EventType.reminder: '',
      EventType.allDay: '',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: IveTokens.brSm,
          border: Border(left: BorderSide(color: color, width: 4)),
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
                      style: const TextStyle(fontSize: 11, color: IveTokens.ink2),
                    ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: IveTokens.hairline),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(typeEmojis[event.type] ?? '', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.ink),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.location!,
                      style: const TextStyle(fontSize: 12, color: IveTokens.mute),
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

// 
//  WISHLIST ITEM CARD
// 

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
      ItemAvailability.inStock: IveTokens.success,
      ItemAvailability.outOfStock: IveTokens.danger,
      ItemAvailability.preOrder: IveTokens.warning,
      ItemAvailability.discontinued: IveTokens.mute,
      ItemAvailability.unknown: IveTokens.ink2,
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
          color: IveTokens.surface,
          borderRadius: IveTokens.brSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: IveTokens.genieSoft,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(IveTokens.rSm),
                  topRight: Radius.circular(IveTokens.rSm),
                ),
              ),
              child: Center(
                child: Icon(Icons.image_outlined, size: 36, color: IveTokens.genieLine),
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
                      color: IveTokens.genie,
                    )),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IveTokens.ink),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.category!,
                      style: const TextStyle(fontSize: 11, color: IveTokens.mute),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: IveTokens.ink),
                  ),
                  // Savings progress
                  if (item.savedAmount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: IveTokens.brXs,
                            child: LinearProgressIndicator(
                              value: item.savedPercentage / 100,
                              backgroundColor: IveTokens.hairline2,
                              valueColor: const AlwaysStoppedAnimation(IveTokens.success),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.savedPercentage.toInt()}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: IveTokens.success),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Availability
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (availabilityColors[item.availability] ?? IveTokens.ink2).withValues(alpha: 0.1),
                      borderRadius: IveTokens.brXs,
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

// 
//  STATEMENT CARD WIDGET
// 

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
          color: IveTokens.surface,
          borderRadius: IveTokens.brSm,
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
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: IveTokens.ink),
                            ),
                          ),
                          if (card.isLocked)
                            const Icon(Icons.lock, size: 16, color: IveTokens.mute),
                        ],
                      ),
                      Text(
                        card.summary,
                        style: const TextStyle(fontSize: 12, color: IveTokens.mute),
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
                    borderRadius: IveTokens.brXs,
                    child: LinearProgressIndicator(
                      value: card.completionPercent / 100,
                      backgroundColor: IveTokens.hairline2,
                      valueColor: AlwaysStoppedAnimation(
                        card.completionPercent >= 80
                            ? IveTokens.success
                            : card.completionPercent >= 50
                                ? IveTokens.genie
                                : IveTokens.warning,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${card.completionPercent}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: IveTokens.mute),
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
                    color: IveTokens.genieSoft,
                    borderRadius: IveTokens.brXs,
                  ),
                  child: Text(
                    h,
                    style: const TextStyle(fontSize: 11, color: IveTokens.ink2),
                  ),
                )).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Updated ${_timeAgo(card.lastUpdated)}',
              style: const TextStyle(fontSize: 11, color: IveTokens.ink2),
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
