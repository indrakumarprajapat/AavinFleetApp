import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../constants/app_enums.dart';
import '../../../../models/delivered_order_model.dart';
import '../../../../models/order_model.dart';
import '../../../../utils/date-util.dart';
import '../controllers/claims_controller.dart';

class CreateClaimView extends GetView<ClaimsController> {
  const CreateClaimView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final claimsController = Get.find<ClaimsController>();
    claimsController.loadDeliveredOrders();
    
    final reasonController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedOrder = Rxn<DeliveredOrderModel>();
    final selectedItems = <Map<String, dynamic>>[].obs;
    final selectedImages = <File>[].obs;
    final isFormValid = false.obs;

    void removeDuplicates(RxList<Map<String, dynamic>> items) {
      final seen = <int>{};
      items.removeWhere((item) {
        final productId = item['productId'] as int;
        if (seen.contains(productId)) {
          return true;
        }
        seen.add(productId);
        return false;
      });
    }

    void validateForm() {
      removeDuplicates(selectedItems);
      isFormValid.value = selectedOrder.value != null &&
          reasonController.text.isNotEmpty &&
          selectedItems.isNotEmpty &&
          selectedImages.length >= 2;
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Create Claim', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF00ADD9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSelection(selectedOrder, validateForm),
                  SizedBox(height: 20),
                  _buildReasonField(reasonController, selectedOrder, validateForm),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildItemsSection(selectedOrder, selectedItems, validateForm),
            SizedBox(height: 16),
            _buildPhotoSection(selectedImages, selectedOrder, validateForm),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.all(20),
              child: _buildSubmitButton(
                reasonController,
                descriptionController,
                selectedOrder,
                selectedItems,
                selectedImages,
                isFormValid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSelection(Rxn<DeliveredOrderModel> selectedOrder, VoidCallback validateForm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long, color: Color(0xFF00ADD9), size: 20),
            SizedBox(width: 8),
            Text(
              'Select Delivered Order *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
          ],
        ),
        SizedBox(height: 12),
        Obx(() {
          if (controller.deliveredOrders.isEmpty) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'No delivered orders found',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: DropdownButtonFormField<DeliveredOrderModel>(
              initialValue: selectedOrder.value,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Choose a delivered order',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF00ADD9)),
              items: controller.deliveredOrders.map((order) {
                return DropdownMenuItem<DeliveredOrderModel>(
                  value: order,
                  child: Text(
                    '${DateUtil.formatDateDDEEYY(order.orderDate)} ( ${order.shift == OrderShift.morning ? 'Morning': 'Evening' } )  - ₹${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (DeliveredOrderModel? value) {
                selectedOrder.value = value;
                if (value != null) {
                  controller.loadOrderItems(value.id);
                }
                validateForm();
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReasonField(TextEditingController reasonController, Rxn<DeliveredOrderModel> selectedOrder, VoidCallback validateForm) {
    final reasons = ['Missing', 'Damaged',  'Wrong Item'];
    final selectedReason = Rxn<String>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.report_problem, color: Color(0xFF00ADD9), size: 20),
            SizedBox(width: 8),
            Text(
              'Reason for Claim *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
          ],
        ),
        SizedBox(height: 12),
        Obx(() => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: selectedOrder.value != null ? Colors.grey[50] : Colors.grey[100],
          ),
          child: DropdownButtonFormField<String>(
            value: selectedReason.value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: selectedOrder.value != null ? 'Select claim reason' : 'Select an order first',
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF00ADD9)),
            items: reasons.map((reason) {
              return DropdownMenuItem<String>(
                value: reason,
                child: Text(reason, style: TextStyle(fontWeight: FontWeight.w500)),
              );
            }).toList(),
            onChanged: selectedOrder.value != null ? (String? value) {
              selectedReason.value = value;
              reasonController.text = value ?? '';
              validateForm();
            } : null,
          ),
        )),
      ],
    );
  }



