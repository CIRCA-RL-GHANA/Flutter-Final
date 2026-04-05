import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/onboarding/screens/screen_0_preloading.dart';
import '../../features/onboarding/screens/screen_1_splash.dart';
import '../../features/onboarding/screens/screen_2_welcome.dart';
import '../../features/onboarding/screens/screen_3_phone_input.dart';
import '../../features/onboarding/screens/screen_4_otp_verification.dart';
import '../../features/onboarding/screens/screen_5_registration.dart';
import '../../features/onboarding/screens/screen_6_profile_photo.dart';
import '../../features/onboarding/screens/screen_7_biometric.dart';
import '../../features/onboarding/screens/screen_8_role_selection.dart';
import '../../features/onboarding/screens/screen_9_permissions.dart';
import '../../features/onboarding/screens/screen_10_success.dart';
import '../../features/onboarding/screens/screen_11_tutorial.dart';
import '../../features/onboarding/screens/screen_12_welcome_back.dart';
import '../../features/onboarding/screens/screen_13_error_recovery.dart';
import '../screens/prompt_screen.dart';
// User Details Screens
import '../../features/user_details/screens/user_details_master_screen.dart';
import '../../features/user_details/screens/context_management_screen.dart';
import '../../features/user_details/screens/create_entity_screen.dart';
import '../../features/user_details/screens/avatar_editor_screen.dart';
import '../../features/user_details/screens/security_screen.dart';
import '../../features/user_details/screens/privacy_center_screen.dart';
import '../../features/user_details/screens/notification_settings_screen.dart';
import '../../features/user_details/screens/accessibility_screen.dart';
import '../../features/user_details/screens/audit_log_screen.dart';
// Utility Module Screens
import '../../features/utility/screens/utility_dashboard_screen.dart';
import '../../features/utility/screens/settings_screen.dart';
import '../../features/utility/screens/notification_center_screen.dart';
import '../../features/utility/screens/search_screen.dart';
import '../../features/utility/screens/help_support_screen.dart';
import '../../features/utility/screens/data_privacy_screen.dart';
import '../../features/utility/screens/accessibility_center_screen.dart';
import '../../features/utility/screens/advanced_data_screen.dart';
import '../../features/utility/screens/system_monitor_screen.dart';
// Setup Dashboard Module Screens
import '../../features/setup_dashboard/screens/setup_dashboard_screen.dart';
import '../../features/setup_dashboard/screens/products_screen.dart';
import '../../features/setup_dashboard/screens/vehicles_screen.dart';
import '../../features/setup_dashboard/screens/tabs_screen.dart';
import '../../features/setup_dashboard/screens/discounts_screen.dart';
import '../../features/setup_dashboard/screens/staff_screen.dart';
import '../../features/setup_dashboard/screens/audit_screen.dart';
import '../../features/setup_dashboard/screens/places_screen.dart';
import '../../features/setup_dashboard/screens/zones_screen.dart';
import '../../features/setup_dashboard/screens/bands_screen.dart';
import '../../features/setup_dashboard/screens/branches_screen.dart';
import '../../features/setup_dashboard/screens/campaigns_screen.dart';
import '../../features/setup_dashboard/screens/social_screen.dart';
import '../../features/setup_dashboard/screens/connections_screen.dart';
import '../../features/setup_dashboard/screens/profile_screen.dart';
import '../../features/setup_dashboard/screens/outlook_screen.dart';
import '../../features/setup_dashboard/screens/subscription_screen.dart';
import '../../features/setup_dashboard/screens/interests_screen.dart';
import '../../features/setup_dashboard/screens/qpoints_screen.dart';
import '../../features/setup_dashboard/screens/my_activity_screen.dart';
// Setup Dashboard Detail Screens
import '../../features/setup_dashboard/screens/product_detail_screen.dart';
import '../../features/setup_dashboard/screens/vehicle_detail_screen.dart';
import '../../features/setup_dashboard/screens/tab_detail_screen.dart';
import '../../features/setup_dashboard/screens/staff_detail_screen.dart';
import '../../features/setup_dashboard/screens/branch_detail_screen.dart';
import '../../features/setup_dashboard/screens/place_detail_screen.dart';
import '../../features/setup_dashboard/screens/zone_detail_screen.dart';
import '../../features/setup_dashboard/screens/campaign_detail_screen.dart';
import '../../features/setup_dashboard/screens/discount_detail_screen.dart';
import '../../features/setup_dashboard/screens/connection_detail_screen.dart';
import '../../features/setup_dashboard/screens/social_detail_screen.dart';
import '../../features/setup_dashboard/screens/product_create_screen.dart';
import '../../features/setup_dashboard/screens/campaign_create_screen.dart';
import '../../features/setup_dashboard/screens/tab_create_screen.dart';
// Market Module Screens
import '../../features/market/screens/market_hub_screen.dart';
import '../../features/market/screens/market_search_screen.dart';
import '../../features/market/screens/market_filters_screen.dart';
import '../../features/market/screens/market_explore_screen.dart';
import '../../features/market/screens/market_branch_screen.dart';
import '../../features/market/screens/market_product_listing_screen.dart';
import '../../features/market/screens/market_product_filters_screen.dart';
import '../../features/market/screens/market_product_detail_screen.dart';
import '../../features/market/screens/market_cart_screen.dart';
import '../../features/market/screens/market_checkout_screen.dart';
import '../../features/market/screens/market_transactions_screen.dart';
import '../../features/market/screens/market_pickup_screen.dart';
import '../../features/market/screens/market_return_screen.dart';
import '../../features/market/screens/market_delivery_tracker_screen.dart';
import '../../features/market/screens/market_ride_hailing_screen.dart';
// Live Module Screens
import '../../features/live/screens/live_dashboard_screen.dart';
import '../../features/live/screens/live_orders_screen.dart';
import '../../features/live/screens/live_order_detail_screen.dart';
import '../../features/live/screens/live_driver_assignment_screen.dart';
import '../../features/live/screens/live_package_creation_screen.dart';
import '../../features/live/screens/live_returns_screen.dart';
import '../../features/live/screens/live_return_review_screen.dart';
import '../../features/live/screens/live_return_rejection_screen.dart';
import '../../features/live/screens/live_packages_screen.dart';
import '../../features/live/screens/live_package_detail_screen.dart';
import '../../features/live/screens/live_driver_home_screen.dart';
import '../../features/live/screens/live_package_acceptance_screen.dart';
import '../../features/live/screens/live_delivery_verification_screen.dart';
import '../../features/live/screens/live_return_pickup_screen.dart';
import '../../features/live/screens/live_multi_hop_transfer_screen.dart';
import '../../features/live/screens/live_transport_driver_home_screen.dart';
import '../../features/live/screens/live_ride_execution_screen.dart';
import '../../features/live/screens/live_analytics_screen.dart';
import '../../features/live/screens/live_driver_performance_screen.dart';
import '../../features/live/screens/live_emergency_sos_screen.dart';
import '../../features/live/screens/live_incident_report_screen.dart';
import '../../features/live/screens/live_settings_screen.dart';
import '../../features/live/screens/live_operations_screen.dart';
// Updates Module Screens
import '../../features/updates/screens/updates_feed_screen.dart';
import '../../features/updates/screens/updates_detail_screen.dart';
import '../../features/updates/screens/updates_likes_screen.dart';
import '../../features/updates/screens/updates_shares_screen.dart';
import '../../features/updates/screens/updates_saved_screen.dart';
import '../../features/updates/screens/updates_search_screen.dart';
import '../../features/updates/screens/updates_options_screen.dart';
import '../../features/updates/screens/updates_create_screen.dart';
import '../../features/updates/screens/updates_notifications_screen.dart';
import '../../features/updates/screens/updates_interests_screen.dart';
import '../../features/updates/screens/updates_following_screen.dart';
import '../../features/updates/screens/updates_insights_screen.dart';
import '../../features/updates/screens/updates_social_feed_screen.dart';
// QualChat Module Screens
import '../../features/qualchat/screens/qualchat_loading_screen.dart';
import '../../features/qualchat/screens/qualchat_dashboard_screen.dart';
import '../../features/qualchat/screens/qualchat_hey_yas_screen.dart';
import '../../features/qualchat/screens/qualchat_timeline_screen.dart';
import '../../features/qualchat/screens/qualchat_preferences_screen.dart';
import '../../features/qualchat/screens/qualchat_vibe_image_screen.dart';
import '../../features/qualchat/screens/qualchat_presence_screen.dart';
import '../../features/qualchat/screens/qualchat_new_chat_screen.dart';
import '../../features/qualchat/screens/qualchat_chat_list_screen.dart';
import '../../features/qualchat/screens/qualchat_archived_screen.dart';
import '../../features/qualchat/screens/qualchat_thread_screen.dart';
import '../../features/qualchat/screens/qualchat_nudges_screen.dart';
import '../../features/qualchat/screens/qualchat_action_center_screen.dart';
import '../../features/qualchat/screens/qualchat_settings_screen.dart';
import '../../features/qualchat/screens/qualchat_onboarding_screen.dart';
import '../../features/qualchat/screens/qualchat_premium_screen.dart';

