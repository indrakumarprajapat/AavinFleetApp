import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../modules/agent/wallet/controllers/wallet_controller.dart';

class PaymentResponseWebView extends StatefulWidget {
  final String successUrl;

  const PaymentResponseWebView({Key? key, required this.successUrl}) : super(key: key);

  @override
  _PaymentResponseWebViewState createState() => _PaymentResponseWebViewState();
}

class _PaymentResponseWebViewState extends State<PaymentResponseWebView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pop(context);
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Status'),
        automaticallyImplyLeading: false,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.successUrl)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
        ),
        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(source: """
            document.addEventListener('click', function(e) {
              if (e.target.textContent.includes('Close') || 
                  e.target.textContent.includes('close') ||
                  e.target.onclick && e.target.onclick.toString().includes('close')) {
                window.flutter_inappwebview.callHandler('closeWebView');
              }
            });
          """);
        },
        onConsoleMessage: (controller, consoleMessage) {
          if (consoleMessage.message.contains('close')) {
            Navigator.pop(context);

          }
        },
      ),
    );
  }
}