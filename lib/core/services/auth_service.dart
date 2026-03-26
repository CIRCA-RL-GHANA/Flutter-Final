import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for authentication operations.
/// Handles login, logout, token management, and session validation.
class AuthService {
  final ApiClient _api;

  AuthService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Login with phone number/username and password.
  /// Returns user info and JWT tokens.
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiRoutes.auth.login,
      data: {
        'identifier': identifier,
        'password': password,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Save tokens on successful login
    if (response.success && response.data != null) {
      final tokens = response.data!['tokens'] as Map<String, dynamic>?;
      if (tokens != null) {
        await _api.saveTokens(
          accessToken: tokens['accessToken'] as String,
          refreshToken: tokens['refreshToken'] as String,
        );
      }
    }

    return response;
  }

  /// Get the current authenticated user's info.
  Future<ApiResponse<Map<String, dynamic>>> getMe() async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.auth.me,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Refresh the access token.
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.auth.refresh,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Logout and clear tokens.
  Future<void> logout() async {
    try {
      await _api.post(ApiRoutes.auth.logout);
    } finally {
      await _api.clearTokens();
    }
  }

  /// Check if user is currently authenticated.
  bool get isAuthenticated => _api.isAuthenticated;
}
