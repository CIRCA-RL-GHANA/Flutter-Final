/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// GenieFullScreenLauncher – Modal + Full-Screen Module Navigation
///
/// When an intent sets requiresFullScreen=true Genie can:
///   1. Push the module's named route (full-screen mode).
///   2. Show a bottom-sheet overlay for semi-immersive depth.
/// Also renders the '+' expand menu that lists all accessible modules.
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design/ive.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../features/prompt/models/rbac_models.dart';
import '../../features/prompt/providers/context_provider.dart';
import '../genie_intent.dart';
import '../genie_rbac_enforcer.dart';
import '../genie_tactile_actions.dart';

class GenieFullScreenLauncher {
  /// Launch the full-screen route for a module, gated by RBAC.
  ///
  /// If the current role lacks access to [module], the navigation is
  /// suppressed and a polite denial snackbar is surfaced. Callers that
  /// already know the role may use [launchForRole] directly.
  static void launch(BuildContext context, GenieModule module) {
    final role = _resolveRole(context);
    launchForRole(context, module, role);
  }

  /// Launch with an explicit role (used by callers that already have it).
  static void launchForRole(
      BuildContext context, GenieModule module, UserRole role) {
    if (!GenieRBACEnforcer.canAccessModule(role, module)) {
      _denyAccess(context, role, module);
      return;
    }
    GenieTactileActions.onNavigate();
    final route = _routeForModule(module);
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

  static UserRole _resolveRole(BuildContext context) {
    try {
      return context.read<ContextProvider>().currentRole;
    } catch (_) {
      return UserRole.none;
    }
  }

  static void _denyAccess(
      BuildContext context, UserRole role, GenieModule module) {
    GenieTactileActions.onError();
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final message =
        GenieRBACEnforcer.getDenialMessage(role, module, 'open');
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.textPrimary,
      ),
    );
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
      case GenieModule.fintech:
        return AppRoutes.fintechLoans;
      case GenieModule.enterprise:
        return AppRoutes.enterpriseDashboard;
      default:
        return null;
    }
  }
}

class _ModuleMenuSheet extends StatelessWidget {
  final UserRole role;
  const _ModuleMenuSheet({required this.role});

  static const _allModules = <(GenieModule, String, IconData, Color)>[
    (GenieModule.goPage,         'GO PAGE',    Icons.payments_outlined,        Color(0xFFFFD27A)),
    (GenieModule.market,         'MARKET',     Icons.storefront_outlined,      Color(0xFF6FA8FF)),
    (GenieModule.eplay,          'e-PLAY',     Icons.graphic_eq_rounded,       Color(0xFFB591FF)),
    (GenieModule.community,      'COMMUNITY',  Icons.public_outlined,          Color(0xFF4FC4D9)),
    (GenieModule.myUpdates,      'UPDATES',    Icons.dynamic_feed_outlined,    Color(0xFFB39BFA)),
    (GenieModule.setupDashboard, 'SETUP',      Icons.tune_rounded,             Color(0xFF8C92FF)),
    (GenieModule.alerts,         'ALERTS',     Icons.notifications_none,       Color(0xFFFF7373)),
    (GenieModule.live,           'LIVE',       Icons.sensors_rounded,          Color(0xFF4FD1A1)),
    (GenieModule.qualChat,       'qualChat',   Icons.chat_bubble_outline,      Color(0xFF4ECFE1)),
    (GenieModule.april,          'APRIL',      Icons.auto_awesome_outlined,    Color(0xFFFFB14E)),
    (GenieModule.userDetails,    'PROFILE',    Icons.person_outline,           Color(0xFF4FD0A6)),
    (GenieModule.utility,        'UTILITY',    Icons.handyman_outlined,        Color(0xFF9BA3AE)),
    (GenieModule.fintech,        'FINTECH',    Icons.account_balance_outlined, Color(0xFF5BE0C2)),
    (GenieModule.enterprise,     'ENTERPRISE', Icons.business_center_outlined, Color(0xFFC99B2C)),
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
                  icon: Icons.folder_outlined,
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
                icon: m.$3,
                label: m.$2,
                color: m.$4,
                onTap: () {
                  Navigator.pop(context);
                  GenieFullScreenLauncher.launchForRole(
                      context, m.$1, role);
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
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.icon,
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
          scale: _pressed ? 0.95 : 1.0,
          duration: IveTokens.dMicro,
          child: Container(
            decoration: BoxDecoration(
              color: IveTokens.bg,
              borderRadius: IveTokens.brSm,
              border: Border.all(
                color: _pressed
                    ? widget.color.withValues(alpha: 0.6)
                    : IveTokens.hairline,
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 26, color: widget.color),
                const SizedBox(height: IveTokens.s2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: IveTokens.label,
                      height: 1.2,
                    ),
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
