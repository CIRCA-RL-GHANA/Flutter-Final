/// Centralized API route constants for the Flutter app.
/// These MUST match the backend controller routes exactly.
///
/// Base URL format: {host}/api/v1/{route}
class ApiRoutes {
  ApiRoutes._();

  static const auth = _AuthRoutes();
  static const users = _UserRoutes();
  static const profiles = _ProfileRoutes();
  static const entities = _EntityRoutes();
  static const qpoints = _QPointRoutes();
  static const products = _ProductRoutes();
  static const orders = _OrderRoutes();
  static const vehicles = _VehicleRoutes();
  static const rides = _RideRoutes();
  static const social = _SocialRoutes();
  static const calendar = _CalendarRoutes();
  static const planner = _PlannerRoutes();
  static const statement = _StatementRoutes();
  static const wishlist = _WishlistRoutes();
  static const interests = _InterestRoutes();
  static const places = _PlaceRoutes();
  static const subscriptions = _SubscriptionRoutes();
  static const ai = _AIRoutes();
  static const health = _HealthRoutes();
  static const entityProfiles = _EntityProfileRoutes();
  static const favoriteDrivers = _FavoriteDriverRoutes();
  static const marketProfiles = _MarketProfileRoutes();
  static const wallets = _WalletRoutes();
  static const payments = _PaymentRoutes();
  static const go = _GoRoutes();
}

class _AuthRoutes {
  const _AuthRoutes();
  String get login => '/auth/login';
  String get logout => '/auth/logout';
  String get refresh => '/auth/refresh';
  String get me => '/auth/me';
}

class _UserRoutes {
  const _UserRoutes();
  String get register => '/users/register';
  String get verifyOtp => '/users/verify-otp';
  String get verifyBiometric => '/users/verify-biometric';
  String get setPin => '/users/set-pin';
  String get assignStaff => '/users/staff/assign';
  String get checkPhone => '/users/check-phone';
  String get resendOtp => '/users/resend-otp';
  String byId(String id) => '/users/$id';
  String checkUsername(String username) => '/users/check-username/$username';
}

class _ProfileRoutes {
  const _ProfileRoutes();
  String get create => '/profiles';
  String byId(String id) => '/profiles/$id';
  String byUser(String userId) => '/profiles/user/$userId';
  String byEntity(String entityId) => '/profiles/entity/$entityId';
  String visibility(String profileId) => '/profiles/$profileId/visibility';
  String interaction(String profileId) =>
      '/profiles/$profileId/interaction-preferences';
}

class _EntityRoutes {
  const _EntityRoutes();
  String get createIndividual => '/entities/individual';
  String get createOther => '/entities/other';
  String get createBranches => '/entities/branches';
  String byId(String id) => '/entities/$id';
  String byOwner(String ownerId) => '/entities/owner/$ownerId';
  String branches(String entityId) => '/entities/$entityId/branches';
}

class _QPointRoutes {
  const _QPointRoutes();
  String get deposit => '/qpoints/transactions/deposit';
  String get transfer => '/qpoints/transactions/transfer';
  String get withdraw => '/qpoints/transactions/withdraw';
  String get transactions => '/qpoints/transactions';
  String get reviewFraud => '/qpoints/transactions/review-fraud';
}

class _ProductRoutes {
  const _ProductRoutes();
  String get create => '/products';
  String get list => '/products';
  String get search => '/products/search';
  String byId(String id) => '/products/$id';
  String updateStock(String id) => '/products/$id/stock';
  String view(String id) => '/products/$id/view';
  String rate(String id) => '/products/$id/rating';
  String get media => '/products/media';
  String mediaByProduct(String productId) => '/products/$productId/media';
  String get discounts => '/products/discounts';
  String activeDiscounts(String productId) =>
      '/products/$productId/active-discounts';
  String get deliveryZones => '/products/delivery-zones';
  String get sos => '/products/sos';
  String byEntity(String entityId) => '/products/entity/$entityId';
  String deleteMedia(String id) => '/products/media/$id';
  String discountById(String id) => '/products/discounts/$id';
  String resolveSOS(String id) => '/products/sos/$id/resolve';
  String cancelSOS(String id) => '/products/sos/$id/cancel';
  String deliveryZoneById(String id) => '/products/delivery-zones/$id';
  String deliveryZonesByProduct(String productId) =>
      '/products/delivery-zones/product/$productId';
  String get findDeliveryZoneByLocation => '/products/delivery-zones/find-by-location';
}

