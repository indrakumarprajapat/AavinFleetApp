import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/session_manager.dart';
import '../../../../models/fleet_user.dart';
import '../../../../models/booth_model.dart';
import '../../../../api/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/global_cart_service.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  final apiService = Get.find<ApiService>();
  final globalCartService = Get.find<GlobalCartService>();
  
  final _isLoading = false.obs;
  final _boothDetails = Rxn<Society>();
  final _fleetUser = Rxn<FleetUser>();
  
  bool get isLoading => _isLoading.value;
  Society? get boothDetails => _boothDetails.value;
  FleetUser? get fleetUser => _fleetUser.value;
  
  var suppliesDate = ''.obs;
  var tripId = 0.obs;
  var pdfUrl = "".obs;
  var products = <dynamic>[].obs;

  late TabController tabController;
  late PageController pageController;

  final currentIndex = 0.obs;
  final isInitialLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    tabController = TabController(length: 4, vsync: this);
    pageController = PageController();

    final session = Get.find<SessionManager>();
    session.loadSession(); 
    
    if (session.fleetUser.value != null) {
      setFleetUser(session.fleetUser.value);
    }

    loadRouteDetails();
    _addSampleData(); 
  }

  void _addSampleData() {
    if (_fleetUser.value == null) {
      _fleetUser.value = FleetUser(
        name: "Test Agent",
        routeName: "R-102 (Sample Route)",
        vehicleRegistrationNumber: "TN-37-CZ-1234",
      );
    }

    if (products.isEmpty) {
      products.value = [
        {
          'product_name': 'Standardized Milk (500ml)',
          'pkt_qty': 120,
          'litre': 60,
          'total_tray': 10,
          'pkt_plus': 2,
          'pkt_minus': 0,
          'leakes': 1,
        },
        {
          'product_name': 'Toned Milk (500ml)',
          'pkt_qty': 84,
          'litre': 42,
          'total_tray': 7,
          'pkt_plus': 0,
          'pkt_minus': 1,
          'leakes': 0,
        },
      ];
    }
  }

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args != null && args['tab'] != null) {
      final tabIndex = args['tab'] as int;
      currentIndex.value = tabIndex;
      pageController.animateToPage(
        tabIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    tabController.dispose();
    pageController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadRouteDetails(silent: true);
    }
  }

  void setFleetUser(FleetUser? user) {
    _fleetUser.value = user;
  }

  Future<void> fetchActiveTrip() async {
    try {
      _isLoading.value = true;
      final response = await apiService.getTrip(tripId: 0);
      final data = response['data'] ?? response;

      if (data != null && data['id'] != null) {
        tripId.value = int.tryParse(data['id'].toString()) ?? 0;
        await fetchTripSummary();
      }
    } catch (e) {
      debugPrint("Error fetching active trip: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchTripSummary() async {
    if (tripId.value == 0) return;
    try {
      final summary = await apiService.getTripSummary(tripId.value);
      final data = summary['data'] ?? summary;
      if (data != null && data['products'] != null) {
        products.value = data['products'] as List;
      } else if (data is List) {
        products.value = data;
      }
    } catch (e) {
      debugPrint("Error fetching trip summary: $e");
    }
  }

  void openPdf() {
    if (tripId.value == 0) {
      Get.snackbar("No Active Trip", "Please wait until a trip is assigned.");
      return;
    }
    Get.toNamed(Routes.PDF, arguments: tripId.value);
  }

  Future<void> startDelivery() async {
    if (tripId.value == 0) {
      Get.snackbar("No Active Trip", "No trip assigned yet.");
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

  Future<void> loadRouteDetails({bool silent = false}) async {
    try {
      if (!silent) _isLoading.value = true;
      await fetchActiveTrip();
      final reportDetails = await apiService.getRouteDetails();
      pdfUrl(reportDetails.mainRouteUrl.toString());
      
      if (products.isEmpty) {
        _addSampleData();
      }
    } catch (e) {
      debugPrint('Error loading route details: $e');
      if (products.isEmpty) _addSampleData();
    } finally {
      if (!silent) _isLoading.value = false;
      isInitialLoading.value = false;
    }
  }
}
