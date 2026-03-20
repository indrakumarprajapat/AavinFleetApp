import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/claim_details_model.dart';
import '../../../../models/claim_model.dart';
import '../../../../models/delivered_order_model.dart';
import '../../../../models/order_model.dart';
import '../../../../api/api_service.dart';

class ClaimsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final allClaims = <ClaimModel>[].obs;
  final filteredClaims = <ClaimModel>[].obs;
  final deliveredOrders = <DeliveredOrderModel>[].obs;
  final orderItems = <OrderItemModel>[].obs;
  final isLoading = false.obs;
  final selectedStatus = 0.obs; // 0: all, 1: pending, 2: approved, 3: rejected
  final selectedFilterStatus = Rxn<int>();
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final selectedLimit = Rxn<int>();
  final selectedClaim = Rxn<ClaimDetailsModel>();

  List<ClaimModel> get claims => filteredClaims;

  @override
  void onInit() {
    super.onInit();
    // loadClaims();
    // loadDeliveredOrders();
  }

  Future<void> loadClaims() async {
    try {
      isLoading.value = true;
      final result = await _apiService.getClaims(
        status: selectedFilterStatus.value,
        fromDate: fromDate.value?.toIso8601String().split('T')[0],
        toDate: toDate.value?.toIso8601String().split('T')[0],
        limit: selectedLimit.value,
      );
      allClaims.value = result;
      _applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load claims: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    if (selectedStatus.value == 0) {
      filteredClaims.value = List.from(allClaims);
    } else {
      filteredClaims.value = allClaims.where((claim) => claim.status == selectedStatus.value).toList();
    }
  }

  Future<void> loadClaimDetails(int claimId) async {
    try {
      isLoading.value = true;
      selectedClaim.value = await _apiService.getClaimDetails(claimId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load claim details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDeliveredOrders() async {
    try {
      final response = await _apiService.getDeliveredOrders();
      deliveredOrders.value = response.map<DeliveredOrderModel>((json) => DeliveredOrderModel.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load delivered orders: $e');
    }
  }

  Future<void> loadOrderItems(int orderId) async {
    try {
      final orderDetails = await _apiService.getOrderDetails(orderId);
      orderItems.value = orderDetails.items ?? [];
    } catch (e) {
      print('Failed to load order items: $e');
      orderItems.clear();
    }
  }

  Future<void> createClaim({
    required int orderId,
    required String reason,
    String? description,
    List<File>? images,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await _apiService.createClaim(
        orderId: orderId,
        reason: reason,
        description: description,
        images: images,
        items: items,
      );
      
      if (response.isNotEmpty && response['claimId'] != null) {
        Get.snackbar('Success', response['message'] ?? 'Claim submitted successfully');
        // Get.offAllNamed('/', arguments: {'tab': 1});
        Get.back(result: {
          "claimId": 123,
          "status": "success",
        });
        loadClaims();
      }
    } catch (e) {
      // Get.snackbar('Error', 'Failed to create claim: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateClaim({
    required int claimId,
    List<File>? images,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await _apiService.updateClaim(
        claimId: claimId,
        images: images,
        description: description,
      );
      
      print('Controller updateClaim response: $response');
      
      if (response['claimId'] != null || response['message'] != null) {
        Get.snackbar('Success', 'Images uploaded successfully');
        await loadClaimDetails(claimId);
        print('Controller returning true');
        return true;
      }
      print('Controller returning false - no claimId or message');
      return false;
    } catch (e) {
      print('Controller updateClaim error: $e');
      Get.snackbar('Error', 'Failed to upload images: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(int status) {
    selectedStatus.value = status;
    _applyFilter();
  }

  String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Approved';
      case 3:
        return 'Rejected';
      case 4:
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Get.theme.colorScheme.secondary;
      case 2:
        return Get.theme.colorScheme.primary;
      case 3:
        return Get.theme.colorScheme.error;
      case 4:
        return Get.theme.colorScheme.brightness == Brightness.dark ? Color(0xFF00ADD9) : Color(0xFF00ADD9);
      default:
        return Get.theme.colorScheme.outline;
    }
  }

  void showFilterDialog() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
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
                    'Filter Claims',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      selectedFilterStatus.value = null;
                      fromDate.value = null;
                      toDate.value = null;
                      selectedLimit.value = null;
                      loadClaims();
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
                    // _buildFilterSection('Status', [
                    //   _buildFilterChip('Pending', 1, selectedFilterStatus),
                    //   _buildFilterChip('Approved', 2, selectedFilterStatus),
                    //   _buildFilterChip('Rejected', 3, selectedFilterStatus),
                    // ]),
                    // SizedBox(height: 20),
                    _buildDateSection(),
                    SizedBox(height: 20),
                    _buildLimitSection(),
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
                        loadClaims();
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

  Widget _buildFilterChip(String label, int? value, Rxn<int> selectedValue) {
    return Obx(() => FilterChip(
      label: Text(label),
      backgroundColor: Colors.white,
      selected: selectedValue.value == value,
      onSelected: (selected) {
        selectedValue.value = selected ? value : null;
      },
      selectedColor: Color(0xFF00ADD9).withValues(alpha: 0.2),
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
                  fromDate.value?.toIso8601String().split('T')[0] ?? 'From Date',
                  style: TextStyle(
                    color: fromDate.value == null ? Colors.grey : Colors.black87,
                  ),
                ),
              )),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Obx(() => OutlinedButton(
                onPressed: () => _selectDate(false),
                child: Text(
                  toDate.value?.toIso8601String().split('T')[0] ?? 'To Date',
                  style: TextStyle(
                    color: toDate.value == null ? Colors.grey : Colors.black87,
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
      if (isFromDate) {
        fromDate.value = picked;
      } else {
        toDate.value = picked;
      }
    }
  }

  Widget _buildLimitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Limit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('10', 10, selectedLimit),
            _buildFilterChip('25', 25, selectedLimit),
            _buildFilterChip('50', 50, selectedLimit),
            _buildFilterChip('100', 100, selectedLimit),
          ],
        ),
      ],
    );
  }
}