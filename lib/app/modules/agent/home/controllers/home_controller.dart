// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import '../../../../utils/location-utils.dart';
// import '../../../../data/session_manager.dart';
// import '../../../../models/fleet_user.dart';
// import '../../../../models/booth_model.dart';
// import '../../../../api/api_service.dart';
// import '../../../../routes/app_pages.dart';
// import '../../../../services/global_cart_service.dart';
//
// class HomeController extends GetxController with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
//   final apiService = Get.find<ApiService>();
//   final globalCartService = Get.find<GlobalCartService>();
//
//   final _isLoading = false.obs;
//   final _boothDetails = Rxn<Society>();
//   final _fleetUser = Rxn<FleetUser>();
//
//   bool get isLoading => _isLoading.value;
//   Society? get boothDetails => _boothDetails.value;
//   FleetUser? get fleetUser => _fleetUser.value;
//
//   var suppliesDate = ''.obs;
//   var tripId = 0.obs;
//   var pdfUrl = "".obs;
//   var products = <dynamic>[].obs;
//
//   late TabController tabController;
//   late PageController pageController;
//
//   final currentIndex = 0.obs;
//   final isInitialLoading = true.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addObserver(this);
//
//     tabController = TabController(length: 4, vsync: this);
//     pageController = PageController();
//
//     final session = Get.find<SessionManager>();
//     session.loadSession();
//
//     if (session.fleetUser.value != null) {
//       setFleetUser(session.fleetUser.value);
//     }
//
//     loadRouteDetails();
//   }
//
//   @override
//   void onReady() {
//     super.onReady();
//     final args = Get.arguments;
//     if (args != null && args['tab'] != null) {
//       final tabIndex = args['tab'] as int;
//       currentIndex.value = tabIndex;
//       pageController.animateToPage(
//         tabIndex,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.ease,
//       );
//     }
//   }
//
//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     tabController.dispose();
//     pageController.dispose();
//     super.onClose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       loadRouteDetails(silent: true);
//     }
//   }
//
//   void setFleetUser(FleetUser? user) {
//     _fleetUser.value = user;
//   }
//
//   // Future<void> fetchActiveTrip() async {
//   //   try {
//   //     _isLoading.value = true;
//   //     final response = await apiService.getTrip(tripId: 0);
//   //
//   //     dynamic data;
//   //     if (response is Map) {
//   //       data = response['data'] ?? response;
//   //     } else {
//   //       data = response;
//   //     }
//   //
//   //     if (data != null && data is Map && data['id'] != null) {
//   //       tripId.value = int.tryParse(data['id'].toString()) ?? 0;
//   //       await fetchTripSummary();
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Error fetching active trip: $e");
//   //   } finally {
//   //     _isLoading.value = false;
//   //   }
//   // }
//
//   // Future<void> fetchTripSummary() async {
//   //   if (tripId.value == 0) return;
//   //   try {
//   //     final summary = await apiService.getTripSummary(tripId.value);
//   //     final data = summary['data'] ?? summary;
//   //     if (data != null && data['products'] != null) {
//   //       products.value = data['products'] as List;
//   //     } else if (data is List) {
//   //       products.value = data;
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Error fetching trip summary: $e");
//   //   }
//   // }
//
//   void openPdf() {
//     if (tripId.value == 0) {
//       Get.snackbar("No Active Trip", "Please wait until a trip is assigned.");
//       return;
//     }
//     Get.toNamed(Routes.PDF, arguments: tripId.value);
//   }
//
//   Future<void> startDelivery() async {
//     if (tripId.value == 0) {
//       Get.snackbar("No Active Trip", "No trip assigned yet.");
//       return;
//     }
//     try {
//       _isLoading.value = true;
//
//       final allowed = await LocationUtils.ensureLocationPermission();
//       double lat = 0, lng = 0;
//       if (allowed) {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         lat = position.latitude;
//         lng = position.longitude;
//       }
//
//       await apiService.startTrip(tripId.value, lat, lng);
//       Get.offNamed(Routes.DELIVERY_ROUTE, arguments: tripId.value);
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> loadRouteDetails({bool silent = false}) async {
//     try {
//       if (!silent) _isLoading.value = true;
//
//       final reportDetails = await apiService.getRouteDetails();
//       tripId.value = 5;
//       debugPrint("Active Trip ID (TEMP): ${tripId.value}");
//       pdfUrl(reportDetails.mainRouteUrl.toString());
//
//       if (reportDetails.products != null && reportDetails.products!.isNotEmpty) {
//         products.value = reportDetails.products!;
//       }
//
//       // 3. Optional: Fetch summary if tripId was found
//       if (tripId.value != 0) {
//         // await fetchTripSummary();
//       }
//
//     } catch (e) {
//       debugPrint('Error loading route details: $e');
//     } finally {
//       if (!silent) _isLoading.value = false;
//       isInitialLoading.value = false;
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../utils/location-utils.dart';
import '../../../../data/session_manager.dart';
import '../../../../models/fleet_user.dart';
import '../../../../models/booth_model.dart';
import '../../../../api/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/global_cart_service.dart';

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

  // ✅ OPEN PDF
  void openPdf() {
    if (tripId.value == 0) {
      Get.snackbar("No Active Trip", "Please wait until a trip is assigned.");
      return;
    }
    Get.toNamed(Routes.PDF, arguments: tripId.value);
  }

  // ✅ START DELIVERY (ALWAYS NAVIGATES)
  Future<void> startDelivery() async {
    if (tripId.value == 0) {
      Get.snackbar("No Active Trip", "No trip assigned yet.");
      return;
    }

    try {
      _isLoading.value = true;

      final allowed = await LocationUtils.ensureLocationPermission();

      double lat = 0, lng = 0;

      if (allowed) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      }

      try {
        await apiService.startTrip(tripId.value, lat, lng);
      } catch (e) {
        final error = e.toString();

        // ✅ Ignore safe errors
        if (error.contains("Trip already started")) {
          debugPrint("Trip already started, continuing...");
        } else {
          debugPrint("startTrip error ignored: $error");
        }
      }

    } catch (e) {
      debugPrint("Unexpected error: $e");
    } finally {
      _isLoading.value = false;
    }

    // ✅ ALWAYS NAVIGATE
    Get.offNamed(Routes.DELIVERY_ROUTE, arguments: tripId.value);
  }

  // ✅ LOAD ROUTE DETAILS (TEMP FIX APPLIED)
  Future<void> loadRouteDetails({bool silent = false}) async {
    try {
      if (!silent) _isLoading.value = true;

      final reportDetails = await apiService.getRouteDetails();

      // 🔥 TEMP FIX (remove later)
      tripId.value = 5;
      debugPrint("Active Trip ID (TEMP): ${tripId.value}");

      pdfUrl(reportDetails.mainRouteUrl.toString());

      if (reportDetails.products != null &&
          reportDetails.products!.isNotEmpty) {
        products.value = reportDetails.products!;
      }

    } catch (e) {
      debugPrint('Error loading route details: $e');
    } finally {
      if (!silent) _isLoading.value = false;
      isInitialLoading.value = false;
    }
  }
}