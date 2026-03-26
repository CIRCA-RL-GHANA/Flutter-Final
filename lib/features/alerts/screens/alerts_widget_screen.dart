/// Alerts Screen 0 — PROMPT Screen Integration (Alerts Widget)
/// Glass morphism card, metrics row, resolved preview, resolver avatars,
/// mini donut chart, real-time badge

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsWidgetScreen extends StatelessWidget {
  const AlertsWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFFEF2F2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kAlertsColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: kAlertsColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAlertsColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
              // ──── HEADER ROW ────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kAlertsColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.notification_important, size: 18, color: kAlertsColor),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Alerts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    // Real-time badge
                    if (provider.pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kAlertsColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${provider.pendingCount} pending',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/alerts'),
                      child: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),

              // ──── METRICS ROW ────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _MetricPill(
                      emoji: '🔴',
                      label: 'Pending',
                      value: '${provider.pendingCount}',
                      color: kAlertsColor,
                    ),
                    const SizedBox(width: 8),
                    _MetricPill(
                      emoji: '✅',
                      label: 'Resolved',
                      value: '${provider.resolvedCount}',
                      color: kAlertsResolved,
                    ),
                    const SizedBox(width: 8),
                    _MetricPill(
                      emoji: '⚡',
                      label: 'Critical',
                      value: '${provider.highPriorityPendingCount}',
                      color: kAlertsCritical,
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, indent: 16, endIndent: 16),

              // ──── LATEST PENDING ALERTS ────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Needs Attention',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(width: 6),
                    if (provider.highPriorityPendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kAlertsColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${provider.highPriorityPendingCount}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/alerts'),
                      child: const Text(
                        'View all',
                        style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Preview of top 3 pending alerts
              if (provider.pendingAlerts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'All clear — no pending alerts 🎉',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                )
              else
                ...provider.pendingAlerts.take(3).map((alert) => _CompactAlertRow(
                  alert: alert,
                  onTap: () => Navigator.pushNamed(context, '/alerts/detail', arguments: alert.id),
                )),

              const SizedBox(height: 12),

              // ──── DISTRIBUTION + RESOLVER ROW ────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    // Mini donut
                    if (provider.issueDistribution.isNotEmpty) ...[
                      MiniDonutChart(data: provider.issueDistribution, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: provider.issueDistribution.take(3).map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Text(_categoryEmoji(d.category), style: const TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text('${d.percentage.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 4),
                                Text(_categoryLabel(d.category), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],

                    // Resolver avatars stack
                    const SizedBox(width: 8),
                    _ResolverAvatarStack(staff: provider.staff.where((s) => s.isAvailable).take(3).toList()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _categoryEmoji(AlertCategory cat) {
    const map = {
      AlertCategory.payment: '💳',
      AlertCategory.shipment: '📦',
      AlertCategory.system: '⚙️',
      AlertCategory.driverRide: '🚗',
      AlertCategory.returnRefund: '↩️',
      AlertCategory.account: '👤',
      AlertCategory.security: '🔒',
      AlertCategory.other: '📋',
    };
    return map[cat] ?? '📋';
  }

  String _categoryLabel(AlertCategory cat) {
    const map = {
      AlertCategory.payment: 'Payment',
      AlertCategory.shipment: 'Shipment',
      AlertCategory.system: 'System',
      AlertCategory.driverRide: 'Ride',
      AlertCategory.returnRefund: 'Refund',
      AlertCategory.account: 'Account',
      AlertCategory.security: 'Security',
      AlertCategory.other: 'Other',
    };
    return map[cat] ?? 'Other';
  }
}

// ──────────────────────────────────────────────
// Compact Alert Row (for widget preview)
// ──────────────────────────────────────────────

class _CompactAlertRow extends StatelessWidget {
  final AlertItem alert;
  final VoidCallback? onTap;

  const _CompactAlertRow({required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pColor = _priorityColor(alert.priority);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: pColor, width: 3),
            top: const BorderSide(color: Color(0xFFE5E7EB)),
            right: const BorderSide(color: Color(0xFFE5E7EB)),
            bottom: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          children: [
            Text(alert.categoryEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '#${alert.id} • ${_timeAgo(alert.createdAt)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: pColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _priorityShort(alert.priority),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: pColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(AlertPriority p) {
    switch (p) {
      case AlertPriority.critical: return kAlertsCritical;
      case AlertPriority.high: return kAlertsColor;
      case AlertPriority.medium: return kAlertsWarning;
      case AlertPriority.low: return kAlertsInfo;
    }
  }

  String _priorityShort(AlertPriority p) {
    switch (p) {
      case AlertPriority.critical: return '🚨';
      case AlertPriority.high: return '🔥';
      case AlertPriority.medium: return '⚠️';
      case AlertPriority.low: return 'ℹ️';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

// ──────────────────────────────────────────────
// Metric Pill
// ──────────────────────────────────────────────

class _MetricPill extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _MetricPill({required this.emoji, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Resolver Avatar Stack
// ──────────────────────────────────────────────

class _ResolverAvatarStack extends StatelessWidget {
  final List<AlertStaffMember> staff;
  const _ResolverAvatarStack({required this.staff});

  @override
  Widget build(BuildContext context) {
    if (staff.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: 54,
      height: 28,
      child: Stack(
        children: [
          for (int i = 0; i < staff.length; i++)
            Positioned(
              left: i * 14.0,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: [kAlertsColor, kAlertsInfo, kAlertsResolved][i % 3].withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    staff[i].name[0],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: [kAlertsColor, kAlertsInfo, kAlertsResolved][i % 3],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
