/// ═══════════════════════════════════════════════════════════════════════════
/// Fulfillment Service — Flutter ↔ Backend Integration
///
/// Maps to FulfillmentController endpoints:
///   POST /fulfillment/rules
///   GET  /fulfillment/rules/{entityId}
///   PUT  /fulfillment/rules/{id}
///   DELETE /fulfillment/rules/{id}
///   GET  /fulfillment/tasks/{entityId}
///   POST /fulfillment/tasks
///   GET  /fulfillment/tasks/{id}/detail
/// ═══════════════════════════════════════════════════════════════════════════
library;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class FulfillmentService {
  final ApiClient _api;

  FulfillmentService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Rules ────────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> createRule(
    Map<String, dynamic> data,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.fulfillment.rules,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> listRules(String entityId) {
    return _api.get<List<dynamic>>(
      ApiRoutes.fulfillment.listRules(entityId),
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateRule(
    String id,
    Map<String, dynamic> updates,
  ) {
    return _api.put<Map<String, dynamic>>(
      '/fulfillment/rules/$id',
      data: updates,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> deleteRule(String id) {
    return _api.delete<void>(ApiRoutes.fulfillment.deleteRule(id));
  }

  // ─── Tasks ────────────────────────────────────────────────────────────────

  Future<ApiResponse<List<dynamic>>> listTasks(
    String entityId, {
    String? status,
  }) {
    return _api.get<List<dynamic>>(
      ApiRoutes.fulfillment.listTasks(entityId),
      queryParameters: {
        if (status != null) 'status': status,
      },
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> dispatchTask(
    String entityId, {
    String? orderId,
    String? overrideProvider,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.fulfillment.tasks,
      data: {
        'entityId': entityId,
        if (orderId != null) 'orderId': orderId,
        if (overrideProvider != null) 'overrideProvider': overrideProvider,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTask(String id) {
    return _api.get<Map<String, dynamic>>(
      '/fulfillment/tasks/$id/detail',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
