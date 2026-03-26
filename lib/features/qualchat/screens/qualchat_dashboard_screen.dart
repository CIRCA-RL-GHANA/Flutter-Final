/// qualChat Screen 1 — Dashboard (Enhanced)
/// Mode toggle, Vibe Check (Owner), Presence Hub, Insights, Archive

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatDashboardScreen extends StatelessWidget {
  const QualChatDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
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
                onPressed: () {},
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
                  color: kChatColor.withOpacity(0.05),
                  child: Text(
                    'Role: Owner • Context: Personal • Mode: ${provider.mode == ChatMode.social ? "Social" : "Professional"}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ),

                // Mode toggle (Owner only)
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: kChatColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kChatColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI: ${ai.insights.first['title'] ?? ''}',
                              style: const TextStyle(fontSize: 12, color: kChatColor, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                backgroundColor: const Color(0xFF6B7280),
                child: const Icon(Icons.theater_comedy, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),
              // Primary FAB
              FloatingActionButton(
                heroTag: 'primary_fab',
                onPressed: () {
                  if (provider.mode == ChatMode.social) {
                    Navigator.pushNamed(context, '/qualchat/hey-yas');
                  } else {
                    Navigator.pushNamed(context, '/qualchat/new-chat');
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
      title: 'My Hey Yas 💖',
      trailing: '⟳',
      onTrailingTap: () {},
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
            '🎯 Connection Success Rate',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
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
                          ? kChatSocial.withOpacity(0.7)
                          : const Color(0xFFE5E7EB),
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
            style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Text(
                'Active Sparks: ${provider.activeSparks}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
              ),
              const Text(' • ', style: TextStyle(color: Color(0xFF9CA3AF))),
              Text(
                'Matches: ${provider.matchCount} 💘',
                style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Energy Level: ${provider.energyLevel}% ⚡',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),

          // Smart nudge card
          if (QualChatProvider.nudges.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kChatSocial.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kChatSocial.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🥺 ${QualChatProvider.nudges.first.prompt}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${QualChatProvider.nudges.first.reason}"',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickButton(label: 'Send Message', onTap: () {}),
                      const SizedBox(width: 8),
                      _QuickButton(label: 'Remind Later', onTap: () {}),
                      const SizedBox(width: 8),
                      _QuickButton(label: 'Pass', onTap: () {}),
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
                  onPressed: () => Navigator.pushNamed(context, '/qualchat/hey-yas'),
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
                  onPressed: () => Navigator.pushNamed(context, '/qualchat/action-center'),
                  icon: const Text('📊'),
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
      title: '👥 Presence Dashboard',
      child: Column(
        children: [
          Row(
            children: [
              PresenceStatCard(
                count: stats.online,
                label: 'Online',
                status: PresenceStatus.online,
                changePercent: stats.onlineChangePercent,
                onTap: () => Navigator.pushNamed(context, '/qualchat/presence'),
              ),
              const SizedBox(width: 8),
              PresenceStatCard(
                count: stats.idle,
                label: 'Idle',
                status: PresenceStatus.idle,
                changePercent: stats.idleChangePercent,
                onTap: () => Navigator.pushNamed(context, '/qualchat/presence'),
              ),
              const SizedBox(width: 8),
              PresenceStatCard(
                count: stats.offline,
                label: 'Offline',
                status: PresenceStatus.offline,
                changePercent: stats.offlineChangePercent,
                onTap: () => Navigator.pushNamed(context, '/qualchat/presence'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Available now
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Available Now:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
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
                  Text(u.name, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
                  const SizedBox(width: 4),
                  Text('(${u.role})', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  const Spacer(),
                  Icon(Icons.chat, size: 16, color: kChatColor),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Search + actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                SizedBox(width: 8),
                Text(
                  'Search or start new chat...',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/qualchat/new-chat'),
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
                  onPressed: () => Navigator.pushNamed(context, '/qualchat/presence'),
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
      title: '🧠 Conversation Insights',
      trailing: 'ⓘ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Conversations:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          ...QualChatProvider.insights.map((i) {
            IconData icon;
            Color iconColor;
            switch (i.priority) {
              case InsightPriority.unresolved:
                icon = Icons.warning_amber;
                iconColor = const Color(0xFFF59E0B);
              case InsightPriority.followUp:
                icon = Icons.schedule;
                iconColor = const Color(0xFF3B82F6);
              case InsightPriority.completed:
                icon = Icons.check_circle;
                iconColor = const Color(0xFF10B981);
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
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: const [
              Text('Sentiment Trend: 📈 Positive',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              SizedBox(width: 16),
              Text('Response Time: ⏱️ Avg 12m',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 12),

          // Recent media
          const Text('Recent Media:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Row(
            children: [
              _MediaThumb(icon: Icons.photo, label: '📸'),
              const SizedBox(width: 8),
              _MediaThumb(icon: Icons.videocam, label: '📹'),
              const SizedBox(width: 8),
              _MediaThumb(icon: Icons.attach_file, label: '📎'),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('+3', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/qualchat/archived'),
                  child: const Text('📁 Archive Manager'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kChatColor,
                    side: const BorderSide(color: kChatColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('📊 Full Report'),
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

  // ──── SECTION D: ARCHIVE ────

  Widget _buildArchiveSection(BuildContext context, QualChatProvider provider) {
    return QualChatSectionCard(
      title: '🗃️ Archived Conversations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${QualChatProvider.archivedChats.length} threads hidden • Last archived: Today',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          ...QualChatProvider.archivedChats.take(2).map((a) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: kChatColor.withOpacity(0.1),
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
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SmallAction(label: 'Manage', onTap: () => Navigator.pushNamed(context, '/qualchat/archived')),
              const SizedBox(width: 8),
              _SmallAction(label: 'Restore All', onTap: () {}),
              const SizedBox(width: 8),
              _SmallAction(label: 'Empty Trash', onTap: () {}, isDestructive: true),
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
          border: Border.all(color: kChatSocial.withOpacity(0.3)),
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
        color: kChatColor.withOpacity(0.1),
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
                ? const Color(0xFFEF4444).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
