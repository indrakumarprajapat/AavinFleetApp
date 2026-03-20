import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../constants/api_constants.dart';
import '../../../../models/agent_model.dart';
import '../../../../models/booth_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../api/api_service.dart';
import '../../../../services/global_cart_service.dart';
import '../../../../services/ccavenue_service.dart';
import '../../../../services/cashfree_service.dart';

class CheckoutController extends GetxController {
  final apiService = Get.find<ApiService>();
  final globalCartService = Get.find<GlobalCartService>();
  final _isLoading = false.obs;
  final _orderData = <String, dynamic>{}.obs;
  final _selectedPaymentMethod = 2.obs;
  final Rx<Society?> boothData = Rx<Society?>(null);
  final _walletBalance = 0.0.obs;
  final _outstandingAmount = 0.0.obs;
  final storage = GetStorage();
  late Razorpay _razorpay;
  int? _currentTransactionId;
  final Rx<SocietyUser?> agentData = Rx<SocietyUser?>(null);
  final _isButtonDisabled = false.obs;
  final _paymentGateways = <Map<String, dynamic>>[].obs;
  bool get isLoading => _isLoading.value;
  bool get isButtonDisabled => _isButtonDisabled.value;
  int get selectedPaymentMethod => _selectedPaymentMethod.value;
  double get walletBalance => _walletBalance.value;
  double get outstandingAmount => _outstandingAmount.value;
  double get subtotalAmount => (_orderData['subtotalAmount'] ?? 0.0).toDouble();
  double get totalTax => (_orderData['totalTax'] ?? 0.0).toDouble();
  double get totalAmount => (_orderData['totalAmount'] ?? 0.0).toDouble();
  double get totalDiscount => (_orderData['totalDiscount']??0.0).toDouble();
  bool get canUseWallet => _walletBalance.value >= totalAmount;
  List<Map<String, dynamic>> get paymentGateways => _paymentGateways;

  void selectPaymentMethod(int method) {
    if (method == 1 && !canUseWallet) {
      Get.snackbar('Insufficient Balance', 'Your wallet balance is insufficient for this order');
      return;
    }
    _selectedPaymentMethod.value = method;
  }

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final agentJson = storage.read('agent');
    if (agentJson != null) {
      agentData.value = SocietyUser.fromJson(agentJson);
    }
    final boothJson = storage.read('societyDetails');
    if (boothJson != null) {
      if (boothJson is Map<String, dynamic>) {
        boothData.value = Society.fromJson(boothJson);
      } else if (boothJson is Society) {
        boothData.value = boothJson;
      }
    }
    _orderData.value = arguments;
    _loadWalletBalance();
    _loadCreditOutstanding();
    _loadPaymentGateways();
    _initializeRazorpay();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      _isLoading.value = true;
      
      if (_currentTransactionId == null) throw Exception('Transaction ID not found');
      
      Get.snackbar('Processing', 'Verifying payment, please wait...', 
        backgroundColor: Colors.blue, colorText: Colors.white, duration: Duration(seconds: 60));
      
      final result = await apiService.verifyPaymentAndUpdateOrders(
        transactionId: _currentTransactionId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature ?? '',
      );
      
