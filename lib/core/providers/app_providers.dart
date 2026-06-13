import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../features/april/providers/april_provider.dart';
import '../../features/april/providers/statement_provider.dart';
import '../../features/april/providers/wishlist_provider.dart';
import '../../features/alerts/providers/alerts_provider.dart';
import '../../features/community/providers/community_provider.dart';
import '../../features/eplay/providers/eplay_provider.dart';
import '../../features/go/providers/go_provider.dart';
import '../../features/go/providers/qpoint_market_provider.dart';
import '../../features/go/providers/qpoints_tos_provider.dart';
import '../../features/live/providers/live_provider.dart';
import '../../features/market/providers/market_provider.dart';
import '../../features/onboarding/providers/biometric_provider.dart';
import '../../features/onboarding/providers/device_check_provider.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/onboarding/providers/permission_provider.dart';
import '../../features/onboarding/providers/phone_auth_provider.dart';
import '../../features/onboarding/providers/profile_provider.dart';
import '../../features/onboarding/providers/registration_provider.dart';
import '../../features/onboarding/providers/role_provider.dart';
import '../../features/prompt/providers/context_provider.dart';
import '../../features/prompt/providers/prompt_provider.dart';
import '../../features/qualchat/providers/qualchat_provider.dart';
import '../../features/setup_dashboard/providers/campaigns_provider.dart';
import '../../features/setup_dashboard/providers/fulfillment_provider.dart';
import '../../features/setup_dashboard/providers/interests_provider.dart';
import '../../features/setup_dashboard/providers/multi_channel_provider.dart';
import '../../features/setup_dashboard/providers/setup_dashboard_provider.dart';
import '../../features/setup_dashboard/providers/tabs_provider.dart';
import '../../features/updates/providers/updates_provider.dart';
import '../../features/user_details/providers/user_details_provider.dart';
import '../../features/user_details/providers/wallets_provider.dart';
import '../../features/utility/providers/subscriptions_provider.dart';
import '../../features/utility/providers/utility_provider.dart';
import '../services/ai_assistant_service.dart';
import '../services/ai_insights_notifier.dart';
import '../services/alerts_service.dart';
import '../services/campaigns_service.dart';
import '../services/chat_service.dart';
import '../services/files_service.dart';
import '../services/fulfillment_service.dart';
import '../services/interests_service.dart';
import '../services/localstorage_service.dart';
import '../services/multi_channel_service.dart';
import '../services/orders_service.dart';
import '../services/subscriptions_service.dart';
import '../services/sync/sync_manager.dart';
import '../services/tabs_service.dart';
import '../services/wallets_service.dart';
import '../services/websocket_service.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> get providers {
    return [
      // Onboarding Providers
      ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ChangeNotifierProvider(create: (_) => DeviceCheckProvider()),
      ChangeNotifierProvider(create: (_) => PhoneAuthProvider()),
      ChangeNotifierProvider(create: (_) => RegistrationProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => BiometricProvider()),
      ChangeNotifierProvider(create: (_) => RoleProvider()),
      ChangeNotifierProvider(create: (_) => PermissionProvider()),

      // PROMPT Screen Providers
      ChangeNotifierProvider(create: (_) {
        final provider = ContextProvider();
        provider.init().catchError((e) => debugPrint('[ContextProvider] init failed: $e'));
        return provider;
      }),
      ChangeNotifierProvider(create: (_) => PromptProvider()),

      // User Details Module Provider
      ChangeNotifierProvider(create: (_) {
        final provider = UserDetailsProvider();
        provider.init().catchError((e) => debugPrint('[UserDetailsProvider] init failed: $e'));
        return provider;
      }),

      // Utility Module Provider
      ChangeNotifierProvider(create: (_) => UtilityProvider()),

      // Setup Dashboard Module Provider
      ChangeNotifierProvider(create: (_) => SetupDashboardProvider()),

      // GO Module Provider
      ChangeNotifierProvider(create: (_) => GoProvider()),

      // Q Points Market Providers
      ChangeNotifierProvider(create: (_) => QPointMarketProvider()),
      ChangeNotifierProvider(create: (_) => QPointsTosProvider()),

      // Market Module Provider
      ChangeNotifierProvider(create: (_) {
        final provider = MarketProvider();
        provider.init().catchError((e) => debugPrint('[MarketProvider] init failed: $e'));
        return provider;
      }),

      // Live Module Provider
      ChangeNotifierProvider(create: (_) {
        final provider = LiveProvider();
        provider.init().catchError((e) => debugPrint('[LiveProvider] init failed: $e'));
        return provider;
      }),

      // My Updates Module Provider
      ChangeNotifierProvider(create: (_) => UpdatesProvider()),

      // QualChat Module Provider
      ChangeNotifierProvider(create: (_) => QualChatProvider()),

      // APRIL Module Provider
      ChangeNotifierProvider(create: (_) {
        final provider = AprilProvider();
        provider.init().catchError((e) => debugPrint('[AprilProvider] init failed: $e'));
        return provider;
      }),

      // Alerts Module Provider
      ChangeNotifierProvider(create: (_) {
        final provider = AlertsProvider();
        provider.init().catchError((e) => debugPrint('[AlertsProvider] init failed: $e'));
        return provider;
      }),

      // e-Play Module Provider
      ChangeNotifierProvider(create: (_) => EPlayProvider()),

      // Community Module Provider
      ChangeNotifierProvider(create: (_) => CommunityProvider()),

      // ── Wallets Module Provider ─────────────────────────────────────────
      ChangeNotifierProvider(create: (_) => WalletsProvider()),

      // ── Subscriptions Module Provider ───────────────────────────────────
      ChangeNotifierProvider(create: (_) => SubscriptionsProvider()),

      // ── April Module — Wishlist & Statement Providers ───────────────────
      ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ChangeNotifierProvider(create: (_) => StatementProvider()),

      // ── Setup Dashboard Extended Providers ─────────────────────────────
      ChangeNotifierProvider(create: (_) => CampaignsProvider()),
      ChangeNotifierProvider(create: (_) => TabsProvider()),
      ChangeNotifierProvider(create: (_) => InterestsProvider()),
      ChangeNotifierProvider(create: (_) => MultiChannelProvider()),
      ChangeNotifierProvider(create: (_) => FulfillmentProvider()),

      // ── AI Cross-Cutting Providers ──────────────────────────────────────
      // AI Assistant: conversational AI chat available app-wide
      ChangeNotifierProvider(create: (_) => AIAssistantService()),

      // AI Insights Notifier: financial / planner AI state
      ChangeNotifierProvider(create: (_) => AIInsightsNotifier()),

      // ── Infrastructure Services ─────────────────────────────────────────
      ChangeNotifierProvider(create: (_) => WebSocketService()),

      // ChatService is a ChangeNotifier (real-time state).
      ChangeNotifierProvider(
        create: (_) => ChatService(),
      ),

      // OrdersService is a stateless API service — use plain Provider.
      Provider<OrdersService>(
        create: (_) => OrdersService(),
      ),

      // ── Stateless API Services ──────────────────────────────────────────
      Provider<WalletsService>(create: (_) => WalletsService()),
      Provider<FilesService>(create: (_) => FilesService()),
      Provider<SubscriptionsService>(create: (_) => SubscriptionsService()),
      Provider<InterestsService>(create: (_) => InterestsService()),
      Provider<AlertsService>(create: (_) => AlertsService()),
      Provider<CampaignsService>(create: (_) => CampaignsService()),
      Provider<TabsService>(create: (_) => TabsService()),
      Provider<MultiChannelService>(create: (_) => MultiChannelService()),
      Provider<FulfillmentService>(create: (_) => FulfillmentService()),

      ChangeNotifierProvider(
        create: (_) {
          final storage = LocalStorageService();
          storage.init().catchError((e) => debugPrint('[Storage] init failed: $e'));
          return storage;
        },
      ),

      ChangeNotifierProvider(
        create: (_) {
          final sync = SyncManager();
          sync.init().catchError((e) => debugPrint('[SyncManager] init failed: $e'));
          return sync;
        },
      ),
    ];
  }
}
