import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/delivery_model.dart';
import '../modules/delivery/controllers/delivery_controller.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryModel store;
  final DeliveryStatus status;
  final bool isCollection;
  final int? tray;
  final int? packet;
  final int? tub;
  final int? remainingTray;

  DeliveryCard({
    super.key,
    required this.store,
    required this.status,
    this.tray,
    this.packet,
    this.tub,
    this.remainingTray,
    this.isCollection = false,
  });

  int get totalTray =>
      tray ?? store.products.fold(0, (sum, p) => sum + p.trays);

  int get totalPacket =>
      packet ?? store.products.fold(0, (sum, p) => sum + p.packets);

  int get totalTub =>
      tub ?? store.products.fold(0, (sum, p) => sum + p.tubs);

  bool get isDelivered => status == DeliveryStatus.delivered;

  bool get isCurrent => status == DeliveryStatus.delivering;

  static final Map<DeliveryStatus, Color> statusColors = {
    DeliveryStatus.delivered: Colors.green,
    DeliveryStatus.delivering: Colors.blue,
    DeliveryStatus.pending: Colors.grey,
  };

  static final Map<DeliveryStatus, String> deliveryText = {
    DeliveryStatus.delivered: "DELIVERED",
    DeliveryStatus.delivering: "IN_PROGRESS",
    DeliveryStatus.pending: "PENDING",
  };

  Color getStatusColor() {
    return statusColors[status] ?? Colors.grey;
  }

  String getStatusText() {
    if (isCollection) {
      return {
        DeliveryStatus.delivered: "COLLECTED",
        DeliveryStatus.delivering: "COLLECTING",
        DeliveryStatus.pending: "TO BE COLLECTED",
      }[status] ?? "Unknown";
    }
    return deliveryText[status] ?? "Unknown";
  }


  DeliveryStatus mapStatus(String? status) {
    switch (status) {
      case "DELIVERED":
        return DeliveryStatus.delivered;
      case "IN_PROGRESS":
        return DeliveryStatus.delivering;
      case "PENDING":
        return DeliveryStatus.pending;
      default:
        return DeliveryStatus.pending;
    }
  }

  //
  // Color getCardColor(DeliveryModel status) {
  //   if (status == DeliveryStatus.delivering) return Colors.blue.shade50;
  //   if (status == DeliveryStatus.pending) return Colors.grey.shade200;
  //   return Colors.white;
  // }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final h = MediaQuery
        .of(context)
        .size
        .height;
    final w = MediaQuery
        .of(context)
        .size
        .width;

    return GestureDetector(
      onTap: () {
        controller.openStoreDetails(store);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: isCurrent ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrent ? Border.all(color: Colors.blue, width: 1.5) : null,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: h * 0.08,
                  width: h * 0.08,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: getStatusColor(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    store.number,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.06,
                    ),
                  ),
                ),

                SizedBox(width: w * 0.03),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.storeName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: w * 0.06,
                              ),
                            ),
                          ),
                          Container(
                            height: w * 0.065,
                            width: w * 0.065,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDelivered
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                            child: Icon(
                              Icons.check,
                              size: w * 0.045,
                              color: isDelivered ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        store.address,
                        style: TextStyle(
                            color: Colors.grey, fontSize: w * 0.035),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: h * 0.015),
            Divider(color: Colors.grey.shade300),
            SizedBox(height: h * 0.015),

            /// 🔷 DATA
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: w * 0.045,
                      color: (isDelivered || isCurrent)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    SizedBox(width: w * 0.015),
                    Text(
                      isCollection ? "Collection" : "Delivery",
                      style: TextStyle(
                        fontSize: w * 0.04,
                        color: !isDelivered && !isCurrent
                            ? Colors.grey
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: h * 0.015),

                /// TRAY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: w * 0.045,
                          color: (isDelivered || isCurrent)
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        SizedBox(width: w * 0.015),
                        Text("Tray", style: TextStyle(fontSize: w * 0.04)),
                      ],
                    ),
                    Text("$totalTray",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: w * 0.04)),
                  ],
                ),

                /// PACKET
                if (!isCollection) ...[
                  SizedBox(height: h * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_drink,
                            size: w * 0.045,
                            color: (isDelivered || isCurrent)
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          SizedBox(width: w * 0.015),
                          Text("Packet", style: TextStyle(fontSize: w * 0.04)),
                        ],
                      ),
                      Text("$totalPacket",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: w * 0.04)),
                    ],
                  ),
                ],

                SizedBox(height: h * 0.01),

                /// TUB (HIDDEN IN COLLECTION MODE)
                if (!isCollection) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_mall,
                            size: w * 0.045,
                            color: (isDelivered || isCurrent)
                                ? Colors.green
                                : Colors.grey,
                          ),
                          SizedBox(width: w * 0.015),
                          Text("Tub", style: TextStyle(fontSize: w * 0.04)),
                        ],
                      ),
                      Text("$totalTub",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: w * 0.04)),
                    ],
                  ),
                ],

                /// REMAINING
                if (store.remainingTrays > 0) ...[
                  SizedBox(height: h * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: w * 0.045,
                            color: Colors.orange,
                          ),
                          SizedBox(width: w * 0.015),
                          Text("Previous Remaining",
                              style: TextStyle(
                                  fontSize: w * 0.035, color: Colors.orange.shade800)),
                        ],
                      ),
                      Text("${store.remainingTrays}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: w * 0.04,
                              color: Colors.orange.shade800)),
                    ],
                  ),
                ],
              ],
            ),

            SizedBox(height: h * 0.02),

            /// STATUS + DIRECTIONS
            Row(
              children: [
                Container(
                  height: h * 0.035,
                  padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    getStatusText(),
                    style: TextStyle(
                      color: getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.035,
                    ),
                  ),
                ),
                const Spacer(),

                GestureDetector(
                  onTap: (isCurrent || isDelivered)
                      ? () => controller.openMap(store.address)
                      : null,
                  child: Container(
                    height: h * 0.04,
                    padding: EdgeInsets.symmetric(horizontal: w * 0.035),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (isCurrent || isDelivered)
                          ? getStatusColor().withOpacity(0.2)
                          : Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions,
                          size: w * 0.04,
                          color: (isCurrent || isDelivered)
                              ? getStatusColor()
                              : Colors.grey,
                        ),
                        SizedBox(width: w * 0.015),
                        Text(
                          "Directions",
                          style: TextStyle(
                            fontSize: w * 0.03,
                            fontWeight: FontWeight.bold,
                            color: (isCurrent || isDelivered)
                                ? getStatusColor()
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
