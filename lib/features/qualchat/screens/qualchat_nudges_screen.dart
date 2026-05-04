/// qualChat Screen 11 — Smart Nudges
/// AI wingmate: swipe deck, nudge types, AI decision mode, settings

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatNudgesScreen extends StatelessWidget {
  const QualChatNudgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        final nudges = QualChatProvider.nudges;
        final currentIndex = provider.currentNudgeIndex;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: QualChatAppBar(
            title: 'Smart Nudges',
            actions: [
              IconButton(
                icon: const Icon(Icons.tune, color: kChatColor),
                onPressed: () => _showNudgeSettings(context, provider),
              ),
            ],
          ),
          body: nudges.isEmpty
              ? const QualChatEmptyState(
                  icon: Icons.auto_awesome,
                  title: 'All caught up!',
                  message: "No nudges right now. We'll notify you when there's something to act on 🌟",
                )
              : Column(
                  children: [
                    Consumer<AIInsightsNotifier>(
                      builder: (context, ai, _) {
                        if (ai.insights.isEmpty) return const SizedBox.shrink();
                        return Container(
                          color: kChatColor.withOpacity(0.07),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    // Header stats
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kChatColor.withOpacity(0.08), kChatColorLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: kChatColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI Wingmate Active 🤖',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '${nudges.length} nudges to review • ${currentIndex + 1} of ${nudges.length}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          // AI mode toggle
                          Column(
                            children: [
                              Switch(
                                value: true,
                                onChanged: (_) {},
                                activeColor: kChatColor,
                              ),
                              const Text('Auto', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Nudge progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: List.generate(nudges.length, (i) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: i <= currentIndex ? kChatColor : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Swipe deck — current nudge
                    Expanded(
                      child: currentIndex < nudges.length
                          ? _NudgeCard(nudge: nudges[currentIndex])
                          : const QualChatEmptyState(
                              icon: Icons.check_circle_outline,
                              title: 'All reviewed!',
                              message: 'You\'ve gone through all nudges. Nice work! 🎉',
                            ),
                    ),

                    // Action buttons
                    if (currentIndex < nudges.length)
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Pass
                            _ActionCircle(
                              icon: Icons.close,
                              color: const Color(0xFFEF4444),
                              label: 'Skip',
                              onTap: () => provider.handleNudgeAction(
                                NudgeAction.pass,
                              ),
                            ),
                            // Snooze
                            _ActionCircle(
                              icon: Icons.schedule,
                              color: const Color(0xFFF59E0B),
                              label: 'Later',
                              onTap: () => provider.handleNudgeAction(
                                NudgeAction.snooze,
                              ),
                            ),
                            // Accept
                            _ActionCircle(
                              icon: Icons.check,
                              color: const Color(0xFF10B981),
                              label: 'Do It',
                              size: 64,
                              onTap: () => provider.handleNudgeAction(
                                NudgeAction.accept,
                              ),
                            ),
                            // Custom
                            _ActionCircle(
                              icon: Icons.auto_fix_high,
                              color: kChatColor,
                              label: 'AI Do',
                              onTap: () => provider.handleNudgeAction(
                                NudgeAction.custom,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  void _showNudgeSettings(BuildContext context, QualChatProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nudge Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Nudge type toggles
            ...NudgeType.values.map((type) {
              final labels = {
                NudgeType.followUp: '📎 Follow-ups',
                NudgeType.reEngagement: '🤝 Re-engagement',
                NudgeType.profileUpdate: '📝 Profile Updates',
                NudgeType.compatibility: '💫 Compatibility',
                NudgeType.activity: '⚡ Activity',
              };
              return SwitchListTile(
                title: Text(labels[type] ?? type.name, style: const TextStyle(fontSize: 14)),
                value: true,
                onChanged: (_) {},
                activeColor: kChatColor,
              );
            }),

            const Divider(height: 32),

            // Frequency
            const Text('Nudge Frequency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'low', label: Text('Low')),
                ButtonSegment(value: 'medium', label: Text('Medium')),
                ButtonSegment(value: 'high', label: Text('High')),
              ],
              selected: const {'medium'},
              onSelectionChanged: (_) {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return kChatColor;
                  return null;
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Quiet hours
            const Text('Quiet Hours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Enable quiet hours', style: TextStyle(fontSize: 14)),
              subtitle: const Text('10:00 PM - 8:00 AM', style: TextStyle(fontSize: 12)),
              value: true,
              onChanged: (_) {},
              activeColor: kChatColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _NudgeCard extends StatelessWidget {
  final SmartNudge nudge;
  const _NudgeCard({required this.nudge});

  @override
  Widget build(BuildContext context) {
    final typeIcons = {
      NudgeType.followUp: '📎',
      NudgeType.reEngagement: '🤝',
      NudgeType.profileUpdate: '📝',
      NudgeType.compatibility: '💫',
      NudgeType.activity: '⚡',
    };
    final priority = nudge.matchPercentage >= 90
        ? TaskPriority.high
        : nudge.matchPercentage >= 75
            ? TaskPriority.medium
            : TaskPriority.low;
    final priorityColors = {
      TaskPriority.high: const Color(0xFFEF4444),
      TaskPriority.medium: const Color(0xFFF59E0B),
      TaskPriority.low: const Color(0xFF10B981),
    };

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type & Priority header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (priorityColors[priority] ?? kChatColor).withOpacity(0.08),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(typeIcons[nudge.type] ?? '💬', style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nudge.prompt,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (priorityColors[priority] ?? kChatColor).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              priority.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: priorityColors[priority] ?? kChatColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(nudge.createdAt),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              nudge.reason,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF374151)),
            ),
          ),

          // AI suggestion
          Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kChatColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kChatColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: kChatColor.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      const Text(
                        'AI Suggestion',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kChatColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nudge.suggestedOpener,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Person info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: kChatColor.withOpacity(0.15),
                  child: Text(
                    nudge.person.name[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: kChatColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nudge.person.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Match: ${nudge.matchPercentage}%',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                // Match percentage bar
                SizedBox(
                  width: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: nudge.matchPercentage / 100.0,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation(
                        nudge.matchPercentage > 80
                            ? const Color(0xFF10B981)
                            : nudge.matchPercentage > 50
                                ? kChatColor
                                : const Color(0xFFF59E0B),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double size;
  final VoidCallback onTap;

  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.label,
    this.size = 52,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Icon(icon, color: color, size: size * 0.45),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
