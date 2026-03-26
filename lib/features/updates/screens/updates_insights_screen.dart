/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN 12 — Update Insights (Business Roles)
/// Reach, impressions, engagement rate, time-based analytics, AI insights,
/// audience demographics, content performance, ROI metrics.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../models/updates_models.dart';
import '../providers/updates_provider.dart';
import '../widgets/updates_widgets.dart';

class UpdatesInsightsScreen extends StatelessWidget {
  const UpdatesInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesProvider(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  String _timePeriod = '7d';

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, prov, _) {
        final insight = prov.insight;
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: UpdatesAppBar(
            title: 'Insights',
            actions: [
              // Time period picker
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<String>(
                  initialValue: _timePeriod,
                  onSelected: (v) => setState(() => _timePeriod = v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kUpdatesColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_periodLabel(_timePeriod), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kUpdatesColor)),
                        const Icon(Icons.arrow_drop_down, size: 16, color: kUpdatesColor),
                      ],
                    ),
                  ),
                  itemBuilder: (_) => ['7d', '30d', '90d', '1y'].map((p) => PopupMenuItem(
                    value: p,
                    child: Text(_periodLabel(p), style: const TextStyle(fontSize: 13)),
                  )).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                color: AppColors.textSecondary,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report exported'), backgroundColor: kUpdatesColor, duration: Duration(seconds: 1)),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kUpdatesColor.withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kUpdatesColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kUpdatesColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
                // Overview metrics
                _OverviewMetrics(insight: insight),

                const SizedBox(height: 14),

                // Engagement rate card
                _EngagementRateCard(insight: insight),

                const SizedBox(height: 14),

