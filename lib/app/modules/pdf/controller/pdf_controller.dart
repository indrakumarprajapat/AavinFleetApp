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

      /// STEP 1: GET TRIP (to get shift)
      final tripResponse =
      await _apiService.getTrip(tripId: tripId.value);

      final tripData = tripResponse['data'] ?? tripResponse;

      if (tripData == null) {
        hasError.value = true;
        return;
      }

      /// FIX: correct Rx assignment
      shift.value = int.parse(tripData['shift'].toString());

      print("Trip Data: $tripData");
      print("Shift: ${shift.value}");

      /// STEP 2: GET ROUTE REPORT (PDF)
      final response = await _apiService.getRouteReport(shift.value);

      print("PDF Controller Response: $response");

      final data = response['data'] ?? response;

      final url = data['pdfUrl'] ?? data['routePdf'];

      if (url != null && url.toString().isNotEmpty) {
        pdfUrl.value = url.toString();
      } else {
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