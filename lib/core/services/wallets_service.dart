/// 
/// Wallets Service  Flutter  Backend Integration
///
/// Maps to WalletsController endpoints:
///   GET /wallets/balance
///   GET /wallets/me
/// 
library;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class WalletsService {
  final ApiClient _api;

  WalletsService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  //  Wallet 

  Future<ApiResponse<Map<String, dynamic>>> getBalance() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.wallets.balance,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getWallet() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.wallets.me,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
