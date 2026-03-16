import 'package:get/get.dart';

import '../../../../api/api_service.dart';
class MilkOrdersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final orders = <dynamic>[].obs;
  final isLoading = true.obs;
  final orderStatus = <int, int>{}.obs;
  final expandedOrders = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getOrdersCard();
      orders.value = response;
      orderStatus.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    try {
      final response = await _apiService.getOrdersCard();
      orders.value = response;
      orderStatus.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh orders: $e');
    }
  }

  void toggleOrderExpansion(int orderId) {
    expandedOrders[orderId] = !(expandedOrders[orderId] ?? false);
  }

  Future<void> updateOrderStatus(int orderId, int status) async {
    try {
      await _apiService.updateOrderStatus(orderId, status);
      orderStatus[orderId] = status;
      Get.snackbar('Success', 'Order status updated successfully');
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('message:')) {
        final messageStart = errorMessage.indexOf('message:') + 8;
        final messageEnd = errorMessage.indexOf('}', messageStart);
        if (messageEnd != -1) {
          errorMessage = errorMessage.substring(messageStart, messageEnd).trim();
        }
      }
      
      Get.snackbar('Error', errorMessage);
    }
  }
}