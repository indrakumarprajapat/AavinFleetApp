import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modules/agent/milk_orders/controllers/milk_orders_controller.dart';

class MilkContentWidget extends StatelessWidget {
  final double height;
  const MilkContentWidget({this.height = 16, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MilkOrdersController());
    return _buildContent(controller);
  }



  String _formatDate() {
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return 'Today, ${months[now.month - 1]} ${now.day}';
  }

  String _getProductInfo(List<dynamic> orderItems) {
    if (orderItems.isEmpty) return 'No items';
    final totalQty = orderItems.fold(0.0, (sum, item) => sum + double.parse(item['quantity'].toString()));
    return 'View Order Items (${totalQty.toInt()})';
  }



  Widget _buildOrderInfo(Map<String, dynamic> order) {
    final deliveryType = order['delivery_type'] == 1 ? 'Booth Pickup' : 'Door Delivery';
    final shift = order['shift'] == 1 ? 'Morning' : order['shift'] == 2 ? 'Evening' : 'Anytime';
    final status = order['status'] == 1 ? 'New' : order['status'] == 2 ? 'Paid' : order['status'] == 3 ? 'Cancelled' : 'Delivered';
    final mobile = order['mobile_number'] ?? '';
    final address = order['address'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                deliveryType,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                shift,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // SizedBox(width: 6),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //   decoration: BoxDecoration(
            //     color: Colors.green.withValues(alpha:0.1),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Text(
            //     status,
            //     style: TextStyle(
            //       fontSize: 10,
            //       color: Colors.green[700],
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                address,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildContent(MilkOrdersController controller) {
    return Obx(() => RefreshIndicator(
      onRefresh: controller.refreshOrders,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 12),
        child: controller.isLoading.value
            ? SizedBox(
                height: Get.height * 0.6,
                child: Center(child: CircularProgressIndicator()),
              )
            : controller.orders.isEmpty
                ? SizedBox(
                    height: Get.height * 0.6,
                    width: Get.height * 0.6,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/cardMilk.svg',
                            width: 80,
                            height: 85,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No orders available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          _formatDate(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: height),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.orders.length,
                        itemBuilder: (context, index) {
                          final order = controller.orders[index];
                          return _buildOrderCard(order, controller);
                        },
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
      ),
    ));
  }

  Widget _buildOrderCard(Map<String, dynamic> order, MilkOrdersController controller) {
    final orderId = order['id'];
    final customerName = order['full_name'] ?? 'Unknown';
    final productInfo = _getProductInfo(order['order_items'] ?? []);
    return Obx(() {
      final currentStatus = controller.orderStatus[orderId] ?? order['status'] ?? 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      customerName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: currentStatus == 3 || currentStatus == 4 ? null : () => controller.updateOrderStatus(orderId, 4),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: currentStatus == 4 ? Colors.green : (currentStatus == 3 ? Colors.grey[300] : Colors.green.withValues(alpha:0.1)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: currentStatus == 4 ? Colors.white : (currentStatus == 3 ? Colors.grey : Colors.green),
                          size: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: currentStatus == 3 || currentStatus == 4 ? null : () => controller.updateOrderStatus(orderId, 3),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: currentStatus == 3 ? Colors.red : (currentStatus == 4 ? Colors.grey[300] : Colors.red.withValues(alpha:0.1)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: currentStatus == 3 ? Colors.white : (currentStatus == 4 ? Colors.grey : Colors.red),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Text(
                //   customerId,
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Colors.grey[600],
                //   ),
                // ),
                // SizedBox(height: 8),
                _buildOrderInfo(order),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.toggleOrderExpansion(orderId),
                        child: Row(
                          children: [
                            Text(
                              productInfo,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              controller.expandedOrders[orderId] == true ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _makePhoneCall(order['mobile_number']),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Call Now',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _openGoogleMaps(order['lat'], order['lng']),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'View Loc.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (controller.expandedOrders[orderId] == true)
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.only(right: 16,left: 16,top:8,bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...order['order_items'].map<Widget>((item) => Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['product_name'] ?? 'Unknown Product',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Qty: ${item['quantity']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Column(
          //   children: [
          //     Row(
          //       children: [
          //         GestureDetector(
          //           onTap: currentStatus == 2 ? null : () => _updateOrderStatus(orderId, 1),
          //           child: Container(
          //             width: 40,
          //             height: 40,
          //             decoration: BoxDecoration(
          //               color: currentStatus == 1 ? Colors.green : (currentStatus == 2 ? Colors.grey[300] : Colors.green.withValues(alpha:0.1)),
          //               shape: BoxShape.circle,
          //             ),
          //             child: Icon(
          //               Icons.check,
          //               color: currentStatus == 1 ? Colors.white : (currentStatus == 2 ? Colors.grey : Colors.green),
          //               size: 24,
          //             ),
          //           ),
          //         ),
          //         SizedBox(width: 12),
          //         GestureDetector(
          //           onTap: currentStatus == 1 ? null : () => _updateOrderStatus(orderId, 2),
          //           child: Container(
          //             width: 40,
          //             height: 40,
          //             decoration: BoxDecoration(
          //               color: currentStatus == 2 ? Colors.red : (currentStatus == 1 ? Colors.grey[300] : Colors.red.withValues(alpha:0.1)),
          //               shape: BoxShape.circle,
          //             ),
          //             child: Icon(
          //               Icons.close,
          //               color: currentStatus == 2 ? Colors.white : (currentStatus == 1 ? Colors.grey : Colors.red),
          //               size: 24,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ],
      ),
    );
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _openGoogleMaps(double lat, double lng) async {
    final Uri mapsUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      } else {
        final Uri webMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
        await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open maps');
    }
  }
}