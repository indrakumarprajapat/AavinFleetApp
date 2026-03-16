import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _isConnected = true.obs;
  
  bool get isConnected => _isConnected.value;
  
  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isConnected.value = true;
        return true;
      }
    } catch (e) {
      _isConnected.value = false;
      return false;
    }
    return false;
  }
  
  Future<bool> checkServerConnectivity(String baseUrl) async {
    try {
      final uri = Uri.parse(baseUrl);
      final result = await InternetAddress.lookup(uri.host);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      print('Server connectivity check failed: $e');
      return false;
    }
    return false;
  }
  
  void showNoInternetDialog() {
    if (!Get.isDialogOpen!) {
      Get.dialog(
        AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                checkConnectivity();
              },
              child: Text('Retry'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }
}