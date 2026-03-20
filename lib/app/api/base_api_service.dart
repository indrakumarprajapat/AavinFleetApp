import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../data/data_service.dart';
import 'api_exception.dart';
import 'package:dio/dio.dart' as dioD;
import 'package:dio/dio.dart' hide MultipartFile, FormData;

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

  // Upload helper (Multipart)
  // Future<T> upload<T>({
  //   required String path,
  //   required Map<String, dynamic> fields,
  //   List<File>? files,
  //   T Function(dynamic data)? parser,
  //   Options? options,
  // }) async {
  //   // final form = FormData();
  //   final formData = dioD.FormData.fromMap({
  //     'file': await dioD.MultipartFile.fromFile(file.path),
  //     'jsondata': '{"lat":$lat,"lng":$lng}',
  //     'code': 'BOOTH_UPDATE',
  //   });
  //
  //   // append fields
  //   fields.forEach((k, v) {
  //     form.fields.add(MapEntry(k, v == null ? '' : v.toString()));
  //   });
  //
  //   // append files
  //   if (files != null && files.isNotEmpty) {
  //     for (final f in files) {
  //       final filename = f.path.split(Platform.pathSeparator).last;
  //       form.files.add(
  //         MapEntry(
  //           'file',
  //           MultipartFile.fromFileSync(f.path, filename: filename),
  //         ),
  //       );
  //     }
  //   }
  //
  //   try {
  //     final response = await dio.post(
  //       path,
  //       data: form,
  //       options: options?.copyWith(
  //         headers: {
  //           ...?options.headers,
  //           'Content-Type': 'multipart/form-data',
  //         },
  //       ) ??
  //           Options(headers: {'Content-Type': 'multipart/form-data'}),
  //     );
  //     return parser != null ? parser(response.data) : response.data as T;
  //   } on DioException catch (e) {
  //     throw _handleDioError(e);
  //   } catch (e) {
  //     throw ApiException(e.toString());
  //   }
  // }

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
