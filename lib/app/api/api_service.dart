import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart' hide MultipartFile, FormData;
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';
import '../models/DeviceInfo.dart';
import '../models/credit_outstanding_model.dart';
import '../models/models.dart';
import '../models/razorpay-order-response.dart';

class ApiService extends GetxService {
  late Dio _societyDio;

  @override
  void onInit() {
    super.onInit();
    _societyDio = Dio(
      BaseOptions(
        baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
        connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _societyDio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<ApiResponseModel> agentLogin(
    String mobileNumber,
    DeviceInfo deviceInfo,
    String versionStr,
  ) async {
    try {
      final response = await _societyDio.post(
        '/auth/login',
        data: {
          'username': mobileNumber,
          "login_device": deviceInfo.loginDevice,
          "d_os_api": deviceInfo.dOsApi,
          "d_manufacture": deviceInfo.dManufacture,
          "d_model": deviceInfo.dModel,
          "d_os_version": deviceInfo.dOsVersion,
          "app_cur_version": versionStr,
        },
      );
      return ApiResponseModel.fromJson(response.data, null);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> loginWithPassword(
    String username,
    String password,
  ) async {
    try {
      final response = await _societyDio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> agentForgotPassword(String username) async {
    try {
      final response = await _societyDio.post(
        '/auth/forgot-password',
        data: {'username': username},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp(
    String resetToken,
    String otp,
  ) async {
    try {
      final response = await _societyDio.post(
        '/auth/verify-reset-otp',
        data: {
          'resetToken': resetToken,
          'otp': otp,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String resetToken,
    String newPassword,
  ) async {
    try {
      final response = await _societyDio.post(
        '/auth/reset-password',
        data: {
          'resetToken': resetToken,
          'newPassword': newPassword,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<LoginResponseModel> agentVerifyOtp(
    String accessToken,
    String otp,
  ) async {
    try {
      final response = await _societyDio.post(
        '/auth/verify-otp',
        data: {'accessToken': accessToken, 'otp': otp},
      );
      return LoginResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> agentResendOtp(String accessToken) async {
    try {
      final response = await _societyDio.post(
        '/auth/resend-otp',
        data: {'accessToken': accessToken},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<LoginResponseModel> agentAutoLogin(
    String accessToken,
    DeviceInfo deviceInfo,
    String versionStr,
  ) async {
    try {
      final response = await _societyDio.post(
        '/auth/autologin',
        data: {
          'accessToken': accessToken,
          "login_device": deviceInfo.loginDevice,
          "d_os_api": deviceInfo.dOsApi,
          "d_manufacture": deviceInfo.dManufacture,
          "d_model": deviceInfo.dModel,
          "d_os_version": deviceInfo.dOsVersion,
          "app_cur_version": versionStr,
        },
      );
      return LoginResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<SlotModel>> getAgentSlots() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _societyDio.get(
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

  Future<ApiResponseModel> verifyKyc({
    bool? isAadhaarKycVerified,
    bool? isPanKycVerified,
    bool? hasBankAccountVerified,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final dioClient = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        ),
      );

      final data = hasBankAccountVerified != null
          ? {'hasBankAccountVerified': hasBankAccountVerified}
          : {
              'isAadhaarKycVerified': isAadhaarKycVerified,
              'isPanKycVerified': isPanKycVerified,
            };

      final response = await dioClient.put(
        '/account/verify-kyc',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return ApiResponseModel.fromJson(response.data, null);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponseModel> updateBoothLocation({
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

      final dioClient = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        ),
      );

      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),
        'jsondata': '{"lat":$lat,"lng":$lng}',
        'code': 'BOOTH_UPDATE',
      });

      final response = await dioClient.put(
        '/society/location',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      return ApiResponseModel.fromJson(response.data, null);
    } catch (e) {
      print('Booth location update error: $e');
      throw _handleError(e);
    }
  }

  Future<ApiResponseModel> updateAgentDetails({
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
      if (accountHolderName != null) data['accountHolderName'] = accountHolderName;
      if (ifscCode != null) data['ifscCode'] = ifscCode;
      if (bankName != null) data['bankName'] = bankName;
      if (bankBranch != null) data['bankBranch'] = bankBranch;

      final response = await _societyDio.put(
        '/account/update-details',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return ApiResponseModel.fromJson(response.data, null);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ProductModel>> getProductsByOrderType(int orderType) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final dioClient = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        ),
      );

      final response = await dioClient.get(
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

  Future<RazorpayOrderResponse> getRazorPayOrderId(
    double amount) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final data = {'amount': amount};
      final response = await _societyDio.post(
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

      final dioClient = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        ),
      );

      final data = {
        'orderType': orderType,
        'shift': shiftType,
        'slotId': slotId,
        'shiftType': shiftType,
        'isEstimate': isEstimate,
      };
      if (paymentMethod != null) data['paymentMethod'] = paymentMethod;

      final response = await _societyDio.post(
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

      final dioClient = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        ),
      );

      final response = await dioClient.post(
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

  Future<Map<String, dynamic>> getCartEstimate({int? shiftType}) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final dioClient = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        ),
      );

      final queryParams = <String, dynamic>{};
      if (shiftType != null) {
        queryParams['shiftType'] = shiftType;
      }

      final response = await dioClient.get(
        '/cart/count',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CartResponseModel> getCartItems({int? shiftType}) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final dioClient = Dio(
        BaseOptions(
          baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        ),
      );

      final queryParams = <String, int>{};
      if (shiftType != null) {
        queryParams['shiftType'] = shiftType;
      }

      final response = await dioClient.get(
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

      final response = await _societyDio.get(
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

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _societyDio.post(
        '/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
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

  Future<OrderModel> getOrderDetails(int orderId) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
        '/orders-card',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    int status,
  ) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _societyDio.put(
        '/orders-card/$orderId/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SocietyUser> getAgentProfile() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _societyDio.get(
        '/account/profile',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final responseData = response.data;
      return SocietyUser.fromJson(responseData['agent'] ?? responseData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponseModel> uploadProfilePhoto(File file) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),
        'jsondata': '{}',
      });

      final response = await _societyDio.post(
        '/account/upload-profile-photo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return ApiResponseModel.fromJson(response.data, null);
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.post(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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
        'Claims API call: ${_societyDio.options.baseUrl}/claims with params: $queryParams',
      );

      final response = await _societyDio.get(
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
        'Calling delivered orders API: ${_societyDio.options.baseUrl}/delivered-order',
      );

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.post(
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
        'Update claim API call: ${_societyDio.options.baseUrl}/claims/$claimId',
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

      final response = await _societyDio.put(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.delete(
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

      final response = await _societyDio.put(
        '/orders/$orderId/cancel',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> checkAppVersion() async {
    try {
      final response = await _societyDio.get('/app-version');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  fetchGoogleApiKey() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');

      final response = await _societyDio.get('/google-api-key',
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
      
      final response = await _societyDio.get(
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
      
      final response = await _societyDio.get(
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
      
      final response = await _societyDio.get(
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
      
      final response = await _societyDio.get(
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
      
      final response = await _societyDio.post(
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
      
      final response = await _societyDio.post(
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
      
      final response = await _societyDio.post(
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
    _societyDio.close();
    super.onClose();
  }

  Future<Map<String, dynamic>> submitDailySupplies(Map<String, dynamic> suppliesData) async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');
      print('suppliesData: $suppliesData');
      final response = await _societyDio.post(
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

      final response = await _societyDio.get(
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

      final response = await _societyDio.get(
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
}
