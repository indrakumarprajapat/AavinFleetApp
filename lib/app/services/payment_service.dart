import 'package:aavin/app/services/wallet_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PaymentService extends GetxController {
  late Razorpay _razorpay;
  final storage = GetStorage();
  
  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
  }
  
  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // void openCheckout({
  //   required double amount,
  //   required String orderId,
  //   required String name,
  //   required String email,
  //   required String contact,
  //   String description = 'Payment for order',
  // }) {
  //   final razorpayKey = storage.read('razorpay_key') ?? '';
  //   var options = {
  //     'key': razorpayKey,
  //     'amount': (amount * 100).toInt(),
  //     'name': 'AAVIN',
  //     'order_id': orderId,
  //     'description': description,
  //     'prefill': {
  //       'contact': contact,
  //       'email': email,
  //       'name': name,
  //     },
  //     'theme': {
  //       'color': '#00ADD9'
  //     }
  //   };
  //
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to open payment: $e');
  //   }
  // }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    try {
      final walletService = Get.find<WalletService>();
      
      final orderId = response.orderId ?? '';
      if (orderId.startsWith('wallet_')) {
        final parts = orderId.split('_');
        final amount = parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 100.0;
        walletService.addMoney(amount, response.paymentId ?? '');
      }
    } catch (e) {
      Get.snackbar('Success', 'Payment completed successfully!');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Payment Failed', response.message ?? 'Payment was cancelled');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', 'Selected: ${response.walletName}');
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}