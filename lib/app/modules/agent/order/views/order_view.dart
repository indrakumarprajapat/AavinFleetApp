import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../widgets/global_bottom_nav.dart';
import '../controllers/order_controller.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 2),
                  Expanded(child: _buildOrderList()),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlobalBottomNav(currentIndex: 0),
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
                        'My Orders',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed('/cart'),
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order History',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: _showFilterDialog,
          child: Text(
            'Filter',
            style: TextStyle(
              color: Color(0xFF00ADD9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No orders found', style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: controller.fetchOrders,
        child: ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildOrderCard(order);
          },
        ),
      );
    });
  }

  Widget _buildOrderCard(order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status ?? 0).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.getStatusText(order.status ?? 0),
                  style: TextStyle(
                    color: _getStatusColor(order.status ?? 0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(order.createdAt ?? ''),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: ${controller.getOrderTypeText(order.orderType ?? 0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shift: ${controller.getShiftText(order.shift ?? 0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00ADD9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => Get.toNamed('/order-details', arguments: order.id),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: Color(0xFF00ADD9),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Filter Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      controller.clearFilters();
                    },
                    child: Text('Clear All', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection('Order Type', [
                      _buildFilterChip('Milk & Curd', 1, controller.selectedOrderType),
                      _buildFilterChip('Buy Products', 2, controller.selectedOrderType),
                    ]),
                    SizedBox(height: 20),
                    _buildFilterSection('Shift', [
                      _buildFilterChip('Morning', 1, controller.selectedShift),
                      _buildFilterChip('Evening', 2, controller.selectedShift),
                    ]),
                    SizedBox(height: 20),
                    _buildFilterSection('Status', [
                      _buildFilterChip('New', 1, controller.selectedStatus),
                      _buildFilterChip('Paid', 2, controller.selectedStatus),
                      _buildFilterChip('Cancelled', 3, controller.selectedStatus),
                      // _buildFilterChip('Delivered', 4, controller.selectedStatus),
                    ]),
                    SizedBox(height: 20),
                    _buildDateSection(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.fetchOrders();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00ADD9),
                      ),
                      child: Text('Apply Filters', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int value, RxInt selectedValue) {
    return Obx(() => FilterChip(
      label: Text(label),
      selected: selectedValue.value == value,
      onSelected: (selected) {
        selectedValue.value = selected ? value : 0;
      },
      selectedColor: Color(0xFF00ADD9).withValues(alpha:0.2),
      checkmarkColor: Color(0xFF00ADD9),
    ));
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => OutlinedButton(
                onPressed: () => _selectDate(true),
                child: Text(
                  controller.fromDate.value.isEmpty 
                    ? 'From Date' 
                    : controller.fromDate.value,
                  style: TextStyle(
                    color: controller.fromDate.value.isEmpty 
                      ? Colors.grey 
                      : Colors.black87,
                  ),
                ),
              )),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Obx(() => OutlinedButton(
                onPressed: () => _selectDate(false),
                child: Text(
                  controller.toDate.value.isEmpty 
                    ? 'To Date' 
                    : controller.toDate.value,
                  style: TextStyle(
                    color: controller.toDate.value.isEmpty 
                      ? Colors.grey 
                      : Colors.black87,
                  ),
                ),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      if (isFromDate) {
        controller.fromDate.value = formattedDate;
      } else {
        controller.toDate.value = formattedDate;
      }
    }
  }


}