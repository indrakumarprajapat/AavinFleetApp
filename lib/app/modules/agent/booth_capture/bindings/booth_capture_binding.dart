import 'package:get/get.dart';

import '../controllers/booth_capture_controller.dart';

class BoothCaptureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoothCaptureController>(
      () => BoothCaptureController(),
    );
  }
}
