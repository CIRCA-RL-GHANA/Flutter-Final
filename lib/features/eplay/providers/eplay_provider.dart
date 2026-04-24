/// ═══════════════════════════════════════════════════════════════════════════
/// e-Play Provider — State Management
///
/// Manages content browsing, cloud locker, and creator studio state.
/// Delegates all API calls to EPlayService. Falls back to stub data
/// when offline so the UI always renders.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import '../../../core/services/eplay_service.dart';

class EPlayProvider extends ChangeNotifier {
  final EPlayService _service;

  EPlayProvider({EPlayService? service})
      : _service = service ?? EPlayService();

  // ─── Loading / Error State ────────────────────────────────────────────────

  bool _isBrowseLoading = false;
  bool get isBrowseLoading => _isBrowseLoading;

  bool _isLockerLoading = false;
  bool get isLockerLoading => _isLockerLoading;

  bool _isCreatorLoading = false;
  bool get isCreatorLoading => _isCreatorLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Browse State ─────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _assets = [];
  List<Map<String, dynamic>> get assets => _assets;

  String? _activeTypeFilter;
  String? get activeTypeFilter => _activeTypeFilter;

  int _browsePage = 1;
  bool _browseHasMore = true;
  bool get browseHasMore => _browseHasMore;

  void setTypeFilter(String? type) {
    _activeTypeFilter = type;
    _assets.clear();
    _browsePage = 1;
    _browseHasMore = true;
    notifyListeners();
    loadBrowse();
  }

  Future<void> loadBrowse({bool refresh = false}) async {
    if (refresh) {
      _assets.clear();
      _browsePage = 1;
      _browseHasMore = true;
    }
    if (_isBrowseLoading || !_browseHasMore) return;

    _isBrowseLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.browseAssets(
        type: _activeTypeFilter,
        page: _browsePage,
        limit: 20,
      );
      if (response.success && response.data != null) {
        final data = response.data!;
        final items = (data['items'] as List? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _assets.addAll(items);
        final total = data['total'] as int? ?? 0;
        _browseHasMore = _assets.length < total;
        _browsePage++;
      } else {
        _assets = _fallbackCatalogue;
        _browseHasMore = false;
      }
    } catch (_) {
      _assets = _fallbackCatalogue;
      _browseHasMore = false;
    } finally {
      _isBrowseLoading = false;
      notifyListeners();
    }
  }

  // ─── Cloud Locker State ───────────────────────────────────────────────────

  List<Map<String, dynamic>> _lockerItems = [];
  List<Map<String, dynamic>> get lockerItems => _lockerItems;

  Future<void> loadLocker() async {
    _isLockerLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getLocker();
      if (response.success && response.data != null) {
        final data = response.data!;
        _lockerItems = (data['items'] as List? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
      } else {
        _lockerItems = _fallbackLocker;
      }
    } catch (_) {
      _lockerItems = _fallbackLocker;
    } finally {
      _isLockerLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchaseAsset(String assetId) async {
    try {
      final response = await _service.purchaseAsset(assetId: assetId);
      if (response.success) {
        await loadLocker();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> togglePin(String lockerId) async {
    try {
      final response = await _service.togglePin(lockerId);
      if (response.success) {
        await loadLocker();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Creator Profile State ────────────────────────────────────────────────

  Map<String, dynamic>? _creatorProfile;
  Map<String, dynamic>? get creatorProfile => _creatorProfile;

  Future<void> loadCreatorProfile() async {
    _isCreatorLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getMyCreatorProfile();
      if (response.success) {
        _creatorProfile = response.data;
      }
    } catch (_) {
      // no creator profile yet — that's fine
    } finally {
      _isCreatorLoading = false;
      notifyListeners();
    }
  }

  Future<bool> openCreatorProfile({
    required String displayName,
    String? bio,
  }) async {
    try {
      final response = await _service.openCreatorProfile(
        displayName: displayName,
        bio: bio,
      );
      if (response.success) {
        _creatorProfile = response.data;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Fallback / Offline Data ──────────────────────────────────────────────

  static final List<Map<String, dynamic>> _fallbackCatalogue = List.generate(
    20,
    (i) {
      final types = ['music', 'movie', 'podcast', 'ebook', 'show'];
      final type = types[i % types.length];
      return {
        'id': 'asset-$i',
        'title': 'Title ${i + 1}',
        'creator': 'Creator ${(i % 6) + 1}',
        'type': type,
        'priceQPoints': i % 4 == 0 ? 0 : ((i % 10) + 2) * 100,
        'coverUrl': null,
        'playCount': (i * 312) + 100,
        'purchaseCount': (i * 22),
      };
    },
  );

  static final List<Map<String, dynamic>> _fallbackLocker = [
    {
      'id': 'license-1',
      'asset': {'id': 'asset-0', 'title': 'Afrobeats Vol. 3', 'type': 'music', 'coverUrl': null},
      'isPinned': true,
      'status': 'active',
    },
    {
      'id': 'license-2',
      'asset': {'id': 'asset-2', 'title': 'The River Speaks', 'type': 'movie', 'coverUrl': null},
      'isPinned': false,
      'status': 'active',
    },
  ];
}