      await globalCartService.refreshCartEstimate();
      Get.offAllNamed(Routes.ORDER_SUCCESS, arguments: {'orders': result['orders']});
      Get.snackbar('Success', 'Payment successful! Orders updated.', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      String errorMsg = 'Payment completed but order update failed. Please contact support.';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Payment successful but verification is taking longer. Your order will be updated shortly.';
      }
      Get.snackbar('Payment Processing', errorMsg, backgroundColor: Colors.orange, colorText: Colors.white, duration: Duration(seconds: 5));
    } finally {
      _isLoading.value = false;
      _currentTransactionId = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    _isLoading.value = false;
    if (_currentTransactionId != null) {
      try {
        await apiService.handlePaymentFailure(
          transactionId: _currentTransactionId!,
          failureReason: response.message ?? 'Payment failed',
        );
      } catch (e) {}
    }
    _currentTransactionId = null;
    String title = 'Payment Failed';
    String message = 'Payment could not be completed';
    switch (response.code) {
      case Razorpay.PAYMENT_CANCELLED:
        title = 'Payment Cancelled';
        message = 'You cancelled the payment';
        _isButtonDisabled.value = true;
        Future.delayed(Duration(seconds: 3), () {
          _isButtonDisabled.value = false;
        });
        break;
      case Razorpay.NETWORK_ERROR:
        title = 'Network Error';
        message = 'Please check your internet connection';
        break;
      default:
        if (response.message != null && response.message!.isNotEmpty) {
          message = response.message!;
        }
    }
    
    Get.snackbar(title, message, backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', 'Selected: ${response.walletName}');
  }

  Future<void> _loadWalletBalance() async {
    try {
      final response = await apiService.getWalletBalance();
      _walletBalance.value = (response['balance'] ?? 0.0).toDouble();
    } catch (e) {}
  }

  Future<void> _loadCreditOutstanding() async {
    try {
      final creditOutstanding = await apiService.getCreditOutstanding();
      _outstandingAmount.value = creditOutstanding.outstandingAmount;
    } catch (e) {}
  }

  Future<void> _loadPaymentGateways() async {
    try {
      final response = await apiService.getPaymentGateways();
      if (response['success'] == true) {
        _paymentGateways.value = List<Map<String, dynamic>>.from(response['gateways']);
      }
    } catch (e) {}
  }

  Future<void> placeOrder() async {
    try {
      _isLoading.value = true;
      final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      var shiftType = arguments['shiftType'];
      
      if (_selectedPaymentMethod.value == 1 || _selectedPaymentMethod.value == 3) {
        final order = await apiService.createOrder(
          orderType: shiftType == 0 ? 2 : 1,
          shiftType: arguments['shiftType'] ?? 1,
          slotId: arguments['slotId'] ?? 1,
          isEstimate: false,
          paymentMethod: _selectedPaymentMethod.value == 1 ? 1 : 2,
        );
        
        await globalCartService.refreshCartEstimate();
        Get.offAllNamed(Routes.ORDER_SUCCESS, arguments: {'order': order.toJson()});
      }
    } catch (e) {
      Get.snackbar('Info', '$e');
      // Get.snackbar('Error', 'Failed to place order: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> initiateEasyPayPayment() async {
    try {
      _isLoading.value = true;
      final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      var shiftType = arguments['shiftType'];
      
      final response = await apiService.createEasyPayOrder(
        orderType: shiftType == 0 ? 2 : 1,
        morningSlotId: arguments['morningSlotId'],
        eveningSlotId: arguments['eveningSlotId'],
      );
      
      _currentTransactionId = response['transactionId'];

      // Build the EasyPay initiate URL (hosted on your EC2)
      final initiateUrl =
          '${ApiConstants.baseUrl}bapi/orders/easypay/initiate'
          '?rid=${Uri.encodeComponent(response['referenceId'])}'
          '&crn=${Uri.encodeComponent(response['customerRefNumber'])}'
          '&amt=${Uri.encodeComponent(response['amount'].toString())}';

// Navigate to WebView screen
      _isLoading.value = false;

      Get.toNamed(
        Routes.EASYPAY_WEBVIEW,
        arguments: {
          'paymentUrl': initiateUrl,
          'transactionId': _currentTransactionId,
          'referenceId': response['referenceId'],
        },
      );
      // Get.toNamed(Routes.EASYPAY_WEBVIEW, arguments: {
      //   'htmlContent': htmlContent,
      //   'transactionId': _currentTransactionId,
      //   'referenceId': response['referenceId']
      // });

//       final htmlContent = '''
// <!DOCTYPE html>
// <html>
// <head>
//     <title>EasyPay Payment</title>
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
// </head>
// <body>
//     <div style="text-align: center; padding: 20px; font-family: Arial, sans-serif;">
//         <h3 style="color: #00ADD9;">Redirecting to EasyPay...</h3>
//         <p>Please wait while we redirect you to the payment gateway.</p>
//         <div id="loading" style="margin: 20px 0;">Loading...</div>
//     </div>
//     <form id="easyPayForm" method="POST" action="https://uat-etendering.axisbank.co.in/easypay2.0/frontend/api/payment" accept-charset="UTF-8">
//         <input type="hidden" name="i" value="${response['encryptedData']}" />
//     </form>
//     <script>
//         console.log('EasyPay Form Data:', '${response['encryptedData']}');
//         console.log('Submitting to EasyPay UAT URL');
//
//         // Auto-submit after a short delay
//         setTimeout(function() {
//             document.getElementById('loading').innerHTML = 'Redirecting to payment gateway...';
//             document.getElementById('easyPayForm').submit();
//         }, 1000);
//
//         // Handle potential errors
//         window.addEventListener('error', function(e) {
//             console.error('EasyPay Error:', e);
//             document.getElementById('loading').innerHTML = 'Error loading payment gateway. Please try again.';
//         });
//     </script>
// </body>
// </html>
//       ''';
      // _isLoading.value = false;
      // Get.toNamed(Routes.EASYPAY_WEBVIEW, arguments: {
      //   'htmlContent': htmlContent,
      //   'transactionId': _currentTransactionId,
      //   'referenceId': response['referenceId']
      // });
      
    } catch (e) {
      _isLoading.value = false;
      _currentTransactionId = null;
      Get.snackbar('EasyPay Unavailable', 'Switching to Razorpay payment', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      // await initiateRazorpayPayment();
    }
  }

  Future<void> initiateRazorpayPayment() async {
    try {
      _isLoading.value = true;
      final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      var shiftType = arguments['shiftType'];
      
      final response = await apiService.createRazorpayOrder(
        orderType: shiftType == 0 ? 2 : 1,
        morningSlotId: arguments['morningSlotId'],
        eveningSlotId: arguments['eveningSlotId'],
      );
      
      _currentTransactionId = response['transactionId'];
      if (response['razorpayOrderId'] == null) {
        throw Exception('Razorpay order ID not received');
      }
      var razorpayOrderId = response['razorpayOrderId'];
      final amountInPaise = (response['amount'] as num).round();
      Map<String, dynamic> notes = {};
      if (response['orderIds'] != null && response['orderIds'] is List) {
        List orderIds = response['orderIds'];
        for (int i = 0; i < orderIds.length; i++) {
          notes['order_id${i + 1}'] = orderIds[i];
        }
        notes['razorpayOrderId'] = response['razorpayOrderId'];
      }
      if (response['razorpayOrderId'] != null) {
        notes['razorpayOrderId'] = response['razorpayOrderId'];
      }
      final razorpayKey = storage.read('razorpay_key') ?? '';
      var options = {
        'key': razorpayKey,
        'amount': amountInPaise,
        'order_id': razorpayOrderId,
        'currency': 'INR',
        'name': 'AAVIN',
        'description': 'Order Payment',
        'notes': notes,
        'prefill': {
          'contact': '${agentData.value?.mobileNumber}',
          'email': ''
        },
        'theme': {
          'color': '#00ADD9'
        }
      };
      
      _isLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _razorpay.open(options);
        });
      });
    } catch (e) {
      _isLoading.value = false;
      _currentTransactionId = null;
      Get.snackbar('Info', '$e');
      // Get.snackbar('Error', 'Payment initialization failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> initiateCashfreePayment() async {
    try {
      _isLoading.value = true;
      final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      var shiftType = arguments['shiftType'];
      
      final response = await apiService.createCashfreeOrder(
        orderType: shiftType == 0 ? 2 : 1,
        morningSlotId: arguments['morningSlotId'],
        eveningSlotId: arguments['eveningSlotId'],
      );
      
      _currentTransactionId = response['transactionId'];
      _isLoading.value = false;

      await Get.find<CashfreeService>().makePayment(
        orderId: response['orderId'],
        paymentSessionId: response['paymentSessionId'],
        amount: response['amount'].toDouble(),
        transactionId: _currentTransactionId!,
      );
    } catch (e) {
      _isLoading.value = false;
      _currentTransactionId = null;
      Get.snackbar('Error', 'Cashfree payment initialization failed: $e');
    }
  }

  /// CCAvenue Payment Integration
  Future<void> initiateCCAvenuePayment() async {
    try {
      _isLoading.value = true;
      
      final agentId = agentData.value?.id;
      final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      var shiftType = arguments['shiftType'];
      
      if (agentId == null) {
        throw Exception('Agent ID not found');
      }
      
      _isLoading.value = false;
      
      final morningSlotId = arguments['morningSlotId'];
      final eveningSlotId = arguments['eveningSlotId'];
      
      CCavenueService.makePayment(
        amount: totalAmount,
        userId: int.parse(agentId),
        userType: 2, // 2: agent
        paymentFor: 1, // 1: order payment
        orderType: shiftType == 0 ? 2 : 1,
        morningSlotId: morningSlotId,
        eveningSlotId: eveningSlotId,
        onSuccess: (status, orderId, amount) async {
          await _handleCCAvenueSuccess(status, orderId, amount);
        },
        onError: (error) {
          _handleCCAvenueError(error);
        },
        onCancel: () {
          _handleCCAvenueCancel();
        },
      );
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to initiate CCAvenue payment: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  
  Future<void> _handleCCAvenueSuccess(String status, String orderId, String amount) async {
    try {
      _isLoading.value = true;
      // final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      // var shiftType = arguments['shiftType'];
      //
      // final order = await apiService.createOrder(
      //   orderType: shiftType == 0 ? 2 : 1,
      //   shiftType: arguments['shiftType'] ?? 1,
      //   slotId: arguments['slotId'] ?? 1,
      //   isEstimate: false,
      //   paymentMethod: 3, // CCAvenue payment method
      // );
      await globalCartService.refreshCartEstimate();
      Get.snackbar('Success', 'CCAvenue payment successful! Order placed.',
        backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed(Routes.ORDER_SUCCESS);
    } catch (e) {
      Get.snackbar('Error', 'Payment successful but order creation failed: $e',
        backgroundColor: Colors.orange, colorText: Colors.white);
    } finally {
      _isLoading.value = false;
    }
  }
  
  void _handleCCAvenueError(String error) {
    _isLoading.value = false;
    _isButtonDisabled.value = true;
    
    Future.delayed(Duration(seconds: 3), () {
      _isButtonDisabled.value = false;
    });
    
    Get.snackbar('Payment Failed', 'CCAvenue payment failed: $error',
      backgroundColor: Colors.red, colorText: Colors.white);
  }
  
  void _handleCCAvenueCancel() {
    _isLoading.value = false;
    Get.snackbar('Payment Cancelled', 'CCAvenue payment was cancelled',
      backgroundColor: Colors.orange, colorText: Colors.white);
  }
}