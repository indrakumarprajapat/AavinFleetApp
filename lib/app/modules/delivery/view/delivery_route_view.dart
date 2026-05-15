import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../agent/home/controllers/home_controller.dart';
import '../../../config/app_config.dart';
import '../../../models/delivery_model.dart';
import '../../../widgets/delivery_card.dart';
import '../controllers/delivery_controller.dart';

class DeliveryRouteView extends GetView<DeliveryController> {
  const DeliveryRouteView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final config = Get.find<ClientConfig>();

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: h * 0.24),
            Expanded(
              child: Obx(() {
                  final isCollection =
                      controller.appMode.value == AppMode.collection;

                  final originalDeliveries = controller.deliveries;
                  final deliveries = isCollection
                      ? originalDeliveries.reversed.toList()
                      : originalDeliveries;

                  if (deliveries.isEmpty) {
                    return const Center(
                      child: Text("No deliveries available"),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(w * 0.05, 5, w * 0.05, w * 0.05),
                          itemCount: deliveries.length,
                          itemBuilder: (context, index) {
                            final delivery = deliveries[index];

                            DeliveryStatus status;

                            if (isCollection) {
                              final originalIndex = originalDeliveries.indexOf(delivery);
                              final currentActive = controller.currentCollectingIndex.value;

                              if (delivery.apiIsCollected || 
                                  delivery.collectedTrays > 0 || 
                                  delivery.status == DeliveryStatus.collected) {
                                 status = DeliveryStatus.delivered;
                              } else if (originalIndex == currentActive) {
                                status = DeliveryStatus.delivering; // Currently collecting
                              } else if (originalIndex > currentActive && currentActive != -1) {
                                status = DeliveryStatus.delivered; // Already passed
                              } else {
                                status = DeliveryStatus.toBeCollected; // To be collected
                              }
                            } else {
                              status = delivery.status;
                            }

                            return Padding(
                              padding: EdgeInsets.only(bottom: h * 0.02),
                              child: DeliveryCard(
                                store: delivery,
                                isCollection: isCollection,
                                status: status,
                              ),
                            );
                          },
                        ),
                      ),

                      if (controller.appMode.value == AppMode.delivery &&
                          deliveries.every(
                                  (d) => d.status == DeliveryStatus.delivered || d.status == DeliveryStatus.collected))
                        Padding(
                          padding: EdgeInsets.all(w * 0.04),
                          child: SizedBox(
                            width: double.infinity,
                            height: h * 0.065,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1BA6C8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                controller.initiateCollection();
                              },
                              child: Text(
                                "Start Collection",
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (controller.appMode.value == AppMode.collection &&
                          deliveries.every((d) => d.apiIsCollected || 
                                                  d.collectedTrays > 0 || 
                                                  d.status == DeliveryStatus.collected))
                        Padding(
                          padding: EdgeInsets.all(w * 0.04),
                          child: SizedBox(
                            width: double.infinity,
                            height: h * 0.065,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                controller.showCompletionDialog();
                              },
                              child: Text(
                                "Submit Trip",
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ),
            ],
          ),
          _buildCustomHeader(h, w, config),
        ],
      );
  }

  Widget _buildCustomHeader(double h, double w, ClientConfig config) {
    final now = DateTime.now();
    final dateText = "${now.day}-${now.month}-${now.year}";

    return Obx(() {
      final isCollection = controller.appMode.value == AppMode.collection;
      return Container(
        height: h * 0.22,
        padding: const EdgeInsets.only(top: 35, left: 10, right: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00ADD3), Color(0xFF007EA7), Color(0xFF005F7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                /* IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.offAllNamed(Routes.HOME),
                ), */
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    try {
                      final homeController = Get.find<HomeController>();
                      homeController.isTripStarted.value = false;
                    } catch (e) {
                      Get.back();
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      config.app_title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Balance the back button
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                isCollection ? "Collection Route" : "Delivery Route",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Vehicle: ${controller.vehicleNumber.value}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          dateText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
