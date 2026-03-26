/// APRIL Screen 1 — ActionCore Dashboard (Home Hub)
/// Master header, voice center, notifications, plugin grid, command bar, status

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/widgets/ai_insight_card.dart';
import '../models/april_models.dart';
import '../providers/april_provider.dart';
import '../widgets/april_widgets.dart';

class AprilDashboardScreen extends StatelessWidget {
  const AprilDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AprilProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: CustomScrollView(
            slivers: [
              // ──── MASTER HEADER (Sticky) ────
              SliverAppBar(
                pinned: true,
                expandedHeight: 140,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1A1A),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 22),
                    onPressed: provider.refreshSync,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 22),
                    onPressed: () => Navigator.pushNamed(context, '/april/settings'),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: kAprilColor.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: kAprilColorDark),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.userName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: kAprilColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Owner', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kAprilColorDark)),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text('Personal Context', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _greeting(provider.userName),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${provider.pendingActionCount} actions pending',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: provider.pendingActionCount > 0
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF10B981),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(' • ', style: TextStyle(color: Color(0xFF9CA3AF))),
                              Text(
                                'Last sync: ${_timeAgo(provider.lastSync)}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ──── VOICE COMMAND CENTER ────
                    AprilSectionCard(
                      title: '🎤 Voice Command Center',
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          AprilVoiceButton(
                            state: provider.voiceState,
                            size: 80,
                            onTap: () {
                              if (provider.voiceState == VoiceState.idle) {
                                provider.setVoiceState(VoiceState.listening);
                              } else {
                                provider.setVoiceState(VoiceState.idle);
                              }
                            },
                            onLongPress: () => provider.setVoiceState(VoiceState.listening),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.voiceState == VoiceState.listening
                                ? 'Listening...'
                                : provider.voiceState == VoiceState.processing
                                    ? 'Processing...'
                                    : 'Tap & Speak',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Say "Add meeting with Alex tomorrow"',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 16),

                          // Voice history (collapsible)
                          ExpansionTile(
                            title: const Text('Recent Commands', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            children: provider.voiceHistory.take(5).map((cmd) => Dismissible(
                              key: ValueKey(cmd.id),
                              onDismissed: (_) => provider.removeVoiceCommand(cmd.id),
                              background: Container(color: const Color(0xFFEF4444)),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  cmd.type == CommandType.voice ? Icons.mic : Icons.keyboard,
                                  size: 18,
                                  color: cmd.successful ? kAprilSuccess : const Color(0xFFEF4444),
                                ),
                                title: Text(cmd.text, style: const TextStyle(fontSize: 13)),
                                subtitle: Text(
                                  cmd.result ?? '',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                ),
                                trailing: Text(
                                  _timeAgo(cmd.timestamp),
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ──── SMART NOTIFICATIONS PANEL ────
                    AprilSectionCard(
                      title: '🔔 Notifications',
                      trailing: provider.unreadNotificationCount > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${provider.unreadNotificationCount}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            )
                          : null,
                      child: Column(
                        children: [
                          if (provider.notifications.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('All caught up! 🎉', style: TextStyle(color: Color(0xFF6B7280))),
                            )
                          else
                            ...provider.notifications.map((n) => AprilNotificationCard(
                              notification: n,
                              onDismiss: () => provider.dismissNotification(n.id),
                            )),
                          if (provider.notifications.length > 2) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: provider.markAllNotificationsRead,
                                  child: const Text('Mark all read', style: TextStyle(fontSize: 12, color: kAprilColorDark)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ──── AI INSIGHTS PANEL ────
                    Consumer<AIInsightsNotifier>(
                      builder: (ctx, aiNotifier, _) {
                        final insights = aiNotifier.insights;
                        if (insights.isEmpty) return const SizedBox.shrink();
                        return AprilSectionCard(
                          title: '✨ AI Insights',
                          child: Column(
                            children: [
                              ...insights.take(2).map(
                                (i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: AIInsightCard(insight: i),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ──── PLUGIN QUICK ACCESS GRID ────
                    const Text(
                      '📦 Plugins',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: provider.pluginStatuses.map((ps) {
                        final routes = {
                          AprilPlugin.planner: '/april/planner',
                          AprilPlugin.calendar: '/april/calendar',
                          AprilPlugin.wishlist: '/april/wishlist',
                          AprilPlugin.statement: '/april/statement',
                        };
                        return PluginCard(
                          plugin: ps.plugin,
                          syncStatus: ps.syncStatus,
                          statusText: ps.statusText,
                          badgeCount: ps.badgeCount,
                          onTap: () => Navigator.pushNamed(context, routes[ps.plugin]!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // ──── QUICK COMMAND BAR ────
                    AprilSectionCard(
                      title: '⚡ Quick Command',
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Type a command...',
                              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                              prefixIcon: const Icon(Icons.terminal, color: Color(0xFF9CA3AF)),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.help_outline, size: 20, color: Color(0xFF9CA3AF)),
                                onPressed: () {},
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: ['Add expense', 'Schedule meeting', 'Check balance', 'Add to wishlist']
                                .map((t) => GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: kAprilColor.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(t, style: const TextStyle(fontSize: 11, color: kAprilColorDark)),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ──── SYSTEM STATUS FOOTER ────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('APRIL v2.1.0', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  const Text('All systems synced', style: TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Storage: 124 MB / 1 GB', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  '🛑 Emergency Stop',
                                  style: TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, $name! ☀️';
    if (hour < 17) return 'Good afternoon, $name! 🌤️';
    return 'Good evening, $name! 🌙';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
