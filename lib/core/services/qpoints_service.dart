import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for QPoints wallet operations.
/// Maps to backend QPointsController.
class QPointsService {
  final ApiClient _api;

  QPointsService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Deposit QPoints into wallet.
  /// accountId is resolved server-side from the authenticated user's JWT.
  Future<ApiResponse<Map<String, dynamic>>> deposit({
    required double amount,
    required String description,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpoints.deposit,
      data: {
        'amount': amount,
        'description': description,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Transfer QPoints to another user.
  /// Source account is resolved from JWT; destination resolved from toUserId.
  Future<ApiResponse<Map<String, dynamic>>> transfer({
    required String toUserId,
    required double amount,
    required String description,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpoints.transfer,
      data: {
        'toUserId': toUserId,
        'amount': amount,
        'description': description,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Withdraw QPoints from wallet.
  /// accountId is resolved server-side from the authenticated user's JWT.
  Future<ApiResponse<Map<String, dynamic>>> withdraw({
    required double amount,
    required String description,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpoints.withdraw,
      data: {
        'amount': amount,
        'description': description,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get paginated transaction history.
  Future<ApiResponse<List<Map<String, dynamic>>>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.qpoints.transactions,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Review a flagged fraud transaction.
  Future<ApiResponse<Map<String, dynamic>>> reviewFraud({
    required String transactionId,
    required String status,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.qpoints.reviewFraud,
      data: {
        'transactionId': transactionId,
        'status': status,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
