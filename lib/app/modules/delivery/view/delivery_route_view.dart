import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
    final paddingTop = MediaQuery.of(context).padding.top;
    final config = Get.find<ClientConfig>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          SizedBox(
            height: h * 0.22,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    "assets/images/Vector.svg",
                    colorFilter: const ColorFilter.mode(
                      Color(0xff1BA6C8),
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: paddingTop * 0.6),
                    child: SvgPicture.asset(
                      config.loginLogo,
                      colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn),
                      height: h * 0.06,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.02),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: Obx(() {
              final isCollection =
                  controller.appMode.value == AppMode.collection;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.01),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Hello, ",
                              style: TextStyle(
                                fontSize: w * 0.04,
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text: controller.name.value,
                              style: TextStyle(
                                fontSize: w * 0.065,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          Icon(Icons.local_shipping_outlined,
                              size: w * 0.05, color: Colors.blueGrey),
                          SizedBox(width: w * 0.02),
                          Text(
                            controller.vehicleNumber.value,
                            style: TextStyle(fontSize: w * 0.025),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.02),

                  Text(
                    isCollection
                        ? "Collection Route "
                        : "Delivery Route ",
                    style: TextStyle(
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              );
            }),
          ),

          SizedBox(height: h * 0.01),

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
                      padding: EdgeInsets.all(w * 0.05),
                      itemCount: deliveries.length,
                      itemBuilder: (context, index) {
                        final delivery = deliveries[index];

                        DeliveryStatus status;

                        if (isCollection) {
                          // In reverse flow:
                          // index 0 is the last store (Store 6)
                          // index 5 is the first store (Store 1)
                          
                          final originalIndex = originalDeliveries.indexOf(delivery);
                          
                          if (originalIndex > controller.currentCollectingIndex.value) {
                            status = DeliveryStatus.delivered;
                          } else if (originalIndex == controller.currentCollectingIndex.value) {
                            status = DeliveryStatus.delivering;
                          } else {
                            status = DeliveryStatus.pending;
                          }
                        } else {
                          status = delivery.status;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: h * 0.02),
                          child: DeliveryCard(
                            store: delivery,
                            tray: isCollection
                                ? delivery.totalTrays
                                : delivery.totalTrays,
                            packet: isCollection ? 0 : delivery.totalPackets,
                            isCollection: isCollection,
                            status: status,
                          ),
                        );
                      },
                    ),
                  ),

                  if (controller.appMode.value == AppMode.delivery &&
                      deliveries.every(
                              (d) => d.status == DeliveryStatus.delivered))
                    Padding(
                      padding: EdgeInsets.all(w * 0.04),
                      child: SizedBox(
                        width: double.infinity,
                        height: h * 0.065,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1BA6C8),
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

                  const SizedBox(height: 20),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}