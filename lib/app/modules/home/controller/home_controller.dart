import 'package:aavin/app/modules/pdf/view/pdf_view.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../delivery/controllers/delivery_controller.dart';
import '../../delivery/view/delivery_route_view.dart';

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
    Get.to(() => const PdfView());
  }

  void startDelivery() {
    Get.offNamed(Routes.DELIVERY_ROUTE);
  }
}