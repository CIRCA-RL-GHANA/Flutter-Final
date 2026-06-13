/// ═══════════════════════════════════════════════════════════════════════════
/// Wishlist Provider — State Management
///
/// Manages wishlist items, high-priority items, and purchase tracking.
/// Delegates all API calls to WishlistService.
/// ═══════════════════════════════════════════════════════════════════════════
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _service;

  WishlistProvider({WishlistService? service})
      : _service = service ?? WishlistService();

  // ─── State ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  List<Map<String, dynamic>> _highPriority = [];
  List<Map<String, dynamic>> get highPriority => _highPriority;

  Map<String, dynamic>? _totalValue;
  Map<String, dynamic>? get totalValue => _totalValue;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadWishlist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getWishlist();
      if (response.success && response.data != null) {
        _items = response.data!
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        _items = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _items = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHighPriority() async {
    try {
      final response = await _service.getHighPriorityItems();
      if (response.success && response.data != null) {
        _highPriority = response.data!
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        notifyListeners();
      }
    } catch (_) {
      // keep existing data
    }
  }

  // ─── Create ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> addItem(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.addItem(
        name: data['name'] as String? ?? '',
        estimatedPrice: (data['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
        priority: data['priority'] as String? ?? 'medium',
        category: data['category'] as String? ?? '',
        notes: data['notes'] as String?,
      );
      if (response.success && response.data != null) {
        _items.insert(0, response.data!);
        notifyListeners();
        return response.data;
      }
      _error = response.error?.message ?? 'Failed to add wishlist item';
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

  Future<bool> updateItem(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _service.updateItem(id, updates);
      if (response.success && response.data != null) {
        final idx = _items.indexWhere((i) => i['id'] == id);
        if (idx != -1) _items[idx] = response.data!;
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to update item';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsPurchased(String id, {double? price}) async {
    try {
      final response = await _service.markAsPurchased(id: id, actualPrice: price ?? 0.0);
      if (response.success && response.data != null) {
        final idx = _items.indexWhere((i) => i['id'] == id);
        if (idx != -1) _items[idx] = response.data!;
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to mark as purchased';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<bool> deleteItem(String id) async {
    try {
      final response = await _service.deleteItem(id);
      if (response.success) {
        _items.removeWhere((i) => i['id'] == id);
        _highPriority.removeWhere((i) => i['id'] == id);
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to delete item';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
