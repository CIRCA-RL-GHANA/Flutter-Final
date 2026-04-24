/// ═══════════════════════════════════════════════════════════════════════════
/// GenieFullScreenLauncher – Modal + Full-Screen Module Navigation
///
/// When an intent sets requiresFullScreen=true Genie can:
///   1. Push the module's named route (full-screen mode).
///   2. Show a bottom-sheet overlay for semi-immersive depth.
/// Also renders the '+' expand menu that lists all accessible modules.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../features/prompt/models/rbac_models.dart';
import '../genie_intent.dart';
import '../genie_rbac_enforcer.dart';
import '../genie_tactile_actions.dart';

class GenieFullScreenLauncher {
  /// Launch the full-screen route for a module.
  static void launch(BuildContext context, GenieModule module) {
    GenieTactileActions.onNavigate();
    final route = _routeForModule(module);
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

  /// Show the full-module-list bottom sheet, RBAC-filtered.
  static void showModuleMenu(BuildContext context, UserRole role) {
    GenieTactileActions.onTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModuleMenuSheet(role: role),
    );
  }

  static String? _routeForModule(GenieModule module) {
    switch (module) {
      case GenieModule.goPage:
        return AppRoutes.goHub;
      case GenieModule.market:
        return AppRoutes.marketHub;
      case GenieModule.myUpdates:
        return AppRoutes.updatesFeed;
      case GenieModule.setupDashboard:
        return AppRoutes.setupDashboard;
      case GenieModule.alerts:
        return AppRoutes.alerts;
      case GenieModule.live:
        return AppRoutes.liveDashboard;
      case GenieModule.qualChat:
        return AppRoutes.qualChatDashboard;
      case GenieModule.april:
        return AppRoutes.aprilDashboard;
      case GenieModule.userDetails:
        return AppRoutes.userDetailsMaster;
      case GenieModule.utility:
        return AppRoutes.utilityDashboard;
      case GenieModule.eplay:
        return AppRoutes.eplayHub;
      case GenieModule.community:
        return AppRoutes.communityHub;
      default:
        return null;
    }
  }
}

class _ModuleMenuSheet extends StatelessWidget {
  final UserRole role;
  const _ModuleMenuSheet({required this.role});

  static const _allModules = [
    (GenieModule.goPage, 'GO PAGE', '💰', Color(0xFFFFD700)),
    (GenieModule.market, 'MARKET', '🛍️', Color(0xFF2563EB)),
    (GenieModule.eplay, 'e-PLAY', '🎵', Color(0xFF7C3AED)),
    (GenieModule.community, 'COMMUNITY', '🌍', Color(0xFF0891B2)),
    (GenieModule.myUpdates, 'MY UPDATES', '📰', Color(0xFF8B5CF6)),
    (GenieModule.setupDashboard, 'SETUP DASHBOARD', '⚙️', Color(0xFF6366F1)),
    (GenieModule.alerts, 'ALERTS', '🔔', Color(0xFFEF4444)),
    (GenieModule.live, 'LIVE', '📡', Color(0xFF10B981)),
    (GenieModule.qualChat, 'qualChat', '💬', Color(0xFF06B6D4)),
    (GenieModule.april, 'APRIL', '✨', Color(0xFFF59E0B)),
    (GenieModule.userDetails, 'USER DETAILS', '👤', Color(0xFF059669)),
    (GenieModule.utility, 'UTILITY', '🔧', Color(0xFF6B7280)),
  ];

  @override
  Widget build(BuildContext context) {
    final accessible = _allModules
        .where((m) => GenieRBACEnforcer.canAccessModule(role, m.$1))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.inputBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'All Modules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tap to open full-screen module',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: accessible.length + 1, // +1 for classic dashboard
            itemBuilder: (context, index) {
              if (index == accessible.length) {
                return _ModuleTile(
                  emoji: '🗂️',
                  label: 'Classic\nDashboard',
                  color: AppColors.textSecondary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context)
                        .pushNamed(AppRoutes.promptScreen);
                  },
                );
              }
              final m = accessible[index];
              return _ModuleTile(
                emoji: m.$3,
                label: m.$2,
                color: m.$4,
                onTap: () {
                  Navigator.pop(context);
                  GenieFullScreenLauncher.launch(context, m.$1);
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModuleTile> createState() => _ModuleTileState();
}

class _ModuleTileState extends State<_ModuleTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          GenieTactileActions.onNavigate();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.color.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
