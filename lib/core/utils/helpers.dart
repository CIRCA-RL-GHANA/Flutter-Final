import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer utility for text input
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

/// Phone number formatter per country
class PhoneFormatter {
  static String format(String number, String countryCode) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    switch (countryCode) {
      case 'US':
      case 'CA':
        return _formatUS(digits);
      case 'GB':
        return _formatUK(digits);
      case 'GH':
        return _formatGH(digits);
      default:
        return digits;
    }
  }

  static String _formatUS(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, digits.length.clamp(0, 10))}';
  }

  static String _formatUK(String digits) {
    if (digits.length <= 4) return digits;
    return '${digits.substring(0, 4)} ${digits.substring(4, digits.length.clamp(0, 10))}';
  }

  static String _formatGH(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return '${digits.substring(0, 3)} ${digits.substring(3)}';
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, digits.length.clamp(0, 10))}';
  }

  static int maxLength(String countryCode) {
    switch (countryCode) {
      case 'US':
      case 'CA':
        return 10;
      case 'GB':
        return 11;
      case 'GH':
        return 10;
      default:
        return 15;
    }
  }

  static bool isValid(String number, String countryCode) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    return digits.length >= maxLength(countryCode);
  }
}

/// Validation helpers
class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (value.trim().length < 2) return 'Must be at least 2 characters';
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
      return 'Only letters, spaces, hyphens, and apostrophes allowed';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.length < 3) return 'Must be at least 3 characters';
    if (value.length > 20) return 'Must be 20 characters or less';
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
      return 'Only lowercase letters, numbers, and underscores';
    }
    final reserved = ['admin', 'prompt', 'genie', 'support', 'help', 'system'];
    if (reserved.contains(value)) return 'This username is reserved';
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) return 'PIN is required';
    if (value.length < 4) return 'PIN must be at least 4 digits';
    if (value.length > 6) return 'PIN must be at most 6 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'PIN must contain only digits';
    // Check for simple patterns
    if (RegExp(r'^(\d)\1+$').hasMatch(value)) return 'PIN is too simple';
    return null;
  }
}
