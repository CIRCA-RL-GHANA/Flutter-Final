/// ═══════════════════════════════════════════════════════════════════════════
/// Subscriptions Service — Flutter ↔ Backend Integration
///
/// Maps to SubscriptionsController endpoints:
///   GET   /subscriptions/plans
///   GET   /subscriptions/plans/{id}
///   POST  /subscriptions/activate
///   GET   /subscriptions/active/{targetType}/{targetId}
///   PATCH /subscriptions/{id}/cancel
/// ═══════════════════════════════════════════════════════════════════════════
library;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class SubscriptionsService {
  final ApiClient _api;

  SubscriptionsService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Plans ────────────────────────────────────────────────────────────────

  Future<ApiResponse<List<dynamic>>> getPlans() {
    return _api.get<List<dynamic>>(
      ApiRoutes.subscriptions.plans,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getPlanById(String id) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.subscriptions.planById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Subscriptions ────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> activateSubscription(
    String planId,
    String targetType,
    String targetId,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.subscriptions.activate,
      data: {'planId': planId, 'targetType': targetType, 'targetId': targetId},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getActiveSubscription(
    String targetType,
    String targetId,
  ) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.subscriptions.active(targetType, targetId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> cancelSubscription(
    String id, {
    String? reason,
  }) {
    return _api.patch<void>(
      ApiRoutes.subscriptions.cancel(id),
      data: {
        if (reason != null) 'reason': reason,
      },
    );
  }
}
