/// ═══════════════════════════════════════════════════════════════════════════
/// GO Service — Flutter ↔ Backend Integration
///
/// Maps to GoController endpoints:
///   GET  /go/wallet
///   GET  /go/transactions
///   GET  /go/transactions/{id}
///   POST /go/topup
/// ═══════════════════════════════════════════════════════════════════════════
library;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class GoService {
  final ApiClient _api;

  GoService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Wallet ───────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> getWalletSummary() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.go.wallet,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Transactions ─────────────────────────────────────────────────────────

  Future<ApiResponse<List<dynamic>>> getTransactions({
    String? type,
    String? category,
    int limit = 20,
    int offset = 0,
  }) {
    return _api.get<List<dynamic>>(
      ApiRoutes.go.transactions,
      queryParameters: {
        if (type != null) 'type': type,
        if (category != null) 'category': category,
        'limit': limit,
        'offset': offset,
      },
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTransactionById(String id) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.go.transactionById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Top-Up ───────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> topUp(
    double amount, {
    String? description,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.go.topup,
      data: {
        'amount': amount,
        if (description != null) 'description': description,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
