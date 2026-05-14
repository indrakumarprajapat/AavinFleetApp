import 'package:dio/dio.dart';
import '../data/data_service.dart';
import 'api_exception.dart';

class BaseApiService {
  final Dio dio;

  BaseApiService(BaseOptions options)
      : dio = Dio(options) {
    // Basic interceptors: logging + auth header injection on request
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = DataService.to.accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        // default content type if not set
        options.headers['Content-Type'] ??= 'application/json';
        handler.next(options);
      },
      onError: (err, handler) {
        // transform to ApiException
        handler.next(err);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: false,
      responseHeader: false,
    ));
  }

  // Generic request wrapper
  Future<T> request<T>({
    required String path,
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    bool auth = false, // kept for readability, token injected automatically
    T Function(dynamic data)? parser, // parse response to model
    Duration? timeout,
  }) async {
    try {
      final opts = options?.copyWith(method: method) ?? Options(method: method);
      if (timeout != null) {
        opts.extra = {...?opts.extra, 'timeout': timeout};
      }

      final response = await dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts,
      );

      final responseData = response.data;
      if (parser != null) return parser(responseData);
      // fallback - return raw body if T == dynamic/Map
      return responseData as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ApiException _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String message = e.message ?? 'Unknown network error';

    // Try to extract server-provided message
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else if (data is String) {
      message = data;
    }

    return ApiException(message, statusCode: status, details: data);
  }
}
