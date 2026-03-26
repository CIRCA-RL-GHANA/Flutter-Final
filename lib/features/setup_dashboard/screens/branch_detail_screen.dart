/// ═══════════════════════════════════════════════════════════════════════════
/// SD2.1-DETAIL: BRANCH DETAIL — 4-Tab Deep View
/// Tabs: Overview, Staff, Vehicles, Performance
/// RBAC: Admin(fullAccess), Monitor(viewOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class BranchDetailScreen extends StatefulWidget {
  const BranchDetailScreen({super.key});

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Staff', 'Vehicles', 'Performance'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final branch = setupProv.selectedBranch;
        if (branch == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Branch Detail'),
            body: const SetupEmptyState(
              icon: Icons.business,
              title: 'No branch selected',
              subtitle: 'Select a branch from the list',
            ),
          );
        }

        final branchStaff = setupProv.getStaffByBranch(branch.name);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(title: branch.name),
          body: Column(
            children: [
              _BranchHeader(branch: branch),
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
                    _OverviewTab(branch: branch),
                    _StaffTab(staff: branchStaff),
                    _VehiclesTab(branch: branch),
                    _PerformanceTab(branch: branch),
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

class _BranchHeader extends StatelessWidget {
  final Branch branch;
  const _BranchHeader({required this.branch});

  Color get _statusColor => switch (branch.status) {
    BranchStatus.online => AppColors.success,
    BranchStatus.offline => AppColors.error,
    BranchStatus.maintenance => AppColors.warning,
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
            child: Icon(Icons.business, size: 28, color: _statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branch.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${branch.type} · ${branch.area ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    branch.status.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.accent),
                  Text(' ${branch.rating}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              if (branch.lastSync != null)
                Text(
                  'Synced ${setupTimeAgo(branch.lastSync!)}',
                  style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Branch branch;
  const _OverviewTab({required this.branch});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Revenue', value: '₵${(branch.monthlyRevenue / 1000).toStringAsFixed(0)}K', icon: Icons.attach_money, color: AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Staff', value: '${branch.staffCount}', icon: Icons.people)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Vehicles', value: '${branch.vehicleCount}', icon: Icons.local_shipping, color: kSetupColor)),
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
                  const Text('Branch Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Branch ID', value: branch.id),
              SetupInfoRow(label: 'Type', value: branch.type),
              SetupInfoRow(label: 'Manager', value: branch.managerName ?? 'Unassigned'),
              SetupInfoRow(label: 'Area', value: branch.area ?? 'N/A'),
              SetupInfoRow(label: 'Monthly Revenue', value: '₵${branch.monthlyRevenue.toStringAsFixed(0)}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StaffTab extends StatelessWidget {
  final List<StaffMember> staff;
  const _StaffTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    if (staff.isEmpty) {
      return const SetupEmptyState(
        icon: Icons.people_outline,
        title: 'No staff assigned',
        subtitle: 'No staff members at this branch',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: staff.length,
      itemBuilder: (context, i) {
        final s = staff[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: kSetupColor.withOpacity(0.1),
                child: Text(s.name[0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kSetupColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(s.role, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: s.status == StaffStatus.online ? AppColors.success : AppColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VehiclesTab extends StatelessWidget {
  final Branch branch;
  const _VehiclesTab({required this.branch});

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
                  Icon(Icons.local_shipping, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Fleet Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Total Vehicles', value: '${branch.vehicleCount}'),
              SetupInfoRow(label: 'Active', value: '${(branch.vehicleCount * 0.75).round()}', valueColor: AppColors.success),
              SetupInfoRow(label: 'Maintenance', value: '${(branch.vehicleCount * 0.15).round()}', valueColor: AppColors.warning),
              SetupInfoRow(label: 'Offline', value: '${(branch.vehicleCount * 0.1).round()}', valueColor: AppColors.error),
            ],
          ),
        ),
      ],
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  final Branch branch;
  const _PerformanceTab({required this.branch});

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
                  Icon(Icons.analytics, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Key Metrics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              _PerformanceBar(label: 'Customer Satisfaction', value: branch.rating / 5.0, color: AppColors.success),
              const _PerformanceBar(label: 'Order Fulfillment', value: 0.92, color: kSetupColor),
              _PerformanceBar(label: 'Staff Efficiency', value: 0.85, color: const Color(0xFF8B5CF6)),
              const _PerformanceBar(label: 'Revenue Target', value: 0.78, color: AppColors.warning),
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
                  Icon(Icons.pie_chart, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Revenue Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'Products', value: '₵${(branch.monthlyRevenue * 0.65).toStringAsFixed(0)}'),
              SetupInfoRow(label: 'Services', value: '₵${(branch.monthlyRevenue * 0.25).toStringAsFixed(0)}'),
              SetupInfoRow(label: 'Other', value: '₵${(branch.monthlyRevenue * 0.10).toStringAsFixed(0)}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PerformanceBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _PerformanceBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('${(value * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