// APRIL screens
import '../../features/april/screens/april_widget_screen.dart';
import '../../features/april/screens/april_dashboard_screen.dart';
import '../../features/april/screens/april_planner_screen.dart';
import '../../features/april/screens/april_calendar_screen.dart';
import '../../features/april/screens/april_wishlist_screen.dart';
import '../../features/april/screens/april_statement_screen.dart';
import '../../features/april/screens/april_settings_screen.dart';

// ALERTS screens
import '../../features/alerts/screens/alerts_widget_screen.dart';
import '../../features/alerts/screens/alerts_dashboard_screen.dart';
import '../../features/alerts/screens/alerts_search_screen.dart';
import '../../features/alerts/screens/alerts_filter_screen.dart';
import '../../features/alerts/screens/alerts_detail_screen.dart';
import '../../features/alerts/screens/alerts_composer_screen.dart';
import '../../features/alerts/screens/alerts_resolution_screen.dart';
import '../../features/alerts/screens/alerts_analytics_screen.dart';
import '../../features/alerts/screens/alerts_knowledge_screen.dart';
import '../../features/alerts/screens/alerts_bulk_screen.dart';
import '../../features/alerts/screens/alerts_templates_screen.dart';
import '../../features/alerts/screens/alerts_settings_screen.dart';

