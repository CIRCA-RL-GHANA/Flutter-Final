/// qualChat Screen 6 — Presence Dashboard (Enhanced)
/// Real-Time Operations Center: presence, heatmap, user cards

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatPresenceScreen extends StatelessWidget {
  const QualChatPresenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        final users = provider.filteredUsers;
        const stats = QualChatProvider.presenceStats;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: QualChatAppBar(
            title: 'Presence Dashboard',
            actions: [
              IconButton(
                icon: const Icon(Icons.sync, color: kChatColor),
                onPressed: () {},
                tooltip: 'Sync',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kChatColor.withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      width: double.infinity,
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI: ${ai.insights.first['title'] ?? ''}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kChatColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Live overview
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      PresenceStatCard(count: stats.online, label: 'Online', status: PresenceStatus.online, changePercent: stats.onlineChangePercent),
                      const SizedBox(width: 8),
                      PresenceStatCard(count: stats.idle, label: 'Idle', status: PresenceStatus.idle, changePercent: stats.idleChangePercent),
                      const SizedBox(width: 8),
                      PresenceStatCard(count: stats.offline, label: 'Offline', status: PresenceStatus.offline, changePercent: stats.offlineChangePercent),
                      const SizedBox(width: 8),
                      PresenceStatCard(count: stats.total, label: 'Total', status: PresenceStatus.online),
                    ],
                  ),
                ),

                // Activity heatmap
                QualChatSectionCard(
                  title: 'Activity Heatmap (Last 24h)',
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60,
                        child: CustomPaint(
                          size: const Size(double.infinity, 60),
                          painter: _HeatmapPainter(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('12a', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                          Text('6a', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                          Text('12p', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                          Text('6p', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                          Text('12a', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Most active: 2-4 PM',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),

                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: PresenceFilter.values.map((f) {
                      final isSelected = provider.presenceFilter == f;
                      final labels = {
                        PresenceFilter.individual: '👤 Individual',
                        PresenceFilter.entity: '🏢 Entity',
                        PresenceFilter.all: '🌐 All',
                      };
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => provider.setPresenceFilter(f),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? kChatColor : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              labels[f]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Status filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip2(
                          label: 'All',
                          isSelected: provider.statusFilter == null,
                          onTap: () => provider.setStatusFilter(null),
                        ),
                        _FilterChip2(
                          label: '🟢 Online',
                          isSelected: provider.statusFilter == PresenceStatus.online,
                          onTap: () => provider.setStatusFilter(PresenceStatus.online),
                        ),
                        _FilterChip2(
                          label: '🟡 Idle',
                          isSelected: provider.statusFilter == PresenceStatus.idle,
                          onTap: () => provider.setStatusFilter(PresenceStatus.idle),
                        ),
                        _FilterChip2(
                          label: '🔴 Offline',
                          isSelected: provider.statusFilter == PresenceStatus.offline,
                          onTap: () => provider.setStatusFilter(PresenceStatus.offline),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: provider.setPresenceSearch,
                    decoration: InputDecoration(
                      hintText: 'Search name, role, or department...',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // User list header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'ACTIVE NOW (${users.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // User list
                ...users.map((u) {
                  return _ExpandableUserCard(user: u);
                }),
                const SizedBox(height: 16),

                // Bottom actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat, size: 16),
                          label: const Text('Message All Online'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kChatColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.campaign, size: 16),
                          label: const Text('Announcement'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kChatColor,
                            side: const BorderSide(color: kChatColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip2 extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip2({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? kChatColor.withOpacity(0.1) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: kChatColor) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isSelected ? kChatColor : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandableUserCard extends StatefulWidget {
  final ChatUser user;
  const _ExpandableUserCard({required this.user});

  @override
  State<_ExpandableUserCard> createState() => _ExpandableUserCardState();
}

class _ExpandableUserCardState extends State<_ExpandableUserCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                PresenceDot(status: u.presence),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(u.role, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                if (u.statusMessage != null)
                  Text(u.statusMessage!, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
            if (_expanded) ...[
              const Divider(height: 16),
              _InfoRow('Status', u.statusMessage ?? 'Available'),
              _InfoRow('Average response', '${u.avgResponseMinutes} minutes'),
              _InfoRow('Department', u.department ?? 'N/A'),
              const _InfoRow('Preferred contact', '💬 Chat first'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QuickAction(icon: Icons.chat, label: 'Message', onTap: () {}),
                  const SizedBox(width: 8),
                  _QuickAction(icon: Icons.call, label: 'Call', onTap: () {}),
                  const SizedBox(width: 8),
                  _QuickAction(icon: Icons.calendar_today, label: 'Schedule', onTap: () {}),
                  const SizedBox(width: 8),
                  _QuickAction(icon: Icons.visibility, label: 'View', onTap: () {}),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A))),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: kChatColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: kChatColor),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 10, color: kChatColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / 24;
    final values = [0.1, 0.1, 0.05, 0.05, 0.1, 0.2, 0.4, 0.6, 0.7, 0.8, 0.85, 0.9,
        0.7, 0.8, 0.95, 0.9, 0.85, 0.7, 0.5, 0.3, 0.2, 0.15, 0.1, 0.1];
    for (int i = 0; i < values.length; i++) {
      final h = values[i] * size.height;
      final paint = Paint()
        ..color = Color.lerp(const Color(0xFFCFFAFE), const Color(0xFF06B6D4), values[i])!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * barWidth + 1, size.height - h, barWidth - 2, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
