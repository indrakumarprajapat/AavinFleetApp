// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import '../../../../config/app_config.dart';
// import '../../../../models/product_model.dart';
// import '../../../../utils/calculations.dart';
// import '../../../../widgets/global_bottom_nav.dart';
// import '../../../../widgets/global_header.dart';
// import '../controllers/product_selection_controller.dart';
//
// class ProductSelectionView extends StatefulWidget {
//   const ProductSelectionView({Key? key}) : super(key: key);
//
//   @override
//   State<ProductSelectionView> createState() => _ProductSelectionViewState();
// }
//
// class _ProductSelectionViewState extends State<ProductSelectionView> {
//   final config = Get.find<ClientConfig>();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ProductSelectionController());
//     final slotData = Get.arguments as Map<String, dynamic>? ?? {};
//     final isEvening = slotData['shift'] == 2;
//     final slotTitle = slotData['shift_name'] ?? (isEvening ? 'Evening' : 'Morning');
//
//     return Scaffold(
//       backgroundColor: Color(0xFFF8F8F8),
//       body: Column(
//         children: [
//           GlobalHeader(),
//           Expanded(
//             child: Column(
//               children: [
//                 _buildOrderInfo(slotTitle, slotData['slot_date']),
//                 _buildProductSection(),
//                 // Spacer(),
//                 _buildCartSummary(controller),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: GlobalBottomNav(currentIndex: 0),
//     );
//   }
//
//   Widget _buildHeader() {
//     return SizedBox(
//       height: MediaQuery.of(Get.context!).size.height * 0.25,
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: SvgPicture.asset(
//               'assets/images/Vector.svg',
//               fit: BoxFit.fill,
//               width: double.infinity,
//               colorFilter: ColorFilter.mode(
//                 Color(0xFF00ADD9),
//                 BlendMode.srcIn,
//               ),
//             ),
//           ),
//           Positioned(
//             top: 60,
//             left: 0,
//             right: 0,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Get.back(),
//                     icon: Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                   ),
//                   Expanded(
//                     child: Center(
//                       child: Text(config.app_title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
//                     ),
//                   ),
//                   Stack(
//                     children: [
//                       IconButton(
//                         onPressed: () => Get.toNamed('/cart'),
//                         icon: Icon(
//                           Icons.shopping_cart_outlined,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderInfo(String slotTitle, String? slotDate) {
//     final now = slotDate != null ? DateTime.parse(slotDate) : DateTime.now();
//     final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     final dayName = days[now.weekday - 1];
//     final monthName = months[now.month - 1];
//     final dateStr = "$dayName ${now.day} $monthName, ${now.year}";
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         textBaseline: TextBaseline.alphabetic,
//         children: [
//           Text(
//             'New Order',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Transform.translate(
//             offset: Offset(0, -2),
//             child: Text(
//               dateStr,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProductSection() {
//     final controller = Get.find<ProductSelectionController>();
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Obx(() {
//           if (controller.isLoading) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (controller.products.isEmpty) {
//             return Center(
//               child: Text(
//                 'No products available',
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//             );
//           }
//
//           final milkProducts = controller.products.where((p) =>
//             p.categoryName?.toLowerCase().contains('milk') == true).toList();
//           final curdProducts = controller.products.where((p) =>
//             p.categoryName?.toLowerCase().contains('curd') == true).toList();
//
//           return RefreshIndicator(
//             onRefresh: () async {
//               final arguments = Get.arguments as Map<String, dynamic>? ?? {};
//               final orderType = arguments['shift'] == 2 ? 1 : 1;
//               final shiftType = (arguments['shift'] ?? 1);
//               await controller.loadProducts(orderType);
//               await controller.globalCartService.refreshCartEstimate();
//             },
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (milkProducts.isNotEmpty)
//                     _buildCategoryCard('Milk Products', milkProducts,controller.shiftType.value,controller.enableSingleSlotOnly.value),
//                   SizedBox(height: 20),
//                   if (curdProducts.isNotEmpty)
//                     _buildCategoryCard('Curd Products', curdProducts,controller.shiftType.value,controller.enableSingleSlotOnly.value),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildCategoryCard(String title, List<ProductModel> products, int shiftType, bool enableSingleSlotOnly) {
//     // final controller = Get.find<ProductSelectionController>();
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withValues(alpha: 0.15),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF00AEEF),
//                 ),
//               ),
//               Spacer(),
//               Visibility(
//                 visible: enableSingleSlotOnly == false?true:(enableSingleSlotOnly && shiftType == 1),
//                 child:
//               Column(
//                 children: [
//                   Icon(Icons.wb_sunny, color: Color(0xFFFF7A00), size: 20),
//                   // Text('Units',style: TextStyle(fontSize: 12),)
//                 ],
//               ),
//               ),
//               Visibility(visible: enableSingleSlotOnly == false?true:false, child: SizedBox(width: MediaQuery.of(context).size.height * 0.07)),
//               Visibility(visible: enableSingleSlotOnly == false?true:(enableSingleSlotOnly && shiftType == 2), child: Column(
//                 children: [
//                   Transform.rotate(
//                     angle: -40 * 3.1415926535 / 180,
//                     child: Icon(Icons.nightlight_round, color: Color(0xFF007BFF), size: 20),
//                   ),
//                   // Text('Units', style: TextStyle(fontSize: 12),)
//                 ],
//               )),
//               SizedBox(width: MediaQuery.of(context).size.height * 0.048),
//             ],
//           ),
//           SizedBox(height: 16),
//           ...products.map((product) => _buildProductRow(product,enableSingleSlotOnly,shiftType)),
//         ],
//       ),
//     );
//   }
//
//   // Widget _buildSectionHeader(String title) {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(vertical: 12),
//   //     child: Center(
//   //       child: Text(
//   //         title,
//   //         style: TextStyle(
//   //           fontSize: 20,
//   //           fontWeight: FontWeight.bold,
//   //           color: Color(0xFF00AEEF),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _buildProductRow(ProductModel product,bool enableSingleSlotOnly, int shiftType) {
//     final controller = Get.find<ProductSelectionController>();
//     final morningController = controller.getMorningTextController(product.id ?? 0);
//     final eveningController = controller.getEveningTextController(product.id ?? 0);
//
//     if ((product.morningCartQuantity ?? 0) > 0) {
//       morningController.text = product.morningCartQuantity.toString();
//     } else {
//       morningController.clear();
//     }
//
//     if ((product.eveningCartQuantity ?? 0) > 0) {
//       eveningController.text = product.eveningCartQuantity.toString();
//     } else {
//       eveningController.clear();
//     }
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.name ?? '',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   '₹${(((product.itemUnitType) == 1
//                       ? (product.price ?? 0) * (product.trayCapacity ?? 0)
//                       : (product.price ?? 0))
//                       .toDouble())
//                       .toStringAsFixed(2)} / ${(product.itemUnitType) == 1 ? 'Tray' : 'Pkt'}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 if ((product.morningCartQuantity ?? 0) > 0 || (product.eveningCartQuantity ?? 0) > 0)
//                   Text(
//                     'Total Pkt: ${(((product.morningCartQuantity ?? 0) + (product.eveningCartQuantity ?? 0)) * (product.itemUnitType == 1 ? product.trayCapacity!: 1)).toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.green[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Visibility(visible: enableSingleSlotOnly == false?true:(enableSingleSlotOnly && shiftType == 1),
//             child: SizedBox(
//             width: 60,
//             height: 35,
//             child: _buildSimpleInput(
//               morningController,
//               (value) {
//                 controller.updateCart(product.id ?? 0, CalculationsUtil.roundToNearestQuarterThenToInt(value, product.incrementBy ?? 0.0), 1);
//               },
//               controller.isSlotExpired(1),
//             ),
//           )),
//           Visibility(visible: enableSingleSlotOnly == false?true:false,child: const SizedBox(width: 16)),
//           Visibility(visible: enableSingleSlotOnly == false?true:(enableSingleSlotOnly && shiftType == 2),
//               child: SizedBox(
//               width: 60,
//               height: 35,
//               child: _buildSimpleInput(
//                 eveningController,
//                 (value) {
//                   controller.updateCart(product.id ?? 0, CalculationsUtil.roundToNearestQuarterThenToInt(value, product.incrementBy ?? 0.0), 2);
//                   },
//                 controller.isSlotExpired(2),
//               ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSimpleInput(TextEditingController controller, Function(String) onChanged, bool isExpired) {
//     return SizedBox(
//       height: 35,
//       child: TextField(
//         textAlign: TextAlign.center,
//         keyboardType: TextInputType.numberWithOptions(decimal: true),
//         controller: controller,
//         enabled: !isExpired,
//         onChanged: isExpired ? null : onChanged,
//         onEditingComplete: () {
//           FocusScope.of(context).unfocus();
//         },
//         decoration: InputDecoration(
//           hintText: '0',
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: BorderSide(color: isExpired ? Colors.grey[300]! : Colors.grey[400]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: BorderSide(color: isExpired ? Colors.grey[300]! : Color(0xFF00AEEF)),
//           ),
//           disabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//           fillColor: isExpired ? Colors.grey[50] : null,
//           filled: isExpired,
//         ),
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//           color: isExpired ? Colors.grey[400] : null,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCartSummary(controller) {
//     final controller = Get.find<ProductSelectionController>();
//     return Obx(() {
//       final totalItems = controller.cartEstimate['totalItems'] ?? 0;
//       final totalAmount = controller.cartEstimate['totalAmount'] ?? 0.0;
//       if (totalItems == 0) {
//         return SizedBox.shrink();
//       }
//       return Container(
//         margin: const EdgeInsets.only(left:40,right: 40,bottom: 4),
//         padding: const EdgeInsets.only(left:20,right: 20,top:8,bottom: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.green[300]!),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.green.withValues(alpha: 0.15),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '$totalItems items Added',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '₹ ${totalAmount.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await Get.toNamed('/cart');
//                 final arguments = Get.arguments as Map<String, dynamic>? ?? {};
//                 final orderType = arguments['shift'] == 2 ? 1 : 1;
//                 await controller.loadProducts(orderType);
//                 await controller.globalCartService.refreshCartEstimate();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 'OPEN CART',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }