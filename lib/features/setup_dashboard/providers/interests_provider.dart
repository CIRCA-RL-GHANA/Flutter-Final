/// ═══════════════════════════════════════════════════════════════════════════
/// Interests Provider — State Management
///
/// Manages favorite shops, connection requests, and connections.
/// Delegates all API calls to InterestsService.
/// ═══════════════════════════════════════════════════════════════════════════
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/interests_service.dart';

class InterestsProvider extends ChangeNotifier {
  final InterestsService _service;

  InterestsProvider({InterestsService? service})
      : _service = service ?? InterestsService();

  // ─── State ────────────────────────────────────────────────────────────────

  List<dynamic> _favoriteShops = [];
  List<dynamic> get favoriteShops => _favoriteShops;

  List<dynamic> _sentRequests = [];
  List<dynamic> get sentRequests => _sentRequests;

  List<dynamic> _receivedRequests = [];
  List<dynamic> get receivedRequests => _receivedRequests;

  List<dynamic> _connections = [];
  List<dynamic> get connections => _connections;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Favorite Shops ───────────────────────────────────────────────────────

  Future<void> loadFavoriteShops(String entityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.listFavoriteShops(entityId);
      if (response.success && response.data != null) {
        _favoriteShops = response.data!;
      } else {
        _favoriteShops = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _favoriteShops = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFavoriteShop(String userId, String entityId) async {
    try {
      final response = await _service.addFavoriteShop(userId, entityId);
      if (response.success) {
        await loadFavoriteShops(entityId);
        return true;
      }
      _error = response.error?.message ?? 'Failed to add favorite shop';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavoriteShop(String userId, String entityId) async {
    try {
      final response = await _service.removeFavoriteShop(userId, entityId);
      if (response.success) {
        await loadFavoriteShops(entityId);
        return true;
      }
      _error = response.error?.message ?? 'Failed to remove favorite shop';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Connections ──────────────────────────────────────────────────────────

  Future<void> loadConnections(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getConnections(userId);
      if (response.success && response.data != null) {
        _connections = response.data!;
      } else {
        _connections = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _connections = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Connection Requests ──────────────────────────────────────────────────

  Future<Map<String, dynamic>?> createConnectionRequest(
    String senderId,
    String receiverId, {
    String? message,
  }) async {
    try {
      final response = await _service.createConnectionRequest(
        senderId,
        receiverId,
        message: message,
      );
      if (response.success && response.data != null) {
        _sentRequests.insert(0, response.data!);
        notifyListeners();
        return response.data;
      }
      _error = response.error?.message ?? 'Failed to send connection request';
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> respondToRequest(String id, bool accept) async {
    try {
      final response = await _service.respondToConnectionRequest(id, accept);
      if (response.success) {
        _receivedRequests.removeWhere(
          (r) => (r as Map<String, dynamic>)['id'] == id,
        );
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to respond to request';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadRequests(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.listSentRequests(userId),
        _service.listReceivedRequests(userId),
      ]);
      final sent = results[0];
      final received = results[1];
      if (sent.success && sent.data != null) _sentRequests = sent.data!;
      if (received.success && received.data != null) {
        _receivedRequests = received.data!;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
