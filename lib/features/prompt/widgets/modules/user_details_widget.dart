/// ═══════════════════════════════════════════════════════════════════════════
/// USER DETAILS Widget (Profile & Entities)
/// Visible to: ALL roles
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/rbac_models.dart';

class UserDetailsWidgetContent extends StatelessWidget {
  final AppContextModel activeContext;
  final List<AppContextModel> otherContexts;

  const UserDetailsWidgetContent({
    super.key,
    required this.activeContext,
    required this.otherContexts,
  });

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forModule(PromptModule.userDetails);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/user-details'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header
          Row(
            children: [
              Icon(Icons.person, size: 18, color: color),
              const SizedBox(width: 6),
              const Text(
                'USER DETAILS',
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

          // Current Context Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.15),
                  child: Text(
                    activeContext.name.isNotEmpty
                        ? activeContext.name[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeContext.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        activeContext.roleLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: RoleColors.forRole(activeContext.role),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Profile Completeness
          Row(
            children: [
              const Text(
                'Profile: ',
                style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: AppColors.inputFill,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '75%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Quick Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickSetting(icon: Icons.fingerprint, label: 'Bio', color: color),
              _QuickSetting(icon: Icons.notifications_outlined, label: 'Notif', color: color),
              _QuickSetting(icon: Icons.privacy_tip_outlined, label: 'Privacy', color: color),
            ],
          ),

          const Spacer(),

          // Security Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, size: 12, color: AppColors.success),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    '2FA on • Last login: Today',
                    style: TextStyle(fontSize: 9, color: AppColors.textTertiary),
                  ),
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

class _QuickSetting extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickSetting({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
