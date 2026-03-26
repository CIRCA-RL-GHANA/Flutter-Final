/// ═══════════════════════════════════════════════════════════════════════════
/// UTILITY Widget (Global Tools)
/// Visible to: ALL roles
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class UtilityWidgetContent extends StatelessWidget {
  const UtilityWidgetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.utility);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/utility'),
      child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.build_circle, size: 18, color: color),
              const SizedBox(width: 6),
              const Text(
                'UTILITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tool Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ToolItem(icon: Icons.search, label: 'Search', color: color),
                _ToolItem(icon: Icons.notifications_outlined, label: 'Notifs', color: color),
                _ToolItem(icon: Icons.help_outline, label: 'Help', color: color),
                _ToolItem(icon: Icons.palette_outlined, label: 'Theme', color: color),
                _ToolItem(icon: Icons.language, label: 'Lang', color: color),
                _ToolItem(icon: Icons.accessibility_new, label: 'Access', color: color),
              ],
            ),
          ),

          // Data Management
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.storage, size: 14, color: color),
                const SizedBox(width: 6),
                const Text(
                  '12.4 MB',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Backup: 2h ago',
                  style: TextStyle(fontSize: 9, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ToolItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
