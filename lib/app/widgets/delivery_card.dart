import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/delivery_model.dart';
import '../modules/delivery/controllers/delivery_controller.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryModel store;
  final DeliveryStatus? status;
  final bool isCollection;
  final VoidCallback? onTap;

  const DeliveryCard({
    super.key,
    required this.store,
    this.status,
    this.onTap,
    this.isCollection = false,
  });

  DeliveryStatus get _effectiveStatus => status ?? store.status;

  bool get isDelivered =>
      _effectiveStatus == DeliveryStatus.delivered ||
      _effectiveStatus == DeliveryStatus.collected;
  bool get isCurrent =>
      _effectiveStatus == DeliveryStatus.delivering ||
      _effectiveStatus == DeliveryStatus.collecting;

  static final Map<DeliveryStatus, Color> statusColors = {
    DeliveryStatus.delivered: const Color(0xFF2E7D32),
    DeliveryStatus.delivering: const Color(0xFF00ADD3),
    DeliveryStatus.toBeDelivered: Colors.grey,
    DeliveryStatus.collected: const Color(0xFF2E7D32),
    DeliveryStatus.collecting: const Color(0xFF00ADD3),
    DeliveryStatus.toBeCollected: Colors.grey,
  };

  Color getStatusColor() => statusColors[_effectiveStatus] ?? Colors.grey;

  String getStatusText() {
    if (isCollection) {
      return {
            DeliveryStatus.delivered: "COLLECTED",
            DeliveryStatus.collected: "COLLECTED",
            DeliveryStatus.delivering: "COLLECTING",
            DeliveryStatus.collecting: "COLLECTING",
            DeliveryStatus.toBeCollected: "TO BE COLLECTED",
          }[_effectiveStatus] ??
          "Unknown";
    }
    return {
          DeliveryStatus.delivered: "DELIVERED",
          DeliveryStatus.delivering: "IN_PROGRESS",
          DeliveryStatus.toBeDelivered: "PENDING",
        }[_effectiveStatus] ??
        "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap ?? () => controller.openStoreDetails(store),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFFBBDEFB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrent ? Border.all(color: const Color(0xFF00ADD3), width: 1.5) : null,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: getStatusColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        store.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        store.storeName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.045,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: w * 0.035,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: isDelivered ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.15), 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: getStatusColor().withOpacity(0.3))
                  ),
                  child: Text(
                    getStatusText(), 
                    style: TextStyle(
                      color: getStatusColor().withValues(alpha: 0.9), 
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    )
                  ),
                ),
                TextButton.icon(
                  onPressed: () => controller.openMap(store.address),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text("Directions"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF007EA7),
                    backgroundColor: const Color(0xFF90CAF9),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
