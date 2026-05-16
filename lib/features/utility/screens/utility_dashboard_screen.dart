/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// U0: UTILITY DASHBOARD â€” Master Entry Point
/// System health overview, quick action grid, recent activity feed
/// RBAC-aware: advanced tools only for owner/admin/branchManager
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/utility_models.dart';
import '../providers/utility_provider.dart';
import '../widgets/shared_widgets.dart';

class UtilityDashboardScreen extends StatelessWidget {
  const UtilityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UtilityProvider, ContextProvider>(
      builder: (context, utilProv, ctxProv, _) {
        final role = ctxProv.currentRole;
        final health = utilProv.systemHealth;
        final quickActions = utilProv.getQuickActions(role);

        return Scaffold(
          backgroundColor: const Color(0xFF08080F),
          appBar: const UtilityAppBar(title: 'Utility'),
          body: CustomScrollView(
            slivers: [              // â”€â”€â”€ AI Insights â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kUtilityColor.withValues(alpha: 0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUtilityColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUtilityColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
              ),
              // â”€â”€â”€ System Health Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _SystemHealthBanner(health: health),
                ),
              ),

              // â”€â”€â”€ Quick Actions Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const UtilitySectionTitle(
                        title: 'Quick Actions',
                        icon: Icons.grid_view_rounded,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: quickActions.length,
                        itemBuilder: (context, i) {
                          final action = quickActions[i];
                          return QuickActionGridItem(
                            label: action.label,
                            icon: action.icon,
                            color: action.color,
                            badgeCount: action.badgeCount,
                            onTap: () => Navigator.pushNamed(context, action.route),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // â”€â”€â”€ System Metrics â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UtilitySectionTitle(
                        title: 'System Status',
                        icon: Icons.monitor_heart,
                        trailing: UtilityStatusIndicator(
                          label: health.connectionStatus == ConnectionStatus.online
                              ? 'Online'
                              : health.connectionStatus == ConnectionStatus.degraded
                                  ? 'Degraded'
                                  : 'Offline',
                          color: health.connectionStatus == ConnectionStatus.online
                              ? AppColors.success
                              : health.connectionStatus == ConnectionStatus.degraded
                                  ? AppColors.warning
                                  : AppColors.error,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              label: 'Storage',
                              value: '${health.storageUsedMB.toStringAsFixed(1)} MB',
                              icon: Icons.sd_storage,
                              color: const Color(0xFF8B5CF6),
                              percentage: health.storagePercentage,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              label: 'Alerts',
                              value: '${health.activeAlerts}',
                              icon: Icons.warning_amber,
                              color: health.activeAlerts > 0
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // â”€â”€â”€ Recent Activity â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UtilitySectionTitle(
                        title: 'Recent Activity',
                        icon: Icons.history,
                        trailing: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: kUtilityColor,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: const Text('See All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      UtilitySectionCard(
                        child: Column(
                          children: utilProv.recentActivities.take(5).map((activity) {
                            return _ActivityItem(activity: activity);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // â”€â”€â”€ Bottom Spacer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
}

// â”€â”€â”€ System Health Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SystemHealthBanner extends StatelessWidget {
  final SystemHealthSummary health;
  const _SystemHealthBanner({required this.health});

  @override
  Widget build(BuildContext context) {
    final score = health.overallScore;
    final color = score >= 0.8
        ? AppColors.success
        : score >= 0.5
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          PercentageRing(
            percentage: score,
            color: color,
            size: 56,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score >= 0.8
                      ? 'System Healthy'
                      : score >= 0.5
                          ? 'Needs Attention'
                          : 'Critical Issues',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${health.pendingUpdates} update${health.pendingUpdates != 1 ? 's' : ''} pending Â· Last backup ${_timeAgo(health.lastBackup)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Activity Item â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ActivityItem extends StatelessWidget {
  final RecentActivity activity;
  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _categoryColor(activity.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity.icon, size: 18, color: _categoryColor(activity.category)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _timeAgo(activity.timestamp),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(ActivityCategory cat) {
    switch (cat) {
      case ActivityCategory.security:
        return const Color(0xFF10B981);
      case ActivityCategory.data:
        return const Color(0xFF8B5CF6);
      case ActivityCategory.system:
        return const Color(0xFF3B82F6);
      case ActivityCategory.user:
        return const Color(0xFF6366F1);
      case ActivityCategory.notification:
        return const Color(0xFFF59E0B);
    }
  }
}

// â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}';
}
