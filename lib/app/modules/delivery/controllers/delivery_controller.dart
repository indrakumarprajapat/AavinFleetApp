import 'package:geolocator/geolocator.dart';
import '../../../data/session_manager.dart';
import '../../../utils/location-utils.dart';

import 'package:aavin/app/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import 'package:aavin/app/models/delivery_model.dart';
import 'package:aavin/app/models/app_mode.dart';
import 'package:aavin/app/modules/agent/home/controllers/home_controller.dart';
import 'package:aavin/app/routes/app_pages.dart';


class DeliveryController extends GetxController {
  final ApiService api = Get.find<ApiService>();

  var deliveries = <DeliveryModel>[].obs;
  var isLoading = false.obs;
  var appMode = AppMode.delivery.obs;
  var currentCollectingIndex = 0.obs;
  var isSummaryLoading = false.obs;
  var summary = <String, dynamic>{}.obs;

  int tripId = 1;

  var name = "".obs;
  var vehicleNumber = "".obs;
  var isDialogShown = false.obs;
  final storage = GetStorage();
  var routeCode = "".obs;


  @override
  void onInit() {
    super.onInit();
    
    // 1. Recover Trip Mode & Phase
    final storedMode = storage.read('app_mode');
    final storedPhase = storage.read('trip_phase');

    if (storedMode == 'collection' || storedPhase == 'collection') {
      appMode.value = AppMode.collection;
    } else {
      appMode.value = AppMode.delivery;
    }

    // 2. Recover Trip ID (from arguments or storage)
    if (Get.arguments != null && Get.arguments is int) {
      tripId = Get.arguments;
    } else if (Get.arguments != null) {
      tripId = int.tryParse(Get.arguments.toString()) ?? 0;
    } else {
      tripId = storage.read('active_trip_id') ?? 0;
    }

    if (tripId != 0) {
      storage.write('active_trip_id', tripId);
      debugPrint("DeliveryController: Active Trip ID = $tripId");
    }

    // 3. Recover User Info
    _loadUserInfo();

    // 4. Recover Collection Index
    final storedIndex = storage.read('collecting_index_$tripId');
    if (storedIndex != null) {
      currentCollectingIndex.value = storedIndex;
    }

    // 5. Load Data
    fetchRouteBooths();
  }

  void _loadUserInfo() {
    try {
      final session = Get.find<SessionManager>();
      final user = session.fleetUser.value;

      if (user != null) {
        name.value = user.operatorName ?? "Operator";
        vehicleNumber.value = user.vehicleRegistrationNumber ?? "";
      }
    } catch (e) {
      debugPrint("Error loading user info: $e");
    }
  }

  //FETCH BOOTHS
  Future<void> fetchRouteBooths({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      final data = (appMode.value == AppMode.delivery)
          ? await api.getTripBooths(tripId, "DELIVERY")
          : await api.getCollectionBooths(tripId);

      List<DeliveryModel> initialBooths = data.map<DeliveryModel>((json) {
        return DeliveryModel.fromJson(json);
      }).toList();
      
      // 1. Initialize statuses based on API and Local Storage
      final List<dynamic> rawDelivered = storage.read('delivered_booths_$tripId') ?? [];
      final Set<String> localDeliveredIds = rawDelivered.map((e) => e.toString()).toSet();
      final List<dynamic> rawCollected = storage.read('collected_booths_$tripId') ?? [];
      final Set<String> localCollectedIds = rawCollected.map((e) => e.toString()).toSet();

      for (int i = 0; i < initialBooths.length; i++) {
        final booth = initialBooths[i];
        final bId = booth.boothId.toString();

        if (appMode.value == AppMode.delivery) {
          final isDelivered = booth.apiIsDelivered || localDeliveredIds.contains(bId);

          initialBooths[i] = booth.copyWith(
            status: isDelivered ? DeliveryStatus.delivered : DeliveryStatus.toBeDelivered,
          );
        } else {
          final isCollected = booth.apiIsCollected || localCollectedIds.contains(bId);

          initialBooths[i] = booth.copyWith(
            status: isCollected ? DeliveryStatus.collected : DeliveryStatus.toBeCollected,
          );
        }
      }

      // 1.5 Reverse for collection mode
      if (appMode.value == AppMode.collection) {
        initialBooths = initialBooths.reversed.toList();
      }

      // 2. RESUME LOGIC: Auto-highlight the next available booth (IN_PROGRESS)
      bool hasInProgress = initialBooths.any(
            (b) =>
        b.status == DeliveryStatus.delivering ||
            b.status == DeliveryStatus.collecting,
      );
      if (!hasInProgress) {
        if (appMode.value == AppMode.delivery) {

          final firstPending = initialBooths.indexWhere(
                (b) => b.status == DeliveryStatus.toBeDelivered,
          );

          if (firstPending != -1) {
             initialBooths[firstPending] = initialBooths[firstPending].copyWith(
                status: DeliveryStatus.delivering
             );
          }
        } else {
           // Since it's reversed, we find the first TO BE COLLECTED
           final firstPending = initialBooths.indexWhere(
                 (b) => b.status == DeliveryStatus.toBeCollected,
           );

           if (firstPending != -1) {
             initialBooths[firstPending] = initialBooths[firstPending].copyWith(
                 status: DeliveryStatus.collecting
             );
             currentCollectingIndex.value = firstPending;
           }
        }
      }

      deliveries.value = initialBooths;

    } catch (e) {
      debugPrint("Error fetching booths: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void openStoreDetails(DeliveryModel store) {
    Get.toNamed(Routes.STORE_DETAILS, arguments: store);
  }

  void openMap(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$encoded",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not launch Maps");
    }
  }

