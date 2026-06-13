/// ═══════════════════════════════════════════════════════════════════════════
/// Tabs Provider — State Management
///
/// Manages credit tab lifecycle: listing, creation, charging, settling.
/// Delegates all API calls to TabsService.
/// ═══════════════════════════════════════════════════════════════════════════
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/tabs_service.dart';

class TabsProvider extends ChangeNotifier {
  final TabsService _service;

  TabsProvider({TabsService? service}) : _service = service ?? TabsService();

  // ─── State ────────────────────────────────────────────────────────────────

  List<dynamic> _tabs = [];
  List<dynamic> get tabs => _tabs;

  Map<String, dynamic>? _selectedTab;
  Map<String, dynamic>? get selectedTab => _selectedTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadTabs(String entityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getTabs(entityId);
      if (response.success && response.data != null) {
        _tabs = response.data!;
      } else {
        _tabs = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _tabs = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTab(Map<String, dynamic> tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // ─── Create ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> createTab(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.createTab(data);
      if (response.success && response.data != null) {
        _tabs.insert(0, response.data!);
        notifyListeners();
        return response.data;
      }
      _error = response.error?.message ?? 'Failed to create tab';
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

  // ─── Charge / Settle ──────────────────────────────────────────────────────

  Future<bool> chargeTab(String id, double amount, {String? description}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.chargeTab(id, amount, description: description);
      if (response.success && response.data != null) {
        _updateTabInList(id, response.data!);
        return true;
      }
      _error = response.error?.message ?? 'Failed to charge tab';
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

  Future<bool> settleTab(String id, double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.settleTab(id, amount);
      if (response.success && response.data != null) {
        _updateTabInList(id, response.data!);
        return true;
      }
      _error = response.error?.message ?? 'Failed to settle tab';
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

  Future<bool> deleteTab(String id) async {
    try {
      final response = await _service.deleteTab(id);
      if (response.success) {
        _tabs.removeWhere(
          (t) => (t as Map<String, dynamic>)['id'] == id,
        );
        if (_selectedTab?['id'] == id) _selectedTab = null;
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to delete tab';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateTabInList(String id, Map<String, dynamic> updated) {
    final idx = _tabs.indexWhere(
      (t) => (t as Map<String, dynamic>)['id'] == id,
    );
    if (idx != -1) _tabs[idx] = updated;
    if (_selectedTab?['id'] == id) _selectedTab = updated;
    notifyListeners();
  }
}
