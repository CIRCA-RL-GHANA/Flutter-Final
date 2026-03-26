/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.10: CAMPAIGNS — Marketing Campaign Management
/// Campaign list, ROI tracking, budget, reach/conversions
/// RBAC: Owner(personal), Admin(full), BM(branch), SO(full), BSO(branch),
///        Monitor/BrMon(view)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final campaigns = setupProv.campaigns;

        return SetupRbacGate(
          cardId: 'campaigns',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Marketing',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('campaigns', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'campaigns',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.setupCampaignCreate);
              },
              label: 'Add Campaign',
              icon: Icons.add,
            ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Active',
                          value: '${campaigns.where((c) => c.status == CampaignStatus.active).length}',
                          icon: Icons.campaign,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Avg ROI',
                          value: '${campaigns.where((c) => c.roi > 0).fold<double>(0, (s, c) => s + c.roi) ~/ campaigns.where((c) => c.roi > 0).length}%',
                          icon: Icons.trending_up,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(title: 'All Campaigns', icon: Icons.campaign),
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _CampaignCard(campaign: campaigns[i]),
                    childCount: campaigns.length,
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

class _CampaignCard extends StatelessWidget {
  final Campaign campaign;
  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectCampaign(campaign.id);
        Navigator.pushNamed(context, AppRoutes.setupCampaignDetail);
      },
      child: Container(
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kSetupColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign, size: 22, color: kSetupColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${campaign.type.name} · ${campaign.goal.name}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: campaign.status.name,
                color: _statusColor(campaign.status),
              ),
            ],
          ),
          if (campaign.status == CampaignStatus.active) ...[
            const Divider(height: 20),
            // Budget bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget: ₵${campaign.spent.toStringAsFixed(0)}/₵${campaign.budget.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (campaign.roi > 0)
                  Text('ROI: ${campaign.roi.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: campaign.budget > 0 ? (campaign.spent / campaign.budget).clamp(0.0, 1.0) : 0,
                backgroundColor: AppColors.inputBorder,
                valueColor: const AlwaysStoppedAnimation(kSetupColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CampaignStat(label: 'Reach', value: _formatNum(campaign.reach)),
                _CampaignStat(label: 'Conversions', value: '${campaign.conversions}'),
                if (campaign.conversionRate > 0)
                  _CampaignStat(label: 'Conv. Rate', value: '${campaign.conversionRate.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  Color _statusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.active:
        return AppColors.success;
      case CampaignStatus.paused:
        return AppColors.warning;
      case CampaignStatus.scheduled:
        return AppColors.info;
      case CampaignStatus.draft:
        return AppColors.textTertiary;
      case CampaignStatus.ended:
        return AppColors.error;
    }
  }
}

class _CampaignStat extends StatelessWidget {
  final String label;
  final String value;
  const _CampaignStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}
