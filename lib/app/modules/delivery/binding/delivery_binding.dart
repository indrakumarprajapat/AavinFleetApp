import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../controllers/delivery_controller.dart';

class DeliveryRouteBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DeliveryController(), permanent: true);
  }
}