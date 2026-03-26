import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for managing favorite drivers.
/// Maps to backend FavoriteDriversController.
class FavoriteDriverService {
  final ApiClient _api;

  FavoriteDriverService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Add a driver to favorites.
  Future<ApiResponse<Map<String, dynamic>>> addFavoriteDriver({
    required String addedById,
    required String driverId,
    required String entityId,
    String? nickname,
    String? visibility,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.favoriteDrivers.add,
      queryParameters: {'addedById': addedById},
      data: {
        'driverId': driverId,
        'entityId': entityId,
        if (nickname != null) 'nickname': nickname,
        if (visibility != null) 'visibility': visibility,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Remove a driver from favorites.
  Future<ApiResponse<Map<String, dynamic>>> removeFavoriteDriver({
    required String entityId,
    required String driverId,
  }) async {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.favoriteDrivers.remove,
      data: {
        'entityId': entityId,
        'driverId': driverId,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all favorite drivers for an entity.
  Future<ApiResponse<List<Map<String, dynamic>>>> getFavoriteDrivers({
    required String entityId,
    String? visibility,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.favoriteDrivers.byEntity(entityId),
      queryParameters: {
        if (visibility != null) 'visibility': visibility,
      },
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get a favorite driver by ID.
  Future<ApiResponse<Map<String, dynamic>>> getFavoriteDriverById(
    String id,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.favoriteDrivers.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a favorite driver's details.
  Future<ApiResponse<Map<String, dynamic>>> updateFavoriteDriver({
    required String entityId,
    required String driverId,
    Map<String, dynamic>? data,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.favoriteDrivers.update,
      queryParameters: {
        'entityId': entityId,
        'driverId': driverId,
      },
      data: data ?? {},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Check if a driver is favorited by an entity.
  Future<ApiResponse<Map<String, dynamic>>> checkIsFavorite({
    required String entityId,
    required String driverId,
  }) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.favoriteDrivers.check(entityId, driverId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all entities that have favorited a specific driver.
  Future<ApiResponse<List<Map<String, dynamic>>>> getFavoritesByDriver(
    String driverId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.favoriteDrivers.byDriver(driverId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get public favorites for an entity.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPublicFavorites(
    String entityId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.favoriteDrivers.publicFavorites(entityId),
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Update visibility of a favorite driver.
  Future<ApiResponse<Map<String, dynamic>>> updateVisibility({
    required String entityId,
    required String driverId,
    required String visibility,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.favoriteDrivers.updateVisibility,
      queryParameters: {
        'entityId': entityId,
        'driverId': driverId,
      },
      data: {'visibility': visibility},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update personal rating for a favorite driver.
  Future<ApiResponse<Map<String, dynamic>>> updatePersonalRating({
    required String entityId,
    required String driverId,
    required double rating,
  }) async {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.favoriteDrivers.updateRating,
      queryParameters: {
        'entityId': entityId,
        'driverId': driverId,
      },
      data: {'rating': rating},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get top-rated favorite drivers for an entity.
  Future<ApiResponse<List<Map<String, dynamic>>>> getTopRatedFavorites(
    String entityId, {
    int limit = 10,
  }) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.favoriteDrivers.topRated(entityId),
      queryParameters: {'limit': limit},
      fromJson: (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }
}
