import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../data/data_service.dart';
import '../../../../models/slot_model.dart';
import '../../../../api/api_service.dart';
import '../../../../services/global_cart_service.dart';
import '../../home/controllers/home_controller.dart';

class CartController extends GetxController {
  final apiService = Get.find<ApiService>();
  final globalCartService = Get.find<GlobalCartService>();
  final _cartItems = <Map<String, dynamic>>[].obs;
  final _isLoading = true.obs;
  final enableMorningSlot = false.obs;
  final enableEveningSlot = false.obs;
  final _selectedShift = 1.obs;
  final _cartData = <String, dynamic>{}.obs;
  final _availableShifts = <int>[].obs;
  Timer? _debounceTimer;
  final Map<String, dynamic> _pendingUpdates = {};

  List<Map<String, dynamic>> get cartItems => _cartItems;
  bool get isLoading => _isLoading.value;
  int get selectedShift => _selectedShift.value;
  Map<String, dynamic> get cartData => _cartData;
  List<int> get availableShifts => _availableShifts;
  final storage = GetStorage();
  // final RxInt itemUnitType = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAvailableShifts();
    // final dataService = Get.find<DataService>();
    // final agentModel = dataService.agentModel;
    // itemUnitType.value = agentModel?.itemUnitType ?? storage.read('itemUnitType') ?? 1;
  }

  int _getDefaultShift() {
    return 1;
  }

  void changeShift(int shift) {
    _selectedShift.value = shift;
    loadCartItems();
  }

  Future<void> _checkAvailableShifts() async {
    _isLoading.value = true;
    try {
      final response = await apiService.getCartItems();
      _cartData.value = {
        'subtotalAmount': response.subtotalAmount ?? 0.0,
        'totalTax': response.totalTax ?? 0.0,
        'totalAmount': response.totalAmount ?? 0.0,
        'totalDiscount': response.totalDiscount ?? 0.0,
      };
      enableMorningSlot.value = response.enableMorningSlot ?? false;
      enableEveningSlot.value = response.enableEveningSlot ?? false;
      _cartItems.value = response.items?.map((item) => item.toJson()).toList() ?? [];
    } catch (e) {
      print('Error loading cart: $e');
      _cartItems.value = [];
      _cartData.value = {};
    }
    _isLoading.value = false;
  }

  Future<void> loadCartItems() async {
    try {
      final response = await apiService.getCartItems();
      _cartData.value = {
        'subtotalAmount': response.subtotalAmount ?? 0.0,
        'totalTax': response.totalTax ?? 0.0,
        'totalAmount': response.totalAmount ?? 0.0,
        'totalDiscount': response.totalDiscount ?? 0.0,
      };
      enableMorningSlot.value = response.enableMorningSlot ?? false;
      enableEveningSlot.value = response.enableEveningSlot ?? false;
      _cartItems.value = response.items?.map((item) => item.toJson()).toList() ?? [];
    } catch (e) {
      _cartItems.value = [];
      _cartData.value = {};
      print('Failed to load cart items: $e');
    }
  }

  Future<void> updateCartItem(int productId, double quantity, int shiftType, {int? orderType}) async {
    if(true){
      try {
        final homeController = Get.find<HomeController>();
        final slot = homeController.slots.firstWhere(
              (s) => s.shift == shiftType,
          orElse: () => SlotModel(),
        );
        final slotId = slot.id ?? 1;

        await apiService.updateCart(
            productId: productId,
            quantity: quantity,
            shiftType: shiftType,
            slotId: slotId,
            orderType: orderType ?? 1
        );

        await loadCartItems();
        await globalCartService.refreshCartEstimate();
      } catch (e) {
        print('Cart update error: $e');
      }
    }else{
    final key = '${productId}_$shiftType';
    _pendingUpdates[key] = {'productId': productId, 'quantity': quantity, 'shiftType': shiftType, 'orderType': orderType ?? 1};
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 2), () async {
      final updates = Map<String, dynamic>.from(_pendingUpdates);
      _pendingUpdates.clear();

      try {
        for (final update in updates.values) {
          final homeController = Get.find<HomeController>();
          final slot = homeController.slots.firstWhere(
                (s) => s.shift == update['shiftType'],
            orElse: () => SlotModel(),
          );
          final slotId = slot.id ?? 1;

          await apiService.updateCart(
              productId: update['productId'],
              quantity: update['quantity'],
              shiftType: update['shiftType'],
              slotId: slotId,
              orderType: update['orderType'] ?? 1
          );
        }
        await Future.delayed(Duration(milliseconds: 200));
        await loadCartItems();
        await globalCartService.refreshCartEstimate();
      } catch (e) {
        print('Cart update error: $e');
      }
    });
  }}


  Future<void> refreshCart() async {
    final currentShift = _selectedShift.value;
    await _checkAvailableShifts();
    if (_availableShifts.contains(currentShift)) {
      _selectedShift.value = currentShift;
    }
    await loadCartItems();
    // shiftType: _selectedShift.value
    await globalCartService.refreshCartEstimate();
  }

  double getTotalAmount() {
    return (_cartData['totalAmount'] ?? 0.0).toDouble();
  }

  double getSubtotalAmount() {
    return (_cartData['subtotalAmount'] ?? 0.0).toDouble();
  }

  double getTotalTax() {
    return (_cartData['totalTax'] ?? 0.0).toDouble();
  }

  double getTotalDiscount() {
    return (_cartData['totalDiscount'] ?? 0.0).toDouble();
  }

  int getTotalItems() {
    // return _cartItems.fold(0, (sum, item) => sum + (item['quantity'] ?? 0));
    return _cartItems.length.toInt();
  }

  bool isSlotExpired() {
    try {
      final homeController = Get.find<HomeController>();
      final slots = homeController.slots;
      final currentSlot = slots.firstWhere(
            (slot) => slot?.shift == _selectedShift.value,
        orElse: () => SlotModel(),
      );

      if (currentSlot.id == null) return true;

      final slotDate = currentSlot.slotDate;
      final cutoffTime = currentSlot.cutoffTime;

      if (slotDate == null || cutoffTime == null) return true;

      final now = DateTime.now();
      final slotDateTime = DateTime.parse(slotDate);
      final cutoffParts = cutoffTime.split(':');
      final cutoffDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(cutoffParts[0]),
        int.parse(cutoffParts[1]),
      );

      return now.isAfter(cutoffDateTime);
    } catch (e) {
      return true;
    }
  }

  Future<bool> checkTrayCount() async {
    try {
      final result = await apiService.checkTrayCount();
      return result.isEmpty;
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
      return false;
    }
  }

  void showSlotExpiredDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Slot Expired'),
        content: Text('The ${_selectedShift.value == 1 ? "morning" : "evening"} slot has expired. You cannot proceed with this order.'),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> removeCartItem(int productId) async {
    try {
      _cartItems.removeWhere((item) => item['product_id'] == productId);
      final homeController = Get.find<HomeController>();
      final morningSlot = homeController.slots.firstWhere(
        (s) => s.shift == 1,
        orElse: () => SlotModel(),
      );
      final eveningSlot = homeController.slots.firstWhere(
        (s) => s.shift == 2,
        orElse: () => SlotModel(),
      );
      if (morningSlot.id != null) {
        await apiService.updateCart(
          productId: productId,
          quantity: 0,
          shiftType: 1,
          slotId: morningSlot.id!,
          orderType: 1,
        );
      }
      if (eveningSlot.id != null) {
        await apiService.updateCart(
          productId: productId,
          quantity: 0,
          shiftType: 2,
          slotId: eveningSlot.id!,
          orderType: 1,
        );
      }
      await apiService.updateCart(
        productId: productId,
        quantity: 0,
        shiftType: 0,
        slotId: 1,
        orderType: 2,
      );
      await loadCartItems();
      await globalCartService.refreshCartEstimate();
    } catch (e) {
      print('Failed to remove cart item: $e');
      await loadCartItems();
    }
  }

  Future<void> clearCart() async {
    try {
      await apiService.clearCart();
      await loadCartItems();
      await globalCartService.refreshCartEstimate();
      Get.snackbar(
        'Success',
        'Cart cleared successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cart: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}