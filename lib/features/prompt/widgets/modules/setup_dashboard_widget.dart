/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// SETUP DASHBOARD Widget (Operations Center)
/// Visible to: Owner, Admin (full), Branch Manager (branch-scoped),
/// Social Officer (engagement emphasis), Monitor (view-only)
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class SetupDashboardWidgetContent extends StatelessWidget {
  final UserRole role;

  const SetupDashboardWidgetContent({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.setupDashboard);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.setupDashboard),
      child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — branch-scoped roles get narrower title
          Row(
            children: [
              Icon(Icons.settings_applications, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _headerTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 6-Row Matrix Preview (role-adapted)
          Expanded(
            child: Column(
              children: _getRows(color),
            ),
          ),
        ],
      ),
    ),
    );
  }

  String get _headerTitle {
    switch (role) {
      case UserRole.branchManager:
      case UserRole.branchSocialOfficer:
      case UserRole.branchMonitor:
      case UserRole.branchResponseOfficer:
        return 'SETUP (Branch)';
      case UserRole.driver:
        return 'SETUP (Driver)';
      default:
        return 'SETUP DASHBOARD';
    }
  }

  List<Widget> _getRows(Color color) {
    switch (role) {
      // ── Owner: personal features only ──────────────────────────────────
      case UserRole.owner:
        return [
          _MatrixRow(icon: Icons.person_outline,  label: 'Profile',      value: 'Personal',     color: color),
          _MatrixRow(icon: Icons.place_outlined,  label: 'Places',       value: 'My Locations', color: color),
          _MatrixRow(icon: Icons.stars_outlined,  label: 'Q-Points',     value: '4,820 pts',    color: color),
          _MatrixRow(icon: Icons.track_changes,   label: 'My Activity',  value: 'Today',        color: color),
        ];

      // ── Administrator: full business suite ─────────────────────────────
      case UserRole.administrator:
        return [
          _MatrixRow(icon: Icons.inventory_2,     label: 'Products',   value: '1,245',  color: color),
          _MatrixRow(icon: Icons.people,          label: 'Staff',      value: '42',     color: color),
          _MatrixRow(icon: Icons.account_tree,    label: 'Branches',   value: '12',     color: color),
          _MatrixRow(icon: Icons.stars_outlined,  label: 'Q-Points',   value: 'Entity', color: color),
        ];

      // ── Branch Manager: branch-scoped ops ──────────────────────────────
      case UserRole.branchManager:
        return [
          _MatrixRow(icon: Icons.inventory_2,      label: 'Products',   value: '487 SKUs', color: color),
          _MatrixRow(icon: Icons.people,           label: 'Staff',      value: '12',       color: color),
          _MatrixRow(icon: Icons.local_shipping,   label: 'Vehicles',   value: 'Fleet',    color: color),
          _MatrixRow(icon: Icons.bar_chart,        label: 'My Activity', value: 'Today',   color: color),
        ];

      // ── Social Officer: engagement emphasis ────────────────────────────
      case UserRole.socialOfficer:
        return [
          _MatrixRow(icon: Icons.campaign,         label: 'Marketing',    value: '5 active',  color: color, emphasized: true),
          _MatrixRow(icon: Icons.people_outline,   label: 'Connections',  value: '342',       color: color, emphasized: true),
          _MatrixRow(icon: Icons.interests,        label: 'Interests',    value: 'Managed',   color: color),
          _MatrixRow(icon: Icons.dynamic_feed,     label: 'Social',       value: '3 posts',   color: color),
        ];

      // ── Branch Social Officer: branch engagement ────────────────────────
      case UserRole.branchSocialOfficer:
        return [
          _MatrixRow(icon: Icons.campaign,         label: 'Marketing',    value: 'Branch',    color: color, emphasized: true),
          _MatrixRow(icon: Icons.people_outline,   label: 'Connections',  value: 'Branch',    color: color, emphasized: true),
          _MatrixRow(icon: Icons.interests,        label: 'Interests',    value: 'Managed',   color: color),
          _MatrixRow(icon: Icons.dynamic_feed,     label: 'Social',       value: 'Branch',    color: color),
        ];

      // ── Monitor: view-only oversight ───────────────────────────────────
      case UserRole.monitor:
        return [
          _MatrixRow(icon: Icons.visibility_outlined, label: 'Activity Log', value: 'View Only', color: color),
          _MatrixRow(icon: Icons.bar_chart,           label: 'Outlook',      value: 'Analytics', color: color),
          _MatrixRow(icon: Icons.inventory_2,         label: 'Products',     value: 'View Only', color: color),
          _MatrixRow(icon: Icons.people,              label: 'Staff',        value: 'View Only', color: color),
        ];

      // ── Branch Monitor: branch view-only ───────────────────────────────
      case UserRole.branchMonitor:
        return [
          _MatrixRow(icon: Icons.visibility_outlined, label: 'Activity Log', value: 'Branch',    color: color),
          _MatrixRow(icon: Icons.bar_chart,           label: 'Outlook',      value: 'Branch',    color: color),
          _MatrixRow(icon: Icons.inventory_2,         label: 'Products',     value: 'View Only', color: color),
          _MatrixRow(icon: Icons.people,              label: 'Staff',        value: 'View Only', color: color),
        ];

      // ── Response Officer: operational focus ────────────────────────────
      case UserRole.responseOfficer:
        return [
          _MatrixRow(icon: Icons.local_shipping,   label: 'Vehicles',      value: 'Fleet',      color: color),
          _MatrixRow(icon: Icons.place_outlined,   label: 'Places',        value: 'View Only',  color: color),
          _MatrixRow(icon: Icons.map_outlined,     label: 'Zones',         value: 'Delivery',   color: color),
          _MatrixRow(icon: Icons.track_changes,    label: 'My Activity',   value: 'Today',      color: color),
        ];

      // ── Branch Response Officer: branch ops ────────────────────────────
      case UserRole.branchResponseOfficer:
        return [
          _MatrixRow(icon: Icons.local_shipping,   label: 'Vehicles',      value: 'Branch',     color: color),
          _MatrixRow(icon: Icons.place_outlined,   label: 'Places',        value: 'Branch',     color: color),
          _MatrixRow(icon: Icons.map_outlined,     label: 'Zones',         value: 'Branch',     color: color),
          _MatrixRow(icon: Icons.track_changes,    label: 'My Activity',   value: 'Today',      color: color),
        ];

      // ── Driver: personal ops ───────────────────────────────────────────
      case UserRole.driver:
        return [
          _MatrixRow(icon: Icons.local_shipping,   label: 'My Vehicle',    value: 'Assigned',   color: color),
          _MatrixRow(icon: Icons.map_outlined,     label: 'Zones',         value: 'Delivery',   color: color),
          _MatrixRow(icon: Icons.people_outline,   label: 'Connections',   value: 'Personal',   color: color),
          _MatrixRow(icon: Icons.track_changes,    label: 'My Activity',   value: 'Today',      color: color),
        ];

      // ── none / fallback ────────────────────────────────────────────────
      default:
        return [
          _MatrixRow(icon: Icons.person_outline,   label: 'Profile',       value: 'Personal',   color: color),
          _MatrixRow(icon: Icons.track_changes,    label: 'My Activity',   value: 'Today',      color: color),
          _MatrixRow(icon: Icons.interests,        label: 'Interests',     value: 'Personal',   color: color),
          _MatrixRow(icon: Icons.stars_outlined,   label: 'Q-Points',      value: 'Personal',   color: color),
        ];
    }
  }
}

class _MatrixRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool emphasized;

  const _MatrixRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: emphasized
              ? color.withValues(alpha: 0.08)
              : AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: emphasized
              ? Border.all(color: color.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: emphasized ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
