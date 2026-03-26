import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for managing entities and branches.
/// Maps to backend EntitiesController.
class EntityService {
  final ApiClient _api;

  EntityService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Create an individual entity
  Future<ApiResponse<Map<String, dynamic>>> createIndividual({
    required String ownerId,
    required String entityType,
    required String role,
    String? displayName,
    Map<String, dynamic>? metadata,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.entities.createIndividual,
      data: {
        'ownerId': ownerId,
        'entityType': entityType,
        'role': role,
        if (displayName != null) 'displayName': displayName,
        if (metadata != null) 'metadata': metadata,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create a business/organization entity
  Future<ApiResponse<Map<String, dynamic>>> createOther({
    required String ownerId,
    required String entityType,
    required String businessName,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.entities.createOther,
      data: {
        'ownerId': ownerId,
        'entityType': entityType,
        'businessName': businessName,
        if (description != null) 'description': description,
        if (metadata != null) 'metadata': metadata,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create branches for an entity
  Future<ApiResponse<Map<String, dynamic>>> createBranches({
    required String entityId,
    required List<Map<String, dynamic>> branches,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.entities.createBranches,
      data: {
        'entityId': entityId,
        'branches': branches,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get entity by ID
  Future<ApiResponse<Map<String, dynamic>>> getEntityById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.entities.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get entities by owner ID
  Future<ApiResponse<List<Map<String, dynamic>>>> getEntitiesByOwnerId(
    String ownerId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.entities.byOwner(ownerId),
      fromJson: (json) => (json as List)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
    );
  }

  /// Get branches for an entity
  Future<ApiResponse<List<Map<String, dynamic>>>> getBranches(
    String entityId,
  ) async {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.entities.branches(entityId),
      fromJson: (json) => (json as List)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
    );
  }
}
