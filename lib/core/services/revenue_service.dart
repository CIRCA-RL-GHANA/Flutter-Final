import '../network/api_client.dart';
import '../network/api_response.dart';

/// Platform revenue analytics service.
/// Maps to GET /admin/revenue/* (ADMIN role) and
/// GET /admin/revenue/entities/:entityId/my-fees (ENTERPRISE_ADMIN, FI, FI_AUDITOR).
class RevenueService {
  final ApiClient _api;

  RevenueService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Platform-wide revenue stats  ADMIN only.
  Future<ApiResponse<Map<String, dynamic>>> getPlatformStats() {
    return _api.get<Map<String, dynamic>>(
      '/admin/revenue/stats',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Per-entity monthly fee counters  ADMIN view.
  Future<ApiResponse<Map<String, dynamic>>> getEntityFees(
    String entityId, {
    String? month, // YYYY-MM format
  }) {
    return _api.get<Map<String, dynamic>>(
      '/admin/revenue/entities/$entityId/transaction-fees',
      queryParameters: {
        if (month != null) 'month': month,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Self-service fee view  ENTERPRISE_ADMIN / FI owners see their own fees.
  Future<ApiResponse<Map<String, dynamic>>> getMyFees(
    String entityId, {
    String? month,
  }) {
    return _api.get<Map<String, dynamic>>(
      '/admin/revenue/entities/$entityId/my-fees',
      queryParameters: {
        if (month != null) 'month': month,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
