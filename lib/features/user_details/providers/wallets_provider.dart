/// 
/// Wallets Provider  State Management
///
/// Manages wallet balance and wallet data.
/// Delegates all API calls to WalletsService.
/// 
library;

import 'package:flutter/foundation.dart';
import '../../../core/services/wallets_service.dart';

class WalletsProvider extends ChangeNotifier {
  final WalletsService _service;

  WalletsProvider({WalletsService? service})
      : _service = service ?? WalletsService();

  //  State 

  Map<String, dynamic>? _balance;
  Map<String, dynamic>? get balance => _balance;

  Map<String, dynamic>? _wallet;
  Map<String, dynamic>? get wallet => _wallet;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  //  Load 

  Future<void> loadBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getBalance();
      if (response.success && response.data != null) {
        _balance = response.data;
      } else {
        _error = response.error?.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getWallet();
      if (response.success && response.data != null) {
        _wallet = response.data;
      } else {
        _error = response.error?.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
