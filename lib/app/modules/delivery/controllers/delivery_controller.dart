import 'package:geolocator/geolocator.dart';
import '../../../data/session_manager.dart';
import '../../../utils/location-utils.dart';

import 'package:aavin/app/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/delivery_model.dart';
import '../../../routes/app_pages.dart';

enum AppMode {
  delivery,
  collection,
}

class DeliveryController extends GetxController {
  final ApiService api = Get.find<ApiService>();

  var deliveries = <DeliveryModel>[].obs;
  var isLoading = false.obs;
  var isTripCompleted = false.obs;
  var appMode = AppMode.delivery.obs;
  var currentCollectingIndex = 0.obs;
  var isSummaryLoading = false.obs;
  var summary = <String, dynamic>{}.obs;

  int tripId = 0;

  var name = "".obs;
  var vehicleNumber = "".obs;
  var isDialogShown = false.obs;
  final storage = GetStorage();
  var routeCode = "".obs;

  @override
  void onInit() {
    super.onInit();
    
    final storedMode = storage.read('app_mode');
    if (storedMode != null) {
      appMode.value = storedMode == 'collection' ? AppMode.collection : AppMode.delivery;
    }

    if (Get.arguments != null) {
      tripId = int.tryParse(Get.arguments.toString()) ?? 0;
      if (tripId != 0) {
        storage.write('active_trip_id', tripId);
      }
    } else {
      tripId = storage.read('active_trip_id') ?? storage.read('completed_trip_id') ?? 0;
    }

    if (tripId == 0) {
      isTripCompleted.value = true;
      isLoading.value = false;
      return; // Stop here if no trip is available
    }

    _loadUserInfo();

    final storedIndex = storage.read('collecting_index_$tripId');
    if (storedIndex != null) {
      currentCollectingIndex.value = storedIndex;
    }

    fetchRouteBooths();

    if (storage.read('completed_trip_$tripId') == true) {
      isTripCompleted.value = true;
      if (storage.read('dialog_shown_$tripId') != true) {
        Future.delayed(Duration.zero, () => showTripCompletedDialog());
      }
    }
  }

  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      storage.remove('delivered_booths_$tripId');
      storage.remove('collected_booths_$tripId');
      storage.remove('collecting_index_$tripId');
      await fetchRouteBooths();
      Get.snackbar("Sync Complete", "Route data updated from server", 
        snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar("Refresh Error", e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
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

  Future<void> fetchRouteBooths() async {
    try {
      isLoading.value = true;
      final data = (appMode.value == AppMode.delivery)
          ? await api.getTripBooths(tripId, "DELIVERY")
          : await api.getCollectionBooths(tripId);

      final initialBooths = data.map<DeliveryModel>((json) {
        return DeliveryModel.fromJson(json);
      }).toList();
      
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
          final isCollected = booth.apiIsCollected || localCollectedIds.contains(bId) ||
              (booth.totalTrays > 0 && booth.collectedTrays >= booth.totalTrays);
          initialBooths[i] = booth.copyWith(
            status: isCollected ? DeliveryStatus.collected : DeliveryStatus.toBeCollected,
          );
        }
      }

      bool hasInProgress = initialBooths.any((b) =>
        b.status == DeliveryStatus.delivering || b.status == DeliveryStatus.collecting,
      );

      if (!hasInProgress) {
        if (appMode.value == AppMode.delivery) {
          final firstPending = initialBooths.indexWhere((b) => b.status == DeliveryStatus.toBeDelivered);
          if (firstPending != -1) {
            initialBooths[firstPending] = initialBooths[firstPending].copyWith(status: DeliveryStatus.delivering);
          }
        } else {
          int nextToCollect = -1;
          for (int i = initialBooths.length - 1; i >= 0; i--) {
            if (initialBooths[i].status == DeliveryStatus.toBeCollected) {
              nextToCollect = i;
              break;
            }
          }
          if (nextToCollect != -1) {
            currentCollectingIndex.value = nextToCollect;
            initialBooths[nextToCollect] = initialBooths[nextToCollect].copyWith(status: DeliveryStatus.collecting);
          } else {
            currentCollectingIndex.value = -1;
          }
        }
      } else if (appMode.value == AppMode.collection) {
        currentCollectingIndex.value = initialBooths.indexWhere((b) => b.status == DeliveryStatus.collecting);
      }
      
      storage.write('collecting_index_$tripId', currentCollectingIndex.value);
      deliveries.assignAll(initialBooths);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markDelivered(DeliveryModel store) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      /// Hide keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      /// LOCATION
      final allowed = await LocationUtils.ensureLocationPermission();

      double lat = 0;
      double lng = 0;

      if (allowed) {
        Position? pos = await LocationUtils.getCurrentLocation();

        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
        }
      }

      /// API CALL
      try {
        await api.markDelivered(
          tripId,
          store.boothId,
          store.totalTrays,
          lat,
          lng,
        );

        _saveLocalStatus(
          store.boothId,
          'delivered_booths_$tripId',
        );
      } catch (e) {
        final errorStr = e.toString().toLowerCase();

        /// Already delivered case
        if (!errorStr.contains("already delivered") &&
            !errorStr.contains("already completed")) {
          rethrow;
        }

        _saveLocalStatus(
          store.boothId,
          'delivered_booths_$tripId',
        );
      }

      /// FIND CURRENT INDEX
      final currentIndex = _getIndexById(store.id);

      if (currentIndex == -1) {
        isLoading.value = false;
        return;
      }

      /// UPDATE CURRENT STORE
      final updatedStore = store.copyWith(
        status: DeliveryStatus.delivered,
      );

      deliveries[currentIndex] = updatedStore;

      /// UPDATE NEXT STORE STATUS
      if (currentIndex < deliveries.length - 1) {
        final next = deliveries[currentIndex + 1];

        if (next.status == DeliveryStatus.toBeDelivered ||
            next.status == DeliveryStatus.delivering) {
          deliveries[currentIndex + 1] = next.copyWith(
            status: DeliveryStatus.delivering,
          );
        }
      }

      /// FORCE REFRESH
      deliveries.refresh();

      /// FIND NEXT STORE
      final nextStore = getNextStore(updatedStore);

      /// CLOSE LOADER BEFORE NAVIGATION
      isLoading.value = false;

      /// REMOVE ALL SNACKBARS
      Get.closeAllSnackbars();

      /// SUCCESS MESSAGE
      Get.snackbar(
        "Success",
        "Booth ${store.number} delivered",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );

      /// SMALL DELAY FOR SMOOTH NAVIGATION
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      /// NAVIGATION
      if (nextStore != null) {
        /// REMOVE CURRENT SCREEN AND OPEN NEXT
        Get.offNamed(
          Routes.STORE_DETAILS,
          arguments: nextStore,
          preventDuplicates: false,
        );
      } else {
        /// NO MORE STORES
        if (Get.isOverlaysOpen ?? false) {
          Get.back(closeOverlays: true);
        }

        if (Get.currentRoute == Routes.STORE_DETAILS) {
          Get.back();
        }
      }
    } catch (e) {
      isLoading.value = false;

      Get.closeAllSnackbars();

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }
  void _saveLocalStatus(int boothId, String key) {
    List<dynamic> list = storage.read(key) ?? [];
    if (!list.contains(boothId)) {
      list.add(boothId);
      storage.write(key, list);
    }
  }

