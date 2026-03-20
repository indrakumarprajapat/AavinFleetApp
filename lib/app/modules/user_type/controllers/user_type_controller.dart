import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../constants/app_enums.dart';
import '../../login/controllers/login_controller.dart';

class UserTypeController extends GetxController {
  void selectUserType(UserType type) {
    try {
      if (Get.isRegistered<LoginController>()) {
        Get.delete<LoginController>(force: true);
      }
      // if (Get.isRegistered<CustomerController>()) {
      //   Get.delete<CustomerController>(force: true);
      // }
    } catch (e) {
      // Controllers already disposed
    }
    
    Get.offNamed(Routes.LOGIN, arguments: type.index);
  }
}