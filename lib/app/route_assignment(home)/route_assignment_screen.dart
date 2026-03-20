
import 'package:aavin/app/modules/delivery/controllers/delivery_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../modules/delivery/delivery_points_screen.dart';
import '../modules/pdf/pdf_screen.dart';
import '../widgets/global_header.dart';

/// CONTROLLER
class RouteController extends GetxController {
  String getTodayDate() {
    DateTime now = DateTime.now();
    return "${now.day}-${now.month}-${now.year}";
  }

  void openPdf() {
    Get.to(() => const PdfScreen());
  }

  /// NAVIGATE TO DELIVERY POINTS SCREEN
  void startDelivery() {
    Get.put(DeliveryController());
    Get.to(() => const DeliveryPointsScreen());
  }
}

/// SCREEN
class RouteAssignmentScreen extends GetView<RouteController> {
  const RouteAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Initialize controller
    Get.put(RouteController());

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER WITH AAVIN LOGO
              Stack(
                children: [
                  SvgPicture.asset(
                    "assets/images/Vector.svg",
                    width: double.infinity,
                    height: 220,
                    color: const Color(0xff1BA6C8),
                    fit: BoxFit.fill,
                  ),

                  Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/images/aavinnamakkallogo.svg",
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              /// MAIN CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(blurRadius: 8, color: Colors.black54),
                    ],
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// DATE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),

                          const SizedBox(width: 10),

                          Text(
                            "Date : ${controller.getTodayDate()}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// PDF BOX
                      GestureDetector(
                        onTap: controller.openPdf,

                        child: Container(
                          height: 180,
                          width: double.infinity,

                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                size: 50,
                                color: Colors.red,
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Assigned Route PDF",
                                style: TextStyle(fontSize: 18),
                              ),

                              SizedBox(height: 5),

                              Text(
                                "Tap to view",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      /// START BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1BA6C8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          onPressed: controller.startDelivery,

                          child: const Text(
                            "START DELIVERY",

                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
