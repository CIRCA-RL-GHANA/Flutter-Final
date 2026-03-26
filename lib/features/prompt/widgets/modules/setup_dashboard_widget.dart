/// ═══════════════════════════════════════════════════════════════════════════
/// SETUP DASHBOARD Widget (Operations Center)
/// Visible to: Owner, Admin (full), Branch Manager (branch-scoped),
/// Social Officer (engagement emphasis), Monitor (view-only)
/// ═══════════════════════════════════════════════════════════════════════════

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
          // Header
          Row(
            children: [
              Icon(Icons.settings_applications, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  role == UserRole.branchManager
                      ? 'SETUP (Branch)'
                      : 'SETUP DASHBOARD',
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

  List<Widget> _getRows(Color color) {
    // Social Officer: Emphasize engagement row
    if (role == UserRole.socialOfficer ||
        role == UserRole.branchSocialOfficer) {
      return [
        _MatrixRow(icon: Icons.campaign, label: 'Marketing', value: '5 campaigns', color: color, emphasized: true),
        _MatrixRow(icon: Icons.people, label: 'Connections', value: '342', color: color, emphasized: true),
        _MatrixRow(icon: Icons.inventory_2, label: 'Products', value: '1,245', color: color),
        _MatrixRow(icon: Icons.star, label: 'Rating', value: '4.8', color: color),
      ];
    }

    // Branch Manager: Branch-scoped
    if (role == UserRole.branchManager) {
      return [
        _MatrixRow(icon: Icons.inventory_2, label: 'Products', value: '487 SKUs', color: color),
        _MatrixRow(icon: Icons.people, label: 'Staff', value: '12', color: color),
        _MatrixRow(icon: Icons.star, label: 'Rating', value: '4.8', color: color),
        _MatrixRow(icon: Icons.bar_chart, label: 'Activity', value: 'Today', color: color),
      ];
    }

    // Owner / Admin: Full 6-row matrix (showing top 4 that fit)
    return [
      _MatrixRow(icon: Icons.inventory_2, label: 'Products', value: '1,245', color: color),
      _MatrixRow(icon: Icons.people, label: 'Staff', value: '42', color: color),
      _MatrixRow(icon: Icons.place, label: 'Places', value: '128', color: color),
      _MatrixRow(icon: Icons.campaign, label: 'Marketing', value: '5', color: color),
    ];
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
              ? color.withOpacity(0.08)
              : AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: emphasized
              ? Border.all(color: color.withOpacity(0.2))
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
