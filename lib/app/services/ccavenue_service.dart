import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';
import 'ccavenue_webview_service.dart';

/// CCAvenue Payment Service
/// Complete integration for CCAvenue payments
class CCavenueService {
  
  /// Make payment using backend API
  static Future<void> makePayment({
    required double amount,
    required int userId,
    required int userType,// 1: customer, 2: agent
    required int paymentFor, // 1: order, 2: wallet
    int? orderType, // Only for order payments
    int? morningSlotId, // Only for order payments
    int? eveningSlotId, // Only for order payments
    int? addressId,
    int? boothId,
    int? orderMonth,
    int? deliveryType,
    Function(String status, String orderId, String amount)? onSuccess,
    Function(String error)? onError,
    VoidCallback? onCancel,
  }) async {
    try {
      // Show loading
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Prepare request body
      final requestBody = {
        'amount': double.parse( amount.toStringAsFixed(2)),
        'userId': userId,
        'userType': userType,
        'paymentFor': paymentFor,
      };

      if (orderType != null) requestBody['orderType'] = orderType;
      if (morningSlotId != null) requestBody['morningSlotId'] = morningSlotId;
      if (eveningSlotId != null) requestBody['eveningSlotId'] = eveningSlotId;
      if (addressId != null) requestBody['addressId'] = addressId;
      if (boothId != null) requestBody['boothId'] = boothId;
      if (orderMonth != null) requestBody['orderMonth'] = orderMonth;
      if (deliveryType != null) requestBody['deliveryType'] = deliveryType;

      final storage = GetStorage();
      final token = storage.read('access_token') ?? '';

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}ccavenue/initiate-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      // Hide loading
      Get.back();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true || data['encRequest'] != null) {
          final paymentData = PaymentData(
            accessCode: data['access_code'],
            encVal: data['encRequest'],
          );

          Get.to(() => CCavenueWebView(
            paymentData: paymentData,
            onPaymentComplete: (status, orderId, amount) {
              if (onSuccess != null) {
                onSuccess(status, orderId, amount);
              } else {
                _showDefaultSuccessDialog(status, orderId, amount);
              }
            },
            onPaymentCancel: () {
              if (onCancel != null) {
                onCancel();
              } else {
                Get.snackbar('Payment', 'Payment cancelled by user');
              }
            },
          ));
        } else {
          if (onError != null) {
            onError('Failed to initiate payment: ${data['message'] ?? 'Unknown error'}');
          } else {
            Get.snackbar('Error', 'Failed to initiate payment');
          }
        }
      } else {
        if (onError != null) {
          final error = jsonDecode(response.body);
          Get.snackbar('Info', '${error['error']['message']}');
          // onError('Server error: ${response.statusCode}');
        } else {
          Get.snackbar('Error', 'Server error occurred');
        }
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      if (onError != null) {
        onError('Network error: $e');
      } else {
        Get.snackbar('Error', 'Network error occurred');
      }
    }
  }

  static void _showDefaultSuccessDialog(String status, String orderId, String amount) {
    Get.dialog(
      AlertDialog(
        title: Text('Payment Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.toLowerCase() == 'success' ? Icons.check_circle : Icons.error,
              color: status.toLowerCase() == 'success' ? Colors.green : Colors.red,
              size: 50,
            ),
            SizedBox(height: 10),
            Text('Status: $status'),
            if (orderId.isNotEmpty) Text('Order ID: $orderId'),
            if (amount.isNotEmpty) Text('Amount: ₹$amount'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Format amount for display
  static String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}

/// Payment Data Model for CCAvenue
class PaymentData {
  final String? accessCode;
  final String? encVal;

  PaymentData({
    this.accessCode,
    this.encVal,
  });
}