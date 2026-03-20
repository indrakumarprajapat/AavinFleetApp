import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/order_model.dart';
import '../../../../api/api_service.dart';

class OrderDetailsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final isLoading = true.obs;
  final orderDetails = Rxn<OrderModel>();

  List<OrderItemModel> get orderItems => orderDetails.value?.items ?? [];

  @override
  void onInit() {
    super.onInit();
    final orderId = Get.arguments as int;
    fetchOrderDetails(orderId);
  }

  Future<void> fetchOrderDetails(int orderId) async {
    try {
      isLoading.value = true;
      final order = await _apiService.getOrderDetails(orderId);
      print('Order details: $order');
      print('Order items: ${order.items}');
      orderDetails.value = order;
    } catch (e) {
      print('Error fetching order details: $e');
      Get.snackbar('Error', 'Failed to load order details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder() async {
    try {
      final orderId = orderDetails.value?.id;
      if (orderId == null) return;
      
      final result = await _apiService.cancelOrder(orderId);

      if (orderDetails.value != null) {
        orderDetails.value = orderDetails.value!.copyWith(status: 3);
      }
      
      Get.snackbar(
        'Success', 
        result['message'] ?? 'Order cancelled successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error', 
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}