class _OrderRoutes {
  const _OrderRoutes();
  String get create => '/orders';
  String byId(String id) => '/orders/$id';
  String byUser(String userId) => '/orders/user/$userId';
  String items(String id) => '/orders/$id/items';
  String updateStatus(String id) => '/orders/$id/status';
  String startFulfillment(String id) => '/orders/$id/fulfillment/start';
  String completeFulfillment(String sessionId) =>
      '/orders/fulfillment/$sessionId/complete';
  String get returns => '/orders/returns';
  String returnStatus(String id) => '/orders/returns/$id/status';
  String returnsByUser(String userId) => '/orders/returns/user/$userId';
  String delivery(String id) => '/orders/$id/delivery';
  String deliveryStatus(String id) => '/orders/deliveries/$id/status';
  String deliveriesByDriver(String driverId) =>
      '/orders/deliveries/driver/$driverId';
  String get packages => '/orders/packages';
  String packagesByDriver(String driverId) =>
      '/orders/packages/driver/$driverId';
}

class _VehicleRoutes {
  const _VehicleRoutes();
  String get create => '/vehicles';
  String get list => '/vehicles';
  String byId(String id) => '/vehicles/$id';
  String byPlate(String plateNumber) => '/vehicles/plate/$plateNumber';
  String updateStatus(String id) => '/vehicles/$id/status';
  String get bands => '/vehicles/bands';
  String bandById(String id) => '/vehicles/bands/$id';
  String get createBand => '/vehicles/bands';
  String get assignments => '/vehicles/assignments';
  String assignmentById(String id) => '/vehicles/assignments/$id';
  String get media => '/vehicles/media';
  String mediaByVehicle(String vehicleId) => '/vehicles/$vehicleId/media';
  String deleteMedia(String id) => '/vehicles/media/$id';
  String get pricing => '/vehicles/pricing';
  String pricingById(String id) => '/vehicles/pricing/$id';
  String get calculateWaitCharge => '/vehicles/pricing/calculate-wait-charge';
  String get bandMemberships => '/vehicles/bands/memberships';
  String bandMembershipById(String id) => '/vehicles/bands/memberships/$id';
  String vehiclesByBand(String bandId) => '/vehicles/bands/$bandId/vehicles';
  String vehicleBands(String vehicleId) => '/vehicles/$vehicleId/bands';
  String endAssignment(String id) => '/vehicles/assignments/$id/end';
  String driverActiveAssignment(String driverId) =>
      '/vehicles/drivers/$driverId/active-assignment';
  String vehicleActiveAssignment(String vehicleId) =>
      '/vehicles/$vehicleId/active-assignment';
}

class _RideRoutes {
  const _RideRoutes();
  String get create => '/rides';
  String byId(String id) => '/rides/$id';
  String byUser(String userId) => '/rides/user/$userId';
  String assignDriver(String id) => '/rides/$id/assign-driver';
  String updateStatus(String id) => '/rides/$id/status';
  String verifyRiderPin(String id) => '/rides/$id/verify-rider-pin';
  String verifyDriverPin(String id) => '/rides/$id/verify-driver-pin';
  String track(String id) => '/rides/$id/track';
  String tracking(String id) => '/rides/$id/tracking';
  String get feedback => '/rides/feedback';
  String feedbackByRide(String id) => '/rides/$id/feedback';
  String get referrals => '/rides/referrals';
  String get sos => '/rides/sos';
  String get waitTimeStart => '/rides/wait-time/start';
  String waitTimeEnd(String id) => '/rides/wait-time/$id/end';
  String completeReferral(String id) => '/rides/referrals/$id/complete';
  String resolveSOS(String id) => '/rides/sos/$id/resolve';
}

