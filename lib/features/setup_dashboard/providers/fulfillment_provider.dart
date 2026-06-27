/// 
/// Fulfillment Provider  State Management
///
/// Manages fulfillment rules and dispatch tasks.
/// Delegates all API calls to FulfillmentService.
/// 
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/fulfillment_service.dart';

class FulfillmentProvider extends ChangeNotifier {
  final FulfillmentService _service;

  FulfillmentProvider({FulfillmentService? service})
      : _service = service ?? FulfillmentService();

  //  State 

  List<dynamic> _rules = [];
  List<dynamic> get rules => _rules;

  List<dynamic> _tasks = [];
  List<dynamic> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  //  Rules 

  Future<void> loadRules(String entityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.listRules(entityId);
      if (response.success && response.data != null) {
        _rules = response.data!;
      } else {
        _rules = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _rules = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createRule(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.createRule(data);
      if (response.success && response.data != null) {
        _rules.insert(0, response.data!);
        notifyListeners();
        return response.data;
      }
      _error = response.error?.message ?? 'Failed to create rule';
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

  //  Tasks 

  Future<void> loadTasks(String entityId, {String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.listTasks(entityId, status: status);
      if (response.success && response.data != null) {
        _tasks = response.data!;
      } else {
        _tasks = [];
        _error = response.error?.message;
      }
    } catch (e) {
      _tasks = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> dispatchTask(
    String entityId, {
    String? orderId,
    String? overrideProvider,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.dispatchTask(
        entityId,
        orderId: orderId,
        overrideProvider: overrideProvider,
      );
      if (response.success && response.data != null) {
        _tasks.insert(0, response.data!);
        notifyListeners();
        return response.data;
      }
      _error = response.error?.message ?? 'Failed to dispatch task';
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
}
