import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../../../models/delivery_model.dart';
import '../../delivery/controllers/delivery_controller.dart';

class StoreDetailsController extends GetxController {
  final ApiService api = Get.find<ApiService>();
  final DeliveryController deliveryController = Get.find();
  bool _disposed = false;
  
  final _store = Rxn<DeliveryModel>();
  DeliveryModel? get store => _store.value;
  
  final isLoading = false.obs;
  final TextEditingController collectedTraysController =
  TextEditingController();
  @override
  void onInit() {
    super.onInit();
    final initialStore = Get.arguments as DeliveryModel;
    _store.value = initialStore;

    collectedTraysController.text =
    initialStore.collectedTrays == 0
        ? ""
        : initialStore.collectedTrays.toString();
    fetchBoothProductDetails();
  }

  Future<void> fetchBoothProductDetails() async {
    if (store == null) return;
    try {
      isLoading.value = true;
      final List<dynamic> data = await api.getBoothDetails(
        deliveryController.tripId, 
        store!.boothId
      );

      final products = data.map((json) => DeliveryProductModel.fromJson(json)).toList();
      
      // Update the local store with fetched products
      _store.value = store!.copyWith(products: products);
      
    } catch (e) {
      debugPrint("Error fetching booth details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _disposed = true;
    collectedTraysController.dispose();
    super.onClose();
  }

  Future<void> markDelivered() async {
    if (deliveryController.isLoading.value || store == null) return;
    try {
      await deliveryController.markDelivered(store!);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> markCollected() async {
    if (deliveryController.isLoading.value || store == null) return;
    final trays = int.tryParse(collectedTraysController.text) ?? 0;

    if (trays < 0) {
      Get.snackbar("Error", "Enter valid trays");
      return;
    }

    if (trays > store!.totalTrays && store!.totalTrays > 0) {
      Get.snackbar("Error", "Cannot exceed total trays (${store!.totalTrays})");
      return;
    }

    try {
      await deliveryController.markCollected(store!, trays);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void openMap() {
    if (store != null) {
      deliveryController.openMap(store!.address);
    }
  }
}