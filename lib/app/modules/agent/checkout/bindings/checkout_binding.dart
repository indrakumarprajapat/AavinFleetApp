import 'package:get/get.dart';
import '../../../../services/connectivity_service.dart';
import '../controllers/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectivityService>(() => ConnectivityService());
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}