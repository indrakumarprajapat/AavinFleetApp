import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../widgets/delivery_card.dart';
import 'controllers/delivery_controller.dart';
import '../../models/delivery_model.dart';

class DeliveryPointsScreen extends GetView<DeliveryController> {
  const DeliveryPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [

          /// HEADER
          Stack(
            children: [
              SvgPicture.asset(
                "assets/images/Vector.svg",
                height: 220,
                width: double.infinity,
                color: const Color(0xff1BA6C8),
                fit: BoxFit.fill,
              ),
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: SvgPicture.asset(
                  "assets/svg/aavinnamakkallogo.svg",
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  height: 50,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// TITLE
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              controller.appMode.value == AppMode.delivery
                  ? "Scheduled Deliveries"
                  : "Collection Points",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          )),

          const SizedBox(height: 10),

          /// USER INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Hello, ",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      TextSpan(
                        text: controller.name.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 18),
                    const SizedBox(width: 6),
                    Text(controller.vehicleNumber.value),
                  ],
                ),
              ],
            )),
          ),

          const SizedBox(height: 20),

          /// LIST + BUTTON
          Expanded(
            child: Column(
              children: [

                /// STORE LIST (COMMON FOR BOTH MODES)
                Expanded(
                  child: Obx(() {

                    final isCollection =
                        controller.appMode.value == AppMode.collection;

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: controller.deliveries.length,
                      itemBuilder: (context, index) {

                        final delivery = controller.deliveries[index];

                        /// TOTAL (FROM PRODUCTS)
                        final trayTotal = delivery.products.fold(0, (s, p) => s + p.trays);
                        final packetTotal = delivery.products.fold(0, (s, p) => s + p.packets);
                        final tubTotal = delivery.products.fold(0, (s, p) => s + p.tubs);

                        /// COLLECTION STATUS LOGIC
                        DeliveryStatus status;

                        if (isCollection) {
                          if (index < controller.currentCollectingIndex.value) {
                            status = DeliveryStatus.delivered;
                          } else if (index == controller.currentCollectingIndex.value) {
                            status = DeliveryStatus.delivering;
                          } else {
                            status = DeliveryStatus.pending;
                          }
                        } else {
                          status = delivery.status;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: DeliveryCard(
                                     store: delivery,

                            /// ✅ DATA SWITCH
                            tray: isCollection
                                ? delivery.collectedTrays
                                : trayTotal,

                            packet: isCollection
                                ? 0
                                : packetTotal,

                            tub: isCollection
                                ? delivery.collectedTubs
                                : tubTotal,

                            /// ✅ MODE FLAG
                            isCollection: isCollection,

                            /// ✅ REMAINING (ONLY COLLECTION)
                            remainingTray: isCollection
                                ? (trayTotal - delivery.collectedTrays)
                                : null,

                            remainingTub: isCollection
                                ? (tubTotal - delivery.collectedTubs)
                                : null,

                            /// ✅ STATUS
                            status: status,
                          ),
                        );
                      },
                    );
                  }),
                ),

                /// START COLLECTION BUTTON
                Obx(() {
                  final allDelivered = controller.deliveries
                      .every((d) => d.status == DeliveryStatus.delivered);

                  if (controller.appMode.value == AppMode.delivery && allDelivered) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1BA6C8),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: controller.startCollection,
                        child: const Text("Start Collection",
                        style: TextStyle(
                          fontSize: 20,
                        ),),
                      ),
                    );
                  }

                  return const SizedBox();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
