import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_response.dart';
import '../constants/env_config.dart';
import '../constants/error_codes.dart';

/// Centralized API client for all backend communication.
/// Handles authentication, interceptors, error handling, and response parsing.
class ApiClient {
  static final String _defaultBaseUrl = EnvConfig.baseUrl;
  static const String _tokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  bool _initialized = false;

  // Singleton
  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  /// Expose the underlying Dio instance for services that construct with a
  /// raw Dio (e.g. ChatService, OrdersService).  The instance carries all
  /// configured interceptors, base URL and timeout settings.
  Dio get dio => _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _defaultBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    _setupInterceptors();
  }

  /// Initialize secure storage (call in main.dart)
  Future<void> init() async {
    _cachedAccessToken = await _secureStorage.read(key: _tokenKey);
    _cachedRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
    _initialized = true;
  }

  /// Override the base URL (useful for different environments)
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach auth token if available
          if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_cachedAccessToken';
          }

          if (kDebugMode) {
            debugPrint('→ ${options.method} ${options.baseUrl}${options.path}');
            final sensitivePatterns = ['/auth/', '/users/set-pin', '/users/verify', '/users/register', '/users/verify-otp'];
            final isSensitive = sensitivePatterns.any((p) => options.path.contains(p));
            if (options.data != null && !isSensitive) {
              debugPrint('  Body: ${options.data}');
            } else if (options.data != null && isSensitive) {
              debugPrint('  Body: [REDACTED - sensitive endpoint]');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '← ${response.statusCode} ${response.requestOptions.path}',
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            debugPrint(
              '✗ ${error.response?.statusCode ?? "?"} ${error.requestOptions.path}: ${error.message}',
            );
          }

          // Handle 401 — try token refresh (skip if this IS a refresh request or already retried)
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['isRefreshRequest'] != true &&
              error.requestOptions.extra['retried'] != true) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Retry original request with new token
              error.requestOptions.extra['retried'] = true;
              error.requestOptions.headers['Authorization'] = 'Bearer $_cachedAccessToken';
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Try to refresh the access token using the refresh token
  Future<bool> _tryRefreshToken() async {
    if (_cachedRefreshToken == null || _cachedRefreshToken!.isEmpty) return false;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': _cachedRefreshToken},
        options: Options(
          extra: {'isRefreshRequest': true},
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        await saveTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );
        return true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Token refresh failed: $e');
    }

    // Refresh failed — clear tokens
    await clearTokens();
    return false;
  }

  // ─── Token Management ─────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await _secureStorage.write(key: _tokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Exposes the cached access token for services that need it (e.g. WebSocket reconnect).
  String? get cachedToken => _cachedAccessToken;

  bool get isAuthenticated {
    return _cachedAccessToken != null && _cachedAccessToken!.isNotEmpty;
  }

  // ─── HTTP Methods ─────────────────────────────────

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    assert(_initialized, 'ApiClient.init() must be called before making requests');
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return _handleGenericError<T>(e);
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    assert(_initialized, 'ApiClient.init() must be called before making requests');
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return _handleGenericError<T>(e);
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    assert(_initialized, 'ApiClient.init() must be called before making requests');
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return _handleGenericError<T>(e);
    }
  }

  /// Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    assert(_initialized, 'ApiClient.init() must be called before making requests');
    try {
      final response = await _dio.patch(path, data: data);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return _handleGenericError<T>(e);
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    assert(_initialized, 'ApiClient.init() must be called before making requests');
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return _handleGenericError<T>(e);
    }
  }

  /// Upload a file using multipart form data
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? extraFields,
    T Function(dynamic json)? fromJson,
  }) async {
    assert(_initialized, 'ApiClient.init() must be called before making requests');
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (extraFields != null) ...extraFields,
      });

      final response = await _dio.post(path, data: formData);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return _handleGenericError<T>(e);
    }
  }

  // ─── Response Handling ────────────────────────────

  /// Parse backend response envelope: { data, statusCode, timestamp, path }
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final responseData = response.data;

    if (responseData == null) {
      return ApiResponse<T>(success: true, data: null);
    }

    // Check if response is error (4xx)
    if (response.statusCode != null && response.statusCode! >= 400) {
      return _parseErrorResponse<T>(responseData, response.statusCode!);
    }

    // Backend wraps successful responses in { data: ..., statusCode, timestamp, path }
    if (responseData is Map<String, dynamic>) {
      final payload = responseData.containsKey('data')
          ? responseData['data']
          : responseData;

      T? parsed;
      if (fromJson != null && payload != null) {
        parsed = fromJson(payload);
      } else if (payload is T) {
        parsed = payload;
      }

      return ApiResponse<T>(
        success: true,
        data: parsed,
        statusCode: (responseData['statusCode'] as num?)?.toInt() ?? response.statusCode,
        timestamp: responseData['timestamp'] as String?,
        path: responseData['path'] as String?,
      );
    }

    return ApiResponse<T>.success(responseData as T);
  }

  ApiResponse<T> _parseErrorResponse<T>(dynamic data, int statusCode) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      final errorStr = data['error'] as String? ?? 'ERROR';

      return ApiResponse<T>.failure(
        ApiError(
          code: errorStr,
          message: message is List ? message.join(', ') : message?.toString() ?? 'Request failed',
          details: data,
        ),
        statusCode: statusCode,
      );
    }

    return ApiResponse<T>.failure(
      const ApiError(code: 'UNKNOWN', message: 'An unexpected error occurred'),
      statusCode: statusCode,
    );
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    String code = ErrorCodes.networkError;
    String message = 'A network error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        code = ErrorCodes.timeout;
        message = 'Connection timed out. Try again.';
        break;
      case DioExceptionType.connectionError:
        code = ErrorCodes.connectionRefused;
        message = 'Cannot connect to server. Please check your connection.';
        break;
      case DioExceptionType.badResponse:
        if (error.response != null) {
          return _parseErrorResponse<T>(
            error.response!.data,
            error.response!.statusCode ?? 500,
          );
        }
        break;
      case DioExceptionType.cancel:
        code = 'REQUEST_CANCELLED';
        message = 'Request was cancelled.';
        break;
      default:
        break;
    }

    return ApiResponse<T>.failure(
      ApiError(code: code, message: message),
    );
  }

  ApiResponse<T> _handleGenericError<T>(Object error) {
    return ApiResponse<T>.failure(
      ApiError(
        code: ErrorCodes.internalServerError,
        message: 'An unexpected error occurred: ${error.toString()}',
      ),
    );
  }
}
