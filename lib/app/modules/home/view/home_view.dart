// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import '../../../config/app_config.dart';
// import '../controller/home_controller.dart';
//
// class HomeView extends GetView<HomeController> {
//   const HomeView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;
//     final paddingTop = MediaQuery.of(context).padding.top;
//     final config = Get.find<ClientConfig>();
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Column(
//         children: [
//           SizedBox(
//             height: h * 0.22,
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: SvgPicture.asset(
//                     "assets/images/Vector.svg",
//                     colorFilter: const ColorFilter.mode(
//                       Color(0xff1BA6C8),
//                       BlendMode.srcIn,
//                     ),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.topCenter,
//                   child: Padding(
//                     padding: EdgeInsets.only(top: paddingTop + (h * 0.025)),
//                     child: SvgPicture.asset(
//                       config.loginLogo,
//                       colorFilter: const ColorFilter.mode(
//                         Colors.white,
//                         BlendMode.srcIn,
//                       ),
//                       height: h * 0.06,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.only(bottom: h * 0.05),
//               child: Column(
//                 children: [
//                   SizedBox(height: h * 0.04),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: w * 0.05),
//                     child: Container(
//                       padding: EdgeInsets.all(w * 0.05),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(w * 0.04),
//                         boxShadow: [
//                           BoxShadow(
//                             blurRadius: w * 0.02,
//                             color: Colors.black.withOpacity(0.1),
//                           ),
//                         ],
//                       ),
//
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today,
//                                 color: Colors.blue,
//                                 size: w * 0.06,
//                               ),
//                               SizedBox(width: w * 0.03),
//                               Text(
//                                 "Date : ${controller.getTodayDate()}",
//                                 style: TextStyle(
//                                   fontSize: w * 0.045,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           SizedBox(height: h * 0.04),
//
//                             Obx(() => GestureDetector(
//                                   onTap: controller.isLoading.value ? null : controller.openPdf,
//                                   child: Container(
//                                     height: h * 0.2,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       border: Border.all(color: Colors.blueAccent),
//                                       borderRadius: BorderRadius.circular(w * 0.03),
//                                     ),
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.picture_as_pdf,
//                                           size: w * 0.12,
//                                           color: Colors.red,
//                                         ),
//                                         SizedBox(height: h * 0.015),
//                                         Text(
//                                           "Assigned Route PDF",
//                                           style: TextStyle(fontSize: w * 0.045),
//                                         ),
//                                         SizedBox(height: h * 0.01),
//                                         Text(
//                                           controller.isLoading.value ? "Loading..." : "Tap to view",
//                                           style: TextStyle(
//                                             color: Colors.grey,
//                                             fontSize: w * 0.035,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )),
//
//                           SizedBox(height: h * 0.05),
//
//                           Obx(() => SizedBox(
//                             width: double.infinity,
//                             height: h * 0.065,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xff1BA6C8),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(w * 0.03),
//                                 ),
//                               ),
//                               onPressed: controller.isLoading.value ? null : controller.startDelivery,
//                               child: controller.isLoading.value
//                                   ? const Center(child: CircularProgressIndicator(color: Colors.white))
//                                   : Text(
//                                       "START DELIVERY",
//                                       style: TextStyle(
//                                         fontSize: w * 0.045,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                             ),
//                           )),
//                         ],
//
//                     ),
//                   ),
//                   ),
//               ],
//             ),
//           ),
//           ),
//       ],
//     ),
//     );
//   }
// }