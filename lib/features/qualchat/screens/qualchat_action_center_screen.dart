/// qualChat Screen 12 — Action Center
/// Task manager: priority sections, AI suggestions, profile completeness, analytics

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatActionCenterScreen extends StatelessWidget {
  const QualChatActionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        final tasks = QualChatProvider.tasks;
        final suggestions = QualChatProvider.aiSuggestions;
        final analytics = QualChatProvider.taskAnalytics;
        final completeness = provider.profileCompleteness;

        final actNow =
            tasks.where((t) => t.priority == TaskPriority.high).toList();
        final considerLater = tasks
            .where((t) =>
                t.priority == TaskPriority.medium ||
                t.priority == TaskPriority.low)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: QualChatAppBar(
            title: 'Action Center',
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart, color: kChatColor),
                onPressed: () => _showAnalytics(context, analytics),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kChatColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
              // Profile completeness bar
              QualChatSectionCard(
                title: '🎯 Profile Completeness',
                trailing: '$completeness%',
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: completeness / 100,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation(
                          completeness > 80
                              ? const Color(0xFF10B981)
                              : completeness > 50
                                  ? kChatColor
                                  : const Color(0xFFF59E0B),
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completeness >= 90
                          ? 'Excellent! Your profile is nearly complete 🌟'
                          : completeness >= 70
                              ? 'Good progress! A few more items to go'
                              : 'Complete your profile to get better results',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ──── ACT NOW ────
              if (actNow.isNotEmpty) ...[
                _SectionLabel(
                    title: '🔥 ACT NOW',
                    count: actNow.length,
                    color: const Color(0xFFEF4444)),
                ...actNow.map((task) => _TaskCard(task: task)),
                const SizedBox(height: 16),
              ],

              // ──── CONSIDER LATER ────
              if (considerLater.isNotEmpty) ...[
                _SectionLabel(
                    title: '💡 CONSIDER LATER',
                    count: considerLater.length,
                    color: const Color(0xFFF59E0B)),
                ...considerLater.map((task) => _TaskCard(task: task)),
                const SizedBox(height: 16),
              ],

              // ──── AI SUGGESTIONS ────
              if (suggestions.isNotEmpty) ...[
                const _SectionLabel(
                    title: '🤖 AI SUGGESTIONS', count: 0, color: kChatColor),
                ...suggestions.map((s) => _AISuggestionCard(suggestion: s)),
                const SizedBox(height: 16),
              ],

              // Quick analytics
              QualChatSectionCard(
                title: '📊 Task Analytics',
                child: Row(
                  children: [
                    _MiniStat(
                        label: 'Completed',
                        value: '${analytics.completedThisWeek}',
                        color: const Color(0xFF10B981)),
                    _MiniStat(
                        label: 'Total',
                        value: '${analytics.totalThisWeek}',
                        color: kChatColor),
                    _MiniStat(
                        label: 'Avg Days',
                        value: '${analytics.avgCompletionDays}',
                        color: const Color(0xFFF59E0B)),
                    _MiniStat(
                        label: 'Top Day',
                        value: analytics.mostProductiveDay,
                        color: const Color(0xFFEF4444)),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  void _showAnalytics(BuildContext context, TaskAnalytics analytics) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('📊 Full Task Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _AnalyticsRow(
                label: '✅ Completed',
                value: '${analytics.completedThisWeek}',
                color: const Color(0xFF10B981)),
            _AnalyticsRow(
                label: '📋 Total',
                value: '${analytics.totalThisWeek}',
                color: kChatColor),
            _AnalyticsRow(
                label: '📊 Most Common',
                value: analytics.mostCommonTask,
                color: const Color(0xFFF59E0B)),
            _AnalyticsRow(
                label: '📅 Top Day',
                value: analytics.mostProductiveDay,
                color: const Color(0xFFEF4444)),
            const Divider(height: 24),
            _AnalyticsRow(
                label: '⏱️ Avg Completion',
                value: '${analytics.avgCompletionDays} days',
                color: const Color(0xFF6B7280)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const _SectionLabel(
      {required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final ActionTask task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final priorityColors = {
      TaskPriority.high: const Color(0xFFEF4444),
      TaskPriority.medium: kChatColor,
      TaskPriority.low: const Color(0xFF10B981),
    };
    final typeIcons = {
      TaskType.communication: Icons.chat,
      TaskType.profile: Icons.person,
      TaskType.discovery: Icons.explore,
      TaskType.learning: Icons.school,
      TaskType.social: Icons.people,
    };
    final statusIcons = {
      TaskStatus.actNow: '🔥',
      TaskStatus.considerLater: '💡',
      TaskStatus.completed: '✅',
      TaskStatus.dismissed: '❌',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
              color: priorityColors[task.priority] ?? kChatColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(typeIcons[task.type] ?? Icons.task,
                    size: 20, color: priorityColors[task.priority]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  statusIcons[task.status] ?? '⏳',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                if (task.dueDate != null)
                  Text(
                    '📅 ${task.dueDate!.day}/${task.dueDate!.month}',
                    style: TextStyle(
                      fontSize: 11,
                      color: task.dueDate!.isBefore(DateTime.now())
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF6B7280),
                      fontWeight: task.dueDate!.isBefore(DateTime.now())
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Action buttons
            Row(
              children: [
                _TaskAction(
                    label: 'Complete',
                    color: const Color(0xFF10B981),
                    onTap: () {}),
                const SizedBox(width: 8),
                _TaskAction(
                    label: 'Snooze',
                    color: const Color(0xFFF59E0B),
                    onTap: () {}),
                const SizedBox(width: 8),
                _TaskAction(label: 'Delegate', color: kChatColor, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _TaskAction(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}

class _AISuggestionCard extends StatelessWidget {
  final AISuggestion suggestion;
  const _AISuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kChatColor.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kChatColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: kChatColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion.text,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (suggestion.detail != null) ...[
            const SizedBox(height: 8),
            Text(
              suggestion.detail!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kChatColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Apply',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kChatColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Dismiss',
                    style: TextStyle(fontSize: 12, color: kChatColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AnalyticsRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
