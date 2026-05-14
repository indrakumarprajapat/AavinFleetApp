// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import '../../../models/delivery_model.dart';
// import '../../delivery/controllers/delivery_controller.dart';
//
// class DashboardView  extends GetView<DeliveryController> {
//   const DashboardView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Today's Dashboard"),
//         backgroundColor: const Color(0xff1BA6C8),
//         centerTitle: true,
//       ),
//
//       floatingActionButton: SizedBox(
//         width: w * 0.8,
//         height: 50,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xff1BA6C8),
//             shape: const StadiumBorder(),
//             elevation: 4,
//           ),
//           onPressed: () {
//             SystemNavigator.pop();
//           },
//           child: const Text(
//             "DONE",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       body: Obx(() {
//         if (controller.isSummaryLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         final deliveries = controller.deliveries;
//
//
//         if (deliveries.isEmpty) {
//           return const Center(
//             child: Text(
//               "No deliveries available",
//               style: TextStyle(fontSize: 16),
//             ),
//           );
//         }
//
//         int totalDelivered = 0;
//         int totalCollected = 0;
//         int totalRemaining = 0;
//
//         for (var d in deliveries) {
//           totalDelivered += (d.totalTrays);
//           totalCollected += (d.collectedTrays);
//           totalRemaining += (d.remainingTrays);
//         }
//
//         return RefreshIndicator(
//             onRefresh: () async {
//           await controller.loadTripSummary();
//         },
//         child:SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSummaryCard(w, totalDelivered, totalCollected, totalRemaining),
//
//               const SizedBox(height: 30),
//
//               const Text(
//                 "Route Details",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//
//               const SizedBox(height: 15),
//
//               ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: deliveries.length,
//                 separatorBuilder: (context, index) => const Divider(),
//                 itemBuilder: (context, index) {
//                   final d = deliveries[index];
//
//                   return ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     leading: CircleAvatar(
//                       backgroundColor: Colors.blue.shade50,
//                       child: const Icon(Icons.store, color: Colors.blue),
//                     ),
//                     title: Text(
//                       d.storeName,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(d.address),
//
//                     trailing: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           "Delivered: ${d.totalTrays}",
//                           style: const TextStyle(
//                               color: Colors.green, fontSize: 12),
//                         ),
//                         Text(
//                           "Collected: ${d.collectedTrays}",
//                           style: const TextStyle(
//                               color: Colors.blue, fontSize: 12),
//                         ),
//                         if (d.remainingTrays > 0)
//                           Text(
//                             "Remaining: ${d.remainingTrays}",
//                             style: const TextStyle(
//                                 color: Colors.orange, fontSize: 12),
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildSummaryCard(
//       double w, int totalDelivered, int totalCollected, int totalRemaining) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xff1BA6C8).withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xff1BA6C8)),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "Trip Summary",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStat("Delivered", totalDelivered.toString(), Colors.green),
//               _buildStat("Collected", totalCollected.toString(), Colors.blue),
//               if (totalRemaining > 0)
//                 _buildStat("Remaining", totalRemaining.toString(), Colors.orange),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStat(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(label, style: const TextStyle(color: Colors.grey)),
//         const SizedBox(height: 5),
//         Text(
//           value,
//           style: TextStyle(
//               fontSize: 24, fontWeight: FontWeight.bold, color: color),
//         ),
//         const Text("Trays",
//             style: TextStyle(fontSize: 12, color: Colors.grey)),
//       ],
//     );
//
//   }
// }
