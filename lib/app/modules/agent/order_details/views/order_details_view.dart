import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../models/order_model.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final order = controller.orderDetails.value;
              if (order == null) return const Center(child: Text('No data found'));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOrderSummary(order),
                    const SizedBox(height: 16),
                    _buildAgentInfo(order),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: MediaQuery.of(Get.context!).size.height * 0.25,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/Vector.svg',
              fit: BoxFit.fill,
              width: double.infinity,
              colorFilter: ColorFilter.mode(
                Color(0xFF00ADD9),
                BlendMode.srcIn,
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Order Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  if (order.invoiceUrl != null && order.invoiceUrl!.isNotEmpty)
                    Tooltip(
                      message: 'Invoice',
                      child: IconButton(
                        onPressed: () => _openInvoice(order.invoiceUrl!),
                        icon: Icon(
                          Icons.print,
                          color: Color(0xFF00ADD9),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status ?? 0).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(order.status ?? 0),
                      style: TextStyle(
                        color: _getStatusColor(order.status ?? 0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Type', order.orderType == 1 ? 'Milk & Curd' : 'Buy Products'),
              ),
              Expanded(
                child: _buildInfoItem('Shift', order.shift == 1 ? 'Morning' : order.shift == 2 ? 'Evening' : 'Any Time'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Date', _formatDate(order.createdAt ?? '')),
              ),
              Expanded(
                child: _buildInfoItem('Total Tax', '₹${(order.cGst??0) + (order.sGst??0)}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '₹${(order.totalAmount ?? 0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00ADD9),
                  ),
                ),
              ],
            ),
          ),
          if (order.canCancel == true)
            Container(
              margin: EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => _showCancelConfirmation(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Cancel Order',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgentInfo(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agent Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFF00ADD9).withValues(alpha:0.1),
                child: Icon(Icons.person, color: Color(0xFF00ADD9)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.agentName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      order.agentMobile ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFF00ADD9).withValues(alpha:0.1),
                child: Icon(Icons.store, color: Color(0xFF00ADD9)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.boothName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Code: ${order.boothCode ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (order.boothAddress != null)
                      Text(
                        order.boothAddress!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${controller.orderItems.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.orderItems.map((item) => _buildItemCard(item)),
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Container(
          //   width: 50,
          //   height: 50,
          //   decoration: BoxDecoration(
          //     color: Color(0xFF00ADD9).withValues(alpha:0.1),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Icon(
          //     Icons.inventory_2_outlined,
          //     color: Color(0xFF00ADD9),
          //   ),
          // ),
          // const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (item.trayCount != null && item.trayCount! > 0)
                  Text(
                    '${item.itemUnitType == 1 ? '1 tray = ${item.trayCount} items\n' : ''}Total: ${item.itemUnitType == 1 ? (item.trayCount ?? 0) * (item.quantity ?? 0): item.quantity} Pkt',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                // Text(
                //   'Code: ${item.productCode ?? 'N/A'}',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey[600],
                //   ),
                // ),
                // Text(
                //   'Measure: ${item.measure ?? 'N/A'}',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey[600],
                //   ),
                // ),
                // Text(
                //   'Unit Price: ₹${(item.price ?? 0).toStringAsFixed(2)}',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey[600],
                //   ),
                // ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.itemUnitType == 1?'Tray':'Pkt'}: ${item.quantity ?? 0}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₹${(item.totalPrice ?? 0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00ADD9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1: return 'New';
      case 2: return 'Paid';
      case 3: return 'Cancelled';
      case 4: return 'Delivered';
      default: return 'Unknown';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _calculateTotalTax() {
    double totalTax = 0.0;
    for (var item in controller.orderItems) {
      if (item.trayCount != null && item.trayCount! > 0 && item.price != null && item.quantity != null && item.gst != null) {
        double itemTotal = (item.quantity! * item.trayCount! * item.price!);
        var taxableAmount = ((itemTotal * 100) / (100.0 + (item.gst ?? 0)));
        var tax = itemTotal - taxableAmount;
        totalTax += tax;
      }
    }
    return totalTax.toStringAsFixed(2);
  }

  void _showCancelConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Order'),
        content: Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _openInvoice(String url) async {
    Get.to(() => InvoiceViewerPage(url: url));
  }
}

class InvoiceViewerPage extends StatefulWidget {
  final String url;
  
  const InvoiceViewerPage({Key? key, required this.url}) : super(key: key);
  
  @override
  State<InvoiceViewerPage> createState() => _InvoiceViewerPageState();
}

class _InvoiceViewerPageState extends State<InvoiceViewerPage> {
  late final WebViewController controller;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.url)}'));
  }
  
  void _downloadInvoice() async {
    try {
      final uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not download invoice');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice'),
        backgroundColor: Color(0xFF00ADD9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _downloadInvoice,
            icon: Icon(Icons.download),
            tooltip: 'Download',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00ADD9),
              ),
            ),
        ],
      ),
    );
  }
}