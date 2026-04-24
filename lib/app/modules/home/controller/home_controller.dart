import 'package:aavin/app/api/api_service.dart';
import 'package:aavin/app/modules/pdf/view/pdf_view.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';


class HomeController extends GetxController {

  final ApiService apiService = Get.find();
  var isLoading = false.obs;
  var tripId = 0.obs;

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.day}-${now.month}-${now.year}";
  }

  @override
  void onInit() {
    super.onInit();
    fetchActiveTrip();
  }

  Future<void> fetchActiveTrip() async {
    try {
      isLoading.value = true;
      final response = await apiService.getTrip(tripId: 0);
      
      // Handle nested response data
      final data = response['data'] ?? response;
      
      if (data != null && data['id'] != null) {
        tripId.value = int.tryParse(data['id'].toString()) ?? 0;
        print("Active Trip found: ${tripId.value}");
      }
    } catch (e) {
      print("Error fetching active trip: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void openPdf() {
    if (tripId.value == 0) {
      Get.snackbar(
        "No Active Trip",
        "Please wait until a trip is assigned to you.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(Routes.PDF, arguments: tripId.value);
  }

  Future<void> startDelivery() async {
    if (tripId.value == 0) {
      Get.snackbar(
        "No Active Trip",
        "You cannot start delivery because no trip is assigned to you yet.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await apiService.startTrip(tripId.value);
      Get.offNamed(Routes.DELIVERY_ROUTE, arguments: tripId.value);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

}