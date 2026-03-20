import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../models/slot_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/calculations.dart';
import '../../../../widgets/global_header.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
import '../../product_selection/controllers/product_selection_controller.dart';

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CartView extends StatefulWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late PageController _pageController;
  final Map<String, TextEditingController> _textControllers = {};
  final Set<String> _focusedControllers = {};

  @override
  void initState() {
    super.initState();
    final controller = Get.put(CartController());
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    super.dispose();
  }

  void _disposeController(String key) {
    if (_textControllers.containsKey(key)) {
      _textControllers[key]?.dispose();
      _textControllers.remove(key);
      _focusedControllers.remove(key);
    }
  }

  TextEditingController _getTextController(String key, String initialValue) {
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController(text: initialValue == '0' ? '' : initialValue);
    } else {
      final controller = _textControllers[key]!;
      final displayValue = initialValue == '0' ? '' : initialValue;
      if (!_focusedControllers.contains(key) && controller.text != displayValue) {
        controller.text = displayValue;
      }
    }
    return _textControllers[key]!;
  }

  bool _isSlotExpired(int shiftType) {
    try {
      final homeController = Get.find<HomeController>();
      final slot = homeController.slots.firstWhere(
            (s) => s.shift == shiftType,
        orElse: () => SlotModel(),
      );

      if (slot.createdAt == null || slot.cutoffTime == null) return false;

      final now = DateTime.now();
      final slotDate = DateTime.parse(slot.createdAt!);
      final cutoffParts = slot.cutoffTime!.split(':');
      final cutoffDateTime = DateTime(
        slotDate.year,
        slotDate.month,
        slotDate.day,
        int.parse(cutoffParts[0]),
        int.parse(cutoffParts[1]),
      );

      return now.isAfter(cutoffDateTime);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          GlobalHeader(
            title: 'Cart',
            showCart: false,
            onBack: () {
              FocusScope.of(context).unfocus();
              Get.back();
              Future.delayed(Duration(milliseconds: 100), () {
                if (Get.isRegistered<ProductSelectionController>()) {
                  final productController = Get.find<ProductSelectionController>();
                  final arguments = Get.arguments as Map<String, dynamic>? ?? {};
                  final orderType = arguments['shift'] == 2 ? 1 : 1;
                  productController.loadProducts(orderType);
                  productController.globalCartService.refreshCartEstimate();
                }
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCartContent(controller, context),
                  _buildCartHeader(controller, context),
                  _buildCartSummary(),
                  SizedBox(height: 50)
                ],
              ),
            ),
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
                        'Cart',
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

  Widget _buildCartItem(Map<String, dynamic> item, CartController controller) {
    final productName = item['product_name'] ?? '';
    final productCode = item['product_code'] ?? '';
    final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
    final quantity = item['quantity'] ?? 0;
    final productId = item['product_id'] ?? 0;
    final trayCount = item['tray_capacity'] ?? 1;
    final morningQuantity = item['morning_quantity'] ?? 0;
    final eveningQuantity = item['evening_quantity'] ?? 0;
    final incrementBy = item['increment_by'] ?? 0.0;
    final itemUnitType = item['item_unit_type'] ?? 1;
    final orderType = item['order_type'] ?? 1;

    if (orderType == 1) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Dismissible(
            key: Key('cart_item_type1_$productId'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return true;
            },
            onDismissed: (direction) async {
              _disposeController('morning_$productId');
              _disposeController('evening_$productId');
              await controller.removeCartItem(productId);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white, size: 28),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          productCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${price.toStringAsFixed(2)} x ${itemUnitType == 1 ?(trayCount * quantity):quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total: ₹${(price * (itemUnitType == 1 ?(trayCount * quantity):quantity)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(visible: controller.enableMorningSlot.value,child: SizedBox(
                    width: 60,
                    height: 35,
                    child: _buildSimpleInput(
                      _getTextController('morning_$productId', '$morningQuantity'),
                          (value) {
                            controller.updateCartItem(productId, CalculationsUtil.roundToNearestQuarterThenToInt(value, incrementBy), 1);
                          },
                      _isSlotExpired(1),
                      'morning_$productId',
                    ),
                  )),
                  Visibility(visible: (controller.enableMorningSlot.value && controller.enableEveningSlot.value), child: SizedBox(width: 16)),
                  Visibility(visible: controller.enableEveningSlot.value,child: SizedBox(
                    width: 60,
                    height: 35,
                    child: _buildSimpleInput(
                      _getTextController('evening_$productId', '$eveningQuantity'),
                          (value) {
                            controller.updateCartItem(productId, CalculationsUtil.roundToNearestQuarterThenToInt(value, incrementBy), 2);
                      },
                      _isSlotExpired(2),
                      'evening_$productId',
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Dismissible(
            key: Key('cart_item_$productId'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return true;
            },
            onDismissed: (direction) async {
              _disposeController('other_$productId');
              await controller.removeCartItem(productId);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white, size: 28),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
              ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Total: ₹${(price * quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF00AEEF)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            final newQty = (quantity - 1).clamp(0, double.infinity);
                            controller.updateCartItem(productId, newQty, 0, orderType: 2);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Icon(Icons.remove, size: 16, color: Color(0xFF00AEEF)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            '${quantity.toInt()}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00AEEF),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            final newQty = quantity + 1;
                            controller.updateCartItem(productId, newQty, 0, orderType: 2);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Icon(Icons.add, size: 16, color: Color(0xFF00AEEF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSimpleInput(TextEditingController controller, Function(String) onChanged, bool isExpired, String controllerKey) {
    return SizedBox(
        height: 35,
        child: Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              _focusedControllers.add(controllerKey);
            } else {
              _focusedControllers.remove(controllerKey);
              if (!isExpired) {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  controller.text = '';
                  onChanged('0');
                } else {
                  onChanged(value);
                }
              }
            }
          },
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: controller,
            enabled: !isExpired,
            onSubmitted: isExpired ? null : (value) {
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              hintText: isExpired ? '0' : '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: isExpired ? Colors.grey[300]! : Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: isExpired ? Colors.grey[300]! : Color(0xFF00AEEF)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              fillColor: isExpired ? Colors.grey[50] : null,
              filled: isExpired,
            ),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isExpired ? Colors.grey[400] : null,
            ),
          ),
        ));
  }

  Widget _buildCartHeader(controller,context) {
    return Obx(() {
      final hasOrderType1 = controller.cartItems.any((item) => (item['order_type'] ?? 1) == 1);
      final hasOrderType2 = controller.cartItems.any((item) => (item['order_type'] ?? 1) == 2);

      if (!hasOrderType1 && !hasOrderType2) return SizedBox.shrink();

      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasOrderType1) ...[
              Row(
                children: [
                  Text(
                    'Cart Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00AEEF),
                    ),
                  ),
                  Spacer(),
                  Visibility(visible: controller.enableMorningSlot.value,
                      child:
                  Column(
                    children: [
                      Icon(Icons.wb_sunny, color: Color(0xFFFF7A00), size: 20),
                    ],
                  )),
                  Visibility(visible: (controller.enableMorningSlot.value && controller.enableEveningSlot.value),
                  child:SizedBox(width: MediaQuery.of(context).size.height * 0.08)),
                  Visibility(visible: controller.enableEveningSlot.value,
                  child:Column(
                    children: [
                      Transform.rotate(
                        angle: -40 * 3.1415926535 / 180,
                        child: Icon(Icons.nightlight_round, color: Color(0xFF007BFF), size: 20),
                      ),
                    ],
                  )),
                  SizedBox(width: MediaQuery.of(context).size.height * 0.040),
                ],
              ),
              SizedBox(height: 16),
              ...controller.cartItems
                  .where((item) => (item['order_type'] ?? 1) == 1)
                  .map((item) => _buildCartItem(item, controller))
                  .toList(),
            ],
            if (hasOrderType1 && hasOrderType2) ...[
              SizedBox(height: 16),
              CustomPaint(
                size: Size(double.infinity, 1),
                painter: DashedLinePainter(),
              ),
              SizedBox(height: 10),
            ],
            if (hasOrderType2) ...[
              Text(
                'Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00AEEF),
                ),
              ),
              SizedBox(height: 16),
              ...controller.cartItems
                  .where((item) => (item['order_type'] ?? 1) == 2)
                  .map((item) => _buildCartItem(item, controller))
                  .toList(),
            ],
          ],
        ),
      );
    });
  }

  // Future shift tabs - currently disabled
  // Widget _buildSimpleShiftTabs() {
  //   final controller = Get.find<CartController>();
  //   final shifts = [1, 2, 0];
  //   final shiftNames = ['Morning', 'Evening', 'Products'];
  //
  //   return Container(
  //     margin: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[200],
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       children: List.generate(3, (index) {
  //         final shift = shifts[index];
  //         final shiftName = shiftNames[index];
  //
  //         return Expanded(
  //           child: GestureDetector(
  //             onTap: () {
  //               controller.changeShift(shift);
  //               _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  //             },
  //             child: Obx(() => Container(
  //               padding: EdgeInsets.symmetric(vertical: 12),
  //               decoration: BoxDecoration(
  //                 color: controller.selectedShift == shift ? Colors.blue : Colors.transparent,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Text(
  //                 shiftName,
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   color: controller.selectedShift == shift ? Colors.white : Colors.black,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             )),
  //           ),
  //         );
  //       }),
  //     ),
  //   );
  // }

  // Widget _buildShiftTabs() {
  //   final controller = Get.find<CartController>();
  //   return Obx(() {
  //     final availableShifts = controller.availableShifts;
  //     if (availableShifts.isEmpty) {
  //       return SizedBox.shrink();
  //     }
  //
  //     return Container(
  //       margin: EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.grey[200],
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Row(
  //         children: availableShifts.map((shift) {
  //           final index = availableShifts.indexOf(shift);
  //           final shiftName = shift == 1 ? 'Morning' : shift == 2 ? 'Evening' : 'Products';
  //
  //           return Expanded(
  //             child: GestureDetector(
  //               onTap: () {
  //                 controller.changeShift(shift);
  //                 _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  //               },
  //               child: Container(
  //                 padding: EdgeInsets.symmetric(vertical: 12),
  //                 decoration: BoxDecoration(
  //                   color: controller.selectedShift == shift ? Colors.blue : Colors.transparent,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Text(
  //                   shiftName,
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     color: controller.selectedShift == shift ? Colors.white : Colors.black,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     );
  //   });
  // }

  Widget _buildCartContent(CartController controller, context) {
    return Obx(() {
      if (controller.isLoading) {
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (controller.cartItems.isEmpty) {
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      }

      return SizedBox.shrink();
    });
  }

  Widget _buildCartSummary() {
    final controller = Get.find<CartController>();
    return Obx(() {
      final totalItems = controller.getTotalItems();
      final subtotalAmount = controller.getSubtotalAmount();
      final totalTax = controller.getTotalTax();
      final totalDiscount = controller.getTotalDiscount();
      final totalAmount = controller.getTotalAmount();

      if (totalItems == 0) {
        return SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[300]!),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: TextStyle(fontSize: 16)),
                Text('₹${subtotalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
              ],
            ),
            Visibility(visible: totalDiscount>0? true: false,
              child: Column(
                children: [
                  SizedBox(height: 4),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount:', style: TextStyle(fontSize: 16)),
                    Text('₹${totalDiscount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                  ],
                              ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax:', style: TextStyle(fontSize: 16)),
                Text('₹${totalTax.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total ($totalItems items):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₹${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text('Clear Cart'),
                          content: Text('Are you sure you want to clear all items from cart?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                controller.clearCart();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      minimumSize: Size(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'CLEAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      final canProceed = await controller.checkTrayCount();
                      if (!canProceed) {
                        return;
                      }
                      
                      final homeController = Get.find<HomeController>();
                      
                      final morningSlot = homeController.slots.firstWhere(
                            (s) => s?.shift == 1, // Morning shift
                        orElse: () => SlotModel(),
                      );
                      final eveningSlot = homeController.slots.firstWhere(
                            (s) => s?.shift == 2, // Evening shift
                        orElse: () => SlotModel(),
                      );

                      Get.toNamed(Routes.CHECKOUT, arguments: {
                        'subtotalAmount': subtotalAmount,
                        'orderType': controller.selectedShift != 0 ? 2:1,
                        'totalTax': totalTax,
                        'totalAmount': totalAmount,
                        'shiftType': controller.selectedShift,
                        'slotId': controller.selectedShift == 1 ? morningSlot.id : eveningSlot.id, // Current slot for backward compatibility
                        'morningSlotId': morningSlot.id ?? 0,
                        'eveningSlotId': eveningSlot.id ?? 0,
                        'totalDiscount': totalDiscount,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'CONFIRM ORDER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }}