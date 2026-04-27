import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../constants/app_enums.dart';
import '../../../models/agent_model.dart';
import '../../../models/customer_model.dart';
import '../../../routes/app_pages.dart';
import '../../../api/api_service.dart';
import '../../../services/ccavenue_service.dart';
import '../../../services/cashfree_service.dart';
import '../../agent/wallet/controllers/wallet_controller.dart';

class AddFundsController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final isLoading = false.obs;
  final storage = GetStorage();
  final Rx<FleetUser?> agentData = Rx<FleetUser?>(null);
  final Rx<Customer?> customerData = Rx<Customer?>(null);
  final isCustomer = false.obs;
  final _isLoading = false.obs;
  final apiService = Get.find<ApiService>();
  int? _currentTransactionId;
  late dynamic walletController;
  final _paymentGateways = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get paymentGateways => _paymentGateways;

  @override
  void onInit() {
    super.onInit();
    final userType = storage.read('user_type') ?? UserType.fleetUser.index;
    isCustomer.value = userType == UserType.customer.index;
    
    // if (isCustomer.value) {
    //   final customerData = storage.read('customer');
    //   if (customerData != null) {
    //     if (customerData is Map<String, dynamic>) {
    //       this.customerData.value = Customer.fromJson(customerData);
    //     } else if (customerData is Customer) {
    //       this.customerData.value = customerData;
    //     }
    //   }
    //   walletController = Get.find<CustomerWalletController>();
    // } else {
      final agentJson = storage.read('fleetUser');
      if (agentJson != null) {
        agentData.value = FleetUser.fromJson(agentJson);
      }
      walletController = Get.find<WalletController>();
    // }
    
    _loadPaymentGateways();
  }

  Future<void> _loadPaymentGateways() async {
    try {
      final response = await apiService.getPaymentGateways();
      if (response['success'] == true) {
        _paymentGateways.value = List<Map<String, dynamic>>.from(response['gateways']);
      }
    } catch (e) {}
  }
  // Future<void> _loadPaymentGateways() async {
  //   try {
  //     // Simulate network delay (optional)
  //     await Future.delayed(const Duration(milliseconds: 500));
  //
  //     final response = {
  //       "success": true,
  //       "gateways": [
  //         {
  //           "id": 1,
  //           "name": "razorpay",
  //           "displayName": "Razorpay",
  //           "description": "Pay with cards, UPI, wallets",
  //           "icon": "payment",
  //           "isActive": true
  //         },
  //         {
  //           "id": 2,
  //           "name": "easypay",
  //           "displayName": "EasyPay",
  //           "description": "Pay with EasyPay gateway",
  //           "icon": "payment",
  //           "isActive": true
  //         },
  //         {
  //           "id": 4,
  //           "name": "ccavenue",
  //           "displayName": "CCAvenue",
  //           "description": "Pay with CCAvenue gateway",
  //           "icon": "payment",
  //           "isActive": true
  //         }
  //       ]
  //     };
  //
  //     if (response['success'] == true) {
  //       final gateways =
  //       response['gateways'] as List<dynamic>;
  //
  //       _paymentGateways.value =
  //       List<Map<String, dynamic>>.from(gateways);
  //     }
  //   } catch (e) {
  //     debugPrint("Error loading gateways: $e");
  //   }
  // }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  Future<void> initiateEasyPayPayment() async {
    try {
      _isLoading.value = true;
      final arguments = Get.arguments as Map<String, dynamic>? ?? {};
      var shiftType = arguments['shiftType'];

      final response = await apiService.createEasyPayOrder(
        orderType: 1,//shiftType == 0 ? 2 : 1,
        morningSlotId: 1, //arguments['slotId'],
        eveningSlotId: 1 //arguments['slotId'],
      );

      _currentTransactionId = response['transactionId'];

      final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <title>EasyPay Payment</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
    <div style="text-align: center; padding: 20px; font-family: Arial, sans-serif;">
        <h3 style="color: #00ADD9;">Redirecting to EasyPay...</h3>
        <p>Please wait while we redirect you to the payment gateway.</p>
        <div id="loading" style="margin: 20px 0;">Loading...</div>
    </div>
    <form id="easyPayForm" method="POST" action="https://uat-etendering.axis.bank.in/easypay2.0/frontend/api/payment" accept-charset="UTF-8">
        <input type="hidden" name="i" value="${response['encryptedData']}" />
    </form>
    <script>
        console.log('EasyPay Form Data:', '${response['encryptedData']}');
        console.log('Submitting to EasyPay UAT URL');
        
        // Auto-submit after a short delay
        setTimeout(function() {
            document.getElementById('loading').innerHTML = 'Redirecting to payment gateway...';
            document.getElementById('easyPayForm').submit();
        }, 1000);
        
        // Handle potential errors
        window.addEventListener('error', function(e) {
            console.error('EasyPay Error:', e);
            document.getElementById('loading').innerHTML = 'Error loading payment gateway. Please try again.';
        });
    </script>
</body>
</html>
      ''';

      _isLoading.value = false;
      Get.toNamed(Routes.EASYPAY_WEBVIEW, arguments: {
        'htmlContent': htmlContent,
        'transactionId': _currentTransactionId,
        'referenceId': response['referenceId']
      });

    } catch (e) {
      _isLoading.value = false;
      _currentTransactionId = null;
      Get.snackbar('EasyPay Unavailable', 'Switching to Razorpay payment',
          backgroundColor: Colors.orange, colorText: Colors.white);
      // await initiateRazorpayPayment();
    }
  }

  /// CCAvenue Payment Integration for Add Funds
  Future<void> initiateCCAvenuePayment() async {
    try {
      final amount = double.tryParse(amountController.text);
      if (amount == null || amount <= 0) {
        Get.snackbar('Error', 'Please enter a valid amount');
        return;
      }
      
      _isLoading.value = true;
      
      int? userId;
      int userType;
      
      if (isCustomer.value) {
        userId = customerData.value?.id;
        userType = UserType.customer.index; // 1: customer
      } else {
        userId = int.tryParse(agentData.value?.id ?? '');
        userType = UserType.fleetUser.index; // 2: agent
      }
      
      if (userId == null) {
        throw Exception('User ID not found');
      }
      
      _isLoading.value = false;
      
      CCavenueService.makePayment(
        amount: amount,
        userId: userId,
        userType: userType,
        paymentFor: 2, // Wallet top-up
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
      final amountValue = double.tryParse(amountController.text) ?? 0.0;
      if (isCustomer.value) {
        walletController.loadWalletData();
      } else {
        walletController.loadWalletData();
      }
      amountController.clear();
      Get.snackbar('Success', 'CCAvenue payment successful! ₹${amountValue.toStringAsFixed(2)} added to wallet',
      backgroundColor: Colors.green, colorText: Colors.white);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', 'Payment successful but wallet update failed: $e',
      backgroundColor: Colors.orange, colorText: Colors.white);
    } finally {
      _isLoading.value = false;
    }
  }
  
  void _handleCCAvenueError(String error) {
    _isLoading.value = false;
    Get.snackbar('Payment Failed', 'CCAvenue payment failed: $error',
      backgroundColor: Colors.red, colorText: Colors.white);
  }
  
  void _handleCCAvenueCancel() {
    _isLoading.value = false;
    Get.snackbar('Payment Cancelled', 'CCAvenue payment was cancelled',
      backgroundColor: Colors.orange, colorText: Colors.white);
  }

  Future<void> initiateCashfreeWalletPayment() async {
    try {
      final amount = double.tryParse(amountController.text);
      if (amount == null || amount <= 0) {
        Get.snackbar('Error', 'Please enter a valid amount');
        return;
      }
      
      _isLoading.value = true;
      
      final response = await apiService.createCashfreeWalletOrder(amount: amount);
      
      _isLoading.value = false;
      
      await Get.find<CashfreeService>().makeWalletPayment(
        orderId: response['orderId'],
        paymentSessionId: response['paymentSessionId'],
        amount: amount,
        onSuccess: (orderId) async {
          await _handleCashfreeWalletSuccess(orderId, amount);
        },
        onFailure: (orderId, error) {
          _handleCashfreeWalletFailure(orderId, error);
        },
      );
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to initiate Cashfree payment: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  
  Future<void> _handleCashfreeWalletSuccess(String orderId, double amount) async {
    try {
      _isLoading.value = true;
      
      await apiService.verifyCashfreeWalletPayment(orderId: orderId);
      
      walletController.loadWalletData();
      amountController.clear();
      
      Get.snackbar('Success', 'Cashfree payment successful! ₹${amount.toStringAsFixed(2)} added to wallet',
        backgroundColor: Colors.green, colorText: Colors.white);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', 'Payment successful but verification failed: $e',
        backgroundColor: Colors.orange, colorText: Colors.white);
    } finally {
      _isLoading.value = false;
    }
  }
  
  void _handleCashfreeWalletFailure(String orderId, String error) {
    _isLoading.value = false;
    
    apiService.handleCashfreeWalletPaymentFailure(
      orderId: orderId,
      failureReason: error,
    );
    
    Get.snackbar('Payment Failed', 'Cashfree payment failed: $error',
      backgroundColor: Colors.red, colorText: Colors.white);
  }

}