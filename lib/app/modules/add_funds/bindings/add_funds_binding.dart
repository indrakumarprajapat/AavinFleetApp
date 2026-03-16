import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../../../services/wallet_service.dart';
import '../controllers/add_funds_controller.dart';

class AddFundsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<WalletService>()) {
      Get.lazyPut<WalletService>(() => WalletService());
    }
    Get.lazyPut<AddFundsController>(() => AddFundsController());
  }
}