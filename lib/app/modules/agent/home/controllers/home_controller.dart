import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../utils/location-utils.dart';
import '../../../../data/session_manager.dart';
import 'package:aavin/app/models/app_mode.dart';
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
  final storage = GetStorage();

  final _isLoading = false.obs;
  final _boothDetails = Rxn<Society>();
  final _fleetUser = Rxn<FleetUser>();

  bool get isLoading => _isLoading.value;
  Society? get boothDetails => _boothDetails.value;
  FleetUser? get fleetUser => _fleetUser.value;

  var suppliesDate = ''.obs;
  var tripId = 0.obs;
  var products = <dynamic>[].obs;
  final routeDetail = Rxn<RouteDetail>();

  late TabController tabController;
  late PageController pageController;

  final currentIndex = 0.obs;
  final isInitialLoading = true.obs;
  final currentAppMode = AppMode.home.obs;

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

    // Recover AppMode from storage and Redirect if active trip
    final storedMode = storage.read('app_mode');
    if (storedMode != null && (storedMode == 'delivery' || storedMode == 'collection')) {
      Future.delayed(Duration.zero, () {
        Get.offNamed(Routes.DELIVERY_ROUTE);
      });
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
      } catch (e) {
        if (e.toString().toLowerCase().contains("trip already started")) {
          debugPrint("Trip already started, continuing...");
        } else {
          rethrow;
        }
      }

      currentAppMode.value = AppMode.delivery;
      storage.write('app_mode', 'delivery');
      storage.write('active_trip_id', tripId.value);
      
      // Navigate to Delivery Route and remove Home from stack
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
