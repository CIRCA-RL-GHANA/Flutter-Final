/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 9 — Notifications Center
/// Six filter tabs: All, Likes, Comments, Mentions, Shares, System.
/// Mark all read, individual actions, notification grouping.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesNotificationsScreen extends StatelessWidget {
  const UpdatesNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesProvider(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UpdateNotification> _filtered(List<UpdateNotification> all, int tabIndex) {
    if (tabIndex == 0) return all;
    final type = switch (tabIndex) {
      1 => UpdateNotificationType.like,
      2 => UpdateNotificationType.comment,
      3 => UpdateNotificationType.mention,
      4 => UpdateNotificationType.share,
      5 => UpdateNotificationType.system,
      _ => null,
    };
    if (type == null) return all;
    return all.where((n) => n.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: UpdatesAppBar(
            title: 'Notifications',
            actions: [
              if (prov.unreadNotificationCount > 0)
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    prov.markAllNotificationsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All marked as read'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                    );
                  },
                  child: const Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kUpdatesColor)),
                ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                color: AppColors.textSecondary,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showNotificationSettings(context);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kUpdatesColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Unread counter
              if (prov.unreadNotificationCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: kUpdatesColor.withOpacity(0.04),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: kUpdatesColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${prov.unreadNotificationCount} unread notification${prov.unreadNotificationCount > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kUpdatesColor),
                      ),
                    ],
                  ),
                ),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: kUpdatesColor,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: kUpdatesColor,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  dividerHeight: 0,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('All'),
                        if (prov.unreadNotificationCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(color: kUpdatesColor, borderRadius: BorderRadius.circular(8)),
                            child: Text('${prov.unreadNotificationCount}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ],
                      ],
                    )),
                    const Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite, size: 14), SizedBox(width: 3), Text('Likes')])),
                    const Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chat_bubble, size: 14), SizedBox(width: 3), Text('Comments')])),
                    const Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.alternate_email, size: 14), SizedBox(width: 3), Text('Mentions')])),
                    const Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shortcut, size: 14), SizedBox(width: 3), Text('Shares')])),
                    const Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.info, size: 14), SizedBox(width: 3), Text('System')])),
                  ],
                ),
              ),

              // Notification list
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(6, (tabIndex) {
                    final filtered = _filtered(prov.notifications, tabIndex);
                    if (filtered.isEmpty) {
                      return UpdatesEmptyState(
                        icon: Icons.notifications_none,
                        title: 'No notifications',
                        message: tabIndex == 0
                            ? 'You\'re all caught up! Check back later.'
                            : 'No ${['', 'like', 'comment', 'mention', 'share', 'system'][tabIndex]} notifications yet.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
                      itemBuilder: (context, i) {
                        final notif = filtered[i];
                        return Dismissible(
                          key: ValueKey(notif.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: AppColors.error.withOpacity(0.1),
                            child: const Icon(Icons.delete_outline, color: AppColors.error),
                          ),
                          onDismissed: (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notification dismissed'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                            );
                          },
                          child: NotificationItem(
                            notification: notif,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // Navigate to the relevant update
                            },
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const _NotifToggle(label: 'Likes', subtitle: 'When someone likes your update', value: true),
            const _NotifToggle(label: 'Comments', subtitle: 'When someone comments on your update', value: true),
            const _NotifToggle(label: 'Mentions', subtitle: 'When someone mentions you', value: true),
            const _NotifToggle(label: 'Shares', subtitle: 'When your update is shared', value: true),
            const _NotifToggle(label: 'System', subtitle: 'Platform announcements', value: false),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NotifToggle extends StatefulWidget {
  final String label;
  final String subtitle;
  final bool value;
  const _NotifToggle({required this.label, required this.subtitle, required this.value});

  @override
  State<_NotifToggle> createState() => _NotifToggleState();
}

class _NotifToggleState extends State<_NotifToggle> {
  late bool _value;
  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(widget.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      activeColor: kUpdatesColor,
      contentPadding: EdgeInsets.zero,
    );
  }
}
