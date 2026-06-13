/// ═══════════════════════════════════════════════════════════════════════════
/// Interests Service — Flutter ↔ Backend Integration
///
/// Maps to InterestsController endpoints:
///   POST   /interests/favorite-shops
///   DELETE /interests/favorite-shops
///   GET    /interests/favorite-shops/{entityId}
///   POST   /interests/interests
///   DELETE /interests/interests
///   GET    /interests/interests/{ownerId}
///   POST   /interests/connection-requests
///   PATCH  /interests/connection-requests/{requestId}
///   GET    /interests/connection-requests/sent/{senderId}
///   GET    /interests/connection-requests/received/{receiverId}
///   DELETE /interests/connection-requests/{requestId}
///   PUT    /interests/connection-requests/{requestId}/block
///   GET    /interests/connections/{userId}
///   GET    /interests/interests/categories
/// ═══════════════════════════════════════════════════════════════════════════
library;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class InterestsService {
  final ApiClient _api;

  InterestsService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Favorite Shops ───────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> addFavoriteShop(
    String userId,
    String entityId,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.interests.favoriteShops,
      data: {'userId': userId, 'entityId': entityId},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> removeFavoriteShop(
    String userId,
    String entityId,
  ) {
    return _api.delete<void>(
      ApiRoutes.interests.favoriteShops,
      data: {'userId': userId, 'entityId': entityId},
    );
  }

  Future<ApiResponse<List<dynamic>>> listFavoriteShops(String entityId) {
    return _api.get<List<dynamic>>(
      ApiRoutes.interests.favoriteShopsByEntity(entityId),
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // ─── Interests ────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> addInterest(
    String userId,
    String targetId,
    String targetType,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.interests.interests,
      data: {'userId': userId, 'targetId': targetId, 'targetType': targetType},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> removeInterest(String userId, String targetId) {
    return _api.delete<void>(
      ApiRoutes.interests.interests,
      data: {'userId': userId, 'targetId': targetId},
    );
  }

  Future<ApiResponse<List<dynamic>>> listInterests(String ownerId) {
    return _api.get<List<dynamic>>(
      ApiRoutes.interests.interestsByOwner(ownerId),
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> getInterestCategories() {
    return _api.get<List<dynamic>>(
      ApiRoutes.interests.interestCategories,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // ─── Connection Requests ──────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> createConnectionRequest(
    String senderId,
    String receiverId, {
    String? message,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.interests.connectionRequests,
      data: {
        'senderId': senderId,
        'receiverId': receiverId,
        if (message != null) 'message': message,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> respondToConnectionRequest(
    String requestId,
    bool accept,
  ) {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.interests.respondToRequest(requestId),
      data: {'accept': accept},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> listSentRequests(String senderId) {
    return _api.get<List<dynamic>>(
      ApiRoutes.interests.sentRequests(senderId),
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> listReceivedRequests(String receiverId) {
    return _api.get<List<dynamic>>(
      ApiRoutes.interests.receivedRequests(receiverId),
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<void>> cancelConnectionRequest(String requestId) {
    return _api.delete<void>(
      ApiRoutes.interests.cancelConnectionRequest(requestId),
    );
  }

  Future<ApiResponse<void>> blockConnection(String requestId) {
    return _api.put<void>(
      ApiRoutes.interests.blockRequest(requestId),
      data: {},
    );
  }

  // ─── Connections ──────────────────────────────────────────────────────────

  Future<ApiResponse<List<dynamic>>> getConnections(String userId) {
    return _api.get<List<dynamic>>(
      ApiRoutes.interests.connections(userId),
      fromJson: (json) => json as List<dynamic>,
    );
  }
}