  Widget _buildItemsSection(Rxn<DeliveredOrderModel> selectedOrder, RxList<Map<String, dynamic>> selectedItems, VoidCallback validateForm) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, color: Color(0xFF00ADD9), size: 20),
              SizedBox(width: 8),
              Text(
                'Damaged Items *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (selectedOrder.value == null) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[500], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Please select an order first',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Obx(() {
                  if (controller.orderItems.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'No items found for this order',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select damaged items from order:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 12),
                      ...controller.orderItems.map((item) => _buildOrderItemCard(item, selectedItems, validateForm, selectedOrder.value)),
                    ],
                  );
                }),
                if (selectedItems.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Divider(color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    'Selected Damaged Items (${selectedItems.length}):',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red[700]),
                  ),
                  SizedBox(height: 12),
                  ...selectedItems.map((item) => _buildSelectedItemCard(item, selectedItems, validateForm)),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItemModel item, RxList<Map<String, dynamic>> selectedItems, VoidCallback validateForm, DeliveredOrderModel? selectedOrder) {
    final isClaimAlreadyExists = item.isClaim == true;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isClaimAlreadyExists ? Colors.grey[200] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isClaimAlreadyExists ? Colors.grey[400]! : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          item.productName ?? 'Product #${item.productId}',
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 14,
            color: isClaimAlreadyExists ? Colors.grey[600] : Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.itemUnitType == 1 ? 'Tray': 'Pkt'}: ${item.quantity} | Qty: ${(item.itemUnitType ?? 1) == 1 ? (item.trayCount??0)*(item.quantity??0) : item.quantity} | Price: ₹${item.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  color: isClaimAlreadyExists ? Colors.grey[500] : Colors.grey[600], 
                  fontSize: 12,
                ),
              ),
              // if (isClaimAlreadyExists) ...[
              //   SizedBox(height: 4),
              //   Text(
              //     'Claim already exists for this item',
              //     style: TextStyle(
              //       color: Colors.red[600],
              //       fontSize: 11,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ],
            ],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: isClaimAlreadyExists ? null : () => _showDamageQuantityDialog(item, selectedItems, validateForm, selectedOrder),
          style: ElevatedButton.styleFrom(
            backgroundColor: isClaimAlreadyExists ? Colors.grey[400] : 
                           _isItemSelected(item.productId, selectedItems) ? Colors.orange[600] : Color(0xFF00ADD9),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            isClaimAlreadyExists ? 'Claimed' : 
            _isItemSelected(item.productId, selectedItems) ? 'Update' : 'Add', 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedItemCard(Map<String, dynamic> item, RxList<Map<String, dynamic>> selectedItems, VoidCallback validateForm) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          item['productName'] ?? 'Product #${item['productId']}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Damaged: ${item['damagedQuantity']} / ${item['originalQuantity']}',
                style: TextStyle(color: Colors.red[700], fontSize: 12, fontWeight: FontWeight.w500),
              ),
              if (item['notes'] != null && item['notes'].toString().isNotEmpty)
                Text(
                  'Notes: ${item['notes']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[600]),
          onPressed: () {
            selectedItems.remove(item);
            validateForm();
          },
        ),
      ),
    );
  }
  
  bool _isItemSelected(int? productId, RxList<Map<String, dynamic>> selectedItems) {
    return selectedItems.any((item) => item['productId'] == productId);
  }

  void _removeDuplicates(RxList<Map<String, dynamic>> selectedItems) {
    final seen = <int>{};
    selectedItems.removeWhere((item) {
      final productId = item['productId'] as int;
      if (seen.contains(productId)) {
        return true;
      }
      seen.add(productId);
      return false;
    });
  }

  void _showQuantityInputDialog(RxInt currentQty, int maxQty, TextEditingController controller) {
    final inputController = TextEditingController(text: currentQty.value.toString());
    Get.dialog(
      AlertDialog(
        title: Text('Enter Quantity'),
        content: TextFormField(
          controller: inputController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            _MaxValueInputFormatter(maxQty.toDouble()),
          ],
          decoration: InputDecoration(
            labelText: 'Quantity (0-$maxQty)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(inputController.text) ?? 0;
              if (value >= 0 && value <= maxQty) {
                currentQty.value = value;
                controller.text = value.toString();
                Get.back();
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(RxList<File> selectedImages, Rxn<DeliveredOrderModel> selectedOrder, VoidCallback validateForm) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: Color(0xFF00ADD9), size: 20),
              SizedBox(width: 8),
              Text(
                'Photos *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Upload photos of damaged items (Min: 2, Max: 15)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          Obx(() {
            final canAddMore = selectedImages.length < 15;
            final isOrderSelected = selectedOrder.value != null;
            final isEnabled = isOrderSelected && canAddMore;
            
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isEnabled ? () => _pickImage(selectedImages, ImageSource.camera, validateForm) : null,
                    icon: Icon(Icons.camera_alt, size: 18),
                    label: Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnabled ? Color(0xFF00ADD9) : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                // SizedBox(width: 12),
                // Expanded(
                //   child: ElevatedButton.icon(
                //     onPressed: isEnabled ? () => _pickMultipleImages(selectedImages, validateForm) : null,
                //     icon: Icon(Icons.photo_library, size: 18),
                //     label: Text('Gallery'),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: isEnabled ? Colors.grey[600] : Colors.grey[400],
                //       foregroundColor: Colors.white,
                //       padding: EdgeInsets.symmetric(vertical: 12),
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                //     ),
                //   ),
                // ),
              ],
            );
          }),
          SizedBox(height: 16),
          Obx(() {
            if (selectedImages.isEmpty) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_photo_alternate, color: Colors.grey[500], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'No photos added yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Photos (${selectedImages.length}/15):',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: selectedImages.length >= 2 ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedImages.length >= 2 ? 'Valid' : 'Need ${2 - selectedImages.length} more',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selectedImages.length >= 2 ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                selectedImages[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  selectedImages.removeAt(index);
                                  validateForm();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha:0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    TextEditingController reasonController,
    TextEditingController descriptionController,
    Rxn<DeliveredOrderModel> selectedOrder,
    RxList<Map<String, dynamic>> selectedItems,
    RxList<File> selectedImages,
    RxBool isFormValid,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        final isEnabled = isFormValid.value && !controller.isLoading.value;
        return ElevatedButton(
          onPressed: isEnabled
              ? () => {_submitClaim(
                    reasonController,
                    descriptionController,
                    selectedOrder,
                    selectedItems,
                    selectedImages,
                  ),
              Get.back()}
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? Color(0xFF00ADD9) : Colors.grey[400],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isEnabled ? 2 : 0,
          ),
          child: controller.isLoading.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Submitting...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              : Text(
                  'Submit Claim',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        );
      }),
    );
  }

  void _showDamageQuantityDialog(OrderItemModel item, RxList<Map<String, dynamic>> selectedItems, VoidCallback validateForm, DeliveredOrderModel? selectedOrder) {
    final damagedQtyController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final existingItemIndex = selectedItems.indexWhere((selectedItem) => selectedItem['productId'] == item.productId);
    final existingDamagedQty = existingItemIndex != -1 ? selectedItems[existingItemIndex]['damagedQuantity'] as int : 0;
    final maxQty = item.itemUnitType == 1 ? (item.trayCount ?? 0) * (item.quantity ?? 0) : (item.quantity ?? 0);
    final currentQty = RxInt(existingDamagedQty);
    
    if (existingItemIndex != -1) {
      notesController.text = selectedItems[existingItemIndex]['notes'] ?? '';
      damagedQtyController.text = existingDamagedQty.toString();
    }
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(existingItemIndex != -1 ? 'Update Damage' : 'Report Damage', 
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'Product: ${item.productName ?? 'Product #${item.productId}'}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'Total Available Qty: $maxQty',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              if (existingItemIndex != -1) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Damaged Quantity',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  selectedItems.removeAt(existingItemIndex);
                                  Get.back();
                                  validateForm();
                                  Get.snackbar(
                                    'Removed',
                                    'Item removed from damaged list',
                                    backgroundColor: Colors.orange[100],
                                    colorText: Colors.orange[800],
                                  );
                                },
                                icon: Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                label: Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Obx(() => IconButton(
                                onPressed: currentQty.value > 0 ? () {
                                  currentQty.value--;
                                  damagedQtyController.text = currentQty.value.toString();
                                } : null,
                                icon: Icon(Icons.remove_circle_outline),
                                color: currentQty.value > 0 ? Colors.red : Colors.grey,
                              )),
                              Expanded(
                                child: Obx(() => GestureDetector(
                                  onTap: () {
                                    _showQuantityInputDialog(currentQty, (maxQty ?? 0).toInt(), damagedQtyController);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${currentQty.value}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )),
                              ),
                              Obx(() => IconButton(
                                onPressed: currentQty.value < (maxQty ?? 0) ? () {
                                  currentQty.value++;
                                  damagedQtyController.text = currentQty.value.toString();
                                } : null,
                                icon: Icon(Icons.add_circle_outline),
                                color: currentQty.value < (maxQty ?? 0) ? Colors.green : Colors.grey,
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ] else ...[
                TextFormField(
                  controller: damagedQtyController,
                  decoration: InputDecoration(
                    labelText: 'Damaged Quantity *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    _MaxValueInputFormatter((maxQty ?? 0).toDouble()),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter damaged quantity';
                    }
                    final damagedQty = int.tryParse(value);
                    if (damagedQty == null || damagedQty > (maxQty ?? 0) || damagedQty < 0) {
                      return 'Enter valid quantity (0-$maxQty)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
              ],
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
              ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final finalQty = existingItemIndex != -1 ? currentQty.value : int.tryParse(damagedQtyController.text) ?? 0;
              
              if (existingItemIndex == -1 && (finalQty <= 0 || finalQty > (maxQty ?? 0))) {
                Get.snackbar(
                  'Invalid Quantity',
                  'Please enter valid quantity (1-$maxQty)',
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                );
                return;
              }
              
              if (existingItemIndex != -1) {
                if (finalQty == 0) {
                  selectedItems.removeAt(existingItemIndex);
                  Get.back();
                  validateForm();
                  Get.snackbar(
                    'Removed',
                    'Item removed from damaged list',
                    backgroundColor: Colors.orange[100],
                    colorText: Colors.orange[800],
                  );
                } else {
                  selectedItems[existingItemIndex] = {
                    'productId': item.productId,
                    'productName': item.productName,
                    'damagedQuantity': finalQty,
                    'originalQuantity': maxQty,
                    'notes': notesController.text.isNotEmpty ? notesController.text : null,
                  };
                  selectedItems.refresh();
                  Get.back();
                  Get.snackbar(
                    'Updated',
                    'Damaged quantity updated to $finalQty',
                    backgroundColor: Colors.green[100],
                    colorText: Colors.green[800],
                  );
                }
              } else {
                final duplicateIndex = selectedItems.indexWhere((existing) => existing['productId'] == item.productId);
                if (duplicateIndex == -1) {
                  selectedItems.add({
                    'productId': item.productId,
                    'productName': item.productName,
                    'damagedQuantity': finalQty,
                    'originalQuantity': maxQty,
                    'notes': notesController.text.isNotEmpty ? notesController.text : null,
                  });
                }
                Get.back();
              }
              _removeDuplicates(selectedItems);
              validateForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00ADD9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(existingItemIndex != -1 ? 'Update Item' : 'Add Item', 
                      style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(RxList<File> selectedImages, ImageSource source, VoidCallback validateForm) async {
    if (selectedImages.length >= 15) {
      Get.snackbar(
        'Limit Reached',
        'You can only upload maximum 15 photos',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    
    if (pickedFile != null) {
      selectedImages.add(File(pickedFile.path));
      validateForm();
      
      if (selectedImages.length == 15) {
        Get.snackbar(
          'Maximum Reached',
          'You have reached the maximum limit of 15 photos',
          backgroundColor: Colors.blue[100],
          colorText: Colors.blue[800],
        );
      }
    }
  }

  Future<void> _pickMultipleImages(RxList<File> selectedImages, VoidCallback validateForm) async {
    final remainingSlots = 15 - selectedImages.length;
    if (remainingSlots <= 0) {
      Get.snackbar(
        'Limit Reached',
        'You can only upload maximum 15 photos',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }
    
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    
    if (pickedFiles.isNotEmpty) {
      final filesToAdd = pickedFiles.take(remainingSlots).map((xFile) => File(xFile.path)).toList();
      selectedImages.addAll(filesToAdd);
      validateForm();
      
      if (pickedFiles.length > remainingSlots) {
        Get.snackbar(
          'Selection Limited',
          'Only ${filesToAdd.length} photos were added due to the 15 photo limit',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      }
      
      if (selectedImages.length == 15) {
        Get.snackbar(
          'Maximum Reached',
          'You have reached the maximum limit of 15 photos',
          backgroundColor: Colors.blue[100],
          colorText: Colors.blue[800],
        );
      }
    }
  }

  Future<void> _submitClaim(
    TextEditingController reasonController,
    TextEditingController descriptionController,
    Rxn<DeliveredOrderModel> selectedOrder,
    RxList<Map<String, dynamic>> selectedItems,
    RxList<File> selectedImages,
  ) async {
    if (reasonController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a reason for the claim');
      return;
    }

    if (selectedOrder.value == null) {
      Get.snackbar('Error', 'Please select an order');
      return;
    }

    if (selectedItems.isEmpty) {
      Get.snackbar('Error', 'Please add at least one damaged item');
      return;
    }

    await controller.createClaim(
      orderId: selectedOrder.value!.id,
      reason: reasonController.text,
      description: null,
      images: selectedImages.isNotEmpty ? selectedImages : null,
      items: selectedItems,
    );
  }
}

class _MaxValueInputFormatter extends TextInputFormatter {
  final double maxValue;
  
  _MaxValueInputFormatter(this.maxValue);
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final int? value = int.tryParse(newValue.text);
    if (value == null || value > maxValue) {
      if (value != null && value > maxValue) {
        Get.snackbar(
          'Invalid Input',
          'Maximum allowed quantity is ${maxValue.toInt()}',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: Duration(seconds: 2),
        );
      }
      return oldValue;
    }
    return newValue;
  }
}