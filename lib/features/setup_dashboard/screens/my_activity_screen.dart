/// ═══════════════════════════════════════════════════════════════════════════
/// SD3.5: MY ACTIVITY — Tasks, Goals, Timeline
/// Task progress, goal tracking with progress bars, today's activity timeline
/// RBAC: Owner(all), Admin(all), BM(branch), SO(entity),
///        BSO(branch), Monitor/BrMon(view), RO/BRO(own), Driver(own)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class MyActivityScreen extends StatelessWidget {
  const MyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final tasks = setupProv.tasks;
        final goals = setupProv.goals;
        final timeline = setupProv.timeline;

        final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;

        return SetupRbacGate(
          cardId: 'myActivity',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'My Activity',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('myActivity', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'myActivity',
              onPressed: () {},
              label: 'Add Task',
              icon: Icons.add_task,
            ),
          body: CustomScrollView(
            slivers: [
              // ─── Task Summary ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Tasks',
                          value: '$completedTasks / ${tasks.length}',
                          icon: Icons.task_alt,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Goals',
                          value: '${goals.length} active',
                          icon: Icons.flag,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Productivity',
                          value: tasks.isEmpty ? '—' : '${(completedTasks * 100 / tasks.length).round()}%',
                          icon: Icons.speed,
                          color: tasks.isEmpty
                              ? AppColors.textTertiary
                              : (completedTasks / tasks.length) >= 0.7
                                  ? AppColors.success
                                  : (completedTasks / tasks.length) >= 0.4
                                      ? AppColors.warning
                                      : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Overdue Alert ────────────────────────────
              if (tasks.where((t) => t.status != TaskStatus.completed && t.status != TaskStatus.cancelled && (t.dueDate?.isBefore(DateTime.now()) ?? false)).isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.warning_amber, size: 18, color: AppColors.error),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Overdue Tasks',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error),
                                ),
                                Text(
                                  '${tasks.where((t) => t.status != TaskStatus.completed && t.status != TaskStatus.cancelled && (t.dueDate?.isBefore(DateTime.now()) ?? false)).length} tasks past due date',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.error),
                        ],
                      ),
                    ),
                  ),
                ),

              // ─── Task Status Filter ───────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TaskStatusChip(label: 'All', count: tasks.length, isSelected: true),
                        const SizedBox(width: 6),
                        _TaskStatusChip(label: 'To Do', count: tasks.where((t) => t.status == TaskStatus.todo).length, color: AppColors.textTertiary),
                        const SizedBox(width: 6),
                        _TaskStatusChip(label: 'In Progress', count: tasks.where((t) => t.status == TaskStatus.inProgress).length, color: kSetupColor),
                        const SizedBox(width: 6),
                        _TaskStatusChip(label: 'Completed', count: completedTasks, color: AppColors.success),
                        const SizedBox(width: 6),
                        _TaskStatusChip(label: 'Blocked', count: tasks.where((t) => t.status == TaskStatus.blocked).length, color: AppColors.error),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Tasks Section ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: const SetupSectionTitle(title: 'Tasks', icon: Icons.checklist),
                ),
              ),

              // ─── AI Insights ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kSetupColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI: ${ai.insights.first['title'] ?? ''}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TaskCard(task: tasks[i]),
                    childCount: tasks.length,
                  ),
                ),
              ),

              // ─── Goals Section ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: const SetupSectionTitle(title: 'Goals', icon: Icons.flag),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _GoalCard(goal: goals[i]),
                    childCount: goals.length,
                  ),
                ),
              ),

              // ─── Timeline Section ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: const SetupSectionTitle(title: "Today's Timeline", icon: Icons.timeline),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TimelineItem(entry: timeline[i], isLast: i == timeline.length - 1),
                    childCount: timeline.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final UserTask task;
  const _TaskCard({required this.task});

  Color get _statusColor => switch (task.status) {
    TaskStatus.todo => AppColors.textTertiary,
    TaskStatus.inProgress => kSetupColor,
    TaskStatus.completed => AppColors.success,
    TaskStatus.blocked => AppColors.error,
    TaskStatus.cancelled => AppColors.textTertiary,
    TaskStatus.overdue => AppColors.warning,
  };

  IconData get _statusIcon => switch (task.status) {
    TaskStatus.todo => Icons.radio_button_unchecked,
    TaskStatus.inProgress => Icons.play_circle_outline,
    TaskStatus.completed => Icons.check_circle,
    TaskStatus.blocked => Icons.block,
    TaskStatus.cancelled => Icons.cancel_outlined,
    TaskStatus.overdue => Icons.schedule,
  };

  Color get _priorityColor => switch (task.priority) {
    'high' => AppColors.error,
    'medium' => AppColors.warning,
    _ => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    final completedChecklist = task.checklist.where((c) => c.isDone).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _statusColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon, size: 18, color: _statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _priorityColor),
                ),
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (task.checklist.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: task.checklist.isEmpty ? 0 : completedChecklist / task.checklist.length,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completedChecklist/${task.checklist.length}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                task.assignee,
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                'Due ${setupTimeAgo(task.dueDate ?? DateTime.now())}',
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final UserGoal goal;
  const _GoalCard({required this.goal});

  Color get _statusColor => switch (goal.status) {
    GoalStatus.onTrack => AppColors.success,
    GoalStatus.atRisk => AppColors.warning,
    GoalStatus.behind => AppColors.error,
    GoalStatus.completed => kSetupColor,
    GoalStatus.ahead => AppColors.info,
    GoalStatus.needsAttention => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, size: 16, color: kSetupColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  goal.status.name.toUpperCase(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${goal.progress}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _statusColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${goal.currentValue} / ${goal.targetValue} ${goal.unit}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today, size: 11, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                'Due ${setupTimeAgo(goal.deadline ?? goal.dueDate ?? DateTime.now())}',
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ActivityTimelineEntry entry;
  final bool isLast;
  const _TimelineItem({required this.entry, required this.isLast});

  Color get _actionColor => switch (entry.action) {
    'login' => kSetupColor,
    'sale' => AppColors.success,
    'delivery' => const Color(0xFF8B5CF6),
    'update' => AppColors.warning,
    'approval' => AppColors.success,
    'campaign' => const Color(0xFFEC4899),
    'message' => kSetupColor,
    _ => AppColors.textTertiary,
  };

  IconData get _actionIcon => switch (entry.action) {
    'login' => Icons.login,
    'sale' => Icons.point_of_sale,
    'delivery' => Icons.local_shipping,
    'update' => Icons.edit,
    'approval' => Icons.check_circle_outline,
    'campaign' => Icons.campaign,
    'message' => Icons.message,
    _ => Icons.circle,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Timeline Connector ──────────────
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _actionColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey.shade200),
                  ),
              ],
            ),
          ),
          // ─── Content ─────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _actionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_actionIcon, size: 16, color: _actionColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          entry.subtitle,
                          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(entry.timestamp ?? DateTime.now()),
                    style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $amPm';
  }
}

// ─── Task Status Chip ────────────────────────────────────────────────────────

class _TaskStatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color? color;
  final bool isSelected;

  const _TaskStatusChip({
    required this.label,
    required this.count,
    this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kSetupColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? c.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? c.withOpacity(0.4) : AppColors.inputBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? c : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: c.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: c),
            ),
          ),
        ],
      ),
    );
  }
}
