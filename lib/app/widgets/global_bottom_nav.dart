import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../modules/agent/product_selection/controllers/product_selection_controller.dart';
import 'others_content_widget.dart';
import 'wallet_content_widget.dart';
import 'milk_content_widget.dart';
import 'claims_content_widget.dart';

class GlobalBottomNav extends StatelessWidget {
  final int currentIndex;

  const GlobalBottomNav({
    Key? key,
    this.currentIndex = 0,
  }) : super(key: key);

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        _showClaimsContent();
        break;
      case 2:
        _showOthersContent();
        break;
      case 3:
        _showWalletContent();
        break;
    }
  }

  void _showMilkContent() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
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
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: MilkContentWidget(height: 25),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _showOthersContent() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
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
            Expanded(child: OthersContentWidget()),
          ],
        ),
      ),
      isScrollControlled: true,
    ).then((_) {
      if (Get.currentRoute.contains('product-selection')) {
        try {
          final controller = Get.find<ProductSelectionController>();
          final arguments = Get.arguments as Map<String, dynamic>? ?? {};
          final shiftType = arguments['shift'] ?? 1;
          controller.globalCartService.refreshCartEstimate();
        } catch (e) {

        }
      }
    });
  }

  void _showClaimsContent() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
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
            Expanded(child: _buildClaimsBottomSheetContent()),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildClaimsBottomSheetContent() {
    return ClaimsContentWidget();
  }

  void _showWalletContent() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
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
            Expanded(child: WalletContentWidget()),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/homeIcon.svg',
              width: 21.21,
              height: 22,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/cardMilk.svg',
              width: 13.71,
              height: 19.41,
            ),
            label: 'Claims',
          ),
          // BottomNavigationBarItem(
          //   icon: SvgPicture.asset(
          //     'assets/icons/cardMilk.svg',
          //     width: 13.71,
          //     height: 19.41,
          //   ),
          //   label: 'Card Milk',
          // ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/otherIcon.svg',
              width: 18.39,
              height: 21.67,
            ),
            label: 'Others',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/walletIcon.svg',
              width: 22.44,
              height: 19.17,
            ),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}