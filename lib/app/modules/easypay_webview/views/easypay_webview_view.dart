import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/easypay_webview_controller.dart';

class EasyPayWebviewView extends GetView<EasyPayWebviewController> {
  const EasyPayWebviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EasyPay Payment'),
        backgroundColor: Color(0xFF00ADD9),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => controller.handlePaymentCancel(),
        ),
      ),
      body: Obx(() => controller.isLoading
          ? Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: controller.webViewController)),
    );
  }
}