import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../../../data/data_service.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<DataService>(() => DataService()..init());
    Get.put<LoginController>(LoginController(), permanent: true);
  }
}
