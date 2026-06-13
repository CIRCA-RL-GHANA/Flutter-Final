/// ═══════════════════════════════════════════════════════════════════════════
/// Campaigns Provider — State Management
///
/// Manages campaign lifecycle: listing, creation, activation, pausing.
/// Delegates all API calls to CampaignsService.
/// ═══════════════════════════════════════════════════════════════════════════
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/campaigns_service.dart';

class CampaignsProvider extends ChangeNotifier {
  final CampaignsService _service;

  CampaignsProvider({CampaignsService? service})
      : _service = service ?? CampaignsService();

  // ─── State ────────────────────────────────────────────────────────────────

  List<dynamic> _campaigns = [];
  List<dynamic> get campaigns => _campaigns;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadCampaigns(String entityId, {String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getCampaigns(entityId, status: status);
      if (response.success && response.data != null) {
        _campaigns = response.data!;
      } else {
        _campaigns = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _campaigns = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Create ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> createCampaign(
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.createCampaign(data);
      if (response.success && response.data != null) {
        _campaigns.insert(0, response.data!);
        notifyListeners();
        return response.data;
      }
      _error = response.error?.message ?? 'Failed to create campaign';
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

  // ─── Update ───────────────────────────────────────────────────────────────

  Future<bool> updateCampaign(
    String id,
    Map<String, dynamic> updates,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.updateCampaign(id, updates);
      if (response.success && response.data != null) {
        final idx = _campaigns.indexWhere(
          (c) => (c as Map<String, dynamic>)['id'] == id,
        );
        if (idx != -1) _campaigns[idx] = response.data!;
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to update campaign';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<bool> deleteCampaign(String id) async {
    try {
      final response = await _service.deleteCampaign(id);
      if (response.success) {
        _campaigns.removeWhere(
          (c) => (c as Map<String, dynamic>)['id'] == id,
        );
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to delete campaign';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Activate / Pause ─────────────────────────────────────────────────────

  Future<bool> activate(String id) async {
    try {
      final response = await _service.activateCampaign(id);
      if (response.success && response.data != null) {
        _updateCampaignInList(id, response.data!);
        return true;
      }
      _error = response.error?.message ?? 'Failed to activate campaign';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> pause(String id) async {
    try {
      final response = await _service.pauseCampaign(id);
      if (response.success && response.data != null) {
        _updateCampaignInList(id, response.data!);
        return true;
      }
      _error = response.error?.message ?? 'Failed to pause campaign';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateCampaignInList(String id, Map<String, dynamic> updated) {
    final idx = _campaigns.indexWhere(
      (c) => (c as Map<String, dynamic>)['id'] == id,
    );
    if (idx != -1) _campaigns[idx] = updated;
    notifyListeners();
  }
}
