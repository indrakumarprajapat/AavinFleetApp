import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_colors.dart';
import 'splash_widget_cbe.dart';
import 'splash_widget_namakkal.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = Get.find<ClientConfig>();

    switch (config.name) {
      case ClientConfig.CLIENT_NAMAKKAL:
      case ClientConfig.CLIENT_CBE:
        return const SplashViewNamakkal();
      case ClientConfig.CLIENT_NILGIRIS:
      default:
        return const SplashViewCBE();
    }
  }
}