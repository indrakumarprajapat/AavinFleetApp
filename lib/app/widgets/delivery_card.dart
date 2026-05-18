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

  static const _teal1 = Color(0xFF005F80);
  static const _teal2 = Color(0xFF007EA7);
  static const _teal3 = Color(0xFF009CBF);
  static const _teal4 = Color(0xFF1BA6C8);
  static const _teal5 = Color(0xFF00ADD3);

  static final Map<DeliveryStatus, Color> statusColors = {
    DeliveryStatus.delivered: Colors.green,
    DeliveryStatus.delivering: _teal2,
    DeliveryStatus.toBeDelivered: Colors.grey,
    DeliveryStatus.collected: Colors.green,
    DeliveryStatus.collecting: _teal2,
    DeliveryStatus.toBeCollected: Colors.grey,
  };

  Color getStatusColor() => statusColors[status] ?? Colors.blueGrey;

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
          DeliveryStatus.delivering: "IN PROGRESS",
          DeliveryStatus.toBeDelivered: "PENDING",
        }[status] ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryController>();
    final w = MediaQuery.of(context).size.width;
    final bool isPending = !isDelivered && !isCurrent;

    return GestureDetector(
      onTap: () => controller.openStoreDetails(store),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
              ? _teal2.withValues(alpha: 0.3)
              : isDelivered 
                ? Colors.green.withValues(alpha: 0.3) 
                : Colors.grey.shade200,
            width: (isCurrent || isDelivered) ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.grey.shade100 : getStatusColor().withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      store.number,
                      maxLines: 1,
                      style: TextStyle(
                        color: isPending ? Colors.grey.shade400 : getStatusColor(),
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.storeName,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20, // Slightly reduced from 28 to prevent wrapping
                          color: isPending ? Colors.grey.shade400 : getStatusColor(),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPending ? Colors.grey.shade400 : Colors.blueGrey.shade400,
                          fontSize: 12, // Reduced from 20 to show more address info
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDelivered)
                  const Icon(Icons.check_circle, color: Colors.green, size: 22)
                else if (isCurrent)
                  const Icon(Icons.check_circle, color: _teal2, size: 22)
                else
                  Icon(Icons.check_circle, color: Colors.grey.shade300, size: 22),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30, // Fixed height for consistency
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.grey.shade50 : getStatusColor().withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isPending ? Colors.grey.shade200 : getStatusColor().withValues(alpha: 0.1)),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          getStatusText(),
                          style: TextStyle(
                            color: isPending ? Colors.grey.shade400 : getStatusColor(),
                            fontWeight: FontWeight.w900,
                            fontSize: 14, // Slightly reduced for "TO BE COLLECTED" cases
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 30, // Match status button height
                  child: TextButton.icon(
                    onPressed: () => controller.openMap(store.address),
                    icon: Icon(Icons.directions_rounded, size: 12, color: isPending ? Colors.grey.shade400 : _teal2),
                    label: Text("MAP", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isPending ? Colors.grey.shade400 : _teal2)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      backgroundColor: (isPending ? Colors.grey : _teal2).withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueIndicator(DeliveryModel store) {
    int totalIssues = 0;
    for (var p in store.products) {
      totalIssues += (p.leak + p.pktMinus + p.pktPlus);
    }

    if (totalIssues == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Icon(Icons.report_problem_rounded, size: 14, color: Colors.orange.shade700),
    );
  }
}
