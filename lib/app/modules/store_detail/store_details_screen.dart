import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../delivery/controllers/delivery_controller.dart';
import '../../models/delivery_model.dart';
import '../delivery/delivery_points_screen.dart';

class StoreDetailsScreen extends StatelessWidget {
  StoreDetailsScreen({super.key});
  final DeliveryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final DeliveryModel? store = Get.arguments;

    if (store == null) {
      return const Scaffold(
        body: Center(child: Text("Store data not found")),
      );
    }

    final int totalTrays = store.totalTrays;
    final int totalPackets = store.totalPackets;
    final int totalTubs = store.totalTubs;

    final TextEditingController collectedTraysController =
        TextEditingController(
            text: store.collectedTrays == 0
                ? ""
                : store.collectedTrays.toString());

    final TextEditingController collectedTubsController = TextEditingController(
        text: store.collectedTubs == 0 ? "" : store.collectedTubs.toString());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(store.storeName),
        centerTitle: true,
        backgroundColor: const Color(0xff1BA6C8),
      ),
      body: Obx(() {
        final isCollection = controller.appMode.value == AppMode.collection;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// STORE CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue.shade50,
                          ),
                          child: const Icon(
                            Icons.store,
                            size: 35,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      store.storeName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "#${store.number}",
                                      style: const TextStyle(
                                        color: Colors.black26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                store.address,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ================= DELIVERY MODE =================
              if (!isCollection) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text("Item",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text("Tray", textAlign: TextAlign.center)),
                      Expanded(
                          child: Text("Packet", textAlign: TextAlign.center)),
                      Expanded(child: Text("Tub", textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(thickness: 1),
                ),
                ...store.products.map((product) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(product.name)),
                        Expanded(
                            child: Text("${product.trays}",
                                textAlign: TextAlign.center)),
                        Expanded(
                            child: Text("${product.packets}",
                                textAlign: TextAlign.center)),
                        Expanded(
                            child: Text("${product.tubs}",
                                textAlign: TextAlign.center)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(thickness: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text("Total",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                          child:
                              Text("$totalTrays", textAlign: TextAlign.center)),
                      Expanded(
                          child: Text("$totalPackets",
                              textAlign: TextAlign.center)),
                      Expanded(
                          child:
                              Text("$totalTubs", textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: controller.openMap,
                          icon: const Icon(Icons.my_location_sharp),
                          label: const Text(
                            "Get Directions",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => _handleDeliveryMark(store, context),
                              icon: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Icon(Icons.check_circle),
                              label: Text(
                                controller.isLoading.value
                                    ? "Processing..."
                                    : "Mark Delivered",
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              /// ================= COLLECTION MODE =================
              if (isCollection) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Trays: ${store.collectedTrays}/$totalTrays | "
                          "Tubs: ${store.collectedTubs}/$totalTubs",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Remaining: ${store.remainingTrays} trays, "
                          "${store.remainingTubs} tubs",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: collectedTraysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Collected Trays",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: collectedTubsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Collected Tubs",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  final trays = int.tryParse(
                                          collectedTraysController.text) ??
                                      0;
                                  final tubs = int.tryParse(
                                          collectedTubsController.text) ??
                                      0;
                                  _handleCollectionMark(
                                      store, trays, tubs, context);
                                },
                          icon: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Icon(Icons.check),
                          label: Text(
                            controller.isLoading.value
                                ? "Processing..."
                                : "Mark Collected",
                          ),
                        ),
                      )),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  /// ✅ Proper Delivery Navigation
  void _handleDeliveryMark(DeliveryModel store, BuildContext context) async {
    await controller.markDeliveredAndGoBack(store);

    final nextStore = controller.getNextStore(store);

    if (nextStore != null) {
      // Replace current screen with the next store
      Get.off(
        () => StoreDetailsScreen(),
        arguments: nextStore,
        preventDuplicates: false,
        transition: Transition.rightToLeft,
      );
    } else {
      // ✅ End of list: Navigate explicitly to DeliveryPointsScreen
      Get.off(() => const DeliveryPointsScreen());
    }
  }

  /// ✅ Proper Collection Navigation
  void _handleCollectionMark(
      DeliveryModel store, int trays, int tubs, BuildContext context) async {
    await controller.markCollectedAndGoBack(store, trays, tubs);

    final nextStore = controller.getNextStore(store);

    if (nextStore != null) {
      // Replace current screen with the next store
      Get.off(
        () => StoreDetailsScreen(),
        arguments: nextStore,
        preventDuplicates: false,
        transition: Transition.rightToLeft,
      );
    } else {
      // ✅ End of list: Navigate explicitly to DeliveryPointsScreen
      Get.off(() => const DeliveryPointsScreen());
    }
  }
}
