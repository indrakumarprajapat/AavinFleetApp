import 'package:get/get.dart';

import '../../../../models/order_model.dart';
import '../../../../api/api_service.dart';

class OrderController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  final RxInt selectedOrderType = 0.obs;
  final RxInt selectedShift = 0.obs;
  final RxInt selectedStatus = 0.obs;
  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      
      Map<String, dynamic> queryParams = {};
      if (selectedOrderType.value > 0) queryParams['orderType'] = selectedOrderType.value;
      if (selectedShift.value > 0) queryParams['shift'] = selectedShift.value;
      if (selectedStatus.value > 0) queryParams['status'] = selectedStatus.value;
      if (fromDate.value.isNotEmpty) queryParams['fromDate'] = fromDate.value;
      if (toDate.value.isNotEmpty) queryParams['toDate'] = toDate.value;
      
      final ordersList = await _apiService.getOrders(queryParams);
      orders.value = ordersList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters({
    int? orderType,
    int? shift,
    int? status,
    String? from,
    String? to,
  }) {
    selectedOrderType.value = orderType ?? 0;
    selectedShift.value = shift ?? 0;
    selectedStatus.value = status ?? 0;
    fromDate.value = from ?? '';
    toDate.value = to ?? '';
    fetchOrders();
  }

  void clearFilters() {
    selectedOrderType.value = 0;
    selectedShift.value = 0;
    selectedStatus.value = 0;
    fromDate.value = '';
    toDate.value = '';
    fetchOrders();
  }

  String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'New';
      case 2:
        return 'Paid';
      case 3:
        return 'Cancelled';
      case 4:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  String getOrderTypeText(int orderType) {
    switch (orderType) {
      case 1:
        return 'Milk & Curd';
      case 2:
        return 'Buy Products';
      default:
        return 'Unknown';
    }
  }

  String getShiftText(int shift) {
    switch (shift) {
      case 0:
        return 'Any Time';
      case 1:
        return 'Morning';
      case 2:
        return 'Evening';
      default:
        return 'Unknown';
    }
  }
}