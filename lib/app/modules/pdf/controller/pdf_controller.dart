import 'package:aavin/app/modules/delivery/view/delivery_route_view.dart';
import 'package:get/get.dart';

class PdfController extends GetxController {

  var isLoading = true.obs;
  var hasError = false.obs;

  final String pdfUrl =
      "https://www.africau.edu/images/default/sample.pdf";

  void onLoaded() {
    isLoading.value = false;
  }

  void onError() {
    isLoading.value = false;
    hasError.value = true;
  }

  void retry() {
    isLoading.value = true;
    hasError.value = false;
  }

  void startDelivery() {
    Get.offAll(() => const DeliveryRouteView());
  }
}