import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../models/DeviceInfo.dart';
import '../../../../routes/app_pages.dart';
import '../../../../api/api_service.dart';
import '../../../../utils/device-util.dart';

class KycSuccessView extends StatelessWidget {
  const KycSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KycSuccessController());
    return Obx(() {
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          // if (!didPop) {
          //   SystemNavigator.pop();
          // }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF00ADD9),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/aavin_logo2.svg',
                  width: 50,
                  height: 50,
                ),
              ],
            ),
            actions: const [
              SizedBox(width: 48),
            ],
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "KYC Completed!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
      
                  const SizedBox(height: 12),

                  const Text(
                    "Your KYC details and Booth location have been submitted successfully.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
      
                  const SizedBox(height: 40),

                  const Text(
                    "🚀 More updates are coming soon.\nStay tuned!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),

                  Text(
                    "Redirecting in ${controller.countdown.value} seconds...",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class KycSuccessController extends GetxController {
  final countdown = 5.obs;
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    startCountdown();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 1) {
        countdown.value--;
      } else {
        timer.cancel();
        redirectToHome();
      }
    });
  }

  Future<void> redirectToHome() async {
    try {
      final storage = GetStorage();
      final accessToken = storage.read('access_token');
      
      if (accessToken != null) {
        final apiService = Get.find<ApiService>();

        final response = await apiService.agentAutoLogin(accessToken);
        
        storage.write('agent', response.agent?.toJson() ?? {});
        storage.write('societyDetails', response.boothDetails?.toJson() ?? {});
        storage.write('profilePhotoUrl', response.agent?.profilePhoto??'');
      }
    } catch (e) {
      print('Auto-login failed: $e');
    } finally {
      Get.offAllNamed(Routes.HOME);
    }
  }
}
