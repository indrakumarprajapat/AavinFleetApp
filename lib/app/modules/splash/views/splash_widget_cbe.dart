import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashViewCBE extends StatelessWidget {
  const SplashViewCBE({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = Get.find<ClientConfig>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Hero(
          tag: 'aavin_logo',
          child: SvgPicture.asset(
            config.loginLogo,
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}