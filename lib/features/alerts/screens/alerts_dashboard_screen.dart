/// Alerts Screen 1 — Dashboard Master View
/// Segmented control (Pending/Resolved/All), priority triage bar,
/// alert cards sorted by priority, time filter chips, real-time counter

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/widgets/ai_insight_card.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';

class AlertsDashboardScreen extends StatelessWidget {
  const AlertsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AlertsAppBar(
            title: 'Alerts',
            actions: [
              // Search
              IconButton(
                icon: const Icon(Icons.search, size: 22),
                onPressed: () => Navigator.pushNamed(context, '/alerts/search'),
              ),
              // Filter with badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list, size: 22),
                    onPressed: () => Navigator.pushNamed(context, '/alerts/filter'),
                  ),
                  if (provider.activeFilterCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(color: kAlertsColor, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${provider.activeFilterCount}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              ),
              // Bulk
              if (provider.isSelectMode)
                IconButton(
                  icon: const Icon(Icons.checklist, size: 22),
                  onPressed: () => Navigator.pushNamed(context, '/alerts/bulk'),
                ),
              // More
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 22),
                onSelected: (v) {
                  switch (v) {
                    case 'compose': Navigator.pushNamed(context, '/alerts/compose'); break;
                    case 'analytics': Navigator.pushNamed(context, '/alerts/analytics'); break;
                    case 'templates': Navigator.pushNamed(context, '/alerts/templates'); break;
                    case 'settings': Navigator.pushNamed(context, '/alerts/settings'); break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'compose', child: Text('New Alert')),
                  PopupMenuItem(value: 'analytics', child: Text('Analytics')),
                  PopupMenuItem(value: 'templates', child: Text('Templates')),
                  PopupMenuItem(value: 'settings', child: Text('Settings')),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: _SegmentedTabBar(
                selected: provider.dashboardTab,
                pendingCount: provider.pendingCount,
                resolvedCount: provider.resolvedCount,
                totalCount: provider.totalCount,
                onChanged: provider.setDashboardTab,
              ),
            ),
          ),
          body: Column(
            children: [
              // ──── PRIORITY TRIAGE BAR ────
              if (provider.dashboardTab == AlertDashboardTab.pending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      _TriageChip(
                        label: '🚨 Critical',
                        count: provider.pendingAlerts.where((a) => a.priority == AlertPriority.critical).length,
                        color: kAlertsCritical,
                        isSelected: provider.priorityFilter == AlertPriority.critical,
                        onTap: () => provider.setPriorityFilter(
                          provider.priorityFilter == AlertPriority.critical ? null : AlertPriority.critical,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _TriageChip(
                        label: '🔥 High',
                        count: provider.pendingAlerts.where((a) => a.priority == AlertPriority.high).length,
                        color: kAlertsColor,
                        isSelected: provider.priorityFilter == AlertPriority.high,
                        onTap: () => provider.setPriorityFilter(
                          provider.priorityFilter == AlertPriority.high ? null : AlertPriority.high,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _TriageChip(
                        label: '⚠️ Med',
                        count: provider.pendingAlerts.where((a) => a.priority == AlertPriority.medium).length,
                        color: kAlertsWarning,
                        isSelected: provider.priorityFilter == AlertPriority.medium,
                        onTap: () => provider.setPriorityFilter(
                          provider.priorityFilter == AlertPriority.medium ? null : AlertPriority.medium,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _TriageChip(
                        label: 'ℹ️ Low',
                        count: provider.pendingAlerts.where((a) => a.priority == AlertPriority.low).length,
                        color: kAlertsInfo,
                        isSelected: provider.priorityFilter == AlertPriority.low,
                        onTap: () => provider.setPriorityFilter(
                          provider.priorityFilter == AlertPriority.low ? null : AlertPriority.low,
                        ),
                      ),
                    ],
                  ),
                ),

              // ──── AI PRIORITY INSIGHTS ────
              if (provider.dashboardTab == AlertDashboardTab.pending)
                Consumer<AIInsightsNotifier>(
                  builder: (ctx, notifier, _) {
                    final insights = notifier.insights;
                    if (insights.isEmpty) return const SizedBox.shrink();
                    // Filter to risk/anomaly insights that are relevant to alerts
                    final alertInsights = insights
                        .where((i) =>
                            (i['type'] as String? ?? '').contains('risk') ||
                            (i['type'] as String? ?? '').contains('anomaly') ||
                            (i['impact'] as String? ?? '') == 'negative')
                        .take(2)
                        .toList();
                    if (alertInsights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.auto_awesome, size: 13, color: Color(0xFF8B5CF6)),
                              SizedBox(width: 5),
                              Text(
                                'AI Risk Intelligence',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...alertInsights.map((i) => AIInsightCard(insight: i)),
                        ],
                      ),
                    );
                  },
                ),

              // ──── SYNC STATUS ────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${provider.filteredAlerts.length} alert${provider.filteredAlerts.length == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: provider.refreshSync,
                      child: Row(
                        children: [
                          const Icon(Icons.sync, size: 14, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            'Updated ${_timeAgo(provider.lastSync)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ──── ALERT LIST ────
              Expanded(
                child: provider.filteredAlerts.isEmpty
                    ? AlertsEmptyState(
                        icon: provider.dashboardTab == AlertDashboardTab.pending
                            ? Icons.check_circle_outline
                            : Icons.inbox_outlined,
                        title: provider.dashboardTab == AlertDashboardTab.pending
                            ? 'All Clear!'
                            : 'No Alerts Found',
                        message: provider.dashboardTab == AlertDashboardTab.pending
                            ? 'No pending alerts. Great work!'
                            : 'Try adjusting your filters or search terms.',
                        actionLabel: provider.activeFilterCount > 0 ? 'Clear Filters' : null,
                        onAction: provider.clearAllFilters,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.filteredAlerts.length,
                        itemBuilder: (context, index) {
                          final alert = provider.filteredAlerts[index];
                          // AI priority badge: wrap critical/high pending alerts
                          final showAIBadge = alert.isPending &&
                              (alert.priority == AlertPriority.critical ||
                                  alert.priority == AlertPriority.high);
                          final card = alert.isPending
                              ? PendingAlertCard(
                                  alert: alert,
                                  isSelected: provider.selectedAlertIds.contains(alert.id),
                                  onTap: () => Navigator.pushNamed(context, '/alerts/detail', arguments: alert.id),
                                  onLongPress: () => provider.toggleSelectAlert(alert.id),
                                )
                              : ResolvedAlertCard(
                                  alert: alert,
                                  onTap: () => Navigator.pushNamed(context, '/alerts/detail', arguments: alert.id),
                                );
                          if (!showAIBadge) return card;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              card,
                              Positioned(
                                top: 6,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome, size: 8, color: Colors.white),
                                      SizedBox(width: 2),
                                      Text('AI', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),

          // ──── BULK ACTIONS FAB ────
          floatingActionButton: provider.isSelectMode
              ? FloatingActionButton.extended(
                  backgroundColor: kAlertsColor,
                  icon: const Icon(Icons.checklist, color: Colors.white),
                  label: Text('${provider.selectedCount} selected', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.pushNamed(context, '/alerts/bulk'),
                )
              : FloatingActionButton(
                  backgroundColor: kAlertsColor,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, '/alerts/compose'),
                ),
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// ──────────────────────────────────────────────
// Segmented Tab Bar
// ──────────────────────────────────────────────

class _SegmentedTabBar extends StatelessWidget {
  final AlertDashboardTab selected;
  final int pendingCount;
  final int resolvedCount;
  final int totalCount;
  final ValueChanged<AlertDashboardTab> onChanged;

  const _SegmentedTabBar({
    required this.selected,
    required this.pendingCount,
    required this.resolvedCount,
    required this.totalCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _TabSegment(
            label: 'Pending',
            count: pendingCount,
            isSelected: selected == AlertDashboardTab.pending,
            color: kAlertsColor,
            onTap: () => onChanged(AlertDashboardTab.pending),
          ),
          _TabSegment(
            label: 'Resolved',
            count: resolvedCount,
            isSelected: selected == AlertDashboardTab.resolved,
            color: kAlertsResolved,
            onTap: () => onChanged(AlertDashboardTab.resolved),
          ),
          _TabSegment(
            label: 'All',
            count: totalCount,
            isSelected: selected == AlertDashboardTab.all,
            color: const Color(0xFF6B7280),
            onTap: () => onChanged(AlertDashboardTab.all),
          ),
        ],
      ),
    );
  }
}

class _TabSegment extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TabSegment({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? color : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Triage Chip
// ──────────────────────────────────────────────

class _TriageChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TriageChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              Text('$count', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
