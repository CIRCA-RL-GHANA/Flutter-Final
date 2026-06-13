/// ═══════════════════════════════════════════════════════════════════════════
/// Subscriptions Provider — State Management
///
/// Manages subscription plans and active subscriptions.
/// Delegates all API calls to SubscriptionsService.
/// ═══════════════════════════════════════════════════════════════════════════
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/subscriptions_service.dart';

class SubscriptionsProvider extends ChangeNotifier {
  final SubscriptionsService _service;

  SubscriptionsProvider({SubscriptionsService? service})
      : _service = service ?? SubscriptionsService();

  // ─── State ────────────────────────────────────────────────────────────────

  List<dynamic> _plans = [];
  List<dynamic> get plans => _plans;

  Map<String, dynamic>? _activeSub;
  Map<String, dynamic>? get activeSub => _activeSub;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Plans ────────────────────────────────────────────────────────────────

  Future<void> loadPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getPlans();
      if (response.success && response.data != null) {
        _plans = response.data!;
      } else {
        _plans = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _plans = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Active Subscription ──────────────────────────────────────────────────

  Future<void> loadActiveSubscription(
    String targetType,
    String targetId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getActiveSubscription(
        targetType,
        targetId,
      );
      if (response.success && response.data != null) {
        _activeSub = response.data;
      } else {
        _activeSub = null;
        _error = response.error?.message;
      }
    } catch (e) {
      _activeSub = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> activateSubscription(
    String planId,
    String targetType,
    String targetId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.activateSubscription(
        planId,
        targetType,
        targetId,
      );
      if (response.success && response.data != null) {
        _activeSub = response.data;
        notifyListeners();
        return response.data;
      }
      _error = response.error?.message ?? 'Failed to activate subscription';
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

  Future<bool> cancelSubscription(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.cancelSubscription(id);
      if (response.success) {
        _activeSub = null;
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to cancel subscription';
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
}
