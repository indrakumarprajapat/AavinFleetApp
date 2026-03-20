import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/delivery/controllers/delivery_controller.dart';
import '../models/delivery_model.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryModel store;

  final int tray;
  final int packet;
  final int tub;

  final DeliveryStatus status;

  final int? remainingTray;
  final int? remainingTub;
  final bool isCollection;

  const DeliveryCard({
    super.key,
    required this.store,
    required this.status,
    required this.tray,
    required this.packet,
    required this.tub,
    this.remainingTray,
    this.remainingTub,
    this.isCollection = false,
  });

  bool get isDelivered => status == DeliveryStatus.delivered;
  bool get isCurrent => status == DeliveryStatus.delivering;

  Color getStatusColor() {
    switch (status) {
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.delivering:
        return Colors.blue;
      case DeliveryStatus.pending:
        return Colors.grey;
    }
  }

  String getStatusText() {
    if (isCollection) {
      switch (status) {
        case DeliveryStatus.delivered:
          return "Collected";
        case DeliveryStatus.delivering:
          return "Collecting";
        case DeliveryStatus.pending:
          return "To Be Collected";
      }
    }

    switch (status) {
      case DeliveryStatus.delivered:
        return "Delivered";
      case DeliveryStatus.delivering:
        return "To Deliver";
      case DeliveryStatus.pending:
        return "Pending";
    }
  }

  Color getCardColor() {
    if (status == DeliveryStatus.delivering) return Colors.blue.shade50;
    if (status == DeliveryStatus.pending) return Colors.grey.shade200;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();

    return GestureDetector(
      onTap: () {
        controller.openStoreDetails(store);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: getCardColor(),
          borderRadius: BorderRadius.circular(16),
          border: isCurrent ? Border.all(color: Colors.blue, width: 1.5) : null,
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TOP ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: getStatusColor(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    store.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

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
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Container(
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDelivered
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 18,
                              color: isDelivered ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.address,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 14),

            /// DATA SECTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITLE
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 18,
                      color: (isDelivered || isCurrent)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCollection ? "Collection" : "Delivery",
                      style: TextStyle(
                        color: !isDelivered && !isCurrent
                            ? Colors.grey
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// TRAY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 18,
                          color: (isDelivered || isCurrent)
                              ? Colors.amber
                              : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        const Text("Tray"),
                      ],
                    ),
                    Text("$tray",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),

                /// PACKET
                if (!isCollection) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 18,
                            color: (isDelivered || isCurrent)
                                ? Colors.deepPurpleAccent
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          const Text("Packet"),
                        ],
                      ),
                      Text("$packet",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                /// TUB
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.grid_view,
                          size: 18,
                          color: (isDelivered || isCurrent)
                              ? Colors.lightGreen
                              : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        const Text("Tub"),
                      ],
                    ),
                    Text("$tub",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),

                /// REMAINING
                if (isCollection &&
                    remainingTray != null &&
                    remainingTub != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Remaining: $remainingTray trays, $remainingTub tubs",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 18),

            /// STATUS
            Row(
              children: [
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),


                /// ✅ GET DIRECTIONS BUTTON BACK
                GestureDetector(
                  onTap: isCurrent || isDelivered
                      ? controller.openMap
                      : null,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (isCurrent || isDelivered)
                          ? getStatusColor().withOpacity(0.2)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions,
                          size: 16,
                          color: (isCurrent || isDelivered)
                              ? getStatusColor()
                              : Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Directions",
                          style: TextStyle(
                            fontSize: 12,
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