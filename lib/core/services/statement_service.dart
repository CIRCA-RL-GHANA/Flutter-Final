import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for personal statement management.
/// Maps to backend StatementController.
class StatementService {
  final ApiClient _api;

  StatementService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Create or update the user's statement.
  Future<ApiResponse<Map<String, dynamic>>> createOrUpdateStatement(
    Map<String, dynamic> data,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.statement.base,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get the current user's statement.
  Future<ApiResponse<Map<String, dynamic>>> getStatement() async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.statement.base,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update the user's statement.
  Future<ApiResponse<Map<String, dynamic>>> updateStatement(
    Map<String, dynamic> data,
  ) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.statement.base,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Delete the user's statement.
  Future<ApiResponse<Map<String, dynamic>>> deleteStatement() async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.statement.base,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Check if the user has a statement.
  Future<ApiResponse<Map<String, dynamic>>> hasStatement() async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.statement.exists,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Provider-facing convenience methods ─────────────────────────────────

  /// Create or update statement from plain content string.
  Future<ApiResponse<Map<String, dynamic>>> createOrUpdate(
    String content,
  ) =>
      createOrUpdateStatement({'content': content});

  /// Replace statement via PUT with plain content string.
  Future<ApiResponse<Map<String, dynamic>>> replaceStatement(
    String content,
  ) {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.statement.base,
      data: {'content': content},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
