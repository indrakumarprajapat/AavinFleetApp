import 'package:aavin/app/modules/agent/home/views/full_pdfview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../config/app_config.dart';

import '../../../../models/slot_model.dart';

import '../../../../services/global_cart_service.dart';

import '../../../../widgets/daily_supplies_form_dialog.dart';
import '../controllers/home_controller.dart';
import '../../drawer/views/agent_drawer_view.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class HomeView extends GetView<HomeController>  {
  HomeView({Key? key}) : super(key: key);

   final _currentIndex = 0.obs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _isInitialLoading = true.obs;
  final config = Get.find<ClientConfig>();


  // void _onPageChanged(int index) {
  //   _currentIndex.value = index;
  //   _tabController?.animateTo(index);
  // }

  // void _onTabTapped(int index) {
  //   _currentIndex.value = index;
  //   // _pageController?.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
  //   // if( config.name == ClientConfig.CLIENT_CBE ||  config.name == ClientConfig.CLIENT_NAMAKKAL){
  //   //   if(_currentIndex.value == 1){
  //   //     Get.find<ClaimsController>().loadClaims();
  //   //   }
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xFFF8F8F8),
        drawer: AgentDrawer(),
        body: Stack(
          children: [
            _buildHomeContent(controller),
            _buildCustomHeader(
              isLocationSubmitted,
              controller.fleetUser?.routeName ?? '',
              controller.fleetUser?.vehicleRegistrationNumber ?? '',
            ),
          ],
        ),
        // bottomNavigationBar: _buildBottomNav(),
      );
    });
  }

  Widget _buildHomeContent(HomeController controller) {
    final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;
    // final isBankVerified = controller.fleetUser?.hasBankAccountVerified == true;
    final allVerified =
        controller.isAadhaarKycVerified &&
        controller.isPanKycVerified &&
        // isBankVerified &&
        isLocationSubmitted;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadRouteDetails();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.height * 0.25),

            /// Body Container
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              child: Obx(() {
                if (controller.isLoading) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF007EA7),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRouteView(),
                    const SizedBox(height: 20),
                    _buildFooterView(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCardsModern(HomeController controller) {
    if (controller.slots.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No slots available",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: controller.slots.map((slot) {
        final isEvening = slot.shift == 2;

        return _buildModernOrderCard(
          title: slot.shiftName ?? (isEvening ? "Evening" : "Morning"),
          icon: isEvening ? Icons.nightlight_round : Icons.wb_sunny,
          color: isEvening ? const Color(0xFF007EA7) : const Color(0xFFFF8C42),
          slot: slot,
        );
      }).toList(),
    );
  }

  Widget _buildModernOrderCard({
    required String title,
    required IconData icon,
    required Color color,
    required SlotModel slot,
  }) {
    final remainingTime = _calculateRemainingTime(
      slot.createdAt ?? '',
      slot.cutoffTime ?? '',
    );

    return GestureDetector(
      onTap: () {
        Get.to(
          () => DailySuppliesFormDialog(
            slotId: slot.id ?? 1,
            shift: slot.shift ?? 1,
            slotDate: slot.slotDate ?? '',
            shiftName: title,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 26),
            ),

            const SizedBox(width: 16),

            /// Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title Shift",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Cutoff in $remainingTime",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
 _buildFooterView(){
   final h = Get.height;
   final w = Get.width;

   /// 🟢 START DELIVERY BUTTON (UNCHANGED)
   return Obx(
         () => SizedBox(
       width: double.infinity,
       height: h * 0.065,
       child: ElevatedButton(
         style: ElevatedButton.styleFrom(
           backgroundColor: const Color(0xff1BA6C8),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(w * 0.03),
           ),
         ),
         onPressed: controller.isLoading
             ? null
             : controller.startDelivery,
         child: controller.isLoading
             ? const Center(
           child: CircularProgressIndicator(
             color: Colors.white,
           ),
         )
             : Text(
           "START DELIVERY",
           style: TextStyle(
             fontSize: w * 0.045,
             color: Colors.white,
             fontWeight: FontWeight.bold,
           ),
         ),
       ),
     ),
   );
 }
  Widget _buildRouteView() {
    final h = Get.height;
    final w = Get.width;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 🔥 PDF SECTION (UPDATED)
              Obx(() {
                final pdfUrl = controller.pdfUrl.value;

                if (controller.isLoading) {
                  return SizedBox(
                    height: h * 0.25,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                /// ❌ No PDF
                if (pdfUrl.isEmpty) {
                  return Container(
                    height: h * 0.2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(w * 0.03),
                    ),
                    child: Center(
                      child: Text(
                        "No Route PDF Available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                /// ✅ PDF Preview + Button
                return    Container(
                  height: h * 0.55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(w * 0.03),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(w * 0.03),
                    child: Stack(
                      children: [
                        /// 📄 PDF VIEW
                        SfPdfViewer.network(
                          controller.pdfUrl.value,
                          canShowScrollHead: false,
                          canShowScrollStatus: false,
                        ),

                        /// 🔘 OVERLAY BUTTON (BOTTOM RIGHT)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => FullPdfViewPage(
                                url: controller.pdfUrl.value,
                              ));
                            },
                            child: Container(
                              padding: EdgeInsets.all(w * 0.025),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5), // transparent
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.open_in_full,
                                color: Colors.white,
                                size: w * 0.06,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),



            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomHeader(
      bool isLocationSubmitted,
      String societyName,
      String regNumber,
      ) {
    final now = DateTime.now();
    final dateText = "${now.day}-${now.month}-${now.year}";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: Get.height * 0.24,
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00ADD3), Color(0xFF007EA7), Color(0xFF005F7A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔹 TOP BAR
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(Icons.menu, color: Colors.white, size: 26),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        config.app_title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  isLocationSubmitted
                      ? _buildCartIcon()
                      : CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// 🔹 ROUTE NAME
              Text(
                'Route: $societyName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Row(children: [
                /// 🔹 VEHICLE NUMBER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Vehicle: $regNumber",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Spacer(),
                /// 🔥 DATE CHIP (NEW)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'Date: '+dateText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              ],)


            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartIcon() {
    return Stack(
      children: [
        Obx(() {
          final isLocationSubmitted =
              controller.boothDetails?.isLocSubmit == true;
          return IconButton(
            onPressed: isLocationSubmitted ? () => Get.toNamed('/cart') : null,
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 30,
            ),
          );
        }),
        Obx(() {
          try {
            final cartService = Get.find<GlobalCartService>();
            final totalItems = cartService.itemsCount;
            if (totalItems > 0) {
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$totalItems',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } catch (e) {}
          return SizedBox.shrink();
        }),
      ],
    );
  }

  // Widget _buildBottomNav() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withValues(alpha: 0.2),
  //           blurRadius: 10,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: BottomNavigationBar(
  //       type: BottomNavigationBarType.fixed,
  //       backgroundColor: Colors.white,
  //       selectedItemColor: Color(0xFF1976D2),
  //       unselectedItemColor: Colors.grey,
  //       elevation: 0,
  //       currentIndex: _currentIndex.value,
  //       // onTap: _onTabTapped,
  //       items: [
  //         BottomNavigationBarItem(
  //           icon: SvgPicture.asset(
  //             'assets/icons/homeIcon.svg',
  //             width: 21.21,
  //             height: 22,
  //           ),
  //           label: 'Home',
  //         ),
  //         if (config.name == ClientConfig.CLIENT_CBE ||
  //             config.name == ClientConfig.CLIENT_NAMAKKAL)
  //           BottomNavigationBarItem(
  //             icon: SvgPicture.asset(
  //               'assets/icons/cardMilk.svg',
  //               width: 13.71,
  //               height: 19.41,
  //             ),
  //             label: 'Claims',
  //           ),
  //         // BottomNavigationBarItem(
  //         //   icon: SvgPicture.asset(
  //         //     'assets/icons/cardMilk.svg',
  //         //     width: 13.71,
  //         //     height: 19.41,
  //         //   ),
  //         //   label: 'Card Milk',
  //         // ),
  //         BottomNavigationBarItem(
  //           icon: SvgPicture.asset(
  //             'assets/icons/otherIcon.svg',
  //             width: 18.39,
  //             height: 21.67,
  //           ),
  //           label: 'Others',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: SvgPicture.asset(
  //             'assets/icons/walletIcon.svg',
  //             width: 22.44,
  //             height: 19.17,
  //           ),
  //           label: 'Wallet',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _calculateRemainingTime(String slotDate, String cutoffTime) {
    try {
      final now = DateTime.now();
      final slotDateTime = DateTime.parse(slotDate);
      final cutoffParts = cutoffTime.split(':');
      final cutoffDateTime = DateTime(
        slotDateTime.year,
        slotDateTime.month,
        slotDateTime.day,
        int.parse(cutoffParts[0]),
        int.parse(cutoffParts[1]),
      );

      final difference = cutoffDateTime.difference(now);

      if (difference.isNegative) {
        return 'Expired';
      }

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m left';
      } else {
        return '${minutes}m left';
      }
    } catch (e) {
      return 'Invalid time';
    }
  }
}
