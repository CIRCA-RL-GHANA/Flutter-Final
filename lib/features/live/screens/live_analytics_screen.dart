/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 18: Live Analytics Dashboard
/// Real-time operations analytics: KPIs, delivery zones,
/// bottleneck alerts, performance trends, predictive insights
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveAnalyticsScreen extends StatelessWidget {
  const LiveAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final metrics = prov.metrics;
        final insights = prov.insights;
        final zones = prov.deliveryZones;
        final bottlenecks = prov.bottlenecks;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: LiveAppBar(
            title: 'Live Analytics',
            actions: [
              IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: () => HapticFeedback.lightImpact()),
              IconButton(
                  icon: const Icon(Icons.file_download, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: () {}),
            ],
          ),
          body: RefreshIndicator(
            color: kLiveColor,
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: kLiveColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI Analytics: ${ai.insights.first['title'] ?? ''}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Key Metrics
                const Text('📊 KEY METRICS',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: LiveMetricBadge(
                            label: 'Total Orders',
                            value: '${metrics.ordersProcessed}',
                            icon: Icons.shopping_bag,
                            color: kLiveColor)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: LiveMetricBadge(
                            label: 'Completed',
                            value:
                                '${(metrics.ordersProcessed * metrics.efficiencyScore).round()}',
                            icon: Icons.check_circle,
                            color: const Color(0xFF10B981))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: LiveMetricBadge(
                            label: 'Active Drivers',
                            value: '${metrics.activeDrivers}',
                            icon: Icons.delivery_dining,
                            color: const Color(0xFF3B82F6))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: LiveMetricBadge(
                            label: 'Avg Delivery',
                            value:
                                '${metrics.avgFulfillmentTimeMinutes.toStringAsFixed(0)}m',
                            icon: Icons.timer,
                            color: const Color(0xFFF59E0B))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: LiveMetricBadge(
                            label: 'Revenue',
                            value:
                                '₵${metrics.todayRevenue.toStringAsFixed(0)}',
                            icon: Icons.attach_money,
                            color: const Color(0xFF8B5CF6))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: LiveMetricBadge(
                            label: 'On-Time Rate',
                            value:
                                '${(metrics.efficiencyScore * 100).toStringAsFixed(0)}%',
                            icon: Icons.speed,
                            color: metrics.efficiencyScore >= 0.9
                                ? const Color(0xFF10B981)
                                : kLiveColor)),
                  ],
                ),

                const SizedBox(height: 16),

                // Delivery Zones
                LiveSectionCard(
                  title: '🗺️ DELIVERY ZONE PERFORMANCE',
                  icon: Icons.map,
                  iconColor: const Color(0xFF3B82F6),
                  child: Column(
                    children:
                        zones.map((zone) => _ZoneCard(zone: zone)).toList(),
                  ),
                ),

                // Bottleneck Alerts
                if (bottlenecks.isNotEmpty)
                  LiveSectionCard(
                    title: '⚠️ BOTTLENECK ALERTS',
                    icon: Icons.warning,
                    iconColor: const Color(0xFFF59E0B),
                    child: Column(
                      children: bottlenecks
                          .map((alert) => _BottleneckCard(alert: alert))
                          .toList(),
                    ),
                  ),

                // Predictive Insights
                LiveSectionCard(
                  title: '🤖 AI PREDICTIVE INSIGHTS',
                  icon: Icons.psychology,
                  iconColor: const Color(0xFF8B5CF6),
                  child: Column(
                    children: insights
                        .map((insight) => _InsightCard(insight: insight))
                        .toList(),
                  ),
                ),

                // Driver Performance Summary
                LiveSectionCard(
                  title: '👥 DRIVER LEADERBOARD',
                  icon: Icons.leaderboard,
                  iconColor: const Color(0xFFF59E0B),
                  child: Column(
                    children: prov.drivers
                        .where(
                            (d) => d.availability != DriverAvailability.offline)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final i = entry.key;
                      final d = entry.value;
                      return _DriverLeaderboardItem(
                        rank: i + 1,
                        driver: d,
                        onTap: () {
                          prov.selectDriver(d.id);
                          Navigator.pushNamed(
                              context, AppRoutes.liveDriverPerformance);
                        },
                      );
                    }).toList(),
                  ),
                ),

                // Performance chart placeholder
                LiveSectionCard(
                  title: '📈 HOURLY ORDER VOLUME',
                  icon: Icons.bar_chart,
                  iconColor: kLiveColor,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart,
                              size: 32, color: AppColors.textTertiary),
                          const SizedBox(height: 4),
                          Text('Hourly order volume chart',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final DeliveryZone zone;
  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: zone.intensity == 'hot'
                    ? kLiveColor
                    : const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(zone.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      if (zone.intensity == 'hot') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: kLiveColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('HIGH DEMAND',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: kLiveColor)),
                        ),
                      ],
                    ],
                  ),
                  Text('${zone.orderCount} orders • ${zone.intensity} demand',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
            Text('${zone.orderCount}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: zone.intensity == 'hot'
                        ? kLiveColor
                        : const Color(0xFF10B981))),
          ],
        ),
      ),
    );
  }
}

class _BottleneckCard extends StatelessWidget {
  final BottleneckAlert alert;
  const _BottleneckCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              alert.icon,
              size: 18,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(alert.description,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final PredictiveInsight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧠', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(insight.description,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverLeaderboardItem extends StatelessWidget {
  final int rank;
  final LiveDriver driver;
  final VoidCallback onTap;
  const _DriverLeaderboardItem(
      {required this.rank, required this.driver, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final medal = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '$rank';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
                width: 28,
                child: Text(medal,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center)),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: kLiveColor.withOpacity(0.1),
              child: Text(driver.name.substring(0, 1),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kLiveColor)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                      '${driver.todayDeliveries} deliveries • ${driver.onTimeRate.toStringAsFixed(0)}% on-time',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                const SizedBox(width: 2),
                Text('${driver.rating}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
