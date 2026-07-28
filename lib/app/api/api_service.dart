import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart' hide MultipartFile, FormData;
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';
import '../data/session_manager.dart';
import '../models/device_info.dart';
import '../models/credit_outstanding_model.dart';
import '../models/models.dart';
import '../models/razorpay-order-response.dart';
import '../models/route_detail.dart';

class ApiService extends GetxService {
  late Dio _dio;

  @override
  void onInit() {
    super.onInit();

    String base = ApiConstants.baseUrl;
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    
    _dio = Dio(
      BaseOptions(
        baseUrl: '$base/${ApiConstants.apiSocietyPrefix}',
        connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final session = Get.find<SessionManager>();
          var fleetUser = session.fleetUser.value;
          // 👇 Only attach token for protected APIs
          if (fleetUser?.accessToken != null && !_isPreLoginApi(options.path)) {
            print('--Read interceptor--');
            print(fleetUser?.accessToken);
            options.headers['Authorization'] = 'Bearer ${fleetUser?.accessToken}';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final session = Get.find<SessionManager>();
            
            // Clear session and redirect to login
            await session.clearSession();
            
            Get.offAllNamed('/login'); // Use string literal if Routes.LOGIN is not available here, or check AppPages
            
            Get.dialog(
              AlertDialog(
                title: const Text("Session Expired"),
                content: const Text("Your session has expired or you have logged in from another device. Please login again."),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("OK"),
                  ),
                ],
              ),
              barrierDismissible: false,
            );
          }
          handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }
  bool _isPreLoginApi(String path) {
    return path.contains('/auth/');
  }
  // void setAccessToken(String token) {
  //   _accessToken = token;
  //
  //   // Optional: also persist
  //   final storage = GetStorage();
  //   storage.write('access_token', token);
  // }

  Future<FleetUser> loginWithPassword(String username, String password,
      {double? lat, double? lng}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );

