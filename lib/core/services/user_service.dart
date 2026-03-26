import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

/// Service for user registration, onboarding, and user management.
/// Maps directly to the backend UsersController endpoints.
class UserService {
  final ApiClient _api;

  UserService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Register a new user.
  /// Returns { userId, message }.
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String phoneNumber,
    required String socialUsername,
    required String wireId,
    required String password,
    String? firstName,
    String? lastName,
    String? email,
    String? deviceFingerprint,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.users.register,
      data: {
        'phoneNumber': phoneNumber,
        'socialUsername': socialUsername,
        'wireId': wireId,
        'password': password,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
        if (deviceFingerprint != null) 'deviceFingerprint': deviceFingerprint,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Check if a phone number exists in the system.
  /// Returns { exists: bool, phoneNumber: string }.
  Future<ApiResponse<Map<String, dynamic>>> checkPhone(
    String phoneNumber,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.users.checkPhone,
      data: {'phoneNumber': phoneNumber},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Check if a username is available.
  /// Returns { available: bool, username: string }.
  Future<ApiResponse<Map<String, dynamic>>> checkUsername(
    String username,
  ) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.users.checkUsername(username),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Verify OTP code.
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.users.verifyOtp,
      data: {
        'phoneNumber': phoneNumber,
        'code': code,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Resend OTP to phone number.
  Future<ApiResponse<Map<String, dynamic>>> resendOtp(
    String phoneNumber,
  ) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.users.resendOtp,
      data: {'phoneNumber': phoneNumber},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Update biometric verification status.
  Future<ApiResponse<Map<String, dynamic>>> verifyBiometric({
    required String userId,
    required bool biometricStatus,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.users.verifyBiometric,
      data: {
        'userId': userId,
        'biometricStatus': biometricStatus,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Set PIN for user.
  Future<ApiResponse<Map<String, dynamic>>> setPin({
    required String userId,
    required String entityId,
    required String pin,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.users.setPin,
      data: {
        'userId': userId,
        'entityId': entityId,
        'pin': pin,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Assign staff role to user.
  Future<ApiResponse<Map<String, dynamic>>> assignStaffRole({
    required String adminId,
    required String userId,
    required String entityId,
    required String role,
    required String pin,
    bool isBranch = false,
    String? posId,
    String? branchId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.users.assignStaff,
      data: {
        'adminId': adminId,
        'userId': userId,
        'entityId': entityId,
        'role': role,
        'pin': pin,
        'isBranch': isBranch,
        if (posId != null) 'posId': posId,
        if (branchId != null) 'branchId': branchId,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get user by ID.
  Future<ApiResponse<Map<String, dynamic>>> getUserById(String id) async {
    return _api.get<Map<String, dynamic>>(
      ApiRoutes.users.byId(id),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
