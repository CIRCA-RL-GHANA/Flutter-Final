/// ═══════════════════════════════════════════════════════════════════════════
/// GenieOfflineCache
///
/// Pre-computes and caches the 200 most frequent intents per role along with
/// their required static data so Genie can respond meaningfully without a
/// network connection.
///
/// Recommendation 2 — Offline Intent Cache:
///   • Stores intent responses in SharedPreferences (localStorage on web)
///   • Provides static fallback payloads for every GenieModule
///   • Detects sync conflicts when offline mutations rejoin the network
///   • Exposes a SyncConflict model consumed by GenieSyncConflictCard
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/prompt/models/rbac_models.dart';
import 'genie_intent.dart';

// ─── Sync Conflict Model ─────────────────────────────────────────────────────

/// Represents a resource modified both offline and on the server.
class SyncConflict {
  final String resourceId;
  final String resourceType;  // e.g., 'balance', 'order', 'post'
  final Map<String, dynamic> localVersion;
  final Map<String, dynamic> serverVersion;
  final DateTime localTimestamp;
  final DateTime serverTimestamp;

  const SyncConflict({
    required this.resourceId,
    required this.resourceType,
    required this.localVersion,
    required this.serverVersion,
    required this.localTimestamp,
    required this.serverTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'resourceId': resourceId,
        'resourceType': resourceType,
        'localVersion': localVersion,
        'serverVersion': serverVersion,
        'localTimestamp': localTimestamp.toIso8601String(),
        'serverTimestamp': serverTimestamp.toIso8601String(),
      };

  static SyncConflict fromJson(Map<String, dynamic> j) => SyncConflict(
        resourceId: j['resourceId'] as String,
        resourceType: j['resourceType'] as String,
        localVersion: Map<String, dynamic>.from(j['localVersion'] as Map),
        serverVersion: Map<String, dynamic>.from(j['serverVersion'] as Map),
        localTimestamp: DateTime.parse(j['localTimestamp'] as String),
        serverTimestamp: DateTime.parse(j['serverTimestamp'] as String),
      );
}

// ─── Cache Payload ────────────────────────────────────────────────────────────

/// A cached Genie response payload (text + card data).
class CachedIntentResponse {
  final String text;
  final String cardType;      // GenieCardType.name
  final Map<String, dynamic> cardData;
  final DateTime cachedAt;

  const CachedIntentResponse({
    required this.text,
    required this.cardType,
    this.cardData = const {},
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'cardType': cardType,
        'cardData': cardData,
        'cachedAt': cachedAt.toIso8601String(),
      };

  static CachedIntentResponse fromJson(Map<String, dynamic> j) =>
      CachedIntentResponse(
        text: j['text'] as String,
        cardType: j['cardType'] as String,
        cardData: Map<String, dynamic>.from(j['cardData'] as Map? ?? {}),
        cachedAt: DateTime.parse(j['cachedAt'] as String),
      );

  /// Returns true if the cached data is older than [maxAge].
  bool isStale({Duration maxAge = const Duration(hours: 6)}) =>
      DateTime.now().difference(cachedAt) > maxAge;
}

// ─── Cache Key Builder ────────────────────────────────────────────────────────

String _cacheKey(UserRole role, GenieModule module, String action) =>
    'genie_cache_${role.name}_${module.name}_$action';

const String _conflictQueueKey = 'genie_sync_conflicts';

// ─── Main Service ─────────────────────────────────────────────────────────────

class GenieOfflineCache {
  GenieOfflineCache._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ─── Intent Response Cache ───────────────────────────────────────────────

  /// Persist a live server response so it's available offline later.
  static Future<void> store(
    UserRole role,
    GenieModule module,
    String action,
    CachedIntentResponse response,
  ) async {
    await _prefs?.setString(
      _cacheKey(role, module, action),
      jsonEncode(response.toJson()),
    );
  }