  int _getIndexById(String id) {
    return deliveries.indexWhere((s) => s.id == id);
  }

  Future<void> markDelivered(DeliveryModel store) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final allowed = await LocationUtils.ensureLocationPermission();
      double lat = 0, lng = 0;
      if (allowed) {
        Position? position = await LocationUtils.getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      }

      await api.markDelivered(tripId, store.boothId, store.totalTrays, lat, lng);

      final index = _getIndexById(store.id);
      if (index != -1) {
        deliveries[index] = store.copyWith(status: DeliveryStatus.delivered);
        
        // Persist delivered status
        final List<dynamic> delivered = storage.read('delivered_booths_$tripId') ?? [];
        if (!delivered.contains(store.id)) {
          delivered.add(store.id);
          storage.write('delivered_booths_$tripId', delivered);
        }

        // Highlight next one
        if (index + 1 < deliveries.length) {
          for (int i = index + 1; i < deliveries.length; i++) {
            if (deliveries[i].status == DeliveryStatus.toBeDelivered) {
              deliveries[i] = deliveries[i].copyWith(status: DeliveryStatus.delivering);
              break;
            }
          }
        }
      }

      final nextStore = getNextStore(deliveries[index]);
      
      // Perform navigation first
      if (nextStore != null) {
        Get.offNamed(Routes.STORE_DETAILS, arguments: nextStore, preventDuplicates: false);
      } else {
        Get.back(); // Go back to the list
        fetchRouteBooths(silent: true); // Refresh list
      }

