/// ═══════════════════════════════════════════════════════════════════════════
/// Community Service — Flutter ↔ Backend Integration
///
/// Maps to CommunityController endpoints:
///   GET    /community              (discover)
///   GET    /community/mine         (my memberships)
///   GET    /community/:id          (community detail)
///   POST   /community              (create)
///   POST   /community/:id/join
///   DELETE /community/:id/leave
///   GET    /community/:id/members
///   PATCH  /community/:id/members/:userId/ban
///   GET    /community/:id/posts
///   POST   /community/:id/posts
///   DELETE /community/:id/posts/:postId
/// ═══════════════════════════════════════════════════════════════════════════

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class CommunityService {
  final ApiClient _api;

  CommunityService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  // ─── Discovery ───────────────────────────────────────────────────────────

  /// Discover public communities, optionally filtered by archetype type.
  ///
  /// [type] one of: library | playlist | theater | fair | hub | hangout | journal
  Future<ApiResponse<Map<String, dynamic>>> discoverCommunities({
    String? type,
    int page = 1,
    int limit = 20,
  }) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.community.discover,
      queryParameters: {
        if (type != null) 'type': type,
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get all communities the current user is a member of.
  Future<ApiResponse<List<Map<String, dynamic>>>> getMyMemberships() {
    return _api.get<List<Map<String, dynamic>>>(
      ApiRoutes.community.mine,
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Fetch full details for a specific community.
  Future<ApiResponse<Map<String, dynamic>>> getCommunityById(String id) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.community.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  /// Create a new community.
  ///
  /// [type] one of: library | playlist | theater | fair | hub | hangout | journal
  /// [visibility] one of: public | invite_only | private
  Future<ApiResponse<Map<String, dynamic>>> createCommunity({
    required String name,
    required String type,
    String? description,
    String visibility = 'public',
    String? tags,
    String? coverUrl,
    Map<String, dynamic>? metadata,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.community.create,
      data: {
        'name': name,
        'type': type,
        'visibility': visibility,
        if (description != null) 'description': description,
        if (tags != null) 'tags': tags,
        if (coverUrl != null) 'coverUrl': coverUrl,
        if (metadata != null) 'metadata': metadata,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Join a public community.
  Future<ApiResponse<Map<String, dynamic>>> joinCommunity(String communityId) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.community.join(communityId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Leave a community the user is a member of.
  Future<ApiResponse<Map<String, dynamic>>> leaveCommunity(String communityId) {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.community.leave(communityId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Members ─────────────────────────────────────────────────────────────

  /// Get paginated member list for a community.
  Future<ApiResponse<Map<String, dynamic>>> getMembers(
    String communityId, {
    int page = 1,
    int limit = 30,
  }) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.community.members(communityId),
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Ban a member from a community (moderator / owner only).
  Future<ApiResponse<Map<String, dynamic>>> banMember({
    required String communityId,
    required String userId,
    required String reason,
  }) {
    return _api.patch<Map<String, dynamic>>(
      ApiRoutes.community.banMember(communityId, userId),
      data: {'reason': reason},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ─── Posts ───────────────────────────────────────────────────────────────

  /// Get paginated posts for a community.
  ///
  /// [postType] optional filter: text | link | poll | event | listing
  Future<ApiResponse<Map<String, dynamic>>> getPosts(
    String communityId, {
    String? postType,
    int page = 1,
    int limit = 20,
  }) {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.community.posts(communityId),
      queryParameters: {
        if (postType != null) 'type': postType,
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Create a new post inside a community.
  ///
  /// [type] one of: text | link | poll | event | listing
  Future<ApiResponse<Map<String, dynamic>>> createPost({
    required String communityId,
    required String type,
    String? title,
    String? body,
    String? linkedContentId,
    Map<String, dynamic>? metadata,
  }) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.community.posts(communityId),
      data: {
        'type': type,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (linkedContentId != null) 'linkedContentId': linkedContentId,
        if (metadata != null) 'metadata': metadata,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Remove a post from a community (moderator / owner only).
  Future<ApiResponse<Map<String, dynamic>>> removePost({
    required String communityId,
    required String postId,
  }) {
    return _api.delete<Map<String, dynamic>>(
      ApiRoutes.community.removePost(communityId, postId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
