/// ═══════════════════════════════════════════════════════════════════════════
/// SD2.4-DETAIL: CAMPAIGN DETAIL — 4-Tab Deep View
/// Tabs: Overview, Audience, Performance, A/B Testing
/// RBAC: Admin/SocialOfficer(fullAccess), Monitor(viewOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class CampaignDetailScreen extends StatefulWidget {
  const CampaignDetailScreen({super.key});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Audience', 'Performance', 'A/B Testing'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final campaign = setupProv.selectedCampaign;
        if (campaign == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Campaign Detail'),
            body: const SetupEmptyState(
              icon: Icons.campaign,
              title: 'No campaign selected',
              subtitle: 'Select a campaign from the list',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(title: campaign.name),
          body: Column(
            children: [
              _CampaignHeader(campaign: campaign),
              const SizedBox(height: 12),
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kSetupColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first['title'] ?? ''}'',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SetupDetailTabBar(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onTabChanged: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    _OverviewTab(campaign: campaign),
                    _AudienceTab(campaign: campaign),
                    _PerformanceTab(campaign: campaign),
                    _ABTestingTab(campaign: campaign),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CampaignHeader extends StatelessWidget {
  final Campaign campaign;
  const _CampaignHeader({required this.campaign});

  Color get _statusColor => switch (campaign.status) {
    CampaignStatus.draft => AppColors.textTertiary,
    CampaignStatus.active => AppColors.success,
    CampaignStatus.paused => AppColors.warning,
    CampaignStatus.ended => kSetupColor,
    CampaignStatus.scheduled => AppColors.info,
  };

  IconData get _statusIcon => switch (campaign.status) {
    CampaignStatus.draft => Icons.edit_note,
    CampaignStatus.active => Icons.play_circle,
    CampaignStatus.paused => Icons.pause_circle,
    CampaignStatus.ended => Icons.check_circle,
    CampaignStatus.scheduled => Icons.schedule,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_statusIcon, size: 28, color: _statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(campaign.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(campaign.type.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        campaign.status.name.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₵${campaign.budget.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${campaign.reach}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Text('Reach', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Campaign campaign;
  const _OverviewTab({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Reach', value: _formatNum(campaign.reach), icon: Icons.visibility)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Conversions', value: _formatNum(campaign.conversions), icon: Icons.shopping_cart, color: AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'ROI', value: '${campaign.roi.toStringAsFixed(0)}%', icon: Icons.trending_up, color: kSetupColor)),
          ],
        ),
        const SizedBox(height: 16),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Campaign Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Campaign ID', value: campaign.id),
              SetupInfoRow(label: 'Type', value: campaign.type.name),
              SetupInfoRow(label: 'Goal', value: campaign.goal.name),
              SetupInfoRow(label: 'Budget', value: '₵${campaign.budget.toStringAsFixed(0)}'),
              SetupInfoRow(label: 'Spent', value: '₵${campaign.spent.toStringAsFixed(0)}'),
              SetupInfoRow(label: 'ROI', value: '${campaign.roi.toStringAsFixed(1)}%', valueColor: campaign.roi > 100 ? AppColors.success : AppColors.warning),
              if (campaign.daysLeft > 0)
                SetupInfoRow(label: 'Days Left', value: '${campaign.daysLeft}'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Budget Utilization', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (campaign.budgetUtilization / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    campaign.budgetUtilization > 90 ? AppColors.error : campaign.budgetUtilization > 60 ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₵${campaign.spent.toStringAsFixed(0)} spent', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('₵${campaign.budget.toStringAsFixed(0)} total', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _AudienceTab extends StatelessWidget {
  final Campaign campaign;
  const _AudienceTab({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Target Audience', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Total Reach', value: '${campaign.reach}'),
              const SetupInfoRow(label: 'Target Group', value: 'Ages 18-45'),
              const SetupInfoRow(label: 'Location', value: 'Greater Accra'),
              const SetupInfoRow(label: 'Interests', value: 'Technology, Retail'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_alt, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Engagement Funnel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              _FunnelRow(label: 'Impressions', value: campaign.reach, maxVal: campaign.reach, color: const Color(0xFF3B82F6)),
              _FunnelRow(label: 'Conversions', value: campaign.conversions, maxVal: campaign.reach, color: AppColors.success),
            ],
          ),
        ),
      ],
    );
  }
}

class _FunnelRow extends StatelessWidget {
  final String label;
  final int value;
  final int maxVal;
  final Color color;
  const _FunnelRow({required this.label, required this.value, required this.maxVal, required this.color});

  @override
  Widget build(BuildContext context) {
    final fraction = maxVal > 0 ? value / maxVal : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('$value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  final Campaign campaign;
  const _PerformanceTab({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Conv. Rate', value: '${campaign.conversionRate.toStringAsFixed(1)}%', icon: Icons.trending_up, color: AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Budget Used', value: '${campaign.budgetUtilization.toStringAsFixed(0)}%', icon: Icons.money, color: AppColors.warning)),
          ],
        ),
        const SizedBox(height: 16),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Performance Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: kSetupColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomPaint(
                  painter: _TrendPainter(color: kSetupColor),
                  size: const Size(double.infinity, 140),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const _LegendDot(color: kSetupColor, label: 'Reach'),
                  const _LegendDot(color: AppColors.success, label: 'Conversions'),
                  const _LegendDot(color: AppColors.warning, label: 'Spend'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  final Color color;
  _TrendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75, 0.85];
    for (int i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = size.height - (points[i] * size.height * 0.8) - size.height * 0.1;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ABTestingTab extends StatelessWidget {
  final Campaign campaign;
  const _ABTestingTab({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('A/B Test Variants', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const _TestVariant(
                name: 'Variant A (Control)',
                ctr: '3.2%',
                convRate: '1.8%',
                color: kSetupColor,
                isWinning: true,
              ),
              const Divider(height: 20),
              _TestVariant(
                name: 'Variant B',
                ctr: '2.7%',
                convRate: '1.5%',
                color: const Color(0xFF8B5CF6),
                isWinning: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Test Configuration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const SetupInfoRow(label: 'Test Duration', value: '14 days'),
              const SetupInfoRow(label: 'Traffic Split', value: '50/50'),
              const SetupInfoRow(label: 'Confidence', value: '95%'),
              const SetupInfoRow(label: 'Min. Sample', value: '1,000 per variant'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TestVariant extends StatelessWidget {
  final String name;
  final String ctr;
  final String convRate;
  final Color color;
  final bool isWinning;

  const _TestVariant({
    required this.name,
    required this.ctr,
    required this.convRate,
    required this.color,
    required this.isWinning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: isWinning ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
              const Spacer(),
              if (isWinning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('WINNING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CTR', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text(ctr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Conv. Rate', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text(convRate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
