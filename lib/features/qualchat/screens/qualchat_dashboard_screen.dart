/// qualChat Screen 1 — Dashboard (Enhanced)
/// Mode toggle, Vibe Check (Owner), Presence Hub, Insights, Archive
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/design/ive_tokens.dart';

class QualChatDashboardScreen extends StatelessWidget {
  const QualChatDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: IveTokens.bg,
          appBar: QualChatAppBar(
            title: 'qualChat Dashboard',
            showBackButton: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text('Settings'),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('Help'),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.feedback_outlined),
                            title: const Text('Feedback'),
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role + Context banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: kChatColor.withValues(alpha: 0.05),
                  child: Text(
                    'Role: Owner • Context: Personal • Mode: ${provider.mode == ChatMode.social ? "Social" : "Professional"}',
                    style: const TextStyle(fontSize: 12, color: IveTokens.labelSecondary),
                  ),
                ),

                // Mode toggle (Owner only)
                ModeToggle(
                  mode: provider.mode,
                  onChanged: provider.setMode,
                ),

                // Section A: Vibe Check & Hey Ya Hub (Social mode)
                if (provider.mode == ChatMode.social) ...[
                  _buildVibeCheckSection(context, provider),
                ],

                // Section B: Live Communications Hub
                _buildPresenceSection(context, provider),

                // Section C: Conversation Intelligence
                _buildInsightsSection(context),

                // Section D: Archived & Hidden
                _buildArchiveSection(context, provider),

                const SizedBox(height: 80),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode toggle FAB (Owner)
              FloatingActionButton.small(
                heroTag: 'mode_fab',
                onPressed: () {
                  provider.setMode(
                    provider.mode == ChatMode.social
                        ? ChatMode.professional
                        : ChatMode.social,
                  );
                },
                backgroundColor: IveTokens.surface,
                child: const Icon(Icons.theater_comedy, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),
              // Primary FAB
              FloatingActionButton(
                heroTag: 'primary_fab',
                onPressed: () {
                  if (provider.mode == ChatMode.social) {
                    Navigator.pushNamed(context, AppRoutes.qualChatHeyYas);
                  } else {
                    Navigator.pushNamed(context, AppRoutes.qualChatNewChat);
                  }
                },
                backgroundColor: provider.mode == ChatMode.social
                    ? kChatSocial
                    : kChatColor,
                child: Icon(
                  provider.mode == ChatMode.social
                      ? Icons.auto_awesome
                      : Icons.chat,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ──── SECTION A: VIBE CHECK ────

  Widget _buildVibeCheckSection(BuildContext context, QualChatProvider provider) {
    return QualChatSectionCard(
      title: 'My Hey Yas',
      trailing: '\u27F3',
      onTrailingTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refreshing...')),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vibe Status: Sparkling Ready ✨',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kChatSocial,
            ),
          ),
          const SizedBox(height: 16),

          // Connection success rate chart
          const Text(
            'ðŸŽ¯ Connection Success Rate',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.label),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Row(
              children: QualChatProvider.connectionHistory.map((c) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: c.isSuccess
                          ? kChatSocial.withValues(alpha: 0.7)
                          : IveTokens.hairline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Last 10 connections',
            style: TextStyle(fontSize: 11, color: IveTokens.labelTertiary),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Text(
                'Active Sparks: ${provider.activeSparks}',
                style: const TextStyle(fontSize: 13, color: IveTokens.label),
              ),
              const Text(' • ', style: TextStyle(color: IveTokens.labelTertiary)),
              Text(
                'Matches: ${provider.matchCount} 💘',
                style: const TextStyle(fontSize: 13, color: IveTokens.label),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Energy Level: ${provider.energyLevel}% âš¡',
            style: const TextStyle(fontSize: 13, color: IveTokens.labelSecondary),
          ),
          const SizedBox(height: 16),

          // Smart nudge card
          if (QualChatProvider.nudges.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kChatSocial.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kChatSocial.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ðŸ¥º ${QualChatProvider.nudges.first.prompt}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: IveTokens.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${QualChatProvider.nudges.first.reason}"',
                    style: const TextStyle(fontSize: 12, color: IveTokens.labelSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickButton(label: 'Send Message', onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatDashboard)),
                      const SizedBox(width: 8),
                      _QuickButton(label: 'Remind Later', onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder set')),
                        );
                      }),
                      const SizedBox(width: 8),
                      _QuickButton(label: 'Pass', onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passed')),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qualChatHeyYas),
                  icon: const Text('✨'),
                  label: const Text('Send Hey Ya'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kChatSocial,
                    side: const BorderSide(color: kChatSocial),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qualChatActionCenter),
                  icon: const Text('ðŸ“Š'),
                  label: const Text('Analytics'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kChatColor,
                    side: const BorderSide(color: kChatColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──── SECTION B: PRESENCE ────

  Widget _buildPresenceSection(BuildContext context, QualChatProvider provider) {
    const stats = QualChatProvider.presenceStats;
    return QualChatSectionCard(
      title: 'Presence Dashboard',
      child: Column(
        children: [
          Row(
            children: [
              PresenceStatCard(
                count: stats.online,
                label: 'Online',
                status: PresenceStatus.online,
                changePercent: stats.onlineChangePercent,
                onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatPresence),
              ),
              const SizedBox(width: 8),
              PresenceStatCard(
                count: stats.idle,
                label: 'Idle',
                status: PresenceStatus.idle,
                changePercent: stats.idleChangePercent,
                onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatPresence),
              ),
              const SizedBox(width: 8),
              PresenceStatCard(
                count: stats.offline,
                label: 'Offline',
                status: PresenceStatus.offline,
                changePercent: stats.offlineChangePercent,
                onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatPresence),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Available now
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Available Now:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.label),
            ),
          ),
          const SizedBox(height: 8),
          ...QualChatProvider.allUsers.where((u) => u.presence == PresenceStatus.online).take(3).map((u) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  PresenceDot(status: u.presence),
                  const SizedBox(width: 8),
                  Text(u.name, style: const TextStyle(fontSize: 13, color: IveTokens.label)),
                  const SizedBox(width: 4),
                  Text('(${u.role})', style: const TextStyle(fontSize: 12, color: IveTokens.labelTertiary)),
                  const Spacer(),
                  const Icon(Icons.chat, size: 16, color: kChatColor),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Search + actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: IveTokens.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, size: 18, color: IveTokens.labelTertiary),
                SizedBox(width: 8),
                Text(
                  'Search or start new chat...',
                  style: TextStyle(fontSize: 13, color: IveTokens.labelTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qualChatNewChat),
                  icon: const Icon(Icons.rocket_launch, size: 16),
                  label: const Text('Start New Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kChatColor,
                    side: const BorderSide(color: kChatColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qualChatPresence),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Browse Active'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kChatColor,
                    side: const BorderSide(color: kChatColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──── SECTION C: INSIGHTS ────

  Widget _buildInsightsSection(BuildContext context) {
    return QualChatSectionCard(
      title: 'Conversation Insights',
      trailing: '\u24D8',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Conversations:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.label),
          ),
          const SizedBox(height: 8),
          ...QualChatProvider.insights.map((i) {
            IconData icon;
            Color iconColor;
            switch (i.priority) {
              case InsightPriority.unresolved:
                icon = Icons.warning_amber;
                iconColor = IveTokens.warning;
              case InsightPriority.followUp:
                icon = Icons.schedule;
                iconColor = IveTokens.moduleMarket;
              case InsightPriority.completed:
                icon = Icons.check_circle;
                iconColor = IveTokens.success;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      i.title,
style: const TextStyle(fontSize: 13, color: IveTokens.label),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text('Sentiment Trend: 📈 Positive',
                  style: TextStyle(fontSize: 12, color: IveTokens.labelSecondary)),
              SizedBox(width: 16),
              Text('Response Time: ⏱️ Avg 12m',
                  style: TextStyle(fontSize: 12, color: IveTokens.labelSecondary)),
            ],
          ),
          const SizedBox(height: 12),

          // Recent media
          const Text('Recent Media:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: IveTokens.label)),
          const SizedBox(height: 8),
          Row(
            children: [
              const _MediaThumb(icon: Icons.photo, label: 'ðŸ“¸'),
              const SizedBox(width: 8),
              const _MediaThumb(icon: Icons.videocam, label: 'ðŸ“¹'),
              const SizedBox(width: 8),
              const _MediaThumb(icon: Icons.attach_file, label: 'ðŸ“Ž'),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: IveTokens.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('+3', style: TextStyle(fontSize: 13, color: IveTokens.labelSecondary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qualChatArchived),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kChatColor,
                    side: const BorderSide(color: kChatColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('ðŸ“ Archive Manager'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qualChatActionCenter),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kChatColor,
                    side: const BorderSide(color: kChatColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('ðŸ“Š Full Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──── SECTION D: ARCHIVE ────

  Widget _buildArchiveSection(BuildContext context, QualChatProvider provider) {
    return QualChatSectionCard(
      title: 'Archived Conversations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${QualChatProvider.archivedChats.length} threads hidden • Last archived: Today',
            style: const TextStyle(fontSize: 12, color: IveTokens.labelSecondary),
          ),
          const SizedBox(height: 12),
          ...QualChatProvider.archivedChats.take(2).map((a) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: kChatColor.withValues(alpha: 0.1),
                    child: Text(
                      a.conversation.title[0],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kChatColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.conversation.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                          '"${a.conversation.lastMessage}"',
                          style: const TextStyle(fontSize: 12, color: IveTokens.labelTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Storage: ${provider.totalArchivedSizeMb.toStringAsFixed(1)} MB saved',
            style: const TextStyle(fontSize: 12, color: IveTokens.labelSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SmallAction(label: 'Manage', onTap: () => Navigator.pushNamed(context, AppRoutes.qualChatArchived)),
              const SizedBox(width: 8),
              _SmallAction(label: 'Restore All', onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All conversations restored')),
                );
              }),
              const SizedBox(width: 8),
              _SmallAction(label: 'Empty Trash', onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Empty Trash'),
                    content: const Text('Permanently delete all archived conversations?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Trash emptied')),
                          );
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }, isDestructive: true),
            ],
          ),
        ],
      ),
    );
  }
}

// ──── HELPER WIDGETS ────

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: kChatSocial.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kChatSocial),
        ),
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MediaThumb({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: kChatColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(label, style: const TextStyle(fontSize: 20))),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _SmallAction({required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive
                ? IveTokens.danger.withValues(alpha: 0.3)
                : IveTokens.hairline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDestructive ? IveTokens.danger : IveTokens.labelSecondary,
          ),
        ),
      ),
    );
  }
}
