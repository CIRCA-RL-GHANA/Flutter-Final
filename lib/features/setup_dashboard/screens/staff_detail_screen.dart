/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.5-DETAIL: STAFF DETAIL — 4-Tab Deep View
/// Tabs: Overview, Schedule, Tasks, Performance
/// RBAC: Owner/Admin(fullAccess), BM(branchScoped), Monitor(viewOnly)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/models/rbac_models.dart';
import '../../prompt/providers/context_provider.dart';
import '../models/setup_dashboard_models.dart';
import '../models/setup_rbac.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class StaffDetailScreen extends StatefulWidget {
  const StaffDetailScreen({super.key});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Overview', 'Schedule', 'Tasks', 'Performance'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        final staff = setupProv.selectedStaff;
        if (staff == null) {
          return Scaffold(
            appBar: const SetupAppBar(title: 'Staff Detail'),
            body: const SetupEmptyState(
              icon: Icons.person,
              title: 'No staff member selected',
              subtitle: 'Select a staff member from the list',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(
            title: staff.name,
            actions: [
              // Edit role action — gated by OTP for Branch Manager
              SetupActionGuard(
                cardId: 'staff',
                child: _RoleChangeButton(
                  staff: staff,
                  currentRole: ctxProv.currentRole,
                ),
              ),
              DataScopeIndicator(
                access: context.read<SetupDashboardProvider>().getCardAccess('staff', ctxProv.currentRole),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Column(
            children: [
              _StaffHeader(staff: staff),
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
                    _OverviewTab(staff: staff),
                    _ScheduleTab(staff: staff),
                    _TasksTab(staff: staff),
                    _PerformanceTab(staff: staff),
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

class _StaffHeader extends StatelessWidget {
  final StaffMember staff;
  const _StaffHeader({required this.staff});

  Color get _statusColor => switch (staff.status) {
    StaffStatus.online => AppColors.success,
    StaffStatus.offline => AppColors.error,
    StaffStatus.idle => AppColors.warning,
    StaffStatus.onLeave => AppColors.textTertiary,
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
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: kSetupColor.withOpacity(0.1),
                child: Text(staff.name[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kSetupColor)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${staff.role} · ${staff.department}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                if (staff.branch?.isNotEmpty ?? false)
                  Text(staff.branch!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          if (staff.rating > 0)
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.accent),
                    Text(' ${staff.rating}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                Text('${staff.reviewCount} reviews', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              ],
            ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final StaffMember staff;
  const _OverviewTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Hours/Week', value: '${staff.hoursThisWeek}', icon: Icons.access_time)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Tasks', value: '${staff.tasksCompleted}/${staff.tasksTotal}', icon: Icons.task_alt, color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 16),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.contact_phone, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Contact Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              if (staff.email != null) SetupInfoRow(label: 'Email', value: staff.email!),
              if (staff.phone != null) SetupInfoRow(label: 'Phone', value: staff.phone!),
              SetupInfoRow(label: 'Department', value: staff.department),
              SetupInfoRow(label: 'Branch', value: (staff.branch?.isNotEmpty ?? false) ? staff.branch! : 'Unassigned'),
              SetupInfoRow(label: 'Joined', value: setupTimeAgo(staff.joinedDate)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final StaffMember staff;
  const _ScheduleTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Weekly Schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              ...days.asMap().entries.map((entry) {
                final isWeekend = entry.key >= 5;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: Text(entry.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isWeekend ? AppColors.textTertiary : AppColors.textPrimary))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: isWeekend ? Colors.grey.shade100 : kSetupColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isWeekend ? 'Off' : '8:00 AM - 5:00 PM',
                            style: TextStyle(fontSize: 11, color: isWeekend ? AppColors.textTertiary : kSetupColor, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
                  Icon(Icons.access_time, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Hours Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              SetupInfoRow(label: 'This Week', value: '${staff.hoursThisWeek} hrs'),
              const SetupInfoRow(label: 'Target', value: '40 hrs'),
              SetupInfoRow(label: 'Overtime', value: '${(staff.hoursThisWeek - 40).clamp(0, 100)} hrs'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TasksTab extends StatelessWidget {
  final StaffMember staff;
  const _TasksTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Progress header
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.task_alt, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Task Completion', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: staff.tasksTotal > 0 ? staff.tasksCompleted / staff.tasksTotal : 0,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
              const SizedBox(height: 8),
              SetupInfoRow(label: 'Completed', value: '${staff.tasksCompleted} / ${staff.tasksTotal}'),
              SetupInfoRow(label: 'Remaining', value: '${staff.tasksTotal - staff.tasksCompleted}'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Sample tasks
        const _SampleTask(title: 'Morning inventory check', isDone: true),
        const _SampleTask(title: 'Process pending orders', isDone: true),
        const _SampleTask(title: 'Customer follow-up calls', isDone: false),
        const _SampleTask(title: 'End-of-day report', isDone: false),
      ],
    );
  }
}

class _SampleTask extends StatelessWidget {
  final String title;
  final bool isDone;

  const _SampleTask({required this.title, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isDone ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDone ? AppColors.textTertiary : AppColors.textPrimary,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  final StaffMember staff;
  const _PerformanceTab({required this.staff});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Row(
          children: [
            Expanded(child: SetupStatCard(label: 'Rating', value: '${staff.rating}', icon: Icons.star, color: AppColors.accent)),
            const SizedBox(width: 10),
            Expanded(child: SetupStatCard(label: 'Reviews', value: '${staff.reviewCount}', icon: Icons.rate_review, color: kSetupColor)),
          ],
        ),
        const SizedBox(height: 16),
        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, size: 18, color: kSetupColor),
                  const SizedBox(width: 8),
                  const Text('Performance Metrics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const _MetricBar(label: 'Attendance', value: 0.95, color: AppColors.success),
              _MetricBar(label: 'Task Completion', value: staff.tasksTotal > 0 ? staff.tasksCompleted / staff.tasksTotal : 0, color: kSetupColor),
              _MetricBar(label: 'Customer Satisfaction', value: staff.rating / 5.0, color: AppColors.accent),
              _MetricBar(label: 'Efficiency', value: 0.82, color: const Color(0xFF8B5CF6)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MetricBar({required this.label, required this.value, required this.color});

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

// ─── Role Change Button ───────────────────────────────────────────────────────

/// Renders "Change Role" icon in the staff detail app bar.
/// For Branch Managers, wraps in [SetupOtpGate] requiring Admin OTP.
class _RoleChangeButton extends StatelessWidget {
  const _RoleChangeButton({required this.staff, required this.currentRole});

  final StaffMember staff;
  final UserRole currentRole;

  @override
  Widget build(BuildContext context) {
    void performRoleChange() {
      showSetupBottomSheet(
        context: context,
        builder: (_) => _RolePickerSheet(staff: staff),
      );
    }

    // Branch Manager: OTP required before showing role picker.
    if (currentRole == UserRole.branchManager) {
      return SetupOtpGate(
        cardId: 'staff',
        action: 'change_role',
        onVerified: performRoleChange,
        child: IconButton(
          icon: const Icon(Icons.manage_accounts_outlined, size: 22),
          color: kSetupColor,
          tooltip: 'Change Role (OTP required)',
          onPressed: null, // Tap handled by SetupOtpGate wrapper.
        ),
      );
    }

    // Administrator: direct access.
    return IconButton(
      icon: const Icon(Icons.manage_accounts_outlined, size: 22),
      color: kSetupColor,
      tooltip: 'Change Role',
      onPressed: performRoleChange,
    );
  }
}

// ─── Role Picker Sheet ────────────────────────────────────────────────────────

class _RolePickerSheet extends StatelessWidget {
  const _RolePickerSheet({required this.staff});

  final StaffMember staff;

  static const _assignableRoles = [
    UserRole.socialOfficer,
    UserRole.responseOfficer,
    UserRole.monitor,
    UserRole.branchManager,
    UserRole.branchSocialOfficer,
    UserRole.branchMonitor,
    UserRole.branchResponseOfficer,
    UserRole.driver,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Assign Role',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        ..._assignableRoles.map(
          (role) => ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: RoleColors.forRole(role).withOpacity(0.15),
              child: Icon(Icons.person, size: 16, color: RoleColors.forRole(role)),
            ),
            title: Text(
              _roleLabel(role),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
            onTap: () {
              Navigator.pop(context);
              // TODO: Call provider.updateStaffRole(staff.id, role)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Role changed to ${_roleLabel(role)}'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: kSetupColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.socialOfficer:         return 'Social Officer';
      case UserRole.responseOfficer:       return 'Response Officer';
      case UserRole.monitor:               return 'Monitor';
      case UserRole.branchManager:         return 'Branch Manager';
      case UserRole.branchSocialOfficer:   return 'Branch Social Officer';
      case UserRole.branchMonitor:         return 'Branch Monitor';
      case UserRole.branchResponseOfficer: return 'Branch Response Officer';
      case UserRole.driver:                return 'Driver';
      default:                             return role.name;
    }
  }
}
