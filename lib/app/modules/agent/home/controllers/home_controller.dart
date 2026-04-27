import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../constants/app_enums.dart';
import '../../../../models/DeviceInfo.dart';
import '../../../../models/agent_model.dart';
import '../../../../models/booth_model.dart';
import '../../../../models/slot_model.dart';
import '../../../../api/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/global_cart_service.dart';
import '../../../../utils/device-util.dart';
import '../../../agent/claims/controllers/claims_controller.dart';

class HomeController extends GetxController {
  final _selectedIndex = 0.obs;
  // final _userType = UserType.customer.obs;
  final apiService = Get.find<ApiService>();
  final globalCartService = Get.find<GlobalCartService>();
  final _slots = <SlotModel>[].obs;
  final _isLoading = false.obs;
  final _isAadhaarKycVerified = false.obs;
  final _isPanKycVerified = false.obs;
  final _boothDetails = Rxn<Society>();
  final _fleetUser = Rxn<FleetUser>();

  int get selectedIndex => _selectedIndex.value;
  // UserType get userType => _userType.value;
  // bool get isCustomer => _userType.value == UserType.customer;
  // bool get isDealer => _userType.value == UserType.agent;
  List<SlotModel> get slots => _slots;
  bool get isLoading => _isLoading.value;
  bool get isAadhaarKycVerified => _isAadhaarKycVerified.value;
  bool get isPanKycVerified => _isPanKycVerified.value;
  Society? get boothDetails => _boothDetails.value;
  FleetUser? get fleetUser => _fleetUser.value;
  String get agentName => _fleetUser.value?.name ?? '';
  String get aadhaarNumber => _fleetUser.value?.aadharNumber ?? '';
  String get panName => _fleetUser.value?.panNumber ?? '';
  var suppliesDate = ''.obs;
  var tripId = 0.obs;
  var pdfUrl = "".obs;


  @override
  void onInit() {
    super.onInit();
    loadRouteDetails();
  }

  void changeTabIndex(int index) {
    _selectedIndex.value = index;
  }

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.day}-${now.month}-${now.year}";
  }

  Future<void> fetchActiveTrip() async {
    try {
      _isLoading.value = true;
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
      _isLoading.value = false;
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
      _isLoading.value = true;
      await apiService.startTrip(tripId.value);
      Get.offNamed(Routes.DELIVERY_ROUTE, arguments: tripId.value);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  void setKycStatus(bool aadhaarVerified, bool panVerified) {
    _isAadhaarKycVerified.value = aadhaarVerified;
    _isPanKycVerified.value = panVerified;
  }

  loadRouteDetails() async {
    try {
      _isLoading.value = true;
      final reportDetails = await apiService.getRouteDetails( );
       pdfUrl(reportDetails.mainRouteUrl.toString());
    } catch (e) {
      print('Error loading slots: $e');
    } finally {
      _isLoading.value = false;
    }
  }

}