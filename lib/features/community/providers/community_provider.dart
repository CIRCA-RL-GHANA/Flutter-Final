/// ═══════════════════════════════════════════════════════════════════════════
/// Community Provider — State Management
///
/// Manages community discovery, memberships, and post state.
/// Delegates all API calls to CommunityService. Gracefully falls back to
/// stub data when offline so the UI always renders beautifully.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import '../../../core/services/community_service.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityService _service;

  CommunityProvider({CommunityService? service})
      : _service = service ?? CommunityService();

  // ─── Loading / Error State ────────────────────────────────────────────────

  bool _isDiscoveryLoading = false;
  bool get isDiscoveryLoading => _isDiscoveryLoading;

  bool _isMineLoading = false;
  bool get isMineLoading => _isMineLoading;

  bool _isPostsLoading = false;
  bool get isPostsLoading => _isPostsLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Discovery State ──────────────────────────────────────────────────────

  List<Map<String, dynamic>> _communities = [];
  List<Map<String, dynamic>> get communities => _communities;

  String? _activeTypeFilter;
  String? get activeTypeFilter => _activeTypeFilter;

  int _discoverPage = 1;
  bool _discoverHasMore = true;
  bool get discoverHasMore => _discoverHasMore;

  void setTypeFilter(String? type) {
    _activeTypeFilter = type;
    _communities.clear();
    _discoverPage = 1;
    _discoverHasMore = true;
    notifyListeners();
    loadDiscovery();
  }

  Future<void> loadDiscovery({bool refresh = false}) async {
    if (refresh) {
      _communities.clear();
      _discoverPage = 1;
      _discoverHasMore = true;
    }
    if (_isDiscoveryLoading || !_discoverHasMore) return;

    _isDiscoveryLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.discoverCommunities(
        type: _activeTypeFilter,
        page: _discoverPage,
        limit: 20,
      );
      if (response.success && response.data != null) {
        final data = response.data!;
        final items = (data['items'] as List? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _communities.addAll(items);
        final total = data['total'] as int? ?? 0;
        _discoverHasMore = _communities.length < total;
        _discoverPage++;
      } else {
        _communities = _fallbackCommunities;
        _discoverHasMore = false;
      }
    } catch (_) {
      _communities = _fallbackCommunities;
      _discoverHasMore = false;
    } finally {
      _isDiscoveryLoading = false;
      notifyListeners();
    }
  }

  // ─── My Memberships State ─────────────────────────────────────────────────

  List<Map<String, dynamic>> _myMemberships = [];
  List<Map<String, dynamic>> get myMemberships => _myMemberships;

  Future<void> loadMyMemberships() async {
    _isMineLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getMyMemberships();
      if (response.success && response.data != null) {
        _myMemberships = response.data!;
      } else {
        _myMemberships = [];
      }
    } catch (_) {
      _myMemberships = [];
    } finally {
      _isMineLoading = false;
      notifyListeners();
    }
  }

  // ─── Active Community Detail ──────────────────────────────────────────────

  Map<String, dynamic>? _activeCommunity;
  Map<String, dynamic>? get activeCommunity => _activeCommunity;

  Future<void> loadCommunityById(String id) async {
    try {
      final response = await _service.getCommunityById(id);
      if (response.success) {
        _activeCommunity = response.data;
        notifyListeners();
      }
    } catch (_) {
      // keep existing data
    }
  }

  Future<bool> joinCommunity(String communityId) async {
    try {
      final response = await _service.joinCommunity(communityId);
      if (response.success) {
        await loadMyMemberships();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> leaveCommunity(String communityId) async {
    try {
      final response = await _service.leaveCommunity(communityId);
      if (response.success) {
        await loadMyMemberships();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Create Community ─────────────────────────────────────────────────────

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  Future<Map<String, dynamic>?> createCommunity({
    required String name,
    required String type,
    String? description,
    String visibility = 'public',
    String? tags,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.createCommunity(
        name: name,
        type: type,
        description: description,
        visibility: visibility,
        tags: tags,
      );
      if (response.success && response.data != null) {
        // Prepend to discovery list so user sees it immediately
        _communities.insert(0, response.data!);
        notifyListeners();
        return response.data;
      }
      _error = 'Failed to create community. Please try again.';
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ─── Posts ────────────────────────────────────────────────────────────────

  final Map<String, List<Map<String, dynamic>>> _postsCache = {};

  Map<String, List<Map<String, dynamic>>> get postsCache => _postsCache;

  List<Map<String, dynamic>> postsFor(String communityId) =>
      _postsCache[communityId] ?? [];

  Future<void> loadPosts(String communityId, {bool refresh = false}) async {
    if (!refresh && _postsCache.containsKey(communityId)) return;

    _isPostsLoading = true;
    notifyListeners();

    try {
      final response = await _service.getPosts(communityId);
      if (response.success && response.data != null) {
        final items = (response.data!['items'] as List? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _postsCache[communityId] = items;
      }
    } catch (_) {
      // keep cached version if available
    } finally {
      _isPostsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String communityId,
    required String type,
    String? title,
    String? body,
  }) async {
    try {
      final response = await _service.createPost(
        communityId: communityId,
        type: type,
        title: title,
        body: body,
      );
      if (response.success) {
        await loadPosts(communityId, refresh: true);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Fallback / Offline Data ──────────────────────────────────────────────

  static final List<Map<String, dynamic>> _fallbackCommunities = [
    {'id': 'c1', 'name': 'Afrobeats Book Club',   'type': 'library',  'memberCount': 1200, 'visibility': 'public'},
    {'id': 'c2', 'name': 'Friday Night Theater',  'type': 'theater',  'memberCount': 845,  'visibility': 'public'},
    {'id': 'c3', 'name': 'Lagos Tech Fair 2026',  'type': 'fair',     'memberCount': 3100, 'visibility': 'public'},
    {'id': 'c4', 'name': 'Kumasi Highlife Vibes', 'type': 'playlist', 'memberCount': 620,  'visibility': 'public'},
    {'id': 'c5', 'name': 'Dev Hive Africa',       'type': 'hub',      'memberCount': 2400, 'visibility': 'public'},
    {'id': 'c6', 'name': 'Accra Meetup',          'type': 'hangout',  'memberCount': 510,  'visibility': 'public'},
  ];
}
