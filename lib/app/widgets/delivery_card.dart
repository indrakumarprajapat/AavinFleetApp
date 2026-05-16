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

  static const _bluePrimary = Color(0xFF0052CC);
  static const _blueDark = Color(0xFF0F172A);

  static final Map<DeliveryStatus, Color> statusColors = {
    DeliveryStatus.delivered: Colors.green.shade600,
    DeliveryStatus.delivering: _bluePrimary,
    DeliveryStatus.toBeDelivered: Colors.blueGrey.shade200,
    DeliveryStatus.collected: Colors.green.shade600,
    DeliveryStatus.collecting: _bluePrimary,
    DeliveryStatus.toBeCollected: Colors.blueGrey.shade200,
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

    return GestureDetector(
      onTap: () => controller.openStoreDetails(store),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCurrent 
              ? _bluePrimary.withValues(alpha: 0.5) 
              : Colors.grey.shade100,
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrent 
                ? _bluePrimary.withValues(alpha: 0.1) 
                : _blueDark.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Store index/number circle
                Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: getStatusColor().withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    store.number,
                    style: TextStyle(
                      color: getStatusColor(),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.storeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _blueDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: Colors.blueGrey.shade300),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.blueGrey.shade400,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDelivered)
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 26)
                else if (isCurrent)
                  const Icon(Icons.radio_button_checked_rounded, color: _bluePrimary, size: 26)
                else
                  Icon(Icons.radio_button_unchecked_rounded, color: Colors.blueGrey.shade100, size: 26),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoBadge(
                  Icons.grid_view_rounded,
                  "${store.totalTrays} Trays",
                  _bluePrimary,
                ),
                const SizedBox(width: 10),
                _buildInfoBadge(
                  Icons.inventory_2_rounded,
                  "${store.totalPackets} Pkts",
                  Colors.indigo,
                ),
                const Spacer(),
                if (!isCollection) ...[
                  _buildIssueIndicator(store),
                  const SizedBox(width: 8),
                ],
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.openMap(store.address),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _bluePrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.directions_rounded, size: 16, color: _bluePrimary),
                          SizedBox(width: 4),
                          Text(
                            "MAP",
                            style: TextStyle(
                              color: _bluePrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: getStatusColor().withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getStatusColor().withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text(
                  getStatusText(),
                  style: TextStyle(
                    color: getStatusColor(),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
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
