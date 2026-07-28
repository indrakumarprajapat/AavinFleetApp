import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../utils/location-utils.dart';
import '../../../../data/session_manager.dart';
import '../../../../models/fleet_user.dart';
import '../../../../models/booth_model.dart';
import '../../../../models/route_detail.dart';
import '../../../../models/collection_trip.dart';
import '../../../../api/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/global_cart_service.dart';
import '../../../../constants/app_enums.dart';
import '../../../../utils/app_snackbar.dart';
import '../../../delivery/controllers/delivery_controller.dart';
import '../../../collection/controllers/collection_route_controller.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  final apiService = Get.find<ApiService>();
  final globalCartService = Get.find<GlobalCartService>();

  final _isLoading = false.obs;
  final _boothDetails = Rxn<Society>();
  final _fleetUser = Rxn<FleetUser>();

  bool get isLoading => _isLoading.value;
  Society? get boothDetails => _boothDetails.value;
  FleetUser? get fleetUser => _fleetUser.value;

  bool get isCollectionFleet => fleetUser?.isCollectionFleet == true;

  var suppliesDate = ''.obs;
  var tripId = 0.obs;
  var products = <dynamic>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;

  final collectionTrip = Rxn<CollectionTrip>();

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
        matchesCategory =
            name.contains(selectedCategory.value.toLowerCase());
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

  String get startButtonLabel {
    if (tripId.value == 0) return 'NO TRIP ASSIGNED';
    if (isCollectionFleet) {
      return fleetUser?.isMtr == true
          ? 'START MTR TRIP'
          : 'START MCR TRIP';
    }
    return 'START DELIVERY';
  }

  Future<void> startDelivery() async {
    if (isCollectionFleet) {
      await startCollectionTrip();
      return;
    }

    if (tripId.value == 0 || _isLoading.value) {
      if (tripId.value == 0) {
        AppSnackbar.warning("No Active Trip", "No trip assigned yet.");
      }
      return;
    }

    try {
      _isLoading.value = true;

      final allowed = await LocationUtils.ensureLocationPermission();

      double lat = 0;
      double lng = 0;

      if (allowed) {
        Position? position = await LocationUtils.getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      }

      try {
        await apiService.startTrip(tripId.value, lat, lng);

        final storage = GetStorage();
        storage.write('active_trip_id', tripId.value);
        storage.write('active_trip_kind', 'distribution');

        if (Get.isRegistered<DeliveryController>()) {
          Get.delete<DeliveryController>();
        }

        Get.offNamed(Routes.DELIVERY_ROUTE, arguments: tripId.value);
      } catch (e) {
        if (e.toString().toLowerCase().contains("trip already started")) {
          debugPrint("Trip already started, continuing...");
          final storage = GetStorage();
          storage.write('active_trip_id', tripId.value);
          storage.write('active_trip_kind', 'distribution');
          Get.offNamed(Routes.DELIVERY_ROUTE, arguments: tripId.value);
        } else {
          rethrow;
        }
      }

      isTripStarted.value = true;
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startCollectionTrip() async {
    if (tripId.value == 0 || _isLoading.value) {
      if (tripId.value == 0) {
        AppSnackbar.warning("No Active Trip", "No collection trip for today.");
      }
      return;
    }

    try {
      _isLoading.value = true;
      final allowed = await LocationUtils.ensureLocationPermission();
      double lat = 0;
      double lng = 0;
      if (allowed) {
        final position = await LocationUtils.getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      }

      try {
        await apiService.startCollectionTrip(tripId.value, lat, lng);
      } catch (e) {
        if (!e.toString().toLowerCase().contains('already started')) {
          rethrow;
        }
      }

      final storage = GetStorage();
      storage.write('active_trip_id', tripId.value);
      storage.write('active_trip_kind', 'collection');

      if (Get.isRegistered<CollectionRouteController>()) {
        Get.delete<CollectionRouteController>();
      }

      Get.offNamed(Routes.COLLECTION_ROUTE, arguments: tripId.value);
    } catch (e) {
      AppSnackbar.error("Could not start trip", e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadRouteDetails({bool silent = false}) async {
    try {
      if (!silent) _isLoading.value = true;

      if (isCollectionFleet) {
        await _loadCollectionTrip();
      } else {
        await _loadDistributionTrip();
      }
    } catch (e) {
      debugPrint('Error loading route details: $e');
    } finally {
      if (!silent) _isLoading.value = false;
      isInitialLoading.value = false;
    }
  }

  Future<void> _loadDistributionTrip() async {
    final reportDetails = await apiService.getRouteDetails();
    routeDetail(reportDetails);
    collectionTrip.value = null;

    final idToUse = reportDetails.tripId ?? reportDetails.id;
    if (idToUse != null) {
      tripId.value = idToUse;
      final storage = GetStorage();
      if (storage.read('completed_trip_$idToUse') == true) {
        tripId.value = 0;
        products.clear();
        return;
      }
    }

    if (reportDetails.products != null) {
      products.value = List<dynamic>.from(reportDetails.products!);
    }
  }

  Future<void> _loadCollectionTrip() async {
    products.clear();
    routeDetail.value = null;
    final trip = await apiService.getTodayCollectionTrip();
    collectionTrip.value = trip;

    if (trip?.id == null) {
      tripId.value = 0;
      return;
    }

    final storage = GetStorage();
    if (storage.read('completed_trip_${trip!.id}') == true) {
      tripId.value = 0;
      return;
    }

    // Resume mid-trip statuses
    if (trip.status == CollectionFleetTripStatus.started ||
        trip.status == CollectionFleetTripStatus.inProgress ||
        trip.status == CollectionFleetTripStatus.collectionDone ||
        trip.status == CollectionFleetTripStatus.submitted) {
      tripId.value = trip.id!;
      storage.write('active_trip_id', trip.id);
      storage.write('active_trip_kind', 'collection');
    } else if (trip.status == CollectionFleetTripStatus.completed ||
        trip.status == CollectionFleetTripStatus.cancelled) {
      tripId.value = 0;
    } else {
      tripId.value = trip.id!;
    }
  }
}
