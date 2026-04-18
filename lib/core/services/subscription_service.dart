import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';
import 'ai_service.dart';

/// Service for subscription and plan management.
/// Maps to backend SubscriptionsController.
/// Extends basic subscription CRUD with AI-powered plan recommendations.
class SubscriptionService {
  final ApiClient _api;
  final AIService _aiService;

  SubscriptionService([ApiClient? api, AIService? aiService])
      : _api = api ?? ApiClient.instance,
        _aiService = aiService ?? AIService();

  /// Get all available subscription plans.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPlans() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.subscriptions.plans,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a single subscription plan by ID.
  Future<ApiResponse<Map<String, dynamic>>> getPlanById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.subscriptions.planById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Activate a subscription for a target.
  ///
  /// [staffCount] is required for per-staff billing (4 QP × staffCount for Basic, etc.).
  /// [entityId]   is the business entity whose Q Points account is debited.
  Future<ApiResponse<Map<String, dynamic>>> activateSubscription({
    required String planId,
    required String targetType,
    required String targetId,
    required String entityId,
    int staffCount = 1,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.subscriptions.activate,
      data: {
        'planId': planId,
        'targetType': targetType,
        'targetId': targetId,
        'entityId': entityId,
        'staffCount': staffCount,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get the active subscription for a target.
  Future<ApiResponse<Map<String, dynamic>>> getActiveSubscription({
    required String targetType,
    required String targetId,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.subscriptions.active(targetType, targetId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Cancel a subscription.
  Future<ApiResponse<Map<String, dynamic>>> cancelSubscription({
    required String id,
    String? reason,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.subscriptions.cancel(id),
      data: {
        if (reason != null) 'reason': reason,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Renew the current subscription.
  Future<ApiResponse<Map<String, dynamic>>> renewSubscription() async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.subscriptions.renew,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create a new subscription plan.
  Future<ApiResponse<Map<String, dynamic>>> createPlan(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.subscriptions.plans,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a subscription plan.
  Future<ApiResponse<Map<String, dynamic>>> updatePlan(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.subscriptions.planById(id),
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete a subscription plan.
  Future<ApiResponse<Map<String, dynamic>>> deletePlan(String id) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.subscriptions.deletePlan(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AI-ENHANCED METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Get AI-recommended subscription plan based on user usage patterns.
  /// Returns the best-fit plan with explanation.
  Future<ApiResponse<Map<String, dynamic>>> getAIRecommendedPlan({
    required double usageScore,
    required String currentTier,
  }) async {
    final plansResp = await getPlans();
    if (!plansResp.isSuccess || plansResp.data == null) {
      return ApiResponse.failure('Unable to fetch plans for AI analysis');
    }
    return _aiService.recommendSubscriptionPlan(
      usageScore: usageScore,
      currentTier: currentTier,
      plans: plansResp.data!,
    );
  }

  /// Get AI-powered retention offer for a subscriber at risk of churn.
  /// Analyzes subscription length, login activity, and feature usage.
  Future<ApiResponse<Map<String, dynamic>>> getAIRetentionOffer({
    required int monthsSubscribed,
    required int lastLoginDaysAgo,
    required double featureUsageScore,
    required double currentMonthlyPrice,
  }) {
    return _aiService.suggestRetentionOffer(
      monthsSubscribed: monthsSubscribed,
      lastLoginDaysAgo: lastLoginDaysAgo,
      featureUsageScore: featureUsageScore,
      currentMonthlyPrice: currentMonthlyPrice,
    );
  }

  /// Analyze cancellation reason using AI NLP.
  /// Returns sentiment, intent, and key issues for product improvement.
  Future<ApiResponse<Map<String, dynamic>>> analyzeCancellationReason(
    String reason,
  ) {
    return _aiService.detectIntent(reason);
  }
}
