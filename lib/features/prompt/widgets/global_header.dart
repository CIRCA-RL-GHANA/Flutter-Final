/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// Global Header (Persistent)
/// Top Navigation Bar with context, search, and quick actions
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../models/rbac_models.dart';
import '../providers/context_provider.dart';
import '../providers/prompt_provider.dart';

class GlobalHeader extends StatelessWidget {
  final VoidCallback? onContextSwitchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSOSTap;

  const GlobalHeader({
    super.key,
    this.onContextSwitchTap,
    this.onNotificationTap,
    this.onSOSTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: IveTokens.bg,
        border: Border(bottom: IveTokens.hairlineSide),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Top Row: Context | Quick Actions ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  // Left: Context Display
                  Expanded(child: _ContextSection(onSwitchTap: onContextSwitchTap)),

                  // Right: Quick Actions
                  _QuickActionsSection(
                    onNotificationTap: onNotificationTap,
                    onSOSTap: onSOSTap,
                  ),
                ],
              ),
            ),

            // ─── Search Bar ─────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _GlobalSearchBar(),
            ),
          ],
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Context Section (Left)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _ContextSection extends StatelessWidget {
  final VoidCallback? onSwitchTap;
  const _ContextSection({this.onSwitchTap});

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();
    final ctx = ctxProvider.activeContext;

    return Row(
      children: [
        // Context Avatar
        _ContextAvatar(
          avatarUrl: ctx.avatarUrl,
          presence: ctx.presence,
          name: ctx.name,
        ),
        const SizedBox(width: 10),

        // Name + Role
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.displayLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: IveTokens.label,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              _RoleBadge(role: ctx.role),
            ],
          ),
        ),

        // Switch Context Button
        _SwitchContextButton(onTap: onSwitchTap),
      ],
    );
  }
}

/// 40px circular avatar with dynamic presence badge
class _ContextAvatar extends StatelessWidget {
  final String? avatarUrl;
  final PresenceStatus presence;
  final String name;

  const _ContextAvatar({
    this.avatarUrl,
    required this.presence,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          Semantics(
            label: 'Profile avatar for $name. Status: ${presence.name}',
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 16,
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
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _presenceColor,
                border: Border.all(color: IveTokens.bg, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _presenceColor {
    switch (presence) {
      case PresenceStatus.online:
        return AppColors.success;
      case PresenceStatus.idle:
        return AppColors.warning;
      case PresenceStatus.offline:
        return AppColors.textTertiary;
    }
  }
}

/// Color-coded pill showing current role
class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = RoleColors.forRole(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: IveTokens.brSm,
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String get _label {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.administrator:
        return 'Admin';
      case UserRole.branchManager:
        return 'Branch Mgr';
      case UserRole.socialOfficer:
        return 'Social';
      case UserRole.responseOfficer:
        return 'Response';
      case UserRole.monitor:
        return 'Monitor';
      case UserRole.branchResponseOfficer:
        return 'Branch Response';
      case UserRole.branchMonitor:
        return 'Branch Monitor';
      case UserRole.branchSocialOfficer:
        return 'Branch Social';
      case UserRole.driver:
        return 'Driver';
      case UserRole.none:
        return 'User';
    }
  }
}

/// ðŸ”„ Switch context button
class _SwitchContextButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _SwitchContextButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Switch context',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: IveTokens.brSm,
          ),
          child: const Icon(
            Icons.sync,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Quick Actions Section (Right)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _QuickActionsSection extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSOSTap;

  const _QuickActionsSection({
    this.onNotificationTap,
    this.onSOSTap,
  });

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();
    final promptProvider = context.watch<PromptProvider>();
    final showSOS = WidgetVisibility.canSeeSOS(ctxProvider.currentRole);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zap Action Menu
        _ZapActionMenu(role: ctxProvider.currentRole),
        const SizedBox(width: 4),

        // Notifications Bell
        _NotificationBell(
          count: promptProvider.notificationCount,
          onTap: onNotificationTap,
        ),

        // Emergency SOS (role-gated)
        if (showSOS) ...[
          const SizedBox(width: 4),
          _EmergencySOS(onTap: onSOSTap),
        ],
      ],
    );
  }
}

/// Role-specific dropdown quick actions
class _ZapActionMenu extends StatelessWidget {
  final UserRole role;
  const _ZapActionMenu({required this.role});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: IveTokens.brSm,
        ),
        child: const Icon(
          Icons.electric_bolt,
          size: 18,
          color: AppColors.accent,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: IveTokens.brLg),
      offset: const Offset(0, 44),
      onSelected: (value) {
        // Navigate to selected module
        HapticFeedback.lightImpact();
      },
      itemBuilder: (context) {
        final actions = WidgetVisibility.getZapActions(role);
        return actions.map((a) {
          return PopupMenuItem<String>(
            value: a.label,
            child: Row(
              children: [
                Icon(a.icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  a.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

/// Notification bell with red badge
class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationBell({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count unread notifications',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: IveTokens.brSm,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: 2,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: IveTokens.brPill,
                      border: Border.all(color: IveTokens.bg, width: 1.5),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Red emergency SOS button
class _EmergencySOS extends StatelessWidget {
  final VoidCallback? onTap;
  const _EmergencySOS({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Emergency SOS button',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          onTap?.call();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: IveTokens.brSm,
          ),
          child: const Icon(
            Icons.sos,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Global Search Bar
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _GlobalSearchBar extends StatelessWidget {
  const _GlobalSearchBar();

  @override
  Widget build(BuildContext context) {
    final promptProvider = context.watch<PromptProvider>();

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: IveTokens.brMd,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search,
            size: 20,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (v) => promptProvider.updateSearch(v),
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search everything...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Voice search
          Semantics(
            label: 'Voice search',
            button: true,
            child: GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.08),
                  borderRadius: IveTokens.brSm,
                ),
                child: Icon(
                  Icons.mic,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Context Switcher (Full-Screen Modal)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class ContextSwitcherSheet extends StatelessWidget {
  const ContextSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(IveTokens.rLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Switch Context',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Active: ${ctxProvider.activeContext.displayLabel}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          ...ctxProvider.availableContexts.map((ctx) {
            final isActive = ctx.id == ctxProvider.activeContext.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  ctxProvider.switchContext(ctx);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryLight.withValues(alpha: 0.08)
                        : AppColors.inputFill,
                    borderRadius: IveTokens.brLg,
                    border: isActive
                        ? Border.all(color: AppColors.primaryLight, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      _ContextAvatar(
                        avatarUrl: ctx.avatarUrl,
                        presence: ctx.presence,
                        name: ctx.name,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ctx.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ctx.subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _RoleBadge(role: ctx.role),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle,
                            size: 20, color: AppColors.primaryLight),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Add Entity button (ALWAYS VISIBLE per spec)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Entity'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: IveTokens.brMd,
                ),
                side: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.3)),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
