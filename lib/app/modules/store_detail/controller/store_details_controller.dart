import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../../../models/delivery_model.dart';
import '../../delivery/controllers/delivery_controller.dart';

class StoreDetailsController extends GetxController {
  final ApiService api = Get.find<ApiService>();
  final DeliveryController deliveryController = Get.find();
  
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
      final updatedStore = store!.copyWith(products: products);
      _store.value = updatedStore;

      // Also update the main list in DeliveryController so the change is reflected when going back
      final index = deliveryController.deliveries.indexWhere((d) => d.id == store!.id);
      if (index != -1) {
        deliveryController.deliveries[index] = updatedStore;
      }
    } catch (e) {
      debugPrint("Error fetching booth details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Note: We don't dispose collectedTraysController here because GetX might 
    // reuse the instance or the view might still access it during transitions,
    // which causes the "used after being disposed" error.
    super.onClose();
  }

  Future<void> markDelivered() async {
    if (deliveryController.isLoading.value || store == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Confirm Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to mark Booth ${store!.number} as delivered (${store!.totalTrays} Trays)?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await deliveryController.markDelivered(store!);
              } catch (e) {
                Get.snackbar("Error", e.toString());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> markCollected() async {
    if (deliveryController.isLoading.value || store == null) return;

    final input = collectedTraysController.text.trim();
    final int collectedCount = int.tryParse(input) ?? 0;

    final int expectedCount = (store!.totalTrays > 0)
        ? store!.totalTrays
        : store!.remainingTrays;

    if (collectedCount != expectedCount && collectedCount != 0) {
      Get.snackbar(
        "Invalid Count",
        "You must collect either all ($expectedCount) or 0 trays.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Confirm Collection", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to mark $collectedCount trays as collected from Booth ${store!.number}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await deliveryController.markCollected(
                  store!,
                  collectedCount,
                );
              } catch (e) {
                Get.snackbar("Error", e.toString());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void openMap() {
    if (store != null) {
      deliveryController.openMap(store!.address);
    }
  }
}