  Future<void> initiateCollection() async {
    try {
      isLoading.value = true;
      appMode.value = AppMode.collection;
      storage.write('app_mode', 'collection');
      await fetchRouteBooths();
    } catch (e) {
      Get.snackbar("Error", "Failed to start collection: $e", snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  void openStoreDetails(DeliveryModel store) {
    Get.toNamed(Routes.STORE_DETAILS, arguments: store);
  }

  void openMap(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void showCompletionDialog() {
    isDialogShown.value = true;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Confirm Submission", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("All collections completed. Submit now?"),
        actions: [
          TextButton(onPressed: () { isDialogShown.value = false; Get.back(); }, child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async { isDialogShown.value = false; Get.back(); await submitTrip(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
        Position? pos = await LocationUtils.getCurrentLocation();
        if (pos != null) { lat = pos.latitude; lng = pos.longitude; }
      }
      await api.endTrip(tripId, lat, lng);
      
      storage.write('completed_trip_$tripId', true);
      storage.write('completed_trip_id', tripId);
      storage.write('dialog_shown_$tripId', false);
      storage.remove('active_trip_id');
      
      isTripCompleted.value = true;
      isLoading.value = false;
      showTripCompletedDialog();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to end trip: $e", snackPosition: SnackPosition.TOP);
    }
  }

  void showTripCompletedDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Column(
            children: [
              Icon(Icons.verified_rounded, color: Colors.lightGreen, size: 60),
              SizedBox(height: 10),
              Text("Trip Completed", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Your trip has been successfully completed and submitted.",
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.offAllNamed(Routes.HOME); // Go to Home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "BACK TO HOME",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  int _getIndexById(String id) {
    return deliveries.indexWhere((s) => s.id == id);
  }

  Future<void> markCollected(
      DeliveryModel store,
      int trays,
      ) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      /// HIDE KEYBOARD
      FocusManager.instance.primaryFocus?.unfocus();

      /// LOCATION
      final allowed =
      await LocationUtils.ensureLocationPermission();

      double lat = 0;
      double lng = 0;

      if (allowed) {
        Position? pos =
        await LocationUtils.getCurrentLocation();

        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
        }
      }

      /// API CALL
      try {
        await api.markCollected(
          tripId,
          store.boothId,
          trays,
          lat,
          lng,
        );

        _saveLocalStatus(
          store.boothId,
          'collected_booths_$tripId',
        );
      } catch (e) {
        final errorStr = e.toString().toLowerCase();

        /// ALREADY COLLECTED CASE
        if (!errorStr.contains("already collected") &&
            !errorStr.contains("already completed")) {
          rethrow;
        }

        _saveLocalStatus(
          store.boothId,
          'collected_booths_$tripId',
        );
      }

      /// FIND CURRENT INDEX
      final currentIndex = _getIndexById(store.id);

      if (currentIndex == -1) {
        isLoading.value = false;
        return;
      }

      /// UPDATE CURRENT STORE
      final updatedStore = store.copyWith(
        collectedTrays: trays,
        status: DeliveryStatus.collected,
      );

      deliveries[currentIndex] = updatedStore;

      /// COLLECTION MODE LOGIC
      if (appMode.value == AppMode.collection) {
        int nextIndex = currentIndex - 1;

        while (nextIndex >= 0) {
          if (deliveries[nextIndex].status !=
              DeliveryStatus.collected) {
            deliveries[nextIndex] =
                deliveries[nextIndex].copyWith(
                  status: DeliveryStatus.collecting,
                );

            currentCollectingIndex.value =
                nextIndex;

            break;
          }

          nextIndex--;
        }

        if (nextIndex < 0) {
          currentCollectingIndex.value = -1;
        }

        storage.write(
          'collecting_index_$tripId',
          currentCollectingIndex.value,
        );
      }

      /// FORCE REFRESH
      deliveries.refresh();

      /// FIND NEXT STORE
      final nextStore = getNextStore(updatedStore);

      /// STOP LOADING BEFORE NAVIGATION
      isLoading.value = false;

      /// REMOVE OLD SNACKBARS
      Get.closeAllSnackbars();

      /// SUCCESS MESSAGE
      Get.snackbar(
        "Success",
        "Booth ${store.number} collected",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );

      /// SMALL DELAY
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      /// NAVIGATION
      if (nextStore != null) {
        /// OPEN NEXT STORE
        Get.offNamed(
          Routes.STORE_DETAILS,
          arguments: nextStore,
          preventDuplicates: false,
        );
      } else {
        /// CLOSE CURRENT SCREEN SAFELY
        if (Get.isOverlaysOpen ?? false) {
          Get.back(closeOverlays: true);
        }

        if (Get.currentRoute ==
            Routes.STORE_DETAILS) {
          Get.back();
        }

        /// SHOW COMPLETION DIALOG
        if (appMode.value ==
            AppMode.collection) {
          final allDone = deliveries.every(
                (d) =>
            d.status ==
                DeliveryStatus.collected ||
                d.apiIsCollected,
          );

          if (allDone) {
            Future.delayed(
              const Duration(milliseconds: 400),
                  () {
                showCompletionDialog();
              },
            );
          }
        }
      }
    } catch (e) {
      isLoading.value = false;

      Get.closeAllSnackbars();

      Get.snackbar(
        "Error",
        "Collection failed: $e",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }
  DeliveryModel? getNextStore(DeliveryModel currentStore) {
    try {
      final index = _getIndexById(currentStore.id);
      if (index == -1 || deliveries.isEmpty) return null;

      if (appMode.value == AppMode.delivery) {
        for (int i = index + 1; i < deliveries.length; i++) {
          if (deliveries[i].status != DeliveryStatus.delivered) return deliveries[i];
        }
      } else {
        for (int i = index - 1; i >= 0; i--) {
          if (deliveries[i].status != DeliveryStatus.collected) return deliveries[i];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
