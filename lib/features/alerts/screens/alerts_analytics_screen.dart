/// Alerts Screen 6 — Analytics Dashboard
/// Volume trends, SLA compliance, category distribution,
/// team workload, resolver leaderboard

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerts_models.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alerts_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class AlertsAnalyticsScreen extends StatelessWidget {
  const AlertsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: const AlertsAppBar(title: 'Analytics'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ──── AI ANALYTICS INSIGHT ────
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: kAlertsColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kAlertsColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['label'] ?? 'Analytics insights available'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kAlertsColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
                // ──── KEY METRICS ────
                Row(
                  children: [
                    _MetricCard(
                      emoji: '📊',
                      label: 'Total',
                      value: '${provider.totalCount}',
                      sub: 'alerts',
                      color: kAlertsColor,
                    ),
                    const SizedBox(width: 10),
                    _MetricCard(
                      emoji: '⏱️',
                      label: 'Avg Resolution',
                      value: '${provider.avgResolutionTime.inHours}h ${provider.avgResolutionTime.inMinutes % 60}m',
                      sub: 'time',
                      color: kAlertsInfo,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MetricCard(
                      emoji: '✅',
                      label: 'SLA Compliance',
                      value: '${provider.slaCompliancePercent}%',
                      sub: 'on-time',
                      color: kAlertsResolved,
                    ),
                    const SizedBox(width: 10),
                    _MetricCard(
                      emoji: '🔴',
                      label: 'Pending',
                      value: '${provider.pendingCount}',
                      sub: 'open alerts',
                      color: kAlertsWarning,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ──── VOLUME TRENDS ────
                AlertsSectionCard(
                  title: '📈 Alert Volume (7 Days)',
                  child: SizedBox(
                    height: 160,
                    child: _BarChart(data: provider.volumeByDay),
                  ),
                ),
                const SizedBox(height: 16),

                // ──── CATEGORY DISTRIBUTION ────
                AlertsSectionCard(
                  title: '🗂️ Category Distribution',
                  child: Column(
                    children: provider.categoryDistribution.map((dp) {
                      final maxCount = provider.categoryDistribution.fold<int>(0, (m, d) => d.count > m ? d.count : m);
                      return _DistributionBar(
                        label: dp.label,
                        count: dp.count,
                        progress: maxCount > 0 ? dp.count / maxCount : 0,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // ──── SLA COMPLIANCE GAUGE ────
                AlertsSectionCard(
                  title: '⏱️ SLA Compliance',
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: provider.slaCompliancePercent / 100,
                                strokeWidth: 10,
                                backgroundColor: const Color(0xFFE5E7EB),
                                valueColor: AlwaysStoppedAnimation(
                                  provider.slaCompliancePercent >= 90 ? kAlertsResolved
                                      : provider.slaCompliancePercent >= 75 ? kAlertsWarning
                                      : kAlertsColor,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${provider.slaCompliancePercent}%',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                                ),
                                const Text('On-time', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _LegendDot(color: kAlertsResolved, label: 'On Track'),
                          const SizedBox(width: 16),
                          const _LegendDot(color: kAlertsWarning, label: 'At Risk'),
                          const SizedBox(width: 16),
                          const _LegendDot(color: kAlertsColor, label: 'Breached'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ──── ISSUE DISTRIBUTION DONUT ────
                AlertsSectionCard(
                  title: '🍩 Issue Mix',
                  child: Row(
                    children: [
                      MiniDonutChart(data: provider.issueDistribution, size: 80),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: provider.issueDistribution.take(5).map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: [kAlertsColor, kAlertsWarning, kAlertsInfo, kAlertsResolved, const Color(0xFF9CA3AF)][provider.issueDistribution.indexOf(d) % 5],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(d.category.name, style: const TextStyle(fontSize: 12))),
                                Text('${d.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ──── RESOLVER LEADERBOARD ────
                AlertsSectionCard(
                  title: '🏆 Top Resolvers',
                  child: Column(
                    children: [
                      for (int i = 0; i < provider.topResolvers.length; i++)
                        ResolverLeaderboardTile(
                          resolver: provider.topResolvers[i],
                          rank: i + 1,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ──── TEAM WORKLOAD ────
                AlertsSectionCard(
                  title: '👥 Team Workload',
                  child: Column(
                    children: provider.staff.map((s) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: kAlertsColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(s.name[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kAlertsColor))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: s.activeAlerts / 6,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor: AlwaysStoppedAnimation(
                                    s.activeAlerts >= 5 ? kAlertsColor : s.activeAlerts >= 3 ? kAlertsWarning : kAlertsResolved,
                                  ),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${s.activeAlerts}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )).toList(),
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

// ──────────────────────────────────────────────
// Metric Card
// ──────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _MetricCard({required this.emoji, required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Bar Chart
// ──────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<AlertAnalyticsPoint> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<int>(0, (m, d) => d.count > m ? d.count : m);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((dp) {
        final height = maxVal > 0 ? (dp.count / maxVal * 120) : 0.0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${dp.count}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: kAlertsColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(dp.label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────
// Distribution Bar
// ──────────────────────────────────────────────

class _DistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final double progress;

  const _DistributionBar({required this.label, required this.count, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(kAlertsColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 30, child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Legend Dot
// ──────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }
}
