import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class GlobalCartService extends GetxService {
  final apiService = Get.find<ApiService>();
  final _cartEstimate = <String, dynamic>{}.obs;

  Map<String, dynamic> get cartEstimate => _cartEstimate;
  int get totalItems => _cartEstimate['totalItems'] ?? 0;
  int get itemsCount => _cartEstimate['items'] ?? 0;
  double get totalAmount => (_cartEstimate['totalAmount'] ?? 0.0).toDouble();

  @override
  void onInit() {
    super.onInit();
    // refreshCartEstimate();
  }

  // Future<void> refreshCartEstimate({int? shiftType}) async {
  //   try {
  //     final response = await apiService.getCartEstimate(shiftType: shiftType);
  //     _cartEstimate.value = response;
  //   } catch (e) {
  //     print('Failed to refresh cart estimate: $e');
  //   }
  // }

  @override
  void onClose() {
    _cartEstimate.value = {};
    super.onClose();
  }

  Future<void> updateCart(int productId, double quantity, int shiftType, int slotId, int orderType) async {
    try {
      final response = await apiService.updateCart(
        productId: productId, 
        quantity: quantity, 
        shiftType: shiftType, 
        slotId: slotId,
        orderType: orderType
      );
      if (response.isNotEmpty) {
        // await refreshCartEstimate();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to update cart');
      }
    } catch (e) {
      Get.defaultDialog(
        title: "Info",
        middleText: "$e",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
        },
      );
    }
  }
}