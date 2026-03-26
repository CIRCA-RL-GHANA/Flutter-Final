import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for interests, favorite shops, and connections.
/// Maps to backend InterestsController.
class InterestService {
  final ApiClient _api;

  InterestService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Add an entity to favorite shops.
  Future<ApiResponse<Map<String, dynamic>>> addFavoriteShop(
    String entityId,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.interests.favoriteShops,
      data: {'entityId': entityId},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Remove an entity from favorite shops.
  Future<ApiResponse<Map<String, dynamic>>> removeFavoriteShop(
    String entityId,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.interests.favoriteShopsByEntity(entityId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all favorite shops.
  Future<ApiResponse<List<Map<String, dynamic>>>> getFavoriteShops() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.interests.favoriteShops,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Add a new interest.
  Future<ApiResponse<Map<String, dynamic>>> addInterest({
    required String category,
    required String name,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.interests.interests,
      data: {
        'category': category,
        'name': name,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Remove an interest by ID.
  Future<ApiResponse<Map<String, dynamic>>> removeInterest(
    String interestId,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.interests.interestsByOwner(interestId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get interests for an owner.
  Future<ApiResponse<List<Map<String, dynamic>>>> getInterests(
    String ownerId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.interests.interestsByOwner(ownerId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Send a connection request to another user.
  Future<ApiResponse<Map<String, dynamic>>> sendConnectionRequest(
    String targetUserId,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.interests.connectionRequests,
      data: {'targetUserId': targetUserId},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Respond to a connection request.
  Future<ApiResponse<Map<String, dynamic>>> respondToConnectionRequest({
    required String requestId,
    required bool accepted,
  }) async {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.interests.connectionRequestById(requestId),
      data: {'accepted': accepted},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get connections for a user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getConnections(
    String userId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.interests.connections(userId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Respond to a connection request (accept/reject).
  Future<ApiResponse<Map<String, dynamic>>> respondToRequest({
    required String requestId,
    required bool accepted,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.interests.respondToRequest(requestId),
      data: {'accepted': accepted},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Block a connection request.
  Future<ApiResponse<Map<String, dynamic>>> blockRequest(
    String requestId,
  ) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.interests.blockRequest(requestId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get available interest categories.
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories() async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.interests.interestCategories,
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a single interest by ID.
  Future<ApiResponse<Map<String, dynamic>>> getInterestById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.interests.interestDetail(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get sent connection requests for a user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getSentRequests(
    String senderId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.interests.sentRequests(senderId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get received connection requests for a user.
  Future<ApiResponse<List<Map<String, dynamic>>>> getReceivedRequests(
    String receiverId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.interests.receivedRequests(receiverId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Cancel a connection request.
  Future<ApiResponse<Map<String, dynamic>>> cancelConnectionRequest(
    String id,
  ) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.interests.cancelConnectionRequest(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get a connection request by ID.
  Future<ApiResponse<Map<String, dynamic>>> getConnectionRequestById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.interests.connectionRequestById(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
