import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/delivery_model.dart';
import '../modules/delivery/controllers/delivery_controller.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryModel store;
  final DeliveryStatus status;
  final bool isCollection;

  const DeliveryCard({
    super.key,
    required this.store,
    required this.status,
    this.isCollection = false,
  });

  bool get isDelivered => status == DeliveryStatus.delivered || status == DeliveryStatus.collected;
  bool get isCurrent => status == DeliveryStatus.delivering || status == DeliveryStatus.collecting;

  static final Map<DeliveryStatus, Color> statusColors = {
    DeliveryStatus.delivered: Colors.green,
    DeliveryStatus.delivering: Colors.blue,
    DeliveryStatus.toBeDelivered: Colors.grey,
    DeliveryStatus.collected: Colors.green,
    DeliveryStatus.collecting: Colors.blue,
    DeliveryStatus.toBeCollected: Colors.grey,
  };

  Color getStatusColor() => statusColors[status] ?? Colors.grey;

  String getStatusText() {
    if (isCollection) {
      return {
            DeliveryStatus.delivered: "COLLECTED",
            DeliveryStatus.collected: "COLLECTED",
            DeliveryStatus.delivering: "COLLECTING",
            DeliveryStatus.collecting: "COLLECTING",
            DeliveryStatus.toBeCollected: "TO BE COLLECTED",
          }[status] ?? "Unknown";
    }
    return {
          DeliveryStatus.delivered: "DELIVERED",
          DeliveryStatus.delivering: "IN_PROGRESS",
          DeliveryStatus.toBeDelivered: "PENDING",
        }[status] ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => controller.openStoreDetails(store),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: isCurrent ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrent ? Border.all(color: Colors.blue, width: 1.5) : null,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: h * 0.08, width: h * 0.08,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: getStatusColor(), borderRadius: BorderRadius.circular(10)),
                  child: Text(store.number, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: w * 0.06)),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.storeName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.05)),
                      Text(store.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: w * 0.035)),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: isDelivered ? Colors.green : Colors.grey.shade300),
              ],
            ),
            Divider(height: h * 0.03),
            // TRAY INFO (Directly from getTripBooths API)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.inventory, size: 18, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Trays", style: TextStyle(fontSize: 16)),
                ]),
                Text("${store.totalTrays}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            // PACKET INFO (Directly from getTripBooths API)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.local_drink, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Packets", style: TextStyle(fontSize: 16)),
                ]),
                Text("${store.totalPackets}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: h * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: getStatusColor().withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(getStatusText(), style: TextStyle(color: getStatusColor(), fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: () => controller.openMap(store.address),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text("Directions"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
