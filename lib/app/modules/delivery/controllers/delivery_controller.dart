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
    
    // 1. Recover Trip Mode
    final storedMode = storage.read('app_mode');
    if (storedMode != null) {
      appMode.value = storedMode == 'collection' ? AppMode.collection : AppMode.delivery;
    }

    // 2. Recover Trip ID (from arguments or storage)
    if (Get.arguments != null) {
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
  Future<void> fetchRouteBooths() async {
    try {
      isLoading.value = true;
      final data = (appMode.value == AppMode.delivery)
          ? await api.getTripBooths(tripId, "DELIVERY")
          : await api.getCollectionBooths(tripId);

      final initialBooths = data.map<DeliveryModel>((json) {
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

          final isDelivered =
              booth.apiIsDelivered ||
                  localDeliveredIds.contains(bId);

          initialBooths[i] = booth.copyWith(
            status: isDelivered
                ? DeliveryStatus.delivered
                : DeliveryStatus.toBeDelivered,
          );

        } else {

          final isCollected =
              booth.apiIsCollected ||
                  localCollectedIds.contains(bId) ||
                  (booth.totalTrays > 0 && booth.collectedTrays >= booth.totalTrays);

          initialBooths[i] = booth.copyWith(
            status: isCollected
                ? DeliveryStatus.collected
                : DeliveryStatus.toBeCollected,
          );
        }
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
            initialBooths[firstPending] =
                initialBooths[firstPending].copyWith(
                  status: DeliveryStatus.delivering,
                );
          }

        } else {

          int nextToCollect = -1;

          for (int i = initialBooths.length - 1; i >= 0; i--) {

            if (initialBooths[i].status ==
                DeliveryStatus.toBeCollected) {

              nextToCollect = i;
              break;
            }
          }

          if (nextToCollect != -1) {

            currentCollectingIndex.value = nextToCollect;

            initialBooths[nextToCollect] =
                initialBooths[nextToCollect].copyWith(
                  status: DeliveryStatus.collecting,
                );

          } else {

            currentCollectingIndex.value = -1;
          }
        }
      } else if (appMode.value == AppMode.collection) {
        currentCollectingIndex.value =
            initialBooths.indexWhere(
                  (b) => b.status == DeliveryStatus.collecting,
            );
      }
      
      storage.write('collecting_index_$tripId', currentCollectingIndex.value);
      deliveries.assignAll(initialBooths);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  //START TRIP
  Future<void> markDelivered(DeliveryModel store) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

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
        await api.markDelivered(
          tripId,
          store.boothId,
          lat,
          lng,
        );

        /// SAVE LOCAL
        List<dynamic> delivered =
            storage.read('delivered_booths_$tripId') ?? [];

        if (!delivered.contains(store.boothId)) {
          delivered.add(store.boothId);

          storage.write(
            'delivered_booths_$tripId',
            delivered,
          );
        }
      } catch (e) {
        final errorStr = e.toString().toLowerCase();

        if (!errorStr.contains("already delivered") &&
            !errorStr.contains("already completed")) {
          rethrow;
        }

        /// SAVE EVEN IF ALREADY DELIVERED
        List<dynamic> delivered =
            storage.read('delivered_booths_$tripId') ?? [];

        if (!delivered.contains(store.boothId)) {
          delivered.add(store.boothId);

          storage.write(
            'delivered_booths_$tripId',
            delivered,
          );
        }
      }

      /// UPDATE CURRENT STORE STATUS
      final index = _getIndexById(store.id);

      if (index == -1) return;

      final updatedStore = store.copyWith(
        status: DeliveryStatus.delivered,
      );

      deliveries[index] = updatedStore;

      /// MOVE NEXT DELIVERY TO IN PROGRESS
      if (index < deliveries.length - 1) {
        final next = deliveries[index + 1];

        if (next.status == DeliveryStatus.toBeDelivered ||
            next.status == DeliveryStatus.delivering) {
          deliveries[index + 1] = next.copyWith(
            status: DeliveryStatus.delivering,
          );
        }
      }

      Get.snackbar(
        "Success",
        "Booth ${store.number} delivered",
        snackPosition: SnackPosition.TOP,
      );

      final nextStore = getNextStore(updatedStore);

      Future.delayed(
        const Duration(milliseconds: 300),
            () async {
          FocusManager.instance.primaryFocus?.unfocus();

          /// NEXT DELIVERY BOOTH
          if (nextStore != null) {
            // Set loading to false BEFORE navigation to ensure the current view
            // handles its state update before it starts being disposed by Get.offNamed
            isLoading.value = false;
            Get.offNamed(
              Routes.STORE_DETAILS,
              arguments: nextStore,
              preventDuplicates: false,
            );
            return;
          }

          /// START COLLECTION MODE
          // initiateCollection manages its own isLoading state
          await initiateCollection();

          /// FIND FIRST COLLECTION BOOTH
          final collectionIndex = deliveries.indexWhere(
            (b) => b.status == DeliveryStatus.collecting,
          );
          
          final collectionBooth = collectionIndex != -1 ? deliveries[collectionIndex] : null;

          /// OPEN COLLECTION BOOTH
          if (collectionBooth != null) {
            Get.offNamed(
              Routes.STORE_DETAILS,
              arguments: collectionBooth,
              preventDuplicates: false,
            );
          } else {
            Get.back();
          }
          isLoading.value = false;
        },
      );
    } catch (e) {
      isLoading.value = false;

      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }
  //START COLLECTION
  Future<void> initiateCollection() async {
    try {

      isLoading.value = true;

      appMode.value = AppMode.collection;

      storage.write('app_mode', 'collection');

      await fetchRouteBooths();

      if (deliveries.isEmpty) return;

      int lastPending = -1;

      for (int i = deliveries.length - 1; i >= 0; i--) {

        if (deliveries[i].status ==
            DeliveryStatus.toBeCollected) {

          lastPending = i;
          break;
        }
      }

      if (lastPending != -1) {

        currentCollectingIndex.value = lastPending;

        deliveries[lastPending] =
            deliveries[lastPending].copyWith(
              status: DeliveryStatus.collecting,
            );
      }

      storage.write(
        'collecting_index_$tripId',
        currentCollectingIndex.value,
      );

    } catch (e) {

      Get.snackbar(
        "Error",
        "Failed to start collection: $e",
      );

    } finally {

      isLoading.value = false;
    }
  }
  @Deprecated("Use markCollected instead")
  Future<void> startCollection(DeliveryModel store) async {
    // This was previously used for individual store collection start
    // but the flow has changed to initiateCollection for the trip
  }


  //NAVIGATION
  void openStoreDetails(DeliveryModel store) {
    Get.toNamed(Routes.STORE_DETAILS, arguments: store);
  }

  void openMap(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$encoded",
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
 //
 //  //DASHBOARD
 // Future<void> loadTripSummary() async {
 //    try{
 //      isSummaryLoading.value = true;
 //      final data = await api.getTripSummary(tripId);
 //      summary.value = data;
 //
 //      // Update vehicle number and name from summary if available
 //      final summaryData = data['data'] ?? data;
 //
 //      if (summaryData['vehicleNumber'] != null) {
 //        vehicleNumber.value = summaryData['vehicleNumber'].toString();
 //      } else if (summaryData['vehicle'] != null && summaryData['vehicle']['number'] != null) {
 //        vehicleNumber.value = summaryData['vehicle']['number'].toString();
 //      }
 //
 //      if (summaryData['driverName'] != null) {
 //        name.value = summaryData['driverName'].toString();
 //      } else if (summaryData['driver'] != null && summaryData['driver']['name'] != null) {
 //        name.value = summaryData['driver']['name'].toString();
 //      }
 //
 //    }catch(e){
 //      debugPrint("Error loading trip summary: $e");
 //    }finally{
 //      isSummaryLoading.value = false;
 //    }
 // }



  void showCompletionDialog() {
    isDialogShown.value = true;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Confirm Submission",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("All collections completed. Submit now?"),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        actions: [
          TextButton(
            onPressed: () {
              isDialogShown.value = false;
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              elevation: 0,
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
      
      // CLEAR PERSISTENCE
      storage.remove('active_trip_id');
      storage.remove('app_mode');
      storage.remove('delivered_booths_$tripId');
      storage.remove('collected_booths_$tripId');
      storage.remove('collecting_index_$tripId');
      
      // Close the app or return to login/home
      SystemNavigator.pop();
    } catch (e) {
      Get.snackbar("Error", "Failed to end trip: $e");
    } finally {
      isLoading.value = false;
    }
  }


  int _getIndexById(String id) {
    return deliveries.indexWhere((s) => s.id == id);
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
        if (!collected.contains(store.boothId)) {
          collected.add(store.boothId);
          storage.write('collected_booths_$tripId', collected);
        }
      } catch (e) {
        final errorStr = e.toString().toLowerCase();
        if (!errorStr.contains("already collected") && 
            !errorStr.contains("already delivered") && 
            !errorStr.contains("already completed")) {
          rethrow;
        }
        // Even on error, if it's already done, mark it locally
        List<dynamic> collected = storage.read('collected_booths_$tripId') ?? [];
        if (!collected.contains(store.boothId)) {
          collected.add(store.boothId);
          storage.write('collected_booths_$tripId', collected);
        }
      }

      final index = _getIndexById(store.id);
      debugPrint("MarkCollected: Booth ${store.number} at index $index. Mode: ${appMode.value}");
      if (index == -1) {
        debugPrint("Error: Could not find booth in list");
        return;
      }

      final updatedStore = store.copyWith(
        collectedTrays: trays,
        status: DeliveryStatus.collected,
      );

      deliveries[index] = updatedStore;

      if (appMode.value == AppMode.collection) {
        int nextIndex = index - 1;
        while (nextIndex >= 0) {
          if (deliveries[nextIndex].status != DeliveryStatus.collected) {
            deliveries[nextIndex] =
                deliveries[nextIndex].copyWith(
                  status: DeliveryStatus.collecting,
                );
            currentCollectingIndex.value = nextIndex;
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
      Get.snackbar(
        "Success", 
        "Booth ${store.number} collected",
        snackPosition: SnackPosition.TOP,
      );

      final nextStore = getNextStore(updatedStore);

      Future.delayed(const Duration(milliseconds: 300), () {
        FocusManager.instance.primaryFocus?.unfocus();

        // Set loading to false BEFORE navigation to ensure the current view
        // handles its state update before it starts being disposed by Get.offNamed
        isLoading.value = false;

        if (nextStore != null) {
          Get.offNamed(
            Routes.STORE_DETAILS,
            arguments: nextStore,
            preventDuplicates: false,
          );
        } else {
          // Return to route list when finished
          showCompletionDialog();
        }
      });
    } catch (e) {
      isLoading.value = false;
      debugPrint("Collection Error: $e");
      Get.snackbar("Error", "Collection failed: $e");
    }
  }

  DeliveryModel? getNextStore(DeliveryModel currentStore) {
    try {
      final index = _getIndexById(currentStore.id);

      if (index == -1 || deliveries.isEmpty) return null;

      if (appMode.value == AppMode.delivery) {
        for (int i = index + 1; i < deliveries.length; i++) {
          if (deliveries[i].status != DeliveryStatus.delivered) {
            return deliveries[i];
          }
        }
      } else {
        for (int i = index - 1; i >= 0; i--) {
          if (deliveries[i].status != DeliveryStatus.collected) {
            return deliveries[i];
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint("getNextStore error: $e");
      return null;
    }
  }
  //
  // void openStoreDetails(DeliveryModel store) {
  //   Get.toNamed(Routes.STORE_DETAILS, arguments: store);
  // }
  //
  // void openMap(String address) async {
  //   final encoded = Uri.encodeComponent(address);
  //   final url = Uri.parse(
  //     "https://www.google.com/maps/search/?api=1&query=$encoded",
  //   );
  //
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   }
  // }
}