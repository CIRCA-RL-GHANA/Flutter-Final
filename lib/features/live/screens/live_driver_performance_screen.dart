/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 19: Driver Performance Detail
/// Individual driver analytics: delivery history, ratings,
/// performance trends, feedback, and management actions
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class LiveDriverPerformanceScreen extends StatelessWidget {
  const LiveDriverPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        final driver = prov.selectedDriver ?? prov.drivers.first;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // Header with driver info
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [kLiveColor, kLiveAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                          const Expanded(child: Text('Driver Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
                          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white70), onPressed: () {}),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(driver.name.substring(0, 1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(height: 8),
                      Text(driver.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text(driver.driverType.name, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                      const SizedBox(height: 12),

                      // Stats row
                      Row(
                        children: [
                          _HeaderStat(label: 'Rating', value: '${driver.rating}', icon: Icons.star),
                          _HeaderStat(label: 'Deliveries', value: '${driver.totalDeliveries}', icon: Icons.check_circle),
                          _HeaderStat(label: 'On-Time', value: '${driver.onTimeRate.toStringAsFixed(0)}%', icon: Icons.timer),
                          _HeaderStat(label: 'Today', value: '${driver.todayDeliveries}', icon: Icons.today),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kLiveColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kLiveColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI: ${ai.insights.first['title'] ?? ''}',
                              style: const TextStyle(fontSize: 12, color: kLiveColor, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Availability & Status
                      LiveSectionCard(
                        title: 'STATUS',
                        icon: Icons.info,
                        iconColor: const Color(0xFF3B82F6),
                        child: Column(
                          children: [
                            _DetailRow(label: 'Availability', value: driver.availability.name.toUpperCase(), valueColor: driver.availability == DriverAvailability.online ? const Color(0xFF10B981) : kLiveColor),
                            if (driver.activePackageId != null)
                              _DetailRow(label: 'Active Package', value: driver.activePackageId!),
                          ],
                        ),
                      ),

                      // Specialties & Badges
                      LiveSectionCard(
                        title: 'SPECIALTIES & BADGES',
                        icon: Icons.military_tech,
                        iconColor: const Color(0xFFF59E0B),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: driver.specialties.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: kLiveColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kLiveColor)),
                              )).toList(),
                            ),
                            if (driver.badges.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text('BADGES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: driver.badges.map((b) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(b.icon, size: 14),
                                      const SizedBox(width: 4),
                                      Text(b.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Performance Chart placeholder
                      LiveSectionCard(
                        title: '📈 DELIVERY TRENDS (7 DAYS)',
                        icon: Icons.trending_up,
                        iconColor: const Color(0xFF10B981),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.show_chart, size: 32, color: AppColors.textTertiary),
                                const SizedBox(height: 4),
                                Text('Performance trend chart', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Recent Feedback
                      LiveSectionCard(
                        title: '💬 RECENT FEEDBACK',
                        icon: Icons.feedback,
                        iconColor: const Color(0xFF8B5CF6),
                        child: Column(
                          children: driver.recentFeedback.map((f) => _FeedbackItem(feedback: f)).toList(),
                        ),
                      ),

                      // Detailed Metrics
                      LiveSectionCard(
                        title: 'DETAILED METRICS',
                        icon: Icons.analytics,
                        iconColor: AppColors.textSecondary,
                        child: Column(
                          children: [
                            _DetailRow(label: 'Total deliveries', value: '${driver.totalDeliveries}'),
                            _DetailRow(label: 'Deliveries today', value: '${driver.todayDeliveries}'),
                            _DetailRow(label: 'Customer rating', value: '${driver.rating} / 5.0'),
                            _DetailRow(label: 'On-time rate', value: '${driver.onTimeRate.toStringAsFixed(1)}%'),
                            _DetailRow(label: 'Current zone', value: 'N/A'),
                            _DetailRow(label: 'Phone', value: 'N/A'),
                          ],
                        ),
                      ),

                      // Management actions
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone, size: 16),
                              label: const Text('CALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.chat, size: 16),
                              label: const Text('MESSAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF3B82F6), padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.assignment, size: 16),
                              label: const Text('ASSIGN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(foregroundColor: kLiveColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _HeaderStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}

class _FeedbackItem extends StatelessWidget {
  final DriverFeedback feedback;
  const _FeedbackItem({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (i) => Icon(
                  i < feedback.rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: const Color(0xFFF59E0B),
                )),
                const SizedBox(width: 6),
                Text(feedback.customerName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
            if (feedback.comment.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('"${feedback.comment}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}
