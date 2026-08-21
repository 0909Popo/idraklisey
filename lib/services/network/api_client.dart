import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_config.dart';
import 'api_response.dart';
import '../auth_storage_service.dart';

/// 🌐 HTTP Client - Dio based API Client
/// 
/// ⚠️ ŞU AN KULLANILMIYOR - ApiConfig.USE_MOCK_DATA = true
/// Gerçek API hazır olunca USE_MOCK_DATA = false yapılacak
class ApiClient {
  late final Dio _dio;
  final AuthStorageService _authStorage = AuthStorageService();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: ApiConfig.TIMEOUT_SECONDS),
        receiveTimeout: Duration(seconds: ApiConfig.TIMEOUT_SECONDS),
        headers: ApiConfig.defaultHeaders,
        validateStatus: (status) {
          // Accept all status codes to handle them manually
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors
    if (ApiConfig.ENABLE_LOGGING && kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Auth interceptor - session token ekler
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Session token varsa header'a ekle
          final sessionToken = await _authStorage.getSessionToken();
          if (sessionToken != null) {
            options.headers['Cookie'] = sessionToken;
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // 401 durumunda session'ı temizle
          if (error.response?.statusCode == 401) {
            await _authStorage.clearAll();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Response handler
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? parser,
  ) {
    final statusCode = response.statusCode ?? 0;

    // Success responses (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      T? data;
      if (parser != null) {
        data = parser(response.data);
      } else if (response.data is T) {
        data = response.data as T;
      }

      return ApiResponse.success(
        data: data as T,
        statusCode: statusCode,
      );
    }

    // Client errors (4xx)
    if (statusCode == 401) {
      return ApiResponse.unauthorized();
    }
    if (statusCode == 403) {
      return ApiResponse.forbidden();
    }
    if (statusCode == 404) {
      return ApiResponse.notFound();
    }

    // Other errors
    return ApiResponse.error(
      message: response.statusMessage ?? 'Bilinməyən xəta baş verdi',
      statusCode: statusCode,
    );
  }

  /// Error handler
  ApiResponse<T> _handleError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.timeout();

      case DioExceptionType.connectionError:
        return ApiResponse.networkError();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) return ApiResponse.unauthorized();
        if (statusCode == 403) return ApiResponse.forbidden();
        if (statusCode == 404) return ApiResponse.notFound();
        return ApiResponse.serverError(
          error.response?.statusMessage,
        );

      case DioExceptionType.cancel:
        return ApiResponse.error(message: 'Sorğu ləğv edildi');

      default:
        return ApiResponse.error(
          message: error.message ?? 'Bilinməyən xəta baş verdi',
        );
    }
  }
}