// GO Module Screens
import '../../features/go/screens/go_financial_screen.dart';
import '../../features/go/screens/go_context_screen.dart';
import '../../features/go/screens/qpoint_market_screen.dart';
import '../../features/go/providers/qpoint_market_provider.dart';
import '../../features/go/screens/go_hub_screen.dart';
import '../../features/go/screens/go_buy_screen.dart';
import '../../features/go/screens/go_sell_screen.dart';
import '../../features/go/screens/go_transfer_screen.dart';
import '../../features/go/screens/go_verification_screen.dart';
import '../../features/go/screens/go_tabs_screen.dart';
import '../../features/go/screens/go_tab_detail_screen.dart';
import '../../features/go/screens/go_requests_screen.dart';
import '../../features/go/screens/go_favorites_screen.dart';
import '../../features/go/screens/go_favorite_detail_screen.dart';
import '../../features/go/screens/go_batch_screen.dart';
import '../../features/go/screens/go_planner_screen.dart';
import '../../features/go/screens/go_tax_screen.dart';
import '../../features/go/screens/go_reports_screen.dart';
import '../../features/go/screens/go_security_screen.dart';
import '../../features/go/screens/go_integrations_screen.dart';
import '../../features/go/screens/go_archive_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Onboarding Routes
  static const String preLoading = '/pre-loading';
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String phoneInput = '/phone-input';
  static const String otpVerification = '/otp-verification';
  static const String registration = '/registration';
  static const String profilePhoto = '/profile-photo';
  static const String biometric = '/biometric';
  static const String roleSelection = '/role-selection';
  static const String permissions = '/permissions';
  static const String success = '/success';
  static const String tutorial = '/tutorial';
  static const String welcomeBack = '/welcome-back';
  static const String errorRecovery = '/error-recovery';

  // Main App Routes
  static const String promptScreen = '/prompt';
  static const String home = '/home';

  // User Details Module Routes
  static const String userDetailsMaster = '/user-details';
  static const String userDetailsContexts = '/user-details/contexts';
  static const String userDetailsCreateEntity = '/user-details/create-entity';
  static const String userDetailsAvatarEditor = '/user-details/avatar-editor';
  static const String userDetailsSecurity = '/user-details/security';
  static const String userDetailsPrivacy = '/user-details/privacy';
  static const String userDetailsNotifications = '/user-details/notifications';
  static const String userDetailsAccessibility = '/user-details/accessibility';
  static const String userDetailsAuditLog = '/user-details/audit-log';

  // Utility Module Routes
  static const String utilityDashboard = '/utility';
  static const String utilitySettings = '/utility/settings';
  static const String utilityNotifications = '/utility/notifications';
  static const String utilitySearch = '/utility/search';
  static const String utilityHelp = '/utility/help';
  static const String utilityPrivacy = '/utility/privacy';
  static const String utilityAccessibility = '/utility/accessibility';
  static const String utilityAdvancedData = '/utility/advanced-data';
  static const String utilitySystemMonitor = '/utility/system-monitor';

  // Setup Dashboard Module Routes
  static const String setupDashboard = '/setup';
  static const String setupProducts = '/setup/products';
  static const String setupVehicles = '/setup/vehicles';
  static const String setupTabs = '/setup/tabs';
  static const String setupDiscounts = '/setup/discounts';
  static const String setupStaff = '/setup/staff';
  static const String setupAudit = '/setup/audit';
  static const String setupPlaces = '/setup/places';
  static const String setupZones = '/setup/zones';
  static const String setupBands = '/setup/bands';
  static const String setupBranches = '/setup/branches';
  static const String setupCampaigns = '/setup/campaigns';
  static const String setupSocial = '/setup/social';
  static const String setupConnections = '/setup/connections';
  static const String setupProfile = '/setup/profile';
  static const String setupOutlook = '/setup/outlook';
  static const String setupSubscription = '/setup/subscription';
  static const String setupInterests = '/setup/interests';
  static const String setupQPoints = '/setup/qpoints';
  static const String setupMyActivity = '/setup/my-activity';

  // Setup Dashboard Detail Routes
  static const String setupProductDetail = '/setup/products/detail';
  static const String setupVehicleDetail = '/setup/vehicles/detail';
  static const String setupTabDetail = '/setup/tabs/detail';
  static const String setupStaffDetail = '/setup/staff/detail';
  static const String setupBranchDetail = '/setup/branches/detail';
  static const String setupPlaceDetail = '/setup/places/detail';
  static const String setupZoneDetail = '/setup/zones/detail';
  static const String setupCampaignDetail = '/setup/campaigns/detail';
  static const String setupDiscountDetail = '/setup/discounts/detail';
  static const String setupConnectionDetail = '/setup/connections/detail';
  static const String setupSocialDetail = '/setup/social/detail';

  // Setup Dashboard Create/Wizard Routes
  static const String setupProductCreate = '/setup/products/create';
  static const String setupCampaignCreate = '/setup/campaigns/create';
  static const String setupTabCreate = '/setup/tabs/create';

  // Market Module Routes
  static const String marketHub = '/market';
  static const String marketSearch = '/market/search';
  static const String marketFilters = '/market/filters';
  static const String marketExplore = '/market/explore';
  static const String marketBranch = '/market/branch';
  static const String marketProductListing = '/market/products';
  static const String marketProductFilters = '/market/products/filters';
  static const String marketProductDetail = '/market/products/detail';
  static const String marketCart = '/market/cart';
  static const String marketCheckout = '/market/checkout';
  static const String marketTransactions = '/market/transactions';
  static const String marketPickup = '/market/pickup';
  static const String marketReturn = '/market/return';
  static const String marketDeliveryTracker = '/market/delivery-tracker';
  static const String marketRideHailing = '/market/ride-hailing';

  // Live Module Routes
  static const String liveDashboard = '/live';
  static const String liveOrders = '/live/orders';
  static const String liveOrderDetail = '/live/orders/detail';
  static const String liveDriverAssignment = '/live/driver-assignment';
  static const String livePackageCreation = '/live/package-creation';
  static const String liveReturns = '/live/returns';
  static const String liveReturnReview = '/live/returns/review';
  static const String liveReturnRejection = '/live/returns/rejection';
  static const String livePackages = '/live/packages';
  static const String livePackageDetail = '/live/packages/detail';
  static const String liveDriverHome = '/live/driver-home';
  static const String livePackageAcceptance = '/live/package-acceptance';
  static const String liveDeliveryVerification = '/live/delivery-verification';
  static const String liveReturnPickup = '/live/return-pickup';
  static const String liveMultiHopTransfer = '/live/multi-hop-transfer';
  static const String liveTransportDriverHome = '/live/transport-driver-home';
  static const String liveRideExecution = '/live/ride-execution';
  static const String liveAnalytics = '/live/analytics';
  static const String liveDriverPerformance = '/live/driver-performance';
  static const String liveEmergencySOS = '/live/emergency-sos';
  static const String liveIncidentReport = '/live/incident-report';
  static const String liveSettings = '/live/settings';
  static const String liveOperations = '/live/operations';

  // Updates Module Routes
  static const String updatesFeed = '/updates';
  static const String updatesDetail = '/updates/detail';
  static const String updatesLikes = '/updates/likes';
  static const String updatesShares = '/updates/shares';
  static const String updatesSaved = '/updates/saved';
  static const String updatesSearch = '/updates/search';
  static const String updatesOptions = '/updates/options';
  static const String updatesCreate = '/updates/create';
  static const String updatesNotifications = '/updates/notifications';
  static const String updatesInterests = '/updates/interests';
  static const String updatesFollowing = '/updates/following';
  static const String updatesInsights = '/updates/insights';
  static const String updatesSocialFeed = '/updates/social-feed';

  // QualChat Module Routes
  static const String qualChatDashboard = '/qualchat';
  static const String qualChatLoading = '/qualchat/loading';
  static const String qualChatHeyYas = '/qualchat/hey-yas';
  static const String qualChatTimeline = '/qualchat/timeline';
  static const String qualChatPreferences = '/qualchat/preferences';
  static const String qualChatVibeImage = '/qualchat/vibe-image';
  static const String qualChatPresence = '/qualchat/presence';
  static const String qualChatNewChat = '/qualchat/new-chat';
  static const String qualChatChats = '/qualchat/chats';
  static const String qualChatArchived = '/qualchat/archived';
  static const String qualChatThread = '/qualchat/thread';
  static const String qualChatNudges = '/qualchat/nudges';
  static const String qualChatActionCenter = '/qualchat/action-center';
  static const String qualChatSettings = '/qualchat/settings';
  static const String qualChatOnboarding = '/qualchat/onboarding';
  static const String qualChatPremium = '/qualchat/premium';

  // APRIL Routes
  static const String aprilDashboard = '/april';
  static const String aprilWidget = '/april/widget';
  static const String aprilPlanner = '/april/planner';
  static const String aprilCalendar = '/april/calendar';
  static const String aprilWishlist = '/april/wishlist';
  static const String aprilStatement = '/april/statement';
  static const String aprilSettings = '/april/settings';

  // ALERTS Routes
  static const String alertsWidget = '/alerts/widget';
  static const String alerts = '/alerts';
  static const String alertsSearch = '/alerts/search';
  static const String alertsFilter = '/alerts/filter';
  static const String alertsDetail = '/alerts/detail';
  static const String alertsCompose = '/alerts/compose';
  static const String alertsResolve = '/alerts/resolve';
  static const String alertsAnalytics = '/alerts/analytics';
  static const String alertsKnowledge = '/alerts/knowledge';
  static const String alertsBulk = '/alerts/bulk';
  static const String alertsTemplates = '/alerts/templates';
  static const String alertsSettings = '/alerts/settings';

  // GO Module Routes
  // QPoints Market Routes
  static const String qPointsMarket = '/go/qpoints-market';

  static const String goContext = '/go/context';
  static const String goHub = '/go';
  static const String goBuy = '/go/buy';
  static const String goSell = '/go/sell';
  static const String goTransfer = '/go/transfer';
  static const String goVerification = '/go/verification';
  static const String goTabs = '/go/tabs';
  static const String goTabDetail = '/go/tab-detail';
  static const String goRequests = '/go/requests';
  static const String goFavorites = '/go/favorites';
  static const String goFavoriteDetail = '/go/favorite-detail';
  static const String goBatch = '/go/batch';
  static const String goPlanner = '/go/planner';
  static const String goTax = '/go/tax';
  static const String goReports = '/go/reports';
  static const String goSecurity = '/go/security';
  static const String goIntegrations = '/go/integrations';
  static const String goArchive = '/go/archive';
  static const String goFinancial = '/go/financial';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case preLoading:
        return _buildRoute(const PreLoadingScreen(), settings);
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case welcome:
        return _buildRoute(const WelcomeScreen(), settings);
      case phoneInput:
        return _buildRoute(const PhoneInputScreen(), settings);
      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          OtpVerificationScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            countryCode: args?['countryCode'] ?? '+1',
          ),
          settings,
        );
      case registration:
        return _buildRoute(const RegistrationScreen(), settings);
      case profilePhoto:
        return _buildRoute(const ProfilePhotoScreen(), settings);
      case biometric:
        return _buildRoute(const BiometricSetupScreen(), settings);
      case roleSelection:
        return _buildRoute(const RoleSelectionScreen(), settings);
      case permissions:
        return _buildRoute(const PermissionsScreen(), settings);
      case success:
        return _buildRoute(const SuccessScreen(), settings);
      case tutorial:
        return _buildRoute(const TutorialScreen(), settings);
      case welcomeBack:
        return _buildRoute(const WelcomeBackScreen(), settings);
      case errorRecovery:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ErrorRecoveryScreen(
            errorType: args?['errorType'] ?? ErrorType.network,
            errorMessage: args?['errorMessage'],
            onRetry: args?['onRetry'],
          ),
          settings,
        );
      case promptScreen:
      case home:
        return _buildRoute(const PromptScreen(), settings);

      // User Details Module
      case userDetailsMaster:
        return _buildRoute(const UserDetailsMasterScreen(), settings);
      case userDetailsContexts:
        return _buildRoute(const ContextManagementScreen(), settings);
      case userDetailsCreateEntity:
        return _buildRoute(const CreateEntityScreen(), settings);
      case userDetailsAvatarEditor:
        return _buildRoute(const AvatarEditorScreen(), settings);
      case userDetailsSecurity:
        return _buildRoute(const SecurityScreen(), settings);
      case userDetailsPrivacy:
        return _buildRoute(const PrivacyCenterScreen(), settings);
      case userDetailsNotifications:
        return _buildRoute(const NotificationSettingsScreen(), settings);
      case userDetailsAccessibility:
        return _buildRoute(const AccessibilityScreen(), settings);
      case userDetailsAuditLog:
        return _buildRoute(const AuditLogScreen(), settings);

      // Utility Module
      case utilityDashboard:
        return _buildRoute(const UtilityDashboardScreen(), settings);
      case utilitySettings:
        return _buildRoute(const SettingsScreen(), settings);
      case utilityNotifications:
        return _buildRoute(const NotificationCenterScreen(), settings);
      case utilitySearch:
        return _buildRoute(const SearchScreen(), settings);
      case utilityHelp:
        return _buildRoute(const HelpSupportScreen(), settings);
      case utilityPrivacy:
        return _buildRoute(const DataPrivacyScreen(), settings);
      case utilityAccessibility:
        return _buildRoute(const AccessibilityCenterScreen(), settings);
      case utilityAdvancedData:
        return _buildRoute(const AdvancedDataScreen(), settings);
      case utilitySystemMonitor:
        return _buildRoute(const SystemMonitorScreen(), settings);

      // Setup Dashboard Module
      case setupDashboard:
        return _buildRoute(const SetupDashboardScreen(), settings);
      case setupProducts:
        return _buildRoute(const ProductsScreen(), settings);
      case setupVehicles:
        return _buildRoute(const VehiclesScreen(), settings);
      case setupTabs:
        return _buildRoute(const TabsScreen(), settings);
      case setupDiscounts:
        return _buildRoute(const DiscountsScreen(), settings);
      case setupStaff:
        return _buildRoute(const StaffScreen(), settings);
      case setupAudit:
        return _buildRoute(const AuditScreen(), settings);
      case setupPlaces:
        return _buildRoute(const PlacesScreen(), settings);
      case setupZones:
        return _buildRoute(const ZonesScreen(), settings);
      case setupBands:
        return _buildRoute(const BandsScreen(), settings);
      case setupBranches:
        return _buildRoute(const BranchesScreen(), settings);
      case setupCampaigns:
        return _buildRoute(const CampaignsScreen(), settings);
      case setupSocial:
        return _buildRoute(const SocialScreen(), settings);
      case setupConnections:
        return _buildRoute(const ConnectionsScreen(), settings);
      case setupProfile:
        return _buildRoute(const ProfileScreen(), settings);
      case setupOutlook:
        return _buildRoute(const OutlookScreen(), settings);
      case setupSubscription:
        return _buildRoute(const SubscriptionScreen(), settings);
      case setupInterests:
        return _buildRoute(const InterestsScreen(), settings);
      case setupQPoints:
        return _buildRoute(const QPointsScreen(), settings);
      case setupMyActivity:
        return _buildRoute(const MyActivityScreen(), settings);

      // Setup Dashboard Detail Screens
      case setupProductDetail:
        return _buildRoute(const ProductDetailScreen(), settings);
      case setupVehicleDetail:
        return _buildRoute(const VehicleDetailScreen(), settings);
      case setupTabDetail:
        return _buildRoute(const TabDetailScreen(), settings);
      case setupStaffDetail:
        return _buildRoute(const StaffDetailScreen(), settings);
      case setupBranchDetail:
        return _buildRoute(const BranchDetailScreen(), settings);
      case setupPlaceDetail:
        return _buildRoute(const PlaceDetailScreen(), settings);
      case setupZoneDetail:
        return _buildRoute(const ZoneDetailScreen(), settings);
      case setupCampaignDetail:
        return _buildRoute(const CampaignDetailScreen(), settings);
      case setupDiscountDetail:
        return _buildRoute(const DiscountDetailScreen(), settings);
      case setupConnectionDetail:
        return _buildRoute(const ConnectionDetailScreen(), settings);
      case setupSocialDetail:
        return _buildRoute(const SocialDetailScreen(), settings);

      // Setup Dashboard Create/Wizard Screens
      case setupProductCreate:
        return _buildRoute(const ProductCreateScreen(), settings);
      case setupCampaignCreate:
        return _buildRoute(const CampaignCreateScreen(), settings);
      case setupTabCreate:
        return _buildRoute(const TabCreateScreen(), settings);

      // Market Module Screens
      case marketHub:
        return _buildRoute(const MarketHubScreen(), settings);
      case marketSearch:
        return _buildRoute(const MarketSearchScreen(), settings);
      case marketFilters:
        return _buildRoute(const MarketFiltersScreen(), settings);
      case marketExplore:
        return _buildRoute(const MarketExploreScreen(), settings);
      case marketBranch:
        return _buildRoute(const MarketBranchScreen(), settings);
      case marketProductListing:
        return _buildRoute(const MarketProductListingScreen(), settings);
      case marketProductFilters:
        return _buildRoute(const MarketProductFiltersScreen(), settings);
      case marketProductDetail:
        return _buildRoute(const MarketProductDetailScreen(), settings);
      case marketCart:
        return _buildRoute(const MarketCartScreen(), settings);
      case marketCheckout:
        return _buildRoute(const MarketCheckoutScreen(), settings);
      case marketTransactions:
        return _buildRoute(const MarketTransactionsScreen(), settings);
      case marketPickup:
        return _buildRoute(const MarketPickupScreen(), settings);
      case marketReturn:
        return _buildRoute(const MarketReturnScreen(), settings);
      case marketDeliveryTracker:
        return _buildRoute(const MarketDeliveryTrackerScreen(), settings);
      case marketRideHailing:
        return _buildRoute(const MarketRideHailingScreen(), settings);

      // Live Module Screens
      case liveDashboard:
        return _buildRoute(const LiveDashboardScreen(), settings);
      case liveOrders:
        return _buildRoute(const LiveOrdersScreen(), settings);
      case liveOrderDetail:
        return _buildRoute(const LiveOrderDetailScreen(), settings);
      case liveDriverAssignment:
        return _buildRoute(const LiveDriverAssignmentScreen(), settings);
      case livePackageCreation:
        return _buildRoute(const LivePackageCreationScreen(), settings);
      case liveReturns:
        return _buildRoute(const LiveReturnsScreen(), settings);
      case liveReturnReview:
        return _buildRoute(const LiveReturnReviewScreen(), settings);
      case liveReturnRejection:
        return _buildRoute(const LiveReturnRejectionScreen(), settings);
      case livePackages:
        return _buildRoute(const LivePackagesScreen(), settings);
      case livePackageDetail:
        return _buildRoute(const LivePackageDetailScreen(), settings);
      case liveDriverHome:
        return _buildRoute(const LiveDriverHomeScreen(), settings);
      case livePackageAcceptance:
        return _buildRoute(const LivePackageAcceptanceScreen(), settings);
      case liveDeliveryVerification:
        return _buildRoute(const LiveDeliveryVerificationScreen(), settings);
      case liveReturnPickup:
        return _buildRoute(const LiveReturnPickupScreen(), settings);
      case liveMultiHopTransfer:
        return _buildRoute(const LiveMultiHopTransferScreen(), settings);
      case liveTransportDriverHome:
        return _buildRoute(const LiveTransportDriverHomeScreen(), settings);
      case liveRideExecution:
        return _buildRoute(const LiveRideExecutionScreen(), settings);
      case liveAnalytics:
        return _buildRoute(const LiveAnalyticsScreen(), settings);
      case liveDriverPerformance:
        return _buildRoute(const LiveDriverPerformanceScreen(), settings);
      case liveEmergencySOS:
        return _buildRoute(const LiveEmergencySOSScreen(), settings);
      case liveIncidentReport:
        return _buildRoute(const LiveIncidentReportScreen(), settings);
      case liveSettings:
        return _buildRoute(const LiveSettingsScreen(), settings);
      case liveOperations:
        return _buildRoute(const LiveOperationsScreen(), settings);

      // Updates Module Screens
      case updatesFeed:
        return _buildRoute(const UpdatesFeedScreen(), settings);
      case updatesDetail:
        return _buildRoute(const UpdatesDetailScreen(), settings);
      case updatesLikes:
        return _buildRoute(const UpdatesLikesScreen(), settings);
      case updatesShares:
        return _buildRoute(const UpdatesSharesScreen(), settings);
      case updatesSaved:
        return _buildRoute(const UpdatesSavedScreen(), settings);
      case updatesSearch:
        return _buildRoute(const UpdatesSearchScreen(), settings);
      case updatesOptions:
        return _buildRoute(const UpdatesOptionsScreen(), settings);
      case updatesCreate:
        return _buildRoute(const UpdatesCreateScreen(), settings);
      case updatesNotifications:
        return _buildRoute(const UpdatesNotificationsScreen(), settings);
      case updatesInterests:
        return _buildRoute(const UpdatesInterestsScreen(), settings);
      case updatesFollowing:
        return _buildRoute(const UpdatesFollowingScreen(), settings);
      case updatesInsights:
        return _buildRoute(const UpdatesInsightsScreen(), settings);
      case updatesSocialFeed:
        return _buildRoute(const UpdatesSocialFeedScreen(), settings);

      // QualChat Module Screens
      case qualChatDashboard:
        return _buildRoute(const QualChatDashboardScreen(), settings);
      case qualChatLoading:
        return _buildRoute(const QualChatLoadingScreen(), settings);
      case qualChatHeyYas:
        return _buildRoute(const QualChatHeyYasScreen(), settings);
      case qualChatTimeline:
        return _buildRoute(const QualChatTimelineScreen(), settings);
      case qualChatPreferences:
        return _buildRoute(const QualChatPreferencesScreen(), settings);
      case qualChatVibeImage:
        return _buildRoute(const QualChatVibeImageScreen(), settings);
      case qualChatPresence:
        return _buildRoute(const QualChatPresenceScreen(), settings);
      case qualChatNewChat:
        return _buildRoute(const QualChatNewChatScreen(), settings);
      case qualChatChats:
        return _buildRoute(const QualChatChatListScreen(), settings);
      case qualChatArchived:
        return _buildRoute(const QualChatArchivedScreen(), settings);
      case qualChatThread:
        return _buildRoute(const QualChatThreadScreen(), settings);
      case qualChatNudges:
        return _buildRoute(const QualChatNudgesScreen(), settings);
      case qualChatActionCenter:
        return _buildRoute(const QualChatActionCenterScreen(), settings);
      case qualChatSettings:
        return _buildRoute(const QualChatSettingsScreen(), settings);
      case qualChatOnboarding:
        return _buildRoute(const QualChatOnboardingScreen(), settings);
      case qualChatPremium:
        final convId = settings.arguments as String?;
        return _buildRoute(QualChatPremiumScreen(conversationId: convId), settings);

      // APRIL Routes
      case aprilDashboard:
        return _buildRoute(const AprilDashboardScreen(), settings);
      case aprilWidget:
        return _buildRoute(const AprilWidgetScreen(), settings);
      case aprilPlanner:
        return _buildRoute(const AprilPlannerScreen(), settings);
      case aprilCalendar:
        return _buildRoute(const AprilCalendarScreen(), settings);
      case aprilWishlist:
        return _buildRoute(const AprilWishlistScreen(), settings);
      case aprilStatement:
        return _buildRoute(const AprilStatementScreen(), settings);
      case aprilSettings:
        return _buildRoute(const AprilSettingsScreen(), settings);

      // ── ALERTS ──────────────────────────────
      case alertsWidget:
        return _buildRoute(const AlertsWidgetScreen(), settings);
      case alerts:
        return _buildRoute(const AlertsDashboardScreen(), settings);
      case alertsSearch:
        return _buildRoute(const AlertsSearchScreen(), settings);
      case alertsFilter:
        return _buildRoute(const AlertsFilterScreen(), settings);
      case alertsDetail:
        final alertId = settings.arguments as String;
        return _buildRoute(AlertsDetailScreen(alertId: alertId), settings);
      case alertsCompose:
        return _buildRoute(const AlertsComposerScreen(), settings);
      case alertsResolve:
        final alertId = settings.arguments as String;
        return _buildRoute(AlertsResolutionScreen(alertId: alertId), settings);
      case alertsAnalytics:
        return _buildRoute(const AlertsAnalyticsScreen(), settings);
      case alertsKnowledge:
        final alertId = settings.arguments as String?;
        return _buildRoute(AlertsKnowledgeScreen(alertId: alertId), settings);
      case alertsBulk:
        return _buildRoute(const AlertsBulkScreen(), settings);
      case alertsTemplates:
        return _buildRoute(const AlertsTemplatesScreen(), settings);
      case alertsSettings:
        return _buildRoute(const AlertsSettingsScreen(), settings);

      // GO Module
      case qPointsMarket:
        return _buildRoute(
          ChangeNotifierProvider(
            create: (_) => QPointMarketProvider(),
            child: const QPointMarketScreen(),
          ),
          settings,
        );
      case goContext:
        return _buildRoute(const GoContextScreen(), settings);
      case goHub:
        return _buildRoute(const GoHubScreen(), settings);
      case goBuy:
        return _buildRoute(const GoBuyScreen(), settings);
      case goSell:
        return _buildRoute(const GoSellScreen(), settings);
      case goTransfer:
        return _buildRoute(const GoTransferScreen(), settings);
      case goVerification:
        return _buildRoute(const GoVerificationScreen(), settings);
      case goTabs:
        return _buildRoute(const GoTabsScreen(), settings);
      case goTabDetail:
        final tabId = settings.arguments as String?;
        return _buildRoute(GoTabDetailScreen(tabId: tabId), settings);
      case goRequests:
        return _buildRoute(const GoRequestsScreen(), settings);
      case goFavorites:
        return _buildRoute(const GoFavoritesScreen(), settings);
      case goFavoriteDetail:
        final favId = settings.arguments as String?;
        return _buildRoute(GoFavoriteDetailScreen(favoriteId: favId), settings);
      case goBatch:
        return _buildRoute(const GoBatchScreen(), settings);
      case goPlanner:
        return _buildRoute(const GoPlannerScreen(), settings);
      case goTax:
        return _buildRoute(const GoTaxScreen(), settings);
      case goReports:
        return _buildRoute(const GoReportsScreen(), settings);
      case goSecurity:
        return _buildRoute(const GoSecurityScreen(), settings);
      case goIntegrations:
        return _buildRoute(const GoIntegrationsScreen(), settings);
      case goArchive:
        return _buildRoute(const GoArchiveScreen(), settings);
      case goFinancial:
        return _buildRoute(const GoFinancialScreen(), settings);

      default:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
