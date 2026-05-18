import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../utils/location-utils.dart';
import '../../../../data/session_manager.dart';
import '../../../../models/fleet_user.dart';
import '../../../../models/booth_model.dart';
import '../../../../models/route_detail.dart';
import '../../../../api/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/global_cart_service.dart';
import '../../../delivery/controllers/delivery_controller.dart';

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
  var products = <dynamic>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;

  List<dynamic> get filteredProducts {
    return products.where((product) {
      final name = (product['product_name'] ?? '').toString().toLowerCase();
      final query = searchQuery.value.toLowerCase();
      final matchesSearch = name.contains(query);

      if (selectedCategory.value == 'All') {
        return matchesSearch;
      }

      bool matchesCategory = false;
      if (selectedCategory.value == 'Milk') {
        matchesCategory = name.contains('milk') ||
            name.contains('tm') ||
            name.contains('std') ||
            name.contains('fcm') ||
            name.contains('sgm');
      } else if (selectedCategory.value == 'Curd') {
        matchesCategory = name.contains('curd') || 
                         name.contains('bm jar') || 
                         name.contains('cup');
      } else {
        matchesCategory = name.contains(selectedCategory.value.toLowerCase());
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  final routeDetail = Rxn<RouteDetail>();

  late TabController tabController;
  late PageController pageController;

  final currentIndex = 0.obs;
  final isInitialLoading = true.obs;
  final isTripStarted = false.obs;

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

  Future<void> startDelivery() async {
    if (tripId.value == 0) {
      Get.snackbar("No Active Trip", "No trip assigned yet.");
      return;
    }

    try {
      _isLoading.value = true;

      final allowed = await LocationUtils.ensureLocationPermission();

      double lat = 0;
      double lng = 0;

      if (allowed) {
        LocationSettings locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
        );
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

        lat = position.latitude;
        lng = position.longitude;
      }

      try {
        await apiService.startTrip(tripId.value, lat, lng);
        
        // 1. Persist the trip ID
        final storage = GetStorage();
        storage.write('active_trip_id', tripId.value);
        
        // 2. Navigate to Delivery Route view and dispose Home
        Get.offNamed(Routes.DELIVERY_ROUTE, arguments: tripId.value);
      } catch (e) {
        if (e.toString().toLowerCase().contains("trip already started")) {
          debugPrint("Trip already started, continuing...");
        } else {
          rethrow;
        }
      }

      isTripStarted.value = true;
      // Initialize DeliveryController if not already registered
      if (!Get.isRegistered<DeliveryController>()) {
        Get.put(DeliveryController());
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadRouteDetails({bool silent = false}) async {
    try {
      if (!silent) _isLoading.value = true;

      final reportDetails = await apiService.getRouteDetails();
      routeDetail.value = reportDetails;

      final idToUse = reportDetails.tripId ?? reportDetails.id;
      if (idToUse != null) {
        tripId.value = idToUse;
        debugPrint("Loaded Trip ID: ${tripId.value}");
      }

      if (reportDetails.products != null) {
        products.value = List<dynamic>.from(reportDetails.products!);
      }

    } catch (e) {
      debugPrint('Error loading route details: $e');
    } finally {
      if (!silent) _isLoading.value = false;
      isInitialLoading.value = false;
    }
  }
}
