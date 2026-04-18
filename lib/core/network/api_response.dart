/// Standardized API response wrapper.
/// Matches the backend TransformInterceptor output format.
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final ApiError? error;
  final int? statusCode;
  final String? timestamp;
  final String? path;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
    this.timestamp,
    this.path,
  });

  /// Parse from the backend's standard response envelope.
  /// Backend wraps responses as: { data: <payload>, statusCode, timestamp, path }
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJsonT,
  }) {
    final rawData = json['data'];
    T? parsed;
    if (fromJsonT != null && rawData != null) {
      parsed = fromJsonT(rawData);
    } else if (rawData is T) {
      parsed = rawData;
    }

    return ApiResponse<T>(
      success: json['statusCode'] != null && (json['statusCode'] as int) < 400,
      data: parsed,
      statusCode: json['statusCode'] as int?,
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
    );
  }

  /// Create a success response
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(success: true, data: data, message: message);
  }

  /// Create an error response
  factory ApiResponse.failure(ApiError error, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  /// Alias for [success] — preferred form used throughout service layer.
  bool get isSuccess => success;

  /// Whether this response has data
  bool get hasData => data != null;

  /// Whether this response has an error
  bool get hasError => error != null;

  @override
  String toString() =>
      'ApiResponse(success=$success, data=$data, error=$error)';
}

/// Standardized API error.
class ApiError {
  final String code;
  final String message;
  final dynamic details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? json['error'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'An error occurred',
      details: json['details'],
    );
  }

  /// Friendly user-facing message
  String get userMessage {
    switch (code) {
      case 'NETWORK_ERROR':
        return 'No internet connection. Please check your network.';
      case 'TIMEOUT':
        return 'Request timed out. Please try again.';
      case 'UNAUTHORIZED':
        return 'Session expired. Please login again.';
      case 'INSUFFICIENT_BALANCE':
        return 'Insufficient QPoints balance for this transaction.';
      default:
        return message;
    }
  }

  @override
  String toString() => 'ApiError(code=$code, message=$message)';
}

/// Paginated response from the backend.
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return PaginatedResponse<T>(
      items: rawItems.map((item) => fromJsonT(item)).toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}
