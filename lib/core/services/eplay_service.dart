/// ═══════════════════════════════════════════════════════════════════════════
/// e-Play Service — Flutter ↔ Backend Integration
///
/// Maps to EplayController endpoints:
///   POST   /eplay/creator/open
///   GET    /eplay/creator/me
///   POST   /eplay/assets
///   PATCH  /eplay/assets/:id/publish
///   GET    /eplay/browse
///   GET    /eplay/assets/:id
///   GET    /eplay/locker
///   POST   /eplay/locker/purchase
///   GET    /eplay/locker/:assetId/stream
///   PATCH  /eplay/locker/:id/pin
/// ═══════════════════════════════════════════════════════════════════════════

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class EPlayService {
  final ApiClient _api;

  EPlayService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Creator Onboarding ──────────────────────────────────────────────────

  /// Open (register) a creator profile. Creator receives royalties per sale.
  Future<ApiResponse<Map<String, dynamic>>> openCreatorProfile({
    required String displayName,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.eplay.openCreator,
      data: {
        'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bannerUrl != null) 'bannerUrl': bannerUrl,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get the authenticated user's own creator profile.
  Future<ApiResponse<Map<String, dynamic>>> getMyCreatorProfile() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.eplay.myCreator,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Content Management ──────────────────────────────────────────────────

  /// Upload / register a new digital asset (creator only).
  ///
  /// [type] one of: music | movie | podcast | ebook | show
  /// [accessModel] one of: perpetual | rental | subscription
  Future<ApiResponse<Map<String, dynamic>>> uploadAsset({
    required String title,
    required String type,
    required String accessModel,
    required double priceQPoints,
    required String encryptedStorageRef,
    String? description,
    String? coverUrl,
    int? durationSeconds,
    int? rentalDurationDays,
    List<String>? tags,
    List<String>? allowedRegions,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.eplay.uploadAsset,
      data: {
        'title': title,
        'type': type,
        'accessModel': accessModel,
        'priceQPoints': priceQPoints,
        'encryptedStorageRef': encryptedStorageRef,
        if (description != null) 'description': description,
        if (coverUrl != null) 'coverUrl': coverUrl,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (rentalDurationDays != null) 'rentalDurationDays': rentalDurationDays,
        if (tags != null) 'tags': tags.join(','),
        if (allowedRegions != null) 'allowedRegions': allowedRegions,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Move an asset from draft → published state.
  Future<ApiResponse<Map<String, dynamic>>> publishAsset(String assetId) {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.eplay.publishAsset(assetId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Discovery ───────────────────────────────────────────────────────────

  /// Browse all published digital assets with optional type filter.
  ///
  /// [type] optional filter: music | movie | podcast | ebook | show
  Future<ApiResponse<Map<String, dynamic>>> browseAssets({
    String? type,
    int page = 1,
    int limit = 20,
  }) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.eplay.browse,
      queryParameters: {
        if (type != null) 'type': type,
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Fetch a single asset by its UUID.
  Future<ApiResponse<Map<String, dynamic>>> getAssetById(String assetId) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.eplay.assetById(assetId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Cloud Locker (Purchased Licenses) ───────────────────────────────────

  /// Get the current user's cloud locker — all purchased / licensed assets.
  Future<ApiResponse<Map<String, dynamic>>> getLocker() {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.eplay.locker,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Purchase (license) a digital asset, paying in QPoints.
  Future<ApiResponse<Map<String, dynamic>>> purchaseAsset({
    required String assetId,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.eplay.purchase,
      data: {'assetId': assetId},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Request a time-limited stream token for a purchased asset.
  Future<ApiResponse<Map<String, dynamic>>> getStreamToken(String assetId) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.eplay.stream(assetId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Toggle pin state of a locker item for quick access.
  Future<ApiResponse<Map<String, dynamic>>> togglePin(String lockerId) {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.eplay.pinLocker(lockerId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
