import 'package:aavin/app/modules/pdf/view/pdf_view.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';


class HomeController extends GetxController {

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.day}-${now.month}-${now.year}";
  }

  @override
  void onInit() {
    super.onInit();
    print("RouteAssignmentController Initialized");
  }

  void openPdf() {
    Get.toNamed(Routes.PDF);
  }

  void startDelivery() {
    Get.offNamed(Routes.DELIVERY_ROUTE);
  }
}