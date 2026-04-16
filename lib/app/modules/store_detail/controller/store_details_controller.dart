import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/delivery_model.dart';
import '../../delivery/controllers/delivery_controller.dart';
import '../../delivery/view/delivery_route_view.dart';
import '../view/store_details_view.dart';

class StoreDetailsController extends GetxController {
  final DeliveryController deliveryController = Get.find();

  late DeliveryModel store;

  late TextEditingController collectedTraysController;

  @override
  void onInit() {
    super.onInit();

    store = Get.arguments;

    collectedTraysController = TextEditingController(
      text: (store.collectedTrays == 0)
          ? ""
          : store.collectedTrays.toString(),
    );
  }

  @override
  void onClose() {
    collectedTraysController.dispose();
    super.onClose();
  }

  /// ================= DELIVERY =================
  Future<void> markDelivered() async {
    await deliveryController.markDelivered(store);

    final nextStore = deliveryController.getNextStore(store);

    if (nextStore != null) {
      Get.off(() => const StoreDetailsView(), arguments: nextStore);
    } else {
      Get.off(() => const DeliveryRouteView());
    }
  }

  /// ================= COLLECTION =================
  Future<void> markCollected() async {
    final trays =
        int.tryParse(collectedTraysController.text) ?? 0;

    if (trays <= 0) {
      Get.snackbar("Error", "Enter valid trays");
      return;
    }

    if (trays > store.totalTrays) {
      Get.snackbar("Error", "Cannot exceed total trays");
      return;
    }

    await deliveryController.markCollected(store, trays);

    final nextStore = deliveryController.getNextStore(store);

    if (nextStore != null) {
      Get.off(() => const StoreDetailsView(), arguments: nextStore);
    } else {
      Get.off(() => const DeliveryRouteView());
    }
  }

  void openMap() {
    deliveryController.openMap(store.address);
  }
}