      // Show notification after navigation
      Get.snackbar(
        "Success", 
        "Booth ${store.number} delivered",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to mark delivered: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markCollected(DeliveryModel store, int trays) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final allowed = await LocationUtils.ensureLocationPermission();
      double lat = 0, lng = 0;
      if (allowed) {
        Position? position = await LocationUtils.getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      }

      try {
        await api.markCollected(tripId, store.boothId, trays, lat, lng);
        
        // SAVE PERSISTENCE
        List<dynamic> collected = storage.read('collected_booths_$tripId') ?? [];
        if (!collected.contains(store.boothId.toString())) {
          collected.add(store.boothId.toString());
          storage.write('collected_booths_$tripId', collected);
        }
      } catch (e) {
        final errorStr = e.toString().toLowerCase();
        if (!errorStr.contains("already collected") && 
            !errorStr.contains("already delivered") && 
            !errorStr.contains("already completed")) {
          rethrow;
        }
        
        // Even if already collected on server, we should update local state to allow navigation
        List<dynamic> collected = storage.read('collected_booths_$tripId') ?? [];
        if (!collected.contains(store.boothId.toString())) {
          collected.add(store.boothId.toString());
          storage.write('collected_booths_$tripId', collected);
        }
      }

      final index = _getIndexById(store.id);
      if (index == -1) return;

      final updatedStore = store.copyWith(
        collectedTrays: trays,
        status: DeliveryStatus.collected,
      );

      deliveries[index] = updatedStore;

      if (appMode.value == AppMode.collection) {
        int nextIndex = index + 1;
        while (nextIndex < deliveries.length) {
          if (deliveries[nextIndex].status != DeliveryStatus.collected) {
            deliveries[nextIndex] =
                deliveries[nextIndex].copyWith(
                  status: DeliveryStatus.collecting,
                );
            currentCollectingIndex.value = nextIndex;
            break;
          }
          nextIndex++;
        }

        if (nextIndex >= deliveries.length) {
          currentCollectingIndex.value = -1;
        }

        storage.write(
          'collecting_index_$tripId',
          currentCollectingIndex.value,
        );
      }

      final nextStore = getNextStore(updatedStore);

      // Perform navigation first
      if (nextStore != null) {
        Get.offNamed(
          Routes.STORE_DETAILS,
          arguments: nextStore,
          preventDuplicates: false,
        );
      } else {
        Get.back(); // Go back to list
        fetchRouteBooths(silent: true); // Refresh list
        if (appMode.value == AppMode.collection) {
          showCompletionDialog();
        }
      }

      // Show notification after navigation
      Get.snackbar(
        "Success", 
        "Booth ${store.number} collected",
        snackPosition: SnackPosition.TOP,

      );

      FocusManager.instance.primaryFocus?.unfocus();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Collection failed: $e");
    }
  }

  DeliveryModel? getNextStore(DeliveryModel currentStore) {
    final index = _getIndexById(currentStore.id);
    if (index == -1 || deliveries.isEmpty) return null;

    for (int i = index + 1; i < deliveries.length; i++) {
      if (appMode.value == AppMode.delivery) {
        if (deliveries[i].status != DeliveryStatus.delivered) {
          return deliveries[i];
        }
      } else {
        if (deliveries[i].status != DeliveryStatus.collected) {
          return deliveries[i];
        }
      }
    }
    return null;
  }

  Future<void> initiateCollection() async {
    try {
      isLoading.value = true;
      appMode.value = AppMode.collection;

      try {
        Get.find<HomeController>().currentAppMode.value = AppMode.collection;
      } catch (e) {}

      storage.write('app_mode', 'collection');
      storage.write('trip_phase', 'collection');

      await fetchRouteBooths();

      if (deliveries.isNotEmpty) {
        final firstToCollect = deliveries.firstWhere(
          (b) =>
              b.status == DeliveryStatus.collecting ||
              b.status == DeliveryStatus.toBeCollected,
          orElse: () => deliveries.first,
        );
        openStoreDetails(firstToCollect);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to start collection: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void showCompletionDialog() {
    isDialogShown.value = true;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Confirm Submission",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("All collections completed. Submit now?"),
        actions: [
          ElevatedButton(
            onPressed: () {
              isDialogShown.value = false;
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBBDEFB),
              foregroundColor: const Color(0xFF007EA7),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: const Color(0xFF007EA7).withValues(alpha: 0.4), width: 1),
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              isDialogShown.value = false;
              Get.back();
              await submitTrip();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007EA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Submit Trip"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> submitTrip() async {
    try {
      isLoading.value = true;
      final allowed = await LocationUtils.ensureLocationPermission();
      double lat = 0, lng = 0;
      if (allowed) {
        Position? position = await LocationUtils.getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      }
      await api.endTrip(tripId, lat, lng);
      
      storage.remove('active_trip_id');
      storage.remove('app_mode');
      storage.remove('trip_phase');
      storage.remove('delivered_booths_$tripId');
      storage.remove('collected_booths_$tripId');
      storage.remove('collecting_index_$tripId');

      try {
        final homeController = Get.find<HomeController>();
        homeController.currentAppMode.value = AppMode.home;
        homeController.tripId.value = 0;
        homeController.loadRouteDetails(silent: true);
        Get.offAllNamed(Routes.HOME);
      } catch (e) {
        Get.offAllNamed(Routes.HOME);
      }
      
      Get.snackbar("Success", "Trip completed successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to end trip: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
