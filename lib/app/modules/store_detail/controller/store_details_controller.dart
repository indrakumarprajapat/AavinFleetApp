import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/api_service.dart';
import '../../../models/delivery_model.dart';
import '../../delivery/controllers/delivery_controller.dart';

class StoreDetailsController extends GetxController {
  final ApiService api = Get.find<ApiService>();
  final DeliveryController deliveryController = Get.find();
  
  final _store = Rxn<DeliveryModel>();
  DeliveryModel? get store => _store.value;
  
  final isLoading = false.obs;
  late TextEditingController collectedTraysController;

  @override
  void onInit() {
    super.onInit();
    collectedTraysController = TextEditingController();
    if (Get.arguments is DeliveryModel) {
      _store.value = Get.arguments as DeliveryModel;
    }
    
    // Listen for updates from the master list to keep this view in sync
    ever(deliveryController.deliveries, (List<DeliveryModel> list) {
      if (_store.value != null) {
        final updated = list.firstWhereOrNull((d) => d.id == _store.value!.id);
        if (updated != null && updated.status != _store.value!.status) {
          _store.value = updated;
        }
      }
    });
    
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

      final updatedStore = store!.copyWith(products: products);
      _store.value = updatedStore;

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
    super.onClose();
  }

  Future<void> markDelivered() async {
    if (deliveryController.isLoading.value || store == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Confirm Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to mark Booth ${store!.number} as delivered?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              Get.back(); // Close dialog
              await deliveryController.markDelivered(store!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007EA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Confirm Collection", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Mark $collectedCount trays as collected from Booth ${store!.number}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              Get.back(); // Close dialog
              await deliveryController.markCollected(store!, collectedCount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007EA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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

  Future<void> callAgent() async {
    if (store?.agentPhone == null) return;
    final Uri url = Uri.parse("tel:${store!.agentPhone}");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar("Error", "Could not launch dialer", snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Error", "Error launching dialer: $e", snackPosition: SnackPosition.TOP);
    }
  }
}