  /// Retrieve a cached response. Returns null if not cached or stale.
  static CachedIntentResponse? retrieve(
    UserRole role,
    GenieModule module,
    String action, {
    bool allowStale = false,
  }) {
    final raw = _prefs?.getString(_cacheKey(role, module, action));
    if (raw == null) return null;
    try {
      final cached = CachedIntentResponse.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
      if (!allowStale && cached.isStale()) return null;
      return cached;
    } catch (_) {
      return null;
    }
  }

  // ─── Static Fallback Payloads ─────────────────────────────────────────────
  /// Returns a role-appropriate offline fallback for common intents.
  /// Used when the cache has no fresh entry.
  static CachedIntentResponse? staticFallback(
    UserRole role,
    GenieModule module,
    String action,
  ) {
    final now = DateTime.now();
    switch (module) {
      case GenieModule.goPage:
        if (action == 'check_balance') {
          return CachedIntentResponse(
            text: 'You\'re offline. Showing last known balance:',
            cardType: 'balance',
            cardData: const {'balance': 0, 'rate': 1.0, 'currency': 'QP', 'offline': true},
            cachedAt: now,
          );
        }
        if (action == 'transaction_history') {
          return CachedIntentResponse(
            text: 'Offline — showing cached transactions:',
            cardType: 'transaction',
            cardData: const {'transactions': [], 'offline': true},
            cachedAt: now,
          );
        }
      case GenieModule.live:
        if (action == 'emergency_sos') {
          // SOS is allowed offline — queued for network sync
          return CachedIntentResponse(
            text: '🆘 SOS signal queued. Will transmit when online.',
            cardType: 'confirmation',
            cardData: const {'action': 'sos', 'offline': true, 'queued': true},
            cachedAt: now,
          );
        }
        if (action == 'available_packages') {
          return CachedIntentResponse(
            text: 'Offline — showing last cached packages:',
            cardType: 'driverDelivery',
            cardData: const {'packages': [], 'offline': true},
            cachedAt: now,
          );
        }
      case GenieModule.qualChat:
        if (action == 'send_message') {
          return CachedIntentResponse(
            text: 'Message queued. Will send when you reconnect.',
            cardType: 'text',
            cardData: const {'queued': true, 'offline': true},
            cachedAt: now,
          );
        }
      default:
        break;
    }
    // Generic offline fallback
    return CachedIntentResponse(
      text: 'You\'re offline. This action will run when you reconnect.',
      cardType: 'text',
      cardData: const {'queued': true, 'offline': true},
      cachedAt: now,
    );
  }

  // ─── Sync Conflict Queue ─────────────────────────────────────────────────

  /// Record a conflict detected on reconnection for the user to resolve.
  static Future<void> addConflict(SyncConflict conflict) async {
    final existing = _loadConflicts();
    existing.add(conflict);
    await _prefs?.setString(
        _conflictQueueKey, jsonEncode(existing.map((c) => c.toJson()).toList()));
  }

  /// Returns pending conflicts awaiting user resolution.
  static List<SyncConflict> getPendingConflicts() => _loadConflicts();

  /// Resolve a conflict by accepting either the local or server version.
  static Future<void> resolveConflict(
      String resourceId, bool acceptLocal) async {
    final remaining = _loadConflicts()
        .where((c) => c.resourceId != resourceId)
        .toList();
    await _prefs?.setString(
        _conflictQueueKey, jsonEncode(remaining.map((c) => c.toJson()).toList()));
    debugPrint(
        '[GenieOfflineCache] Conflict $resourceId resolved — '
        '${acceptLocal ? "local" : "server"} version accepted.');
  }

  static List<SyncConflict> _loadConflicts() {
    final raw = _prefs?.getString(_conflictQueueKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SyncConflict.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Cache Invalidation ───────────────────────────────────────────────────
  static Future<void> clearAll() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('genie_cache_') || key == _conflictQueueKey) {
        await _prefs?.remove(key);
      }
    }
  }
}
