import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_service.dart';
import '../api/agent_api_service.dart';
import '../modules/agent/wallet/controllers/wallet_controller.dart';
import '../services/global_cart_service.dart';
import '../services/connectivity_service.dart';
import '../services/config_service.dart';
import '../services/cashfree_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<AgentApiService>(() => AgentApiService(), fenix: true);
    Get.lazyPut<ConfigService>(() => ConfigService(), fenix: true);
    Get.lazyPut<CashfreeService>(() => CashfreeService(), fenix: true);
    Get.lazyPut<GlobalCartService>(() => GlobalCartService(), fenix: true);
    Get.lazyPut<GetStorage>(() => GetStorage(), fenix: true);
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);

  }
}