import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../../../routes/app_pages.dart';

class PdfController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = true.obs;
  var hasError = false.obs;
  var pdfUrl = "".obs;

  var shift = 1.obs;
  var tripId = 0.obs;

  @override
  void onInit() {
    super.onInit();

    tripId.value = Get.arguments ?? 0;

    fetchRoutePdf();
  }

  Future<void> fetchRoutePdf() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      if (shift.value <= 0) {
        shift.value = 1;
      }
      final response = await _apiService.getRouteReport(shift.value);
      final data = response['data'] ?? response;

      if (data != null && data['success'] == true) {

        if (data['shift'] != null) {
          shift.value = int.tryParse(data['shift'].toString()) ?? shift.value;
        }

        final url = data['pdfUrl'] ?? data['routePdf'];

        if (url != null && url.toString().isNotEmpty) {
          pdfUrl.value = url.toString();
          print("PDF loaded for Shift ${shift.value}: ${pdfUrl.value}");
        } else {
          print("Error: No PDF URL found in Route PDF response");
          hasError.value = true;
        }
      } else {
        print("No PDF found");
        hasError.value = true;
      }
    } catch (e) {
      print("PDF ERROR: $e");
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    fetchRoutePdf();
  }

  void startDelivery() {
    Get.offAllNamed(Routes.DELIVERY_ROUTE);
  }
}