      // Validate response success flag if present
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('success') && data['success'] == false) {
          throw data['message'] ?? 'Invalid credentials';
        }

        // Some backends return 200 OK but with an error status in the body
        if (data.containsKey('status') && (data['status'] == 'error' || data['status'] == false)) {
          throw data['message'] ?? 'Invalid credentials';
        }

        return FleetUser.fromJson(data['data'] ?? data);
      }

      return FleetUser.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  Future<Map<String, dynamic>> checkAppVersion() async {
    try {
      final response = await _dio.get('/app-version');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }


  Future<FleetUser> agentAutoLogin(
    String accessToken,
    DeviceInfo deviceInfo,
    String versionStr, {
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/autologin',
        data: {
          'accessToken': accessToken,
          "login_device": deviceInfo.loginDevice,
          "d_os_api": deviceInfo.dOsApi,
          "d_manufacture": deviceInfo.dManufacture,
          "d_model": deviceInfo.dModel,
          "d_os_version": deviceInfo.dOsVersion,
          "app_cur_version": versionStr,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );
      return FleetUser.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  /*
   * OLD APIS
   */

  Future<FleetUser> loginWithOtp(String mobileNumber, {double? lat, double? lng}) async {
    try {
      final response = await _dio.post(
        '/account/login',
        data: {
          'username': mobileNumber,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );
      return FleetUser.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }


  Future<Map<String, dynamic>> forgotPassword({
    required String mobileNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {
          'mobileNumber': mobileNumber,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtpAndResetPassword({
    required String mobileNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp-reset',
        data: {
          'mobileNumber': mobileNumber,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      final data = response.data;
      if (data is Map && data.containsKey('success') && data['success'] == false) {
        throw data['message'] ?? 'Failed to reset password';
      }

      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put(
        '/account/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<FleetUser> agentVerifyOtp(String accessToken,
      String otp,) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'accessToken': accessToken, 'otp': otp},
      );
      return FleetUser.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> agentResendOtp(String accessToken) async {
    try {
      final response = await _dio.post(
        '/auth/resend-otp',
        data: {'accessToken': accessToken},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }


  Future<List<SlotModel>> getAgentSlots() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/agent/slots',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data is Map && response.data['slots'] != null) {
        final slots = response.data['slots'] as List? ?? [];
        return slots.map((slot) => SlotModel.fromJson(slot)).toList();
      } else if (response.data is List) {
        final slots = response.data as List;
        return slots.map((slot) => SlotModel.fromJson(slot)).toList();
      }

      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<FleetUser> verifyKyc({
    bool? isAadhaarKycVerified,
    bool? isPanKycVerified,
    bool? hasBankAccountVerified,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final data = <String, dynamic>{};
      if (isAadhaarKycVerified != null) data['isAadhaarKycVerified'] = isAadhaarKycVerified;
      if (isPanKycVerified != null) data['isPanKycVerified'] = isPanKycVerified;
      if (hasBankAccountVerified != null) data['hasBankAccountVerified'] = hasBankAccountVerified;

      final response = await _dio.put(
        '/account/verify-kyc',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return FleetUser.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<FleetUser> updateBoothLocation({
    required File file,
    required double lat,
    required double lng,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      print('=== Booth Location Update ===');
      print('Access Token: $accessToken');
      print('Lat: $lat, Lng: $lng');

      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),
        'lat': lat,
        'lng': lng,
      });

      final response = await _dio.put(
        '/society/location',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      return FleetUser.fromJson(response.data);
    } catch (e) {
      print('Booth location update error: $e');
      throw _handleError(e);
    }
  }

  Future<FleetUser> updateAgentDetails({
    String? name,
    String? aadharNumber,
    String? panNumber,
    String? accountNumber,
    String? accountHolderName,
    String? ifscCode,
    String? bankName,
    String? bankBranch,
    required int reqType,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final data = <String, dynamic>{'reqType': reqType};
      if (name != null) data['name'] = name;
      if (aadharNumber != null) data['aadharNumber'] = aadharNumber;
      if (panNumber != null) data['panNumber'] = panNumber;
      if (accountNumber != null) data['accountNumber'] = accountNumber;
      if (accountHolderName != null)
        data['accountHolderName'] = accountHolderName;
      if (ifscCode != null) data['ifscCode'] = ifscCode;
      if (bankName != null) data['bankName'] = bankName;
      if (bankBranch != null) data['bankBranch'] = bankBranch;

      final response = await _dio.put(
        '/account/update-details',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return FleetUser.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ProductModel>> getProductsByOrderType(int orderType) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/products-by-type',
        queryParameters: {
          'orderType': orderType,
          // 'shiftType': shiftType,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final products = response.data as List? ?? [];
      return products.map((product) => ProductModel.fromJson(product)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RazorpayOrderResponse> getRazorPayOrderId(double amount) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final data = {'amount': amount};
      final response = await _dio.post(
        '/orders/razorpay/initiate',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      final responseData = response.data;
      return RazorpayOrderResponse.fromJson(responseData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<OrderModel> createOrder({
    required int orderType,
    required int shiftType,
    required int slotId,
    required bool isEstimate,
    int? paymentMethod,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final data = {
        'orderType': orderType,
        'shiftType': shiftType,
        'slotId': slotId,
        'isEstimate': isEstimate,
      };
      if (paymentMethod != null) data['paymentMethod'] = paymentMethod;

      final response = await _dio.post(
        '/orders',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      final responseData = response.data;
      return OrderModel.fromJson(responseData['order'] ?? responseData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateCart({
    required int productId,
    required double quantity,
    required int shiftType,
    required int slotId,
    required int orderType,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/cart',
        data: {
          'productId': productId,
          'quantity': quantity,
          'shiftType': shiftType,
          'slotId': slotId,
          'orderType': orderType
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Future<Map<String, dynamic>> getCartEstimate({int? shiftType}) async {
  //   try {
  //     final storage = GetStorage();
  //     final accessToken = storage.read('access_token');
  //
  //     final dioClient = Dio(
  //       BaseOptions(
  //         baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
  //         connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
  //         receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
  //       ),
  //     );
  //
  //     final queryParams = <String, dynamic>{};
  //     if (shiftType != null) {
  //       queryParams['shiftType'] = shiftType;
  //     }
  //
  //     final response = await dioClient.get(
  //       '/cart/count',
  //       queryParameters: queryParams,
  //       options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  //     );
  //     return response.data;
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  Future<CartResponseModel> getCartItems({int? shiftType}) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final queryParams = <String, dynamic>{};
      if (shiftType != null) queryParams['shiftType'] = shiftType;

      final response = await _dio.get(
        '/cart',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return CartResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<OrderModel>> getOrders(Map<String, dynamic> queryParams) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/orders',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final orders = response.data as List? ?? [];
      return orders.map((order) => OrderModel.fromJson(order)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<OrderModel> getOrderDetails(int orderId) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/orders/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final responseData = response.data;
      final orderData = responseData['order'] ?? responseData;

      if (responseData['items'] != null) {
        orderData['items'] = responseData['items'];
      }

      return OrderModel.fromJson(orderData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/categories',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final categories = response.data as List? ?? [];
      return categories
          .map((category) => CategoryModel.fromJson(category))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ProductModel>> getOtherProducts(int categoryId) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/other-products',
        queryParameters: {'categoryId': categoryId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final products = response.data as List? ?? [];
      return products.map((product) => ProductModel.fromJson(product)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ProductModel>> getPopularProducts() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/popular-products',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final products = response.data as List? ?? [];
      return products.map((product) => ProductModel.fromJson(product)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/products/$productId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getOrdersCard() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/orders-card',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(int orderId,
      int status,) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.put(
        '/orders-card/$orderId/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<FleetUser> getAgentProfile() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/account/profile',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final responseData = response.data;
      final profile = responseData['data'] ?? responseData['agent'] ?? responseData;
      return FleetUser.fromJson(profile);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<FleetUser> uploadProfilePhoto(File file) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),
        'jsondata': '{}',
      });

      final response = await _dio.post(
        'account/upload-profile-photo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return FleetUser.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Future<Map<String, dynamic>> addFund({
  //   required double amount,
  //   required String paymentMethod,
  //   String? transactionId,
  //   String? description,
  // }) async {
  //   try {
  //     final storage = GetStorage();
  //     final accessToken = storage.read('access_token');
  //
  //     final data = {
  //       'amount': amount,
  //       'paymentMethod': paymentMethod,
  //     };
  //     if (transactionId != null) data['transactionId'] = transactionId;
  //     if (description != null) data['description'] = description;
  //
  //     final response = await _agentDio.post(
  //       '/wallet/add-fund',
  //       data: data,
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $accessToken',
  //           'Content-Type': 'application/json',
  //         },
  //       ),
  //     );
  //     return response.data;
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/wallet/balance',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getWalletTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/wallet/transactions',
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getWalletSummary() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/wallet/summary',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyPaymentAndAddFunds({
    required String paymentId,
    required String orderId,
    required String signature,
    required double amount,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/wallet/add-fund',
        data: {
          'amount': amount,
          'paymentMethod': 'Razorpay',
          'transactionId': paymentId,
          'orderId': orderId,
          'signature': signature,
          'description': 'Wallet recharge via Razorpay',
          'referenceType': 4, // Payment gateway reference
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createRazorpayOrder({
    required int orderType,
    int? morningSlotId,
    int? eveningSlotId,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/orders/create-razorpay-order',
        data: {
          'orderType': orderType,
          'morningSlotId': morningSlotId,
          'eveningSlotId': eveningSlotId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyPaymentAndUpdateOrders({
    required int transactionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/orders/verify-payment',
        data: {
          'transactionId': transactionId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          receiveTimeout: Duration(seconds: 60),
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createEasyPayOrder({
    required int orderType,
    int? morningSlotId,
    int? eveningSlotId,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/orders/create-easypay-order',
        data: {
          'orderType': orderType,
          'morningSlotId': morningSlotId,
          'eveningSlotId': eveningSlotId,
          'paymentGateway': 'easypay',
          'returnUrl': '${ApiConstants.baseUrl}api/easypay-callback',
          'clientIp': '15.206.249.5',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyEasyPayPayment({
    required int transactionId,
    required String encryptedResponse,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/orders/verify-easypay-payment',
        data: {
          'transactionId': transactionId,
          'encryptedResponse': encryptedResponse,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createCashfreeOrder({
    required int orderType,
    int? morningSlotId,
    int? eveningSlotId,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/orders/create-cashfree-order',
        data: {
          'orderType': orderType,
          'morningSlotId': morningSlotId,
          'eveningSlotId': eveningSlotId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyCashfreePayment({
    required int transactionId,
    required String orderId,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/orders/verify-cashfree-payment',
        data: {
          'transactionId': transactionId,
          'orderId': orderId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> handlePaymentFailure({
    required int transactionId,
    required String failureReason,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/orders/payment-failed',
        data: {'transactionId': transactionId, 'failureReason': failureReason},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> handleCashfreePaymentFailure({
    required int transactionId,
    required String orderId,
    String? failureReason,
    String? errorCode,
    String? paymentMethod,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/orders/cashfree-payment-failed',
        data: {
          'transactionId': transactionId,
          'orderId': orderId,
          if (failureReason != null) 'failureReason': failureReason,
          if (errorCode != null) 'errorCode': errorCode,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CreditOutstandingModel> getCreditOutstanding() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/credit-outstanding',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return CreditOutstandingModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getTransactions({
    int? type,
    String? fromDate,
    String? toDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (fromDate != null) queryParams['fromDate'] = fromDate;
      if (toDate != null) queryParams['toDate'] = toDate;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dio.get(
        '/transactions',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ClaimModel>> getClaims({
    int? status,
    String? fromDate,
    String? toDate,
    int? limit,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (fromDate != null) queryParams['fromDate'] = fromDate;
      if (toDate != null) queryParams['toDate'] = toDate;
      if (limit != null) queryParams['limit'] = limit;

      print(
        'Claims API call: ${_dio.options
            .baseUrl}/claims with params: $queryParams',
      );

      final response = await _dio.get(
        '/claims',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      print('Claims API response: ${response.data}');
      final claimsList = response.data as List? ?? [];
      print('Claims list length: ${claimsList.length}');
      return claimsList.map((json) => ClaimModel.fromJson(json)).toList();
    } catch (e) {
      print('Claims API error: $e');
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getDeliveredOrders() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      print(
        'Calling delivered orders API: ${_dio.options
            .baseUrl}/delivered-order',
      );

      final response = await _dio.get(
        '/delivered-order',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      print('Delivered orders API response: ${response.data}');
      return response.data as List? ?? [];
    } catch (e) {
      print('Delivered orders API error: $e');
      throw _handleError(e);
    }
  }

  Future<ClaimDetailsModel> getClaimDetails(int claimId) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/claims/$claimId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return ClaimDetailsModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createClaim({
    required int orderId,
    required String reason,
    String? description,
    List<File>? images,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final formData = dio.FormData();

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          formData.files.add(
            MapEntry('file', await dio.MultipartFile.fromFile(images[i].path)),
          );
        }
      }

      final jsonData = {
        'reason': reason,
        'description': description,
        'items': items,
      };
      formData.fields.add(MapEntry('jsondata', jsonEncode(jsonData)));

      final response = await _dio.post(
        '/orders/$orderId/claims',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateClaim({
    required int claimId,
    List<File>? images,
    String? description,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      print(
        'Update claim API call: ${_dio.options.baseUrl}/claims/$claimId',
      );
      print('Images count: ${images?.length ?? 0}');

      final formData = dio.FormData();

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          formData.files.add(
            MapEntry('file', await dio.MultipartFile.fromFile(images[i].path)),
          );
        }
      }

      final jsonData = description != null ? {'description': description} : {};
      formData.fields.add(MapEntry('jsondata', jsonEncode(jsonData)));

      final response = await _dio.put(
        '/claims/$claimId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Update claim response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Update claim error: $e');
      throw _handleError(e);
    }
  }


  Future<List<dynamic>> checkTrayCount() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/check-tray-count',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data as List? ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> clearCart() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.delete(
        '/cart/clear',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.put(
        '/orders/$orderId/cancel',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }


  fetchGoogleApiKey() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get('/google-api-key',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'x-app-signature': 'aavin-mobile-app-v1',
            'User-Agent': 'Aavin/1.0.0 (Flutter)',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['google_maps_api_key'] ?? '';
      }
    } catch (e) {
      print('Failed to fetch Google API key: $e');
    }
    return '';
  }


  Future<Map<String, dynamic>> getAppConfig({required int userType}) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/config',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getBanners() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/banners',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data as List? ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCommissionStatement({String? month}) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final queryParams = <String, dynamic>{};
      if (month != null) {
        queryParams['month'] = month;
      }

      final response = await _dio.get(
        '/commission-statement',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPaymentGateways() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/payment-gateways',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createCashfreeWalletOrder({
    required double amount,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/wallet/create-cashfree-order',
        data: {'amount': amount},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyCashfreeWalletPayment({
    required String orderId,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/wallet/verify-cashfree-payment',
        data: {'orderId': orderId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> handleCashfreeWalletPaymentFailure({
    required String orderId,
    String? failureReason,
    String? errorCode,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/wallet/cashfree-payment-failed',
        data: {
          'orderId': orderId,
          if (failureReason != null) 'failureReason': failureReason,
          if (errorCode != null) 'errorCode': errorCode,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }

  Future<Map<String, dynamic>> submitDailySupplies(
      Map<String, dynamic> suppliesData) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');
      print('suppliesData: $suppliesData');
      final response = await _dio.post(
        '/milk-supplies',
        data: suppliesData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  getMilkSupplies() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/milk-supplies',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMilkSupplyDetails(int id) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/milk-supplies/$id',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final responseData = error.response!.data;
        if (responseData is Map) {
          if (responseData['error'] != null &&
              responseData['error']['message'] != null) {
            return responseData['error']['message'];
          }
          if (responseData['message'] != null) {
            return responseData['message'];
          }
        }
        return responseData.toString();
      }
      if (error.response?.statusCode == 500) {
        return 'Server error. Please try again later.';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.receiveTimeout:
          return 'Server response timeout. Please try again.';
        case DioExceptionType.connectionError:
          return 'Connection error. Please check your internet connection.';
        case DioExceptionType.badResponse:
          return 'Server error. Please try again later.';
        default:
          return error.message ?? 'Network error. Please try again.';
      }
    }
    return error.toString();
  }

  //Fleet APIs

  // Future<dynamic> getTripSummary(int tripId) async {
  //   try {
  //     final storage = GetStorage();
  //     final accessToken = storage.read('access_token');
  //
  //     final response = await _dio.get(
  //       '/trips/gate-pass/$tripId/summary',
  //       options: Options(
  //         headers: {'Authorization': 'Bearer $accessToken'},
  //       ),
  //     );
  //
  //     final tripResponse = await getTrip(tripId: tripId);
  //     final tripData = (tripResponse is Map && tripResponse.containsKey('data'))
  //         ? tripResponse['data']
  //         : tripResponse;
  //
  //     if (response.data is Map) {
  //       final data = response.data as Map<String, dynamic>;
  //       if (tripData is Map) {
  //         data['pdfUrl'] = tripData['pdfUrl'] ?? tripData['routePdf'];
  //       }
  //       return data;
  //     }
  //
  //     return response.data;
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  //
  // Future<dynamic> getTrip({ tripId = 0}) async {
  //   try {
  //     final storage = GetStorage();
  //     final accessToken = storage.read('access_token');
  //
  //     final response = await _dio.get(
  //       '/trips/gate-pass/$tripId',
  //       options: Options(
  //           headers: {'Authorization': 'Bearer $accessToken'}),
  //     );
  //     return response.data;
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  Future<dynamic> startTrip(int tripId, double lat, double lng) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/trips/$tripId/start',
        data: {
          "lat": lat,
          "lng": lng,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> startTripCollection(int tripId, double lat, double lng) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/trips/$tripId/collection/start',
        data: {
          "lat": lat,
          "lng": lng,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> endTrip(int tripId, double lat, double lng) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/trips/$tripId/end',
        data: {
          "lat": lat,
          "lng": lng,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getTripBooths(int tripId, String s) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/trips/$tripId/delivery-booths',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final data = response.data;
      if (data is List) {
        return data;
      } else if (data is Map) {
        if (data['data'] is List) return data['data'];
        if (data['booths'] is List) return data['booths'];
        if (data['delivery_booths'] is List) return data['delivery_booths'];
      }

      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> markDelivered(
      int tripId,
      int boothId,
      int trayCount,
      double lat,
      double lng,
      ) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/trips/$tripId/delivery/$boothId',
        data: {
          "trayCount": trayCount,
          "lat": lat,
          "lng": lng,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> markCollected(
    int tripId,
    int boothId,
    int trayCollected,
    double lat,
    double lng,
  ) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.post(
        '/trips/$tripId/collection/$boothId',
        data: {
          "trayCollected": trayCollected,
          "lat": lat,
          "lng": lng,
          // "collectionStatus": trayCollected > 0 ? "COLLECTED" : "NOT_COLLECTED",
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getBoothDetails(int tripId, int boothId) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/trips/$tripId/booths/$boothId/delivery-note',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      return response.data as List? ?? [];
    } catch (e) {
      throw _handleError(e);
    }
  }


  Future<List<dynamic>> getCollectionBooths(int tripId) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _dio.get(
        '/trips/$tripId/collection-booths',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final data = response.data;
      if (data is List) {
        return data;
      } else if (data is Map) {
        if (data['data'] is List) return data['data'];
        if (data['booths'] is List) return data['booths'];
        if (data['collection_booths'] is List) return data['collection_booths'];
      }

      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Future<void> startCollection(int tripId) async{
  //   try{
  //     final storage = GetStorage();
  //     final accessToken = storage.read('access_token');
  //
  //     await _dio.post(
  //       '/trips/gate-pass/$tripId/collection/start',
  //       options: Options(headers:{'Authorization': 'Bearer $accessToken'}),
  //     );
  //   }catch(e){
  //     throw _handleError(e);
  //   }
  // }

  Future<RouteDetail> getRouteDetails() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');
      final response = await _dio.get(
        '/trips/gate-pass',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data;

      if (data is List && data.isNotEmpty) {
        return RouteDetail.fromJson(data[0]);
      }

      return RouteDetail.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Future<void> submitTrayCollection(int tripId, int boothId, int trays) async{
  //   try{
  //     final storage = GetStorage();
  //     final accessToken = storage.read('access_token');
  //
  //     await _dio.post(
  //       '/trips/gate-pass/$tripId/booths/$boothId/tray-collected',
  //       data: {'trays': trays},
  //       options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  //     );
  //   }catch(e){
  //     throw _handleError(e);
  //   }
  // }
}





