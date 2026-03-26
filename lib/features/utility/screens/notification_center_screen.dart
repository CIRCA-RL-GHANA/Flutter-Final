/// ═══════════════════════════════════════════════════════════════════════════
/// U2: NOTIFICATION CENTER Screen
/// Filterable notification feed with read/unread/archive, swipe actions,
/// notification type chips, priority indicators
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/utility_models.dart';
import '../providers/utility_provider.dart';
import '../widgets/shared_widgets.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityProvider>(
      builder: (context, prov, _) {
        final filtered = prov.filteredNotifications;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: UtilityAppBar(
            title: 'Notifications',
            actions: [
              if (prov.unreadCount > 0)
                TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    prov.markAllRead();
                  },
                  child: const Text(
                    'Read All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kUtilityColor,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kUtilityColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUtilityColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUtilityColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ─── Status Filter Chips ──────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: UtilityFilterChipRow(
                  labels: [
                    'All (${prov.notifications.where((n) => !n.isArchived).length})',
                    'Unread (${prov.unreadCount})',
                    'Read',
                    'Archived',
                  ],
                  selectedIndex: prov.notificationFilter.index,
                  onSelected: (i) => prov.setNotificationFilter(NotificationFilter.values[i]),
                ),
              ),

              // ─── Type Filter Chips ────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _TypeChip(
                        label: 'All Types',
                        isSelected: prov.notificationTypeFilter == null,
                        onTap: () => prov.setNotificationTypeFilter(null),
                      ),
                      ...NotificationType.values.map((type) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: _TypeChip(
                          label: _typeLabel(type),
                          isSelected: prov.notificationTypeFilter == type,
                          onTap: () => prov.setNotificationTypeFilter(type),
                        ),
                      )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ─── Notification List ────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const UtilityEmptyState(
                        icon: Icons.notifications_none,
                        title: 'No Notifications',
                        subtitle: 'You\'re all caught up! New notifications will appear here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final notif = filtered[i];
                          return Dismissible(
                            key: ValueKey(notif.id),
                            background: _dismissBackground(Colors.blue, Icons.archive, Alignment.centerLeft),
                            secondaryBackground: _dismissBackground(AppColors.error, Icons.delete, Alignment.centerRight),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                prov.archiveNotification(notif.id);
                                return false;
                              } else {
                                prov.deleteNotification(notif.id);
                                return true;
                              }
                            },
                            child: _NotificationCard(
                              notification: notif,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                prov.markNotificationRead(notif.id);
                                if (notif.actionRoute != null) {
                                  Navigator.pushNamed(context, notif.actionRoute!);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dismissBackground(Color color, IconData icon, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }

  String _typeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.system: return 'System';
      case NotificationType.security: return 'Security';
      case NotificationType.transaction: return 'Transaction';
      case NotificationType.social: return 'Social';
      case NotificationType.promotion: return 'Promo';
      case NotificationType.reminder: return 'Reminder';
      case NotificationType.alert: return 'Alert';
      case NotificationType.update: return 'Update';
    }
  }
}

// ─── Type Filter Chip ────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? kUtilityColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kUtilityColor : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? kUtilityColor : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ─── Notification Card ───────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(14),
          border: notification.isRead
              ? null
              : Border.all(color: const Color(0xFF3B82F6).withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority dot + icon
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notification.priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(notification.typeIcon, size: 20, color: notification.priorityColor),
                ),
                if (!notification.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _timeAgo(notification.timestamp),
                        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.senderName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.senderName!,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
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
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${dt.day}/${dt.month}';
}
