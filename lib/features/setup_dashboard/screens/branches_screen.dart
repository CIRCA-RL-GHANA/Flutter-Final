/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.9: BRANCHES — Multi-Location Management
/// Branch list, online status, revenue, staff/vehicle counts
/// RBAC: Admin(full), Monitor(view)
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

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final branches = setupProv.branches;

        return SetupRbacGate(
          cardId: 'branches',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Branches',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('branches', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'branches',
              onPressed: () {
                context.read<SetupDashboardProvider>().selectBranch(null);
                Navigator.pushNamed(context, AppRoutes.setupBranchDetail);
              },
              label: 'Add Branch',
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
                          label: 'Total',
                          value: '${branches.length}',
                          icon: Icons.business,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Online',
                          value: '${branches.where((b) => b.status == BranchStatus.online).length}',
                          icon: Icons.cloud_done,
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
                  child: const SetupSectionTitle(title: 'All Branches', icon: Icons.business),
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
                    (context, i) => _BranchCard(branch: branches[i]),
                    childCount: branches.length,
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

class _BranchCard extends StatelessWidget {
  final Branch branch;
  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectBranch(branch.id);
        Navigator.pushNamed(context, AppRoutes.setupBranchDetail);
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
                child: const Icon(Icons.business, size: 22, color: kSetupColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${branch.type} · ${branch.managerName}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: branch.status.name,
                color: _statusColor(branch.status),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BranchStat(label: 'Staff', value: '${branch.staffCount}', icon: Icons.people),
              _BranchStat(label: 'Vehicles', value: '${branch.vehicleCount}', icon: Icons.local_shipping),
              _BranchStat(
                label: 'Revenue',
                value: '₵${(branch.monthlyRevenue / 1000).toStringAsFixed(0)}K',
                icon: Icons.attach_money,
              ),
              if (branch.rating > 0)
                _BranchStat(label: 'Rating', value: branch.rating.toStringAsFixed(1), icon: Icons.star),
            ],
          ),
          if (branch.lastSync != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.sync, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  'Last sync: ${setupTimeAgo(branch.lastSync!)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  Color _statusColor(BranchStatus status) {
    switch (status) {
      case BranchStatus.online:
        return AppColors.success;
      case BranchStatus.offline:
        return AppColors.error;
      case BranchStatus.maintenance:
        return AppColors.warning;
    }
  }
}

class _BranchStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _BranchStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: kSetupColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}
