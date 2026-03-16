import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'ccavenue_service.dart';
import 'payment_response_webview.dart';
import '../services/config_service.dart';

/// CCAvenue WebView Service
/// Use this widget to display CCAvenue payment page
class CCavenueWebView extends StatefulWidget {
  final PaymentData paymentData;
  final Function(String status, String orderId, String amount)? onPaymentComplete;
  final VoidCallback? onPaymentCancel;

  const CCavenueWebView({
    Key? key,
    required this.paymentData,
    this.onPaymentComplete,
    this.onPaymentCancel,
  }) : super(key: key);

  @override
  _CCavenueWebViewState createState() => _CCavenueWebViewState();
}

class _CCavenueWebViewState extends State<CCavenueWebView> {
  bool loading = true;
  bool paymentProcessed = false;
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _showCancelDialog();
          return false;
        },
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri('https://secure.ccavenue.com/transaction/transaction.do?command=initiateTransaction'),
                  method: 'POST',
                  body: Uint8List.fromList(utf8.encode(
                    "command=initiateTransaction&encRequest=${widget.paymentData.encVal}&access_code=${widget.paymentData.accessCode}"
                  )),
                  headers: {'Content-Type': 'application/x-www-form-urlencoded'}
                ),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    mediaPlaybackRequiresUserGesture: false,
                    javaScriptEnabled: true,
                  ),
                  android: AndroidInAppWebViewOptions(
                    useWideViewPort: true,
                    useHybridComposition: true,
                    loadWithOverviewMode: true,
                    domStorageEnabled: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                    enableViewportScale: true,
                    ignoresViewportScaleLimits: true
                  )
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },

                onLoadError: (controller, url, code, message) {
                  print("WebView Load Error: $message (Code: $code)");
                },
                onLoadStop: (InAppWebViewController controller, WebUri? pageUri) async {
                  setState(() {
                    loading = false;
                  });
                  
                  if (pageUri == null) return;
                  
                  final page = pageUri.toString();
                  print("Current URL: $page");

                  final configService = Get.find<ConfigService>();
                  final paymentResponseUrl = configService.paymentResponseUrl;
                  if (paymentResponseUrl.isNotEmpty && page.contains(paymentResponseUrl) && !paymentProcessed) {
                    paymentProcessed = true;
                    Uri uri = Uri.parse(page);
                    String status = uri.queryParameters['status'] ?? 'unknown';
                    String orderId = uri.queryParameters['orderId'] ?? '';
                    String amount = uri.queryParameters['amount'] ?? '';

                    print('Payment completed - Status: $status, OrderId: $orderId, Amount: $amount');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentResponseWebView(successUrl: page),
                      ),
                    ).then((_) {
                      if (widget.onPaymentComplete != null) {
                        widget.onPaymentComplete!(status, orderId, amount);
                      }
                      Navigator.pop(context);
                    });
                  }

                  // Fallback for direct backend response - same as original project
                  // if (page.contains('15.206.249.5:3042/ccavenue/payment-response')) {
                  //   try {
                  //     var html = await controller.evaluateJavascript(
                  //       source: "window.document.getElementsByTagName('html')[0].outerHTML;"
                  //     );
                  //
                  //     String html1 = html.toString();
                  //     print('Response HTML: $html1');
                  //
                  //     if (widget.onPaymentComplete != null) {
                  //       widget.onPaymentComplete!('completed', '', html1);
                  //     }
                  //     Navigator.pop(context);
                  //   } catch (e) {
                  //     print('Error parsing payment response: $e');
                  //     if (widget.onPaymentComplete != null) {
                  //       widget.onPaymentComplete!('error', '', '');
                  //     }
                  //     Navigator.pop(context);
                  //   }
                  //   return;
                  // }
                  //
                  // // Check for CCAvenue success/failure pages
                  // if (page.contains('ccavenue.com') && (page.contains('success') || page.contains('failure') || page.contains('cancel'))) {
                  //   String status = 'unknown';
                  //   if (page.contains('success')) status = 'success';
                  //   else if (page.contains('failure')) status = 'failed';
                  //   else if (page.contains('cancel')) status = 'cancelled';
                  //
                  //   print('CCAvenue redirect detected - Status: $status');
                  //
                  //   if (widget.onPaymentComplete != null) {
                  //     widget.onPaymentComplete!(status, '', '');
                  //   }
                  //   Navigator.pop(context);
                  // }
                },
              ),
            ),
            if (loading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Do you want to cancel this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onPaymentCancel != null) {
                widget.onPaymentCancel!();
              }
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}