                // Performance chart placeholder
                UpdatesSectionCard(
                  title: 'PERFORMANCE TREND',
                  icon: Icons.show_chart,
                  iconColor: const Color(0xFF3B82F6),
                  trailing: Text(_periodLabel(_timePeriod), style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: _ChartPainter(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Audience breakdown
                UpdatesSectionCard(
                  title: 'AUDIENCE BREAKDOWN',
                  icon: Icons.people,
                  iconColor: kUpdatesAccent,
                  child: Column(
                    children: [
                      const _AudienceRow(label: 'Followers', value: 68, color: kUpdatesColor),
                      const _AudienceRow(label: 'Non-followers', value: 22, color: kUpdatesAccent),
                      _AudienceRow(label: 'New visitors', value: 10, color: const Color(0xFF10B981)),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Content performance
                UpdatesSectionCard(
                  title: 'CONTENT PERFORMANCE',
                  icon: Icons.bar_chart,
                  iconColor: const Color(0xFFF59E0B),
                  child: Column(
                    children: [
                      const _ContentTypeRow(type: 'Images', engagement: 15.2, count: 12),
                      const _ContentTypeRow(type: 'Videos', engagement: 22.8, count: 5),
                      const _ContentTypeRow(type: 'Polls', engagement: 31.5, count: 3),
                      const _ContentTypeRow(type: 'Text', engagement: 8.4, count: 18),
                      const _ContentTypeRow(type: 'Audio', engagement: 12.1, count: 2),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // AI Insights
                UpdatesSectionCard(
                  title: 'AI INSIGHTS',
                  icon: Icons.auto_awesome,
                  iconColor: kUpdatesColor,
                  child: Column(
                    children: insight.aiInsights.map((ai) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kUpdatesColor.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kUpdatesColor.withOpacity(0.12)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb, size: 16, color: kUpdatesColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(ai, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Recommendations
                UpdatesSectionCard(
                  title: 'RECOMMENDATIONS',
                  icon: Icons.tips_and_updates,
                  iconColor: const Color(0xFF10B981),
                  child: Column(
                    children: insight.recommendations.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(entry.value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Best posting times
                UpdatesSectionCard(
                  title: 'BEST POSTING TIMES',
                  icon: Icons.schedule,
                  iconColor: const Color(0xFF3B82F6),
                  child: Column(
                    children: [
                      const _TimeSlot(day: 'Monday', time: '9:00 AM - 11:00 AM', engagement: 'High'),
                      const _TimeSlot(day: 'Wednesday', time: '2:00 PM - 4:00 PM', engagement: 'Very High'),
                      const _TimeSlot(day: 'Friday', time: '6:00 PM - 8:00 PM', engagement: 'Medium'),
                      const _TimeSlot(day: 'Saturday', time: '10:00 AM - 12:00 PM', engagement: 'High'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _periodLabel(String p) => switch (p) {
        '7d' => 'Last 7 days',
        '30d' => 'Last 30 days',
        '90d' => 'Last 90 days',
        '1y' => 'Last year',
        _ => p,
      };
}

// ─── Overview Metrics ───────────────────────────────────────────────────────

class _OverviewMetrics extends StatelessWidget {
  final UpdateInsight insight;
  const _OverviewMetrics({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MetricCard(value: '${insight.totalReach}', label: 'Reach', icon: Icons.visibility, color: kUpdatesColor, change: '+12%')),
        const SizedBox(width: 8),
        Expanded(child: _MetricCard(value: '${insight.impressions}', label: 'Impressions', icon: Icons.remove_red_eye, color: const Color(0xFF3B82F6), change: '+8%')),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String change;
  const _MetricCard({required this.value, required this.label, required this.icon, required this.color, required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(change, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// ─── Engagement Rate Card ───────────────────────────────────────────────────

class _EngagementRateCard extends StatelessWidget {
  final UpdateInsight insight;
  const _EngagementRateCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kUpdatesColor.withOpacity(0.08), kUpdatesAccent.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kUpdatesColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Circular gauge
          SizedBox(
            width: 72, height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72, height: 72,
                  child: CircularProgressIndicator(
                    value: insight.engagementRate / 100,
                    backgroundColor: Colors.white.withOpacity(0.4),
                    valueColor: const AlwaysStoppedAnimation(kUpdatesColor),
                    strokeWidth: 6,
                  ),
                ),
                Text('${insight.engagementRate}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kUpdatesColor)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Engagement Rate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Above average for your category', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.trending_up, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text('+${(insight.engagementRate * 0.15).toStringAsFixed(1)}% vs last period', style: const TextStyle(fontSize: 11, color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Audience Row ───────────────────────────────────────────────────────────

class _AudienceRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _AudienceRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ─── Content Type Row ───────────────────────────────────────────────────────

class _ContentTypeRow extends StatelessWidget {
  final String type;
  final double engagement;
  final int count;
  const _ContentTypeRow({required this.type, required this.engagement, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(type, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: engagement / 35,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation(engagement > 20 ? kUpdatesColor : kUpdatesAccent),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Text('${engagement}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Text('($count)', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// ─── Time Slot ──────────────────────────────────────────────────────────────

class _TimeSlot extends StatelessWidget {
  final String day;
  final String time;
  final String engagement;
  const _TimeSlot({required this.day, required this.time, required this.engagement});

  @override
  Widget build(BuildContext context) {
    final color = switch (engagement) {
      'Very High' => kUpdatesColor,
      'High' => const Color(0xFF10B981),
      _ => const Color(0xFFF59E0B),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
          Expanded(child: Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(engagement, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Simple Chart Painter ───────────────────────────────────────────────────

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kUpdatesColor.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = kUpdatesColor.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.14, size.height * 0.5),
      Offset(size.width * 0.28, size.height * 0.6),
      Offset(size.width * 0.42, size.height * 0.3),
      Offset(size.width * 0.57, size.height * 0.4),
      Offset(size.width * 0.71, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.35),
      Offset(size.width, size.height * 0.15),
    ];

    // Fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paint);

    // Dots
    final dotPaint = Paint()..color = kUpdatesColor..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
