import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_service.dart';

class CashfreeService extends GetxService {
  late CFPaymentGatewayService cfPaymentGatewayService;

  @override
  void onInit() {
    super.onInit();
    cfPaymentGatewayService = CFPaymentGatewayService();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
  }

  Future<void> makePayment({
    required String orderId,
    required String paymentSessionId,
    required double amount,
    required int transactionId,
  }) async {
    try {
      CFSession session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.PRODUCTION)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      CFTheme theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#00ADD9")
          .setNavigationBarTextColor("#FFFFFF")
          .setPrimaryFont("Poppins")
          .setSecondaryFont("Poppins")
          .build();

      CFDropCheckoutPayment cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();

      final storage = GetStorage();
      storage.write('current_transaction_id', transactionId);
      storage.write('current_order_id', orderId);

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } catch (e) {
      Get.snackbar('Error', 'Failed to initiate payment: $e');
    }
  }

  Future<void> makeWalletPayment({
    required String orderId,
    required String paymentSessionId,
    required double amount,
    required Function(String) onSuccess,
    required Function(String, String) onFailure,
  }) async {
    try {
      CFSession session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.PRODUCTION)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      CFTheme theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#00ADD9")
          .setNavigationBarTextColor("#FFFFFF")
          .setPrimaryFont("Poppins")
          .setSecondaryFont("Poppins")
          .build();

      CFDropCheckoutPayment cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();

      final storage = GetStorage();
      storage.write('wallet_success_callback', onSuccess);
      storage.write('wallet_failure_callback', onFailure);
      storage.write('current_wallet_order_id', orderId);

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } catch (e) {
      onFailure(orderId, 'Failed to initiate payment: $e');
    }
  }

  void verifyPayment(String orderId) async {
    try {
      final storage = GetStorage();
      final transactionId = storage.read('current_transaction_id');
      final walletOrderId = storage.read('current_wallet_order_id');
      
      if (walletOrderId != null) {
        final onSuccess = storage.read('wallet_success_callback');
        if (onSuccess != null) {
          onSuccess(orderId);
        }
        storage.remove('wallet_success_callback');
        storage.remove('wallet_failure_callback');
        storage.remove('current_wallet_order_id');
        return;
      }

      if (transactionId != null) {
        final response = await Get.find<ApiService>().verifyCashfreePayment(
          transactionId: transactionId,
          orderId: orderId,
        );

        storage.remove('current_transaction_id');
        storage.remove('current_order_id');

        Get.snackbar('Success', 'Payment successful!');
        Get.offAllNamed('/order-success', arguments: {
          'orderId': orderId,
          'transactionId': transactionId,
          'amount': response['amount'] ?? 0.0,
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Payment verification failed: $e');
    }
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    final storage = GetStorage();
    final transactionId = storage.read('current_transaction_id');
    final walletOrderId = storage.read('current_wallet_order_id');
    
    if (walletOrderId != null) {
      final onFailure = storage.read('wallet_failure_callback');
      if (onFailure != null) {
        onFailure(orderId, errorResponse.getMessage() ?? 'Payment failed');
      }
      storage.remove('wallet_success_callback');
      storage.remove('wallet_failure_callback');
      storage.remove('current_wallet_order_id');
      return;
    }
    
    storage.remove('current_transaction_id');
    storage.remove('current_order_id');

    // Call the new API to handle Cashfree payment failure
    if (transactionId != null) {
      Get.find<ApiService>().handleCashfreePaymentFailure(
        transactionId: transactionId,
        orderId: orderId,
        failureReason: errorResponse.getMessage() ?? 'Payment failed',
        errorCode: errorResponse.getType(),
        paymentMethod: 'cashfree',
      ).catchError((e) {
        print('Failed to record payment failure: $e');
      });
    }

    Get.snackbar(
      'Payment Failed',
      errorResponse.getMessage() ?? 'Payment was cancelled or failed'
    );
  }
}