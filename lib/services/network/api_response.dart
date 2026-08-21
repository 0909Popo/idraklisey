/// 📦 Standardized API Response Wrapper
/// Tüm network isteklerinin dönüş formatı
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.statusCode,
  });

  /// Success response
  factory ApiResponse.success({
    required T data,
    String? message,
    int statusCode = 200,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Error response
  factory ApiResponse.error({
    required String message,
    String? errorCode,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }

  /// Network error (no connection)
  factory ApiResponse.networkError() {
    return ApiResponse(
      success: false,
      message: 'İnternet bağlantısı yoxdur. Zəhmət olmasa yenidən cəhd edin.',
      errorCode: 'NETWORK_ERROR',
    );
  }

  /// Timeout error
  factory ApiResponse.timeout() {
    return ApiResponse(
      success: false,
      message: 'Sorğu çox uzun çəkdi. Zəhmət olmasa yenidən cəhd edin.',
      errorCode: 'TIMEOUT',
    );
  }

  /// Server error
  factory ApiResponse.serverError([String? customMessage]) {
    return ApiResponse(
      success: false,
      message: customMessage ?? 'Server xətası baş verdi. Zəhmət olmasa sonra yenidən cəhd edin.',
      errorCode: 'SERVER_ERROR',
      statusCode: 500,
    );
  }

  /// Unauthorized (401)
  factory ApiResponse.unauthorized() {
    return ApiResponse(
      success: false,
      message: 'Sistemə giriş tələb olunur. Zəhmət olmasa yenidən daxil olun.',
      errorCode: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  /// Forbidden (403)
  factory ApiResponse.forbidden() {
    return ApiResponse(
      success: false,
      message: 'Bu əməliyyat üçün icazəniz yoxdur.',
      errorCode: 'FORBIDDEN',
      statusCode: 403,
    );
  }

  /// Not found (404)
  factory ApiResponse.notFound([String? resource]) {
    return ApiResponse(
      success: false,
      message: resource != null 
          ? '$resource tapılmadı.' 
          : 'Sorğu olunan məlumat tapılmadı.',
      errorCode: 'NOT_FOUND',
      statusCode: 404,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, errorCode: $errorCode, statusCode: $statusCode)';
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (code: $errorCode, status: $statusCode)';
}
