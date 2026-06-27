/// qualChat Screen 12  Action Center
/// Task manager: priority sections, AI suggestions, profile completeness, analytics
library;

import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';

class QualChatActionCenterScreen extends StatelessWidget {
  const QualChatActionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        final tasks = QualChatProvider.tasks;
        const suggestions = QualChatProvider.aiSuggestions;
        const analytics = QualChatProvider.taskAnalytics;
        final completeness = provider.profileCompleteness;

        final actNow =
            tasks.where((t) => t.priority == TaskPriority.high).toList();
        final considerLater = tasks
            .where((t) =>
                t.priority == TaskPriority.medium ||
                t.priority == TaskPriority.low)
            .toList();

        return Scaffold(
          backgroundColor: IveTokens.bg,
          appBar: QualChatAppBar(
            title: 'Action Center',
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart, color: IveTokens.moduleQualChat),
                onPressed: () => _showAnalytics(context, analytics),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile completeness bar
              QualChatSectionCard(
                title: ' Profile Completeness',
                trailing: '$completeness%',
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(IveTokens.rXs),
                      child: LinearProgressIndicator(
                        value: completeness / 100,
                        backgroundColor: IveTokens.hairline,
                        valueColor: AlwaysStoppedAnimation(
                          completeness > 80
                              ? IveTokens.success
                              : completeness > 50
                                  ? IveTokens.moduleQualChat
                                  : IveTokens.warning,
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completeness >= 90
                          ? 'Excellent! Your profile is nearly complete '
                          : completeness >= 70
                              ? 'Good progress! A few more items to go'
                              : 'Complete your profile to get better results',
                      style: IveType.caption.copyWith(color: IveTokens.mute),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              //  ACT NOW 
              if (actNow.isNotEmpty) ...[
                _SectionLabel(
                    title: ' ACT NOW',
                    count: actNow.length,
                    color: IveTokens.danger),
                ...actNow.map((task) => _TaskCard(task: task)),
                const SizedBox(height: 16),
              ],

              //  CONSIDER LATER 
              if (considerLater.isNotEmpty) ...[
                _SectionLabel(
                    title: ' CONSIDER LATER',
                    count: considerLater.length,
                    color: IveTokens.warning),
                ...considerLater.map((task) => _TaskCard(task: task)),
                const SizedBox(height: 16),
              ],

              //  AI SUGGESTIONS 
              if (suggestions.isNotEmpty) ...[
                const _SectionLabel(
                    title: ' AI SUGGESTIONS', count: 0, color: IveTokens.moduleQualChat),
                ...suggestions.map((s) => _AISuggestionCard(suggestion: s)),
                const SizedBox(height: 16),
              ],

              // Quick analytics
              QualChatSectionCard(
                title: ' Task Analytics',
                child: Row(
                  children: [
                    _MiniStat(
                        label: 'Completed',
                        value: '${analytics.completedThisWeek}',
                        color: IveTokens.success),
                    _MiniStat(
                        label: 'Total',
                        value: '${analytics.totalThisWeek}',
                        color: IveTokens.moduleQualChat),
                    _MiniStat(
                        label: 'Avg Days',
                        value: '${analytics.avgCompletionDays}',
                        color: IveTokens.warning),
                    _MiniStat(
                        label: 'Top Day',
                        value: analytics.mostProductiveDay,
                        color: IveTokens.danger),
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
      backgroundColor: IveTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rSm)),
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
                    color: IveTokens.hairline2,
                    borderRadius: BorderRadius.circular(IveTokens.rXs)),
              ),
            ),
            const SizedBox(height: 16),
            Text(' Full Task Analytics',
                style: IveType.headline.copyWith(color: IveTokens.ink)),
            const SizedBox(height: 20),
            _AnalyticsRow(
                label: ' Completed',
                value: '${analytics.completedThisWeek}',
                color: IveTokens.success),
            _AnalyticsRow(
                label: ' Total',
                value: '${analytics.totalThisWeek}',
                color: IveTokens.moduleQualChat),
            _AnalyticsRow(
                label: ' Most Common',
                value: analytics.mostCommonTask,
                color: IveTokens.warning),
            _AnalyticsRow(
                label: ' Top Day',
                value: analytics.mostProductiveDay,
                color: IveTokens.danger),
            Divider(height: 24, color: IveTokens.hairline),
            _AnalyticsRow(
                label: ' Avg Completion',
                value: '${analytics.avgCompletionDays} days',
                color: IveTokens.mute),
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
            style: IveType.subhead.copyWith(
                color: color,
                letterSpacing: 0.5),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(IveTokens.rSm)),
              child: Text('$count',
                  style: IveType.footnote.copyWith(fontWeight: FontWeight.w700, color: color)),
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
      TaskPriority.high: IveTokens.danger,
      TaskPriority.medium: IveTokens.moduleQualChat,
      TaskPriority.low: IveTokens.success,
    };
    final typeIcons = {
      TaskType.communication: Icons.chat,
      TaskType.profile: Icons.person,
      TaskType.discovery: Icons.explore,
      TaskType.learning: Icons.school,
      TaskType.social: Icons.people,
    };
    final statusIcons = {
      TaskStatus.actNow: '',
      TaskStatus.considerLater: '',
      TaskStatus.completed: '',
      TaskStatus.dismissed: '',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border(
          left: BorderSide(
              color: priorityColors[task.priority] ?? IveTokens.moduleQualChat, width: 4),
        ),
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
                    style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink),
                  ),
                ),
                Text(
                  statusIcons[task.status] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                style: IveType.caption.copyWith(color: IveTokens.mute),
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
                    ' ${task.dueDate!.day}/${task.dueDate!.month}',
                    style: IveType.footnote.copyWith(
                      color: task.dueDate!.isBefore(DateTime.now())
                          ? IveTokens.danger
                          : IveTokens.mute,
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
                    color: IveTokens.success,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task marked complete')),
                      );
                    }),
                const SizedBox(width: 8),
                _TaskAction(
                    label: 'Snooze',
                    color: IveTokens.warning,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task snoozed')),
                      );
                    }),
                const SizedBox(width: 8),
                _TaskAction(label: 'Delegate', color: IveTokens.moduleQualChat, onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task delegated')),
                  );
                }),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(IveTokens.rSm),
        ),
        child: Text(label,
            style: IveType.footnote.copyWith(fontWeight: FontWeight.w600, color: color)),
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
        color: IveTokens.moduleQualChat.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(IveTokens.rSm),
        border: Border.all(color: IveTokens.moduleQualChat.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: IveTokens.moduleQualChat),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion.text,
                  style: IveType.bodyEmphasis.copyWith(color: IveTokens.ink),
                ),
              ),
            ],
          ),
          if (suggestion.detail != null) ...[
            const SizedBox(height: 8),
            Text(
              suggestion.detail!,
              style: IveType.caption.copyWith(color: IveTokens.mute),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: IveButton.primary(
                  label: 'Apply',
                  compact: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI suggestion applied')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              IveButton.secondary(
                label: 'Dismiss',
                compact: true,
                expand: false,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI suggestion dismissed')),
                  );
                },
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
              style: IveType.title3.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: IveType.footnote.copyWith(color: IveTokens.mute)),
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
          Text(label, style: IveType.body.copyWith(color: IveTokens.ink)),
          Text(value,
              style: IveType.bodyEmphasis.copyWith(color: color)),
        ],
      ),
    );
  }
}
