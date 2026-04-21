import 'package:aavin/app/modules/delivery/view/delivery_route_view.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

import '../../../../api/api_service.dart';

class PdfController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = true.obs;
  var hasError = false.obs;
  var pdfUrl = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchRoutePdf();
  }

  Future<void> fetchRoutePdf() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final url = await _apiService.getAssignedRoutePdf();
      if (url.isNotEmpty) {
        pdfUrl.value = url;
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void onLoaded() {
    isLoading.value = false;
  }

  void onError() {
    isLoading.value = false;
    hasError.value = true;
  }

  void retry() {
    fetchRoutePdf();
  }

  void startDelivery() {
    Get.offAllNamed(Routes.DELIVERY_ROUTE);
  }
}