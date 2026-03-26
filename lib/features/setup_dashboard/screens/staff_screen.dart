/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.5: STAFF — Team Management
/// Staff list, roles, performance, branch assignment
/// RBAC: Admin(full), BM(branch), Monitor/BrMon(view)
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

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final staff = setupProv.staffMembers;

        return SetupRbacGate(
          cardId: 'staff',
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: SetupAppBar(
              title: 'Staff',
              actions: [
                DataScopeIndicator(access: setupProv.getCardAccess('staff', ctxProv.currentRole)),
                SizedBox(width: 16),
              ],
            ),
            floatingActionButton: SetupRbacFAB(
              cardId: 'staff',
              onPressed: () {
                context.read<SetupDashboardProvider>().selectStaff(null);
                Navigator.pushNamed(context, AppRoutes.setupStaffDetail);
              },
              label: 'Add Staff',
              icon: Icons.add,
            ),
            body: CustomScrollView(
            slivers: [
              // ─── Summary ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: KPIBadge(
                          label: 'Total Staff',
                          value: '${staff.length}',
                          icon: Icons.people,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: KPIBadge(
                          label: 'Online',
                          value: '${setupProv.onlineStaffCount}',
                          icon: Icons.circle,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Staff List ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SetupSectionTitle(
                    title: 'Team Members',
                    icon: Icons.people,
                  ),
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
                    (context, i) => _StaffCard(member: staff[i]),
                    childCount: staff.length,
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

// ─── Staff Card ──────────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  final StaffMember member;
  const _StaffCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SetupDashboardProvider>().selectStaff(member.id);
        Navigator.pushNamed(context, AppRoutes.setupStaffDetail);
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
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kSetupColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kSetupColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${member.role} · ${member.branch ?? member.department}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SetupStatusIndicator(
                label: _statusLabel(member.status),
                color: _statusColor(member.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (member.rating > 0) ...[
                _StaffStat(
                  label: 'Rating',
                  value: member.rating.toStringAsFixed(1),
                  icon: Icons.star,
                  color: AppColors.accent,
                ),
              ],
              _StaffStat(
                label: 'Hours/Week',
                value: '${member.hoursThisWeek}',
                icon: Icons.schedule,
              ),
              if (member.tasksTotal > 0)
                _StaffStat(
                  label: 'Tasks',
                  value: '${member.tasksCompleted}/${member.tasksTotal}',
                  icon: Icons.task_alt,
                  color: AppColors.success,
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  String _statusLabel(StaffStatus status) {
    switch (status) {
      case StaffStatus.online:
        return 'Online';
      case StaffStatus.offline:
        return 'Offline';
      case StaffStatus.idle:
        return 'Idle';
      case StaffStatus.onLeave:
        return 'On Leave';
    }
  }

  Color _statusColor(StaffStatus status) {
    switch (status) {
      case StaffStatus.online:
        return AppColors.success;
      case StaffStatus.offline:
        return AppColors.error;
      case StaffStatus.idle:
        return AppColors.warning;
      case StaffStatus.onLeave:
        return AppColors.info;
    }
  }
}

// ─── Staff Stat ──────────────────────────────────────────────────────────────

class _StaffStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StaffStat({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kSetupColor;
    return Column(
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: c,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
