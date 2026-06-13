/// ═══════════════════════════════════════════════════════════════════════════
/// Multi-Channel Provider — State Management
///
/// Manages multi-channel registrations, sync, and status updates.
/// Delegates all API calls to MultiChannelService.
/// ═══════════════════════════════════════════════════════════════════════════
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/multi_channel_service.dart';

class MultiChannelProvider extends ChangeNotifier {
  final MultiChannelService _service;

  MultiChannelProvider({MultiChannelService? service})
      : _service = service ?? MultiChannelService();

  // ─── State ────────────────────────────────────────────────────────────────

  List<dynamic> _channels = [];
  List<dynamic> get channels => _channels;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadChannels(String entityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.listChannels(entityId);
      if (response.success && response.data != null) {
        _channels = response.data!;
      } else {
        _channels = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _channels = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> registerChannel(
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.registerChannel(data);
      if (response.success && response.data != null) {
        _channels.insert(0, response.data!);
        notifyListeners();
        return response.data;
      }
      _error = response.error?.message ?? 'Failed to register channel';
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Sync ─────────────────────────────────────────────────────────────────

  Future<bool> syncChannel(String id) async {
    try {
      final response = await _service.syncChannel(id);
      if (response.success && response.data != null) {
        _updateChannelInList(id, response.data!);
        return true;
      }
      _error = response.error?.message ?? 'Failed to sync channel';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<bool> deleteChannel(String id) async {
    try {
      final response = await _service.deleteChannel(id);
      if (response.success) {
        _channels.removeWhere(
          (c) => (c as Map<String, dynamic>)['id'] == id,
        );
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to delete channel';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateChannelInList(String id, Map<String, dynamic> updated) {
    final idx = _channels.indexWhere(
      (c) => (c as Map<String, dynamic>)['id'] == id,
    );
    if (idx != -1) _channels[idx] = updated;
    notifyListeners();
  }
}