class _SocialRoutes {
  const _SocialRoutes();
  String get heyya => '/social/heyya';
  String heyyaRespond(String id) => '/social/heyya/$id/respond';
  String get chatSessions => '/social/chat/sessions';
  String get chatMessages => '/social/chat/messages';
  String sessionMessages(String sessionId) =>
      '/social/chat/sessions/$sessionId/messages';
  String markRead(String sessionId) =>
      '/social/chat/sessions/$sessionId/read';
  String get updates => '/social/updates';
  String updateById(String id) => '/social/updates/$id';
  String get comments => '/social/comments';
  String commentsByUpdate(String updateId) =>
      '/social/updates/$updateId/comments';
  String get engagements => '/social/engagements';
  String userEngagements(String userId) => '/social/users/$userId/engagements';
  String commentById(String id) => '/social/comments/$id';
}

class _CalendarRoutes {
  const _CalendarRoutes();
  String get create => '/calendar';
  String get list => '/calendar';
  String byId(String id) => '/calendar/$id';
  String get upcoming => '/calendar/upcoming';
  String get recurring => '/calendar/recurring';
  String get dateRange => '/calendar/date-range';
}

class _PlannerRoutes {
  const _PlannerRoutes();
  String get transactions => '/planner/transactions';
  String transactionById(String id) => '/planner/transactions/$id';
  String byType(String type) => '/planner/transactions/type/$type';
  String get monthly => '/planner/transactions/month';
  String get summary => '/planner/summary';
  String get monthlySummary => '/planner/summary/monthly';
}

class _StatementRoutes {
  const _StatementRoutes();
  String get base => '/statement';
  String get exists => '/statement/exists';
}

class _WishlistRoutes {
  const _WishlistRoutes();
  String get create => '/wishlist';
  String get list => '/wishlist';
  String byId(String id) => '/wishlist/$id';
  String byStatus(String status) => '/wishlist/status/$status';
  String byCategory(String category) => '/wishlist/category/$category';
  String get highPriority => '/wishlist/high-priority';
  String get totalValue => '/wishlist/total-value';
  String purchase(String id) => '/wishlist/$id/purchase';
  String updateStatus(String id, String status) =>
      '/wishlist/$id/status/$status';
}

class _InterestRoutes {
  const _InterestRoutes();
  String get favoriteShops => '/interests/favorite-shops';
  String favoriteShopsByEntity(String entityId) =>
      '/interests/favorite-shops/$entityId';
  String get interests => '/interests/interests';
  String interestsByOwner(String ownerId) =>
      '/interests/interests/$ownerId';
  String get connectionRequests => '/interests/connection-requests';
  String connectionRequestById(String id) =>
      '/interests/connection-requests/$id';
  String sentRequests(String senderId) =>
      '/interests/connection-requests/sent/$senderId';
  String receivedRequests(String receiverId) =>
      '/interests/connection-requests/received/$receiverId';
  String connections(String userId) => '/interests/connections/$userId';
  String respondToRequest(String id) =>
      '/interests/connection-requests/$id/respond';
  String blockRequest(String id) =>
      '/interests/connection-requests/$id/block';
  String get interestCategories => '/interests/interests/categories';
  String interestDetail(String id) => '/interests/interests/detail/$id';
  String cancelConnectionRequest(String id) =>
      '/interests/connection-requests/$id';
}

class _PlaceRoutes {
  const _PlaceRoutes();
  String get create => '/places';
  String get list => '/places';
  String get search => '/places/search';
  String byCategory(String category) => '/places/category/$category';
  String get nearby => '/places/nearby';
  String byId(String id) => '/places/$id';
  String verify(String id) => '/places/$id/verify';
  String rate(String id) => '/places/$id/rate';
  String byEntity(String entityId) => '/places/entity/$entityId';
  String ratings(String id) => '/places/$id/ratings';
  String byUniqueId(String uniqueId) => '/places/unique/$uniqueId';
}

class _SubscriptionRoutes {
  const _SubscriptionRoutes();
  String get plans => '/subscriptions/plans';
  String planById(String id) => '/subscriptions/plans/$id';
  String get activate => '/subscriptions/activate';
  String active(String targetType, String targetId) =>
      '/subscriptions/active/$targetType/$targetId';
  String cancel(String id) => '/subscriptions/$id/cancel';
  String get renew => '/subscriptions/renew';
  String deletePlan(String id) => '/subscriptions/plans/$id';
}

class _AIRoutes {
  const _AIRoutes();
  String get models => '/ai/models';
  String modelById(String id) => '/ai/models/$id';
  String get inferences => '/ai/inferences';
  String inferenceById(String id) => '/ai/inferences/$id';
  String features(String entityType, String entityId) =>
      '/ai/features/$entityType/$entityId';
  String get recommendations => '/ai/recommendations';
  String get workflows => '/ai/workflows';
  String workflowById(String id) => '/ai/workflows/$id';
  String get events => '/ai/events';
  String updateModel(String id) => '/ai/models/$id';
  String updateModelStatus(String id) => '/ai/models/$id/status';
  String modelStats(String id) => '/ai/models/$id/stats';
  String inferencesByModel(String modelId) =>
      '/ai/inferences/model/$modelId';
  String inferencesByEntity(String entityType, String entityId) =>
      '/ai/inferences/entity/$entityType/$entityId';
  String recommendationView(String id) => '/ai/recommendations/$id/view';
  String recommendationClick(String id) => '/ai/recommendations/$id/click';
  String recommendationConvert(String id) => '/ai/recommendations/$id/convert';
  String recommendationsForEntity(String entityType, String entityId) =>
      '/ai/recommendations/entity/$entityType/$entityId';
  String get unprocessedEvents => '/ai/events/unprocessed';
  String processEvent(String id) => '/ai/events/$id/process';
  String eventsByEntity(String entityType, String entityId) =>
      '/ai/events/entity/$entityType/$entityId';
  String modelMetrics(String id) => '/ai/models/$id/metrics';
  String userInferences(String userId) => '/ai/inferences/user/$userId';
  String featureByName(String entityType, String entityId, String name) =>
      '/ai/features/$entityType/$entityId/$name';
  String recommendationStats(String userId) =>
      '/ai/recommendations/stats/$userId';
  String userEvents(String userId) => '/ai/events/user/$userId';

  // ── NLP endpoints ──────────────────────────────────────────────────────
  String get sentiment      => '/ai/nlp/sentiment';
  String get intent         => '/ai/nlp/intent';
  String get keywords       => '/ai/nlp/keywords';
  String get summarise      => '/ai/nlp/summarise';
  String get similarity     => '/ai/nlp/similarity';
  String get semanticSearch => '/ai/nlp/search';

  // ── Pricing endpoints ──────────────────────────────────────────────────
  String get ridePrice        => '/ai/pricing/ride';
  String get discountAdvice   => '/ai/pricing/discount';
  String get retentionOffer   => '/ai/pricing/retention';

  // ── Fraud endpoints ────────────────────────────────────────────────────
  String get fraudScore    => '/ai/fraud/score';
  String get fraudLocation => '/ai/fraud/location';

  // ── Insights endpoints ─────────────────────────────────────────────────
  String get financialInsights  => '/ai/insights/financials';
  String get spendingPattern    => '/ai/insights/spending-pattern';
  String get revenueForecast    => '/ai/insights/forecast';
  String get collaborativeFilter => '/ai/insights/collaborative-filter';

  // ── Planner AI shortcuts ───────────────────────────────────────────────
  String get plannerInsights       => '/planner/ai/insights';
  String get plannerSpending       => '/planner/ai/spending-pattern';
  String get plannerForecast       => '/planner/ai/forecast';

