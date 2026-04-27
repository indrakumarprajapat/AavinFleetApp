// import 'package:dio/dio.dart';
//
// import '../constants/api_constants.dart';
// import '../models/DeviceInfo.dart';
// import '../models/api_response_model.dart';
// import '../models/cart_model.dart';
// import '../models/order_model.dart';
// import '../models/razorpay-order-response.dart';
// import '../models/slot_model.dart';
// import 'base_api_service.dart';
// import 'dart:io';
// import '../models/product_model.dart';
// import '../models/earnings_model.dart';
// import '../models/commission_statement_model.dart';
// import '../models/commission_pdf_response_model.dart';
//
// class AgentApiService extends BaseApiService {
//   AgentApiService()
//       : super(
//     BaseOptions(
//       baseUrl: '${ApiConstants.baseUrl}/${ApiConstants.apiSocietyPrefix}',
//       connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
//       receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
//       headers: {'Content-Type': 'application/json'},
//     ),
//   );
//
//   Future<ApiResponseModel> login(
//       String mobileNumber,
//       DeviceInfo deviceInfo,
//       String versionStr,
//       ) =>
//       request<ApiResponseModel>(
//         path: '/login',
//         method: 'POST',
//         data: {
//           'mobileNumber': mobileNumber,
//           "login_device": deviceInfo.loginDevice,
//           "d_os_api": deviceInfo.dOsApi,
//           "d_manufacture": deviceInfo.dManufacture,
//           "d_model": deviceInfo.dModel,
//           "d_os_version": deviceInfo.dOsVersion,
//           "app_cur_version": versionStr,
//         },
//         parser: (d) => ApiResponseModel.fromJson(d, null),
//       );
//
//   Future<LoginResponseModel> verifyOtp(String accessToken, String otp) =>
//       request<LoginResponseModel>(
//         path: '/verify-otp',
//         method: 'POST',
//         data: {'accessToken': accessToken, 'otp': otp},
//         parser: (d) => LoginResponseModel.fromJson(d),
//       );
//
//   Future<List<SlotModel>> getSlots() =>
//       request<List<SlotModel>>(
//         path: '/agent/slots',
//         method: 'GET',
//         parser: (d) {
//           final slots = (d['slots'] as List? ?? []);
//           return slots.map((s) => SlotModel.fromJson(s)).toList();
//         },
//       );
//
//   // Future<ApiResponseModel> updateBoothLocation({
//   //   required File file,
//   //   required double lat,
//   //   required double lng,
//   // }) =>
//   //     upload<ApiResponseModel>(
//   //       path: '/booths/location',
//   //       fields: {
//   //         'jsondata': '{"lat":$lat,"lng":$lng}',
//   //         'code': 'BOOTH_UPDATE',
//   //       },
//   //       files: [file],
//   //       parser: (d) => ApiResponseModel.fromJson(d, null),
//   //     );
//
//   Future<ApiResponseModel> verifyKyc({
//     bool? isAadhaarKycVerified,
//     bool? isPanKycVerified,
//     bool? hasBankAccountVerified,
//   }) {
//     final data = hasBankAccountVerified != null
//         ? {'hasBankAccountVerified': hasBankAccountVerified}
//         : {
//       'isAadhaarKycVerified': isAadhaarKycVerified,
//       'isPanKycVerified': isPanKycVerified,
//     };
//
//     return request<ApiResponseModel>(
//       path: '/verify-kyc',
//       method: 'PUT',
//       data: data,
//       parser: (d) => ApiResponseModel.fromJson(d, null),
//     );
//   }
//
//   Future<ApiResponseModel> updateAgentDetails({
//     String? name,
//     String? aadharNumber,
//     String? panNumber,
//     String? accountNumber,
//     String? accountHolderName,
//     String? ifscCode,
//     String? bankName,
//     String? bankBranch,
//     required int reqType,
//   }) {
//     final data = <String, dynamic>{'reqType': reqType};
//
//     if (reqType == 1) {
//       if (name != null) data['name'] = name;
//       if (aadharNumber != null) data['aadhar_number'] = aadharNumber;
//       if (panNumber != null) data['pan_number'] = panNumber;
//     } else if (reqType == 2) {
//       if (accountNumber != null) data['account_number'] = accountNumber;
//       if (accountHolderName != null) data['account_holder_name'] = accountHolderName;
//       if (ifscCode != null) data['ifsc_code'] = ifscCode;
//       if (bankName != null) data['bank_name'] = bankName;
//       if (bankBranch != null) data['bank_branch'] = bankBranch;
//     }
//
//     return request<ApiResponseModel>(
//       path: '/update-details',
//       method: 'PUT',
//       data: data,
//       parser: (d) => ApiResponseModel.fromJson(d, null),
//     );
//   }
//
//   Future<List<ProductModel>> getProductsByOrderType(int orderType) =>
//       request<List<ProductModel>>(
//         path: '/products-by-type',
//         method: 'GET',
//         queryParameters: {'orderType': orderType},
//         parser: (d) {
//           final products = (d as List? ?? []);
//           return products.map((p) => ProductModel.fromJson(p)).toList();
//         },
//       );
//
//   Future<RazorpayOrderResponse> createRazorpayOrder(double amount) =>
//       request<RazorpayOrderResponse>(
//         path: '/orders/razorpay/initiate',
//         method: 'POST',
//         data: {'amount': amount},
//         parser: (d) => RazorpayOrderResponse.fromJson(d),
//       );
//
//   Future<OrderModel> createOrder({
//     required int orderType,
//     required int shiftType,
//     required int slotId,
//     required bool isEstimate,
//     int? paymentMethod,
//   }) {
//     final data = {
//       'orderType': orderType,
//       'shift': shiftType,
//       'slotId': slotId,
//       'shiftType': shiftType,
//       'isEstimate': isEstimate,
//     };
//     if (paymentMethod != null) data['paymentMethod'] = paymentMethod;
//
//     return request<OrderModel>(
//       path: '/orders',
//       method: 'POST',
//       data: data,
//       parser: (d) => OrderModel.fromJson(d['order'] ?? d),
//     );
//   }
//
//   Future<Map<String, dynamic>> updateCart({
//     required int productId,
//     required double quantity,
//     required int shiftType,
//     required int slotId,
//     required int orderType,
//   }) =>
//       request<Map<String, dynamic>>(
//         path: '/cart',
//         method: 'POST',
//         data: {
//           'productId': productId,
//           'quantity': quantity,
//           'shiftType': shiftType,
//           'slotId': slotId,
//           'orderType': orderType,
//         },
//       );
//
//   Future<Map<String, dynamic>> getCartEstimate({int? shiftType}) =>
//       request<Map<String, dynamic>>(
//         path: '/cart/count',
//         method: 'GET',
//         queryParameters: shiftType != null ? {'shiftType': shiftType} : null,
//       );
//
//   Future<CartResponseModel> getCartItems({int? shiftType}) =>
//       request<CartResponseModel>(
//         path: '/cart',
//         method: 'GET',
//         queryParameters: shiftType != null ? {'shiftType': shiftType} : null,
//         parser: (d) => CartResponseModel.fromJson(d),
//       );
//
//   Future<List<OrderModel>> getOrders(Map<String, dynamic> queryParams) =>
//       request<List<OrderModel>>(
//         path: '/orders',
//         method: 'GET',
//         queryParameters: queryParams,
//         parser: (d) {
//           final list = (d as List? ?? []);
//           return list.map((o) => OrderModel.fromJson(o)).toList();
//         },
//       );
//
//   Future<EarningsModel> getEarnings(String month) =>
//       request<EarningsModel>(
//         path: '/earnings',
//         method: 'GET',
//         queryParameters: {'month': month},
//         parser: (d) => EarningsModel.fromJson(d),
//       );
//
//   Future<EarningsModel> getMonthlyStatement(String month) =>
//       request<EarningsModel>(
//         path: '/statements',
//         method: 'GET',
//         queryParameters: {'month': month},
//         parser: (d) => EarningsModel.fromJson(d),
//       );
//
//   Future<CommissionStatementModel> getCommissionStatement({String? month}) =>
//       request<CommissionStatementModel>(
//         path: '/commission-statement',
//         method: 'GET',
//         queryParameters: month != null ? {'month': month} : null,
//         parser: (d) => CommissionStatementModel.fromJson(d),
//       );
//
//   Future<CommissionPdfResponse> downloadMonthlyStatementPdf({String? month}) =>
//       request<CommissionPdfResponse>(
//         path: '/statements/pdf',
//         method: 'GET',
//         queryParameters: month != null ? {'month': month} : null,
//         parser: (d) => CommissionPdfResponse.fromJson(d),
//       );
//
//   Future<CommissionPdfResponse> downloadCommissionPdf({String? month}) =>
//       request<CommissionPdfResponse>(
//         path: '/commission-statement/pdf',
//         method: 'GET',
//         queryParameters: month != null ? {'month': month} : null,
//         parser: (d) => CommissionPdfResponse.fromJson(d),
//       );
// }
