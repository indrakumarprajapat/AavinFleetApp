import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../api/api_service.dart';
import '../../../services/global_cart_service.dart';

class EasyPayWebviewController extends GetxController {
  final apiService = Get.find<ApiService>();
  final globalCartService = Get.find<GlobalCartService>();
  final _isLoading = true.obs;
  late WebViewController webViewController;
  int? transactionId;
  String? referenceId;

  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    transactionId = arguments['transactionId'];
    referenceId = arguments['referenceId'];

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    Future.delayed(const Duration(milliseconds: 100), () {
      final paymentUrl = args['paymentUrl'];
      if (paymentUrl != null) {
        _initializeWebView(paymentUrl);
      }
    });
  }

  Future<bool> _testEasyPayConnection() async {
    try {
      final testHtml = '''
        <!DOCTYPE html>
        <html><head><title>Test</title></head>
        <body>
        <script>        
        fetch('https://uat-etendering.axis.bank.in/easypay2.0/frontend/api/payment', {method: 'HEAD', mode: 'no-cors'})
        .then(() => console.log('Server reachable'))
        .catch(() => console.log('Server unreachable'));
        </script>
        </body></html>
        ''';
      
      final testController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(testHtml);
      
      await Future.delayed(Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showConnectionError() {
    _isLoading.value = false;
    Get.dialog(
      AlertDialog(
        title: Text('EasyPay Unavailable'),
        content: Text('EasyPay server is currently unreachable. Please use Razorpay for payment.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text('Use Razorpay'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _initializeWebView(String initialUrl) {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('Page started: $url');
            _isLoading.value = true;
          },
          onPageFinished: (url) {
            debugPrint('Page finished: $url');
            _isLoading.value = false;
            _checkForCallback(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkForCallback(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('Web error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));
  }


  void _handleWebError(WebResourceError error) {
    _isLoading.value = false;
    
    if (error.description.contains('ERR_CONNECTION_RESET') || 
        error.description.contains('ERR_NETWORK_CHANGED')) {
      Get.back();
      Get.snackbar('EasyPay Unavailable', 'Switching to Razorpay payment', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      
      // Auto-trigger Razorpay
      final checkoutController = Get.find<dynamic>();
      if (checkoutController != null && checkoutController.runtimeType.toString().contains('CheckoutController')) {
        checkoutController.initiateRazorpayPayment();
      }
    }
  }

  void _checkForCallback(String url) {
    print('Checking URL for callback: $url');
    
    // Check for EasyPay success/failure patterns
    if (url.contains('easypay') && (url.contains('success') || url.contains('response') || url.contains('callback'))) {
      _handlePaymentCallback(url);
    }
    
    // Also check for specific EasyPay response parameters
    if (url.contains('RID=') || url.contains('CRN=') || url.contains('STC=')) {
      _handlePaymentCallback(url);
    }
  }

  void _handlePaymentCallback(String callbackUrl) async {
    try {
      print('Processing EasyPay callback: $callbackUrl');
      final uri = Uri.parse(callbackUrl);
      
      // Check for encrypted response parameter 'i'
      final encryptedResponse = uri.queryParameters['i'];
      
      // Check for direct EasyPay parameters
      final status = uri.queryParameters['STC']; // Status Code
      final rid = uri.queryParameters['RID']; // Reference ID
      final crn = uri.queryParameters['CRN']; // Customer Reference Number
      
      if (encryptedResponse != null || status != null) {
        // Verify payment with backend using EasyPay-specific endpoint
        if (transactionId != null) {
          final result = await apiService.verifyEasyPayPayment(
            transactionId: transactionId!,
            encryptedResponse: encryptedResponse ?? callbackUrl,
          );
        }
        
        await globalCartService.refreshCartEstimate();
        Get.offAllNamed('/order-success');
        Get.snackbar('Success', 'Payment completed successfully!', 
          backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw Exception('Invalid payment response');
      }
    } catch (e) {
      print('EasyPay callback error: $e');
      Get.snackbar('Error', 'Payment verification failed', 
        backgroundColor: Colors.red, colorText: Colors.white);
      Get.back();
    }
  }

  void handlePaymentCancel() {
    if (transactionId != null) {
      apiService.handlePaymentFailure(
        transactionId: transactionId!,
        failureReason: 'User cancelled payment',
      );
    }
    Get.back();
    Get.snackbar('Cancelled', 'Payment was cancelled', 
      backgroundColor: Colors.orange, colorText: Colors.white);
  }
}