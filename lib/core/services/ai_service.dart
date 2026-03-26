import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for AI model inference and recommendations.
/// Maps to backend AIController.
class AIService {
  final ApiClient _api;

  AIService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Get all available AI models.
  Future<ApiResponse<List<Map<String, dynamic>>>> getModels() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.models,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a single AI model by ID.
  Future<ApiResponse<Map<String, dynamic>>> getModelById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.ai.modelById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create an inference request.
  Future<ApiResponse<Map<String, dynamic>>> createInference({
    required String modelId,
    required Map<String, dynamic> inputData,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.inferences,
      data: {
        'modelId': modelId,
        'inputData': inputData,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get paginated list of inferences.
  Future<ApiResponse<List<Map<String, dynamic>>>> getInferences({
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.inferences,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get AI-powered recommendations.
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendations() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.recommendations,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get AI features for a specific entity.
  Future<ApiResponse<Map<String, dynamic>>> getFeatures({
    required String entityType,
    required String entityId,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.ai.features(entityType, entityId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get available AI workflows.
  Future<ApiResponse<List<Map<String, dynamic>>>> getWorkflows() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.workflows,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create an AI event.
  Future<ApiResponse<Map<String, dynamic>>> createEvent({
    required String eventType,
    required Map<String, dynamic> payload,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.events,
      data: {
        'eventType': eventType,
        'payload': payload,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update an AI model.
  Future<ApiResponse<Map<String, dynamic>>> updateModel(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.ai.updateModel(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update AI model status.
  Future<ApiResponse<Map<String, dynamic>>> updateModelStatus({
    required String id,
    required String status,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.ai.updateModelStatus(id),
      data: {'status': status},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get model statistics.
  Future<ApiResponse<Map<String, dynamic>>> getModelStats(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.ai.modelStats(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get inferences by model ID.
  Future<ApiResponse<List<Map<String, dynamic>>>> getInferencesByModel(
    String modelId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.inferencesByModel(modelId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get inferences by entity.
  Future<ApiResponse<List<Map<String, dynamic>>>> getInferencesByEntity({
    required String entityType,
    required String entityId,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.inferencesByEntity(entityType, entityId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Mark a recommendation as viewed.
  Future<ApiResponse<Map<String, dynamic>>> markRecommendationViewed(
    String id,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.ai.recommendationView(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Mark a recommendation as clicked.
  Future<ApiResponse<Map<String, dynamic>>> markRecommendationClicked(
    String id,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.ai.recommendationClick(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Mark a recommendation as converted.
  Future<ApiResponse<Map<String, dynamic>>> markRecommendationConverted(
    String id,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.ai.recommendationConvert(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get recommendations for a specific entity.
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendationsForEntity({
    required String entityType,
    required String entityId,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.recommendationsForEntity(entityType, entityId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a workflow by ID.
  Future<ApiResponse<Map<String, dynamic>>> getWorkflowById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.ai.workflowById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get unprocessed AI events.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUnprocessedEvents() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.unprocessedEvents,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Process an AI event.
  Future<ApiResponse<Map<String, dynamic>>> processEvent(String id) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.ai.processEvent(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get events by entity.
  Future<ApiResponse<List<Map<String, dynamic>>>> getEventsByEntity({
    required String entityType,
    required String entityId,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.eventsByEntity(entityType, entityId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Create a new AI model.
  Future<ApiResponse<Map<String, dynamic>>> createModel(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.models,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update model metrics.
  Future<ApiResponse<Map<String, dynamic>>> updateModelMetrics({
    required String id,
    required Map<String, dynamic> metrics,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.ai.modelMetrics(id),
      data: metrics,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get inferences for a specific user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserInferences(
    String userId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.userInferences(userId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a specific feature by name for an entity.
  Future<ApiResponse<Map<String, dynamic>>> getFeatureByName({
    required String entityType,
    required String entityId,
    required String featureName,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.ai.featureByName(entityType, entityId, featureName),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Generate recommendations.
  Future<ApiResponse<Map<String, dynamic>>> generateRecommendations(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.recommendations,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get recommendation stats for a user.
  Future<ApiResponse<Map<String, dynamic>>> getRecommendationStats(
    String userId,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.ai.recommendationStats(userId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create a new AI workflow.
  Future<ApiResponse<Map<String, dynamic>>> createWorkflow(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.workflows,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get events for a specific user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserEvents(
    String userId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.userEvents(userId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NLP
  // ═══════════════════════════════════════════════════════════════════════

  /// Analyse sentiment of [text]. Returns score (-1→+1), label, confidence.
  Future<ApiResponse<Map<String, dynamic>>> analyzeSentiment(String text) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.sentiment,
      data: {'text': text},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Detect intent & extract entities from [text].
  Future<ApiResponse<Map<String, dynamic>>> detectIntent(String text) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.intent,
      data: {'text': text},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Extract top keywords from [text].
  Future<ApiResponse<Map<String, dynamic>>> extractKeywords(
    String text, {
    int topN = 10,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.keywords,
      data: {'text': text, 'topN': topN},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Summarise [text] and extract key sentences and keywords.
  Future<ApiResponse<Map<String, dynamic>>> summariseText(String text) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.summarise,
      data: {'text': text},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Compute cosine similarity (0–1) between [text1] and [text2].
  Future<ApiResponse<Map<String, dynamic>>> textSimilarity(
    String text1,
    String text2,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.similarity,
      data: {'text1': text1, 'text2': text2},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// TF-IDF ranked semantic search over [documents] using [query].
  Future<ApiResponse<List<Map<String, dynamic>>>> semanticSearch({
    required String query,
    required List<Map<String, String>> documents,
    int topN = 10,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.semanticSearch,
      data: {'query': query, 'documents': documents, 'topN': topN},
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DYNAMIC PRICING
  // ═══════════════════════════════════════════════════════════════════════

  /// Get AI-powered dynamic ride price with surge multiplier.
  Future<ApiResponse<Map<String, dynamic>>> computeRidePrice({
    required double baseDistance,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String? rideType,
    double demandFactor = 1.0,
    double supplyFactor = 1.0,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.ridePrice,
      data: {
        'baseDistance':  baseDistance,
        'pickupLat':     pickupLat,
        'pickupLng':     pickupLng,
        'dropoffLat':    dropoffLat,
        'dropoffLng':    dropoffLng,
        if (rideType != null) 'rideType': rideType,
        'demandFactor':  demandFactor,
        'supplyFactor':  supplyFactor,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get AI discount recommendation for a product.
  Future<ApiResponse<Map<String, dynamic>>> recommendDiscount({
    required double currentPrice,
    required int daysSinceLastSale,
    required int viewCount,
    required double conversionRate,
    required int stockLevel,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.discountAdvice,
      data: {
        'currentPrice':      currentPrice,
        'daysSinceLastSale': daysSinceLastSale,
        'viewCount':         viewCount,
        'conversionRate':    conversionRate,
        'stockLevel':        stockLevel,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get subscription retention discount offer.
  Future<ApiResponse<Map<String, dynamic>>> suggestRetentionOffer({
    required int monthsSubscribed,
    required int lastLoginDaysAgo,
    required double featureUsageScore,
    required double currentMonthlyPrice,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.retentionOffer,
      data: {
        'monthsSubscribed':    monthsSubscribed,
        'lastLoginDaysAgo':    lastLoginDaysAgo,
        'featureUsageScore':   featureUsageScore,
        'currentMonthlyPrice': currentMonthlyPrice,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FRAUD DETECTION
  // ═══════════════════════════════════════════════════════════════════════

  /// Score a transaction for fraud risk. Returns riskScore (0–1) and signals.
  Future<ApiResponse<Map<String, dynamic>>> scoreFraud({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    List<double>? recentAmounts,
    int? recentCountInHour,
    double? avgHistoricAmount,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.fraudScore,
      data: {
        'userId':           userId,
        'amount':           amount,
        'currency':         currency,
        'paymentMethod':    paymentMethod,
        if (recentAmounts != null)      'recentAmounts':      recentAmounts,
        if (recentCountInHour != null)  'recentCountInHour':  recentCountInHour,
        if (avgHistoricAmount != null)  'avgHistoricAmount':  avgHistoricAmount,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FINANCIAL INSIGHTS
  // ═══════════════════════════════════════════════════════════════════════

  /// Get AI financial insights based on income/expense transactions.
  Future<ApiResponse<List<Map<String, dynamic>>>> getFinancialInsights({
    required List<Map<String, dynamic>> incomeTransactions,
    required List<Map<String, dynamic>> expenseTransactions,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.financialInsights,
      data: {
        'incomeTransactions':  incomeTransactions,
        'expenseTransactions': expenseTransactions,
      },
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Get AI spending pattern analysis.
  Future<ApiResponse<Map<String, dynamic>>> getSpendingPattern(
    List<Map<String, dynamic>> transactions,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.spendingPattern,
      data: {'transactions': transactions},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get AI revenue forecast for next 7 and 30 days.
  Future<ApiResponse<Map<String, dynamic>>> getRevenueForecast(
    List<Map<String, dynamic>> dailySales,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.revenueForecast,
      data: {'dailySales': dailySales},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Collaborative filtering — personalised item recommendations.
  Future<ApiResponse<List<Map<String, dynamic>>>> collaborativeFilter({
    required Map<String, double> targetVector,
    required Map<String, Map<String, double>> allVectors,
    int topN = 10,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.collaborativeFilter,
      data: {
        'targetVector': targetVector,
        'allVectors':   allVectors,
        'topN':         topN,
      },
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PLANNER AI SHORTCUTS
  // ═══════════════════════════════════════════════════════════════════════

  /// Get AI financial insights for the authenticated user's planner data.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPlannerInsights() {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.ai.plannerInsights,
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Get AI spending pattern from planner data.
  Future<ApiResponse<Map<String, dynamic>>> getPlannerSpending() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.ai.plannerSpending,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get AI income forecast from planner data.
  Future<ApiResponse<Map<String, dynamic>>> getPlannerForecast() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.ai.plannerForecast,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Semantic Search ────────────────────────────────────────────────────────

  /// Cross-entity semantic search over a list of documents.
  Future<ApiResponse<List<Map<String, dynamic>>>> searchDocuments({
    required String query,
    required List<Map<String, dynamic>> documents,
    int topN = 20,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.searchDocuments,
      data: {'query': query, 'documents': documents, 'topN': topN},
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Re-rank pre-fetched candidates by cosine similarity to query.
  Future<ApiResponse<List<Map<String, dynamic>>>> rankCandidates({
    required String query,
    required List<Map<String, dynamic>> candidates,
    int topN = 20,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.searchRank,
      data: {'query': query, 'candidates': candidates, 'topN': topN},
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Get autocomplete keyword suggestions from a partial query.
  Future<ApiResponse<Map<String, dynamic>>> searchSuggest(String query) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.searchSuggest,
      data: {'query': query},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Recommendations ────────────────────────────────────────────────────────

  /// Content-based: find items similar to a target (by tags text).
  Future<ApiResponse<List<Map<String, dynamic>>>> getSimilarItems({
    required String targetTags,
    required List<Map<String, dynamic>> catalogueItems,
    int topN = 10,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.similarItems,
      data: {'targetTags': targetTags, 'catalogueItems': catalogueItems, 'topN': topN},
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Personalised product recommendations based on purchase history text.
  Future<ApiResponse<List<Map<String, dynamic>>>> getProductRecommendations({
    required String purchasedTexts,
    required List<Map<String, dynamic>> catalogueItems,
    int topN = 10,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.productRecommendations,
      data: {
        'purchasedTexts': purchasedTexts,
        'catalogueItems': catalogueItems,
        'topN':           topN,
      },
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Personalised feed ranking based on user interest text.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPersonalizedFeed({
    required String interestText,
    required List<Map<String, dynamic>> contentItems,
    int topN = 20,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.personalizedFeed,
      data: {'interestText': interestText, 'contentItems': contentItems, 'topN': topN},
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Blend collaborative + content-based recommendation lists.
  Future<ApiResponse<List<Map<String, dynamic>>>> blendRecommendations({
    required List<Map<String, dynamic>> collaborative,
    required List<Map<String, dynamic>> contentBased,
    int topN = 10,
  }) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.blendRecommendations,
      data: {
        'collaborative': collaborative,
        'contentBased':  contentBased,
        'topN':          topN,
      },
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Recommend best subscription plan for a user.
  Future<ApiResponse<Map<String, dynamic>>> recommendSubscriptionPlan({
    required double usageScore,
    required String currentTier,
    required List<Map<String, dynamic>> plans,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.ai.subscriptionPlanReco,
      data: {
        'usageScore':  usageScore,
        'currentTier': currentTier,
        'plans':       plans,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Score wishlist items by purchase conversion likelihood.
  Future<ApiResponse<List<Map<String, dynamic>>>> scoreWishlistItems(
    List<Map<String, dynamic>> items,
  ) {
    return _api.post<List<Map<String, dynamic>>>(
      ApiRoutes.ai.wishlistScores,
      data: {'items': items},
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }
}