  // ── Semantic Search endpoints ──────────────────────────────────────────
  String get searchDocuments  => '/ai/search';
  String get searchRank       => '/ai/search/rank';
  String get searchSuggest    => '/ai/search/suggest';

  // ── Recommendation endpoints ───────────────────────────────────────────
  String get similarItems          => '/ai/recommendations/similar-items';
  String get productRecommendations => '/ai/recommendations/products';
  String get personalizedFeed      => '/ai/recommendations/feed';
  String get blendRecommendations  => '/ai/recommendations/blend';
  String get subscriptionPlanReco  => '/ai/recommendations/subscription';
  String get wishlistScores        => '/ai/recommendations/wishlist-score';

  // ── Wishlist AI shortcuts ──────────────────────────────────────────────
  String wishlistConversionScores(String userId) =>
      '/wishlist/$userId/ai/conversion-scores';

  // ── Subscription AI shortcuts ──────────────────────────────────────────
  String subscriptionRetentionOffer(String id) =>
      '/subscriptions/$id/ai/retention-offer';
  String get subscriptionPlanAdvice => '/subscriptions/ai/plan-advice';
}

class _HealthRoutes {
  const _HealthRoutes();
  String get check => '/health';
  String get ready => '/health/ready';
  String get live => '/health/live';
}

class _EntityProfileRoutes {
  const _EntityProfileRoutes();
  String get createSettings => '/entity-profiles/settings';
  String settings(String profileType, String profileId) =>
      '/entity-profiles/settings/$profileType/$profileId';
  String settingsById(String id) => '/entity-profiles/settings/$id';
  String get createOperatingHours => '/entity-profiles/operating-hours';
  String operatingHours(String profileType, String profileId) =>
      '/entity-profiles/operating-hours/$profileType/$profileId';
  String operatingHoursById(String id) => '/entity-profiles/operating-hours/$id';
  String get createCategory => '/entity-profiles/categories';
  String get categories => '/entity-profiles/categories';
  String categoryById(String id) => '/entity-profiles/categories/$id';
}

class _FavoriteDriverRoutes {
  const _FavoriteDriverRoutes();
  String get add => '/favorite-drivers';
  String get remove => '/favorite-drivers';
  String byEntity(String entityId) => '/favorite-drivers/entity/$entityId';
  String byId(String id) => '/favorite-drivers/$id';
  String get update => '/favorite-drivers/update';
  String check(String entityId, String driverId) =>
      '/favorite-drivers/check/$entityId/$driverId';
  String byDriver(String driverId) => '/favorite-drivers/driver/$driverId';
  String publicFavorites(String entityId) =>
      '/favorite-drivers/entity/$entityId/public';
  String get updateVisibility => '/favorite-drivers/visibility';
  String get updateRating => '/favorite-drivers/rating';
  String topRated(String entityId) =>
      '/favorite-drivers/entity/$entityId/top-rated';
}

class _MarketProfileRoutes {
  const _MarketProfileRoutes();
  String get create => '/market-profiles';
  String get list => '/market-profiles';
  String byId(String id) => '/market-profiles/$id';
  String aiSegmentation(String id) => '/market-profiles/$id/ai-segmentation';
  String get notifications => '/market-profiles/notifications/my-notifications';
  String markNotificationRead(String id) =>
      '/market-profiles/notifications/$id/read';
}

class _WalletRoutes {
  const _WalletRoutes();
  String get me      => '/wallets/me';
  String get balance => '/wallets/balance';
}

class _PaymentRoutes {
  const _PaymentRoutes();
  String get create       => '/payments';
  String refund(String id) => '/payments/$id/refund';
  String get history      => '/payments/history';
}

class _GoRoutes {
  const _GoRoutes();
  String get wallet          => '/go/wallet';
  String get transactions    => '/go/transactions';
  String transactionById(String id) => '/go/transactions/$id';
  String get topup           => '/go/topup';
}
