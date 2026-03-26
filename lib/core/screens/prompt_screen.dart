/// ═══════════════════════════════════════════════════════════════════════════
/// PROMPT Screen — The Universal Launcher
/// Role-adaptive dashboard with 10 module widgets, global header, RBAC,
/// responsive grid layout, time-based adaptation
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/ai_insights_notifier.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/prompt/models/rbac_models.dart';
import '../../features/prompt/providers/context_provider.dart';
import '../../features/prompt/providers/prompt_provider.dart';
import '../../features/prompt/widgets/global_header.dart';
import '../../features/prompt/widgets/adaptive_grid.dart';
import '../../features/prompt/widgets/module_widget_card.dart';
import '../../features/prompt/widgets/modules/go_page_widget.dart';
import '../../features/prompt/widgets/modules/market_widget.dart';
import '../../features/prompt/widgets/modules/my_updates_widget.dart';
import '../../features/prompt/widgets/modules/setup_dashboard_widget.dart';
import '../../features/prompt/widgets/modules/alerts_widget.dart';
import '../../features/prompt/widgets/modules/live_widget.dart';
import '../../features/prompt/widgets/modules/qualchat_widget.dart';
import '../../features/prompt/widgets/modules/april_widget.dart';
import '../../features/prompt/widgets/modules/user_details_widget.dart';
import '../../features/prompt/widgets/modules/utility_widget.dart';
import '../../features/go/providers/go_provider.dart';
import '../../features/market/providers/market_provider.dart';
import '../../features/live/providers/live_provider.dart';
import '../../features/updates/providers/updates_provider.dart';
import '../../features/qualchat/providers/qualchat_provider.dart';
import '../../features/april/providers/april_provider.dart';
import '../../features/alerts/providers/alerts_provider.dart';
import '../../features/user_details/providers/user_details_provider.dart';
import '../../features/utility/providers/utility_provider.dart';
import '../../features/setup_dashboard/providers/setup_dashboard_provider.dart';
import '../theme/app_colors.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  /// Initialize all feature providers once after the widget tree is ready.
  /// Each provider handles its own errors gracefully with fallback data,
  /// so fire-and-forget is safe here.
  void _initializeProviders() {
    if (_initialized) return;
    _initialized = true;

    // Core providers (needed by PromptScreen directly)
    context.read<ContextProvider>().init();
    context.read<PromptProvider>().init();

    // Feature module providers
    context.read<UserDetailsProvider>().init();
    context.read<UtilityProvider>().init();
    context.read<SetupDashboardProvider>().init();
    context.read<GoProvider>().init();
    context.read<MarketProvider>().init();
    context.read<LiveProvider>().init();
    context.read<UpdatesProvider>().init();
    context.read<QualChatProvider>().init();
    context.read<AprilProvider>().init();
    context.read<AlertsProvider>().init();
  }

  @override
  Widget build(BuildContext context) {
    final contextProvider = context.watch<ContextProvider>();
    final promptProvider = context.watch<PromptProvider>();
    final onboarding = context.watch<OnboardingProvider>();

    final role = contextProvider.currentRole;
    final activeCtx = contextProvider.activeContext;
    final userName = activeCtx.name.isNotEmpty
        ? activeCtx.name
        : (onboarding.fullName.isNotEmpty ? onboarding.fullName : 'User');

    // Get the visible & ordered modules for this role
    final modules = promptProvider.getModuleOrder(role).where(
      (m) => !promptProvider.hiddenByUser.contains(m),
    ).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        // Universal FAB — "+Add Entity" always visible per spec
        floatingActionButton: _AddEntityFAB(contextProvider: contextProvider),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ─── Global Header (pinned) ──────────────────────────────
            SliverToBoxAdapter(
              child: GlobalHeader(
                onContextSwitchTap: () => _showContextSwitcher(context),
                onNotificationTap: () => _showNotifications(context),
                onSOSTap: () => _triggerSOS(context),
              ),
            ),

            // ─── Time Greeting ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  '${promptProvider.timeEmoji} ${promptProvider.timeGreeting}, $userName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // ─── Search Results Overlay ──────────────────────────────
            if (promptProvider.isSearching && promptProvider.searchResults.isNotEmpty)
              SliverToBoxAdapter(
                child: SearchResultsOverlay(
                  results: promptProvider.searchResults.map((r) {
                    return SearchResultTile(
                      icon: _searchResultIcon(r.type),
                      iconColor: _searchResultColor(r.type),
                      title: r.title,
                      subtitle: r.subtitle,
                      type: r.type.name,
                      onTap: () => promptProvider.clearSearch(),
                    );
                  }).toList(),
                  onDismiss: () => promptProvider.clearSearch(),
                ),
              ),

            // ─── Module Widgets Grid ─────────────────────────────────
            if (!promptProvider.isSearching || promptProvider.searchResults.isEmpty)
              AdaptiveGrid(
                children: List.generate(modules.length, (index) {
                  final module = modules[index];
                  final state = promptProvider.getWidgetState(module);
                  final isViewOnly = WidgetVisibility.isViewOnly(role, module);

                  return ModuleWidgetCard(
                    module: module,
                    state: state,
                    isViewOnly: isViewOnly,
                    staggerIndex: index,
                    onTap: () => _onModuleTap(context, module),
                    onLongPress: () => _onModuleLongPress(context, module),
                    onRetry: state == ModuleWidgetState.error
                        ? () => promptProvider.setWidgetState(
                            module, ModuleWidgetState.normal)
                        : null,
                    child: _buildModuleContent(
                      module: module,
                      role: role,
                      context: activeCtx,
                      userName: userName,
                      otherContexts: contextProvider.availableContexts,
                    ),
                  );
                }),
              ),

            // ─── Bottom Padding ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Module Content Factory ──────────────────────────────────────────────

  Widget _buildModuleContent({
    required PromptModule module,
    required UserRole role,
    required AppContextModel context,
    required String userName,
    required List<AppContextModel> otherContexts,
  }) {
    switch (module) {
      case PromptModule.goPage:
        return const GoPageWidgetContent();
      case PromptModule.market:
        return const MarketWidgetContent();
      case PromptModule.myUpdates:
        return const MyUpdatesWidgetContent();
      case PromptModule.setupDashboard:
        return SetupDashboardWidgetContent(role: role);
      case PromptModule.alerts:
        return const AlertsWidgetContent();
      case PromptModule.live:
        return LiveWidgetContent(
          role: role,
          branchType: context.branchType,
          driverType: context.driverType,
        );
      case PromptModule.qualChat:
        return QualChatWidgetContent(role: role);
      case PromptModule.april:
        return AprilWidgetContent(userName: userName);
      case PromptModule.userDetails:
        return UserDetailsWidgetContent(
          activeContext: context,
          otherContexts: otherContexts,
        );
      case PromptModule.utility:
        return const UtilityWidgetContent();
    }
  }

  // ─── Interactions ────────────────────────────────────────────────────────

  void _onModuleTap(BuildContext context, PromptModule module) {
    HapticFeedback.lightImpact();
    // Navigate to the full module screen
    // In production: Navigator.pushNamed(context, module.route);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${ModuleInfo.forModule(module).name}...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onModuleLongPress(BuildContext context, PromptModule module) {
    HapticFeedback.mediumImpact();
    final promptProvider = context.read<PromptProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ModuleInfo.forModule(module).name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.open_in_full, size: 20),
              title: const Text('Open Full View'),
              onTap: () {
                Navigator.pop(ctx);
                _onModuleTap(context, module);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off_outlined, size: 20),
              title: const Text('Hide Widget'),
              onTap: () {
                Navigator.pop(ctx);
                promptProvider.hideWidget(module);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, size: 20),
              title: const Text('Refresh'),
              onTap: () {
                Navigator.pop(ctx);
                promptProvider.setWidgetState(module, ModuleWidgetState.loading);
                Future.delayed(const Duration(seconds: 1), () {
                  promptProvider.setWidgetState(module, ModuleWidgetState.normal);
                });
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showContextSwitcher(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const ContextSwitcherSheet(),
    );
  }

  void _showNotifications(BuildContext context) {
    HapticFeedback.lightImpact();
    final promptProvider = context.read<PromptProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => promptProvider.markAllNotificationsRead(),
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: promptProvider.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final notif = promptProvider.notifications[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: notif.isRead
                          ? AppColors.inputFill
                          : AppColors.info.withOpacity(0.1),
                      child: Icon(
                        _notifIcon(notif.type),
                        size: 16,
                        color: notif.isRead ? AppColors.textTertiary : AppColors.info,
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      notif.body,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                    trailing: notif.isRead
                        ? null
                        : Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.info,
                            ),
                          ),
                    onTap: () => promptProvider.markNotificationRead(notif.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _notifIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.transaction:
        return Icons.swap_horiz;
      case NotificationType.alert:
        return Icons.warning_amber;
      case NotificationType.social:
        return Icons.people;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  IconData _searchResultIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.product:
        return Icons.shopping_bag;
      case SearchResultType.person:
        return Icons.person;
      case SearchResultType.transaction:
        return Icons.receipt_long;
      case SearchResultType.message:
        return Icons.chat_bubble;
      case SearchResultType.alert:
        return Icons.warning_amber;
    }
  }

  Color _searchResultColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.product:
        return AppColors.info;
      case SearchResultType.person:
        return AppColors.success;
      case SearchResultType.transaction:
        return AppColors.warning;
      case SearchResultType.message:
        return const Color(0xFF8B5CF6);
      case SearchResultType.alert:
        return AppColors.error;
    }
  }

  void _triggerSOS(BuildContext context) {
    HapticFeedback.heavyImpact();
    final promptProvider = context.read<PromptProvider>();
    promptProvider.triggerSOS();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.sos, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            const Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'Emergency alert has been sent. Help is on the way.\n\n'
          'Stay calm and keep this screen open.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              promptProvider.cancelSOS();
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ─── Add Entity FAB ─────────────────────────────────────────────────────────

class _AddEntityFAB extends StatelessWidget {
  final ContextProvider contextProvider;
  const _AddEntityFAB({required this.contextProvider});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        // In production: navigate to entity creation flow
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Add Entity flow coming soon...'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      icon: const Icon(Icons.add, size: 20),
      label: const Text(
        'Add Entity',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
