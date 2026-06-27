/// 
/// Statement Provider  State Management
///
/// Manages the user's personal statement.
/// Delegates all API calls to StatementService.
/// 
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/statement_service.dart';

class StatementProvider extends ChangeNotifier {
  final StatementService _service;

  StatementProvider({StatementService? service})
      : _service = service ?? StatementService();

  //  State 

  Map<String, dynamic>? _statement;
  Map<String, dynamic>? get statement => _statement;

  bool _hasStatement = false;
  bool get hasStatement => _hasStatement;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  //  Load 

  Future<void> loadStatement() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final existsResponse = await _service.hasStatement();
      if (existsResponse.success && existsResponse.data != null) {
        _hasStatement = existsResponse.data!['exists'] as bool? ?? false;
      }

      if (_hasStatement) {
        final response = await _service.getStatement();
        if (response.success && response.data != null) {
          _statement = response.data;
        } else {
          _error = response.error?.message;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  Create / Update 

  Future<bool> createOrUpdate(String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.createOrUpdate(content);
      if (response.success && response.data != null) {
        _statement = response.data;
        _hasStatement = true;
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to save statement';
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

  //  Delete 

  Future<bool> delete() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.deleteStatement();
      if (response.success) {
        _statement = null;
        _hasStatement = false;
        notifyListeners();
        return true;
      }
      _error = response.error?.message ?? 'Failed to delete statement';
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
