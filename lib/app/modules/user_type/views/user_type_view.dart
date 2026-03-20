import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_enums.dart';
import '../controllers/user_type_controller.dart';

class UserTypeView extends StatelessWidget {
  const UserTypeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserTypeController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final config = Get.find<ClientConfig>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 1),
              Hero(
                tag: 'aavin_logo',
                child: SvgPicture.asset(
                  config.loginLogo,
                  width: screenWidth < 360 ? 80 : 100,
                  height: screenWidth < 360 ? 80 : 100,
                ),
              ),
              Spacer(flex: 1),
              _buildUserTypeCard(
                controller: controller,
                type: UserType.customer,
                title: 'Customer',
                iconPath: 'assets/icons/customer_icon.svg',
                screenWidth: screenWidth,
              ),
              SizedBox(height: 20),
              _buildUserTypeCard(
                controller: controller,
                type: UserType.society,
                title: 'Society',
                iconPath: 'assets/icons/agent_icon.svg',
                screenWidth: screenWidth,
              ),
              Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required UserTypeController controller,
    required UserType type,
    required String title,
    required String iconPath,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: () => controller.selectUserType(type),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth < 360 ? 18 : 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: type == UserType.customer ? AppColors.primary : AppColors.success,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                type == UserType.customer ? 'assets/icons/customer_icon.svg' : 'assets/icons/agent_icon.svg',
                width: type == UserType.customer ? (screenWidth < 360 ? 28 : 33.5) : (screenWidth < 360 ? 20 : 25.53),
                height: type == UserType.customer ? (screenWidth < 360 ? 20 : 24.74) : (screenWidth < 360 ? 22 : 27.85),
                colorFilter: ColorFilter.mode(
                  type == UserType.customer ? Color(0xFF00ADD9) : Color(0xFF05967B),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: screenWidth < 360 ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: type == UserType.customer ? Color(0xFF00ADD9) : Color(0xFF05967B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: type == UserType.customer ? Color(0xFF00ADD9) : Color(0xFF05967B),
              size: screenWidth < 360 ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }
}