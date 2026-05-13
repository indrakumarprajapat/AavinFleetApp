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
  final productControllers = <int, TextEditingController>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final initialStore = Get.arguments as DeliveryModel;
    _store.value = initialStore;

    collectedTraysController.text = "0";
    fetchBoothProductDetails();
  }

  Future<void> fetchBoothProductDetails() async {
    if (store == null) return;
    try {
      isLoading.value = true;
      final List<dynamic> data =
          await api.getBoothDetails(deliveryController.tripId, store!.boothId);

      final products =
          data.map((json) => DeliveryProductModel.fromJson(json)).toList();

      // Update the local store with fetched products
      _store.value = store!.copyWith(products: products);

      // Initialize product controllers for collection
      _initProductControllers(products);
    } catch (e) {
      debugPrint("Error fetching booth details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _initProductControllers(List<DeliveryProductModel> products) {
    // Clear existing
    productControllers.values.forEach((c) => c.dispose());
    productControllers.clear();

    for (int i = 0; i < products.length; i++) {
      // Pre-fill with 0 or product.trays?
      // If we want total to be 0 initially, set to "0"
      final c = TextEditingController(text: "0");
      productControllers[i] = c;
      c.addListener(_syncTotalFromProducts);
    }
    _syncTotalFromProducts();
  }

  void _syncTotalFromProducts() {
    int total = 0;
    productControllers.forEach((_, c) {
      total += int.tryParse(c.text) ?? 0;
    });
    // Update the main controller. Using text assignment might move cursor if focused,
    // but typically user will type in product fields.
    if (collectedTraysController.text != total.toString()) {
      collectedTraysController.text = total.toString();
    }
  }

  @override
  void onClose() {
    productControllers.values.forEach((c) => c.dispose());
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

    if (deliveryController.isLoading.value ||
        store == null) {
      return;
    }

    final input = collectedTraysController.text.trim();
    final int collectedCount = int.tryParse(input) ?? 0;

    // Strict validation: Must match expected or be 0
    if (collectedCount != store!.totalTrays && collectedCount != 0) {
      Get.snackbar(
        "Invalid Count",
        "You must collect either all (${store!.totalTrays}) or 0 trays.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    try {
      await deliveryController.markCollected(
        store!,
        collectedCount,
      );
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