/// ═══════════════════════════════════════════════════════════════════════════
/// GenieContextChip – Compact Role/Context Display in the Header
/// Shows the active context badge with a switch button. Reuses the existing
/// ContextProvider so it stays in sync with the rest of the app.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../features/prompt/models/rbac_models.dart';
import '../../features/prompt/providers/context_provider.dart';
import '../genie_tactile_actions.dart';

class GenieContextChip extends StatelessWidget {
  final VoidCallback? onSwitchTap;

  const GenieContextChip({super.key, this.onSwitchTap});

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();
    final ctx = ctxProvider.activeContext;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar + presence dot
        SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            children: [
              Semantics(
                label: 'Profile avatar for ${ctx.name}',
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.15),
                  backgroundImage: ctx.avatarUrl != null
                      ? NetworkImage(ctx.avatarUrl!)
                      : null,
                  child: ctx.avatarUrl == null
                      ? Text(
                          ctx.name.isNotEmpty
                              ? ctx.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _presenceColor(ctx.presence),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Name + role pill
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ctx.name.isNotEmpty ? ctx.name : 'User',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            _RolePill(role: ctx.role),
          ],
        ),

        const SizedBox(width: 8),

        // Switch context button
        Semantics(
          button: true,
          label: 'Switch context',
          child: GestureDetector(
            onTap: () {
              GenieTactileActions.onTap();
              onSwitchTap?.call();
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: const Icon(Icons.swap_horiz,
                  size: 16, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Color _presenceColor(PresenceStatus p) {
    switch (p) {
      case PresenceStatus.online:
        return AppColors.success;
      case PresenceStatus.idle:
        return AppColors.warning;
      case PresenceStatus.offline:
        return AppColors.textTertiary;
    }
  }
}

class _RolePill extends StatelessWidget {
  final UserRole role;
  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forRole(role);
    final label = switch (role) {
      UserRole.owner => 'Owner',
      UserRole.administrator => 'Admin',
      UserRole.branchManager => 'Branch Mgr',
      UserRole.driver => 'Driver',
      UserRole.responseOfficer => 'Response',
      UserRole.branchResponseOfficer => 'Br. Response',
      UserRole.socialOfficer => 'Social',
      UserRole.branchSocialOfficer => 'Br. Social',
      UserRole.monitor => 'Monitor',
      UserRole.branchMonitor => 'Br. Monitor',
      _ => 'User',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
