import 'package:get/get.dart';
import '../../../../api/api_service.dart';
import '../../../../services/config_service.dart';
import '../../../../services/global_cart_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<ConfigService>()) {
      Get.lazyPut<ConfigService>(() => ConfigService());
    }
    if (!Get.isRegistered<GlobalCartService>()) {
      Get.lazyPut<GlobalCartService>(() => GlobalCartService());
    }
    Get.put<HomeController>(HomeController());
  }
}