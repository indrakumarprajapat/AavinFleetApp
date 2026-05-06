import 'package:geolocator/geolocator.dart';
import '../../../data/session_manager.dart';
import '../../../utils/location-utils.dart';
import 'dart:convert';

import 'package:aavin/app/api/api_service.dart';
import 'package:aavin/app/modules/store_detail/view/store_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/booth_model.dart';
import '../../../models/fleet_user.dart';
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
    if (Get.arguments != null) {
      tripId = int.tryParse(Get.arguments.toString()) ?? 0;
    }
    _loadUserInfo();
    fetchRouteBooths();
    // loadTripSummary();
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
          
      deliveries.assignAll(
        data.map<DeliveryModel>((json) {
          return DeliveryModel.fromJson(json);
        }).toList(),
      );
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
      double lat = 0, lng = 0;
      if (allowed) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      }

      int boothId = int.tryParse(store.id.toString()) ?? 0;
      await api.markDelivered(tripId, boothId, lat, lng);

      final index = _getIndexById(store.id);
      if(index == -1) return;
      final updatedStore = store.copyWith(status: DeliveryStatus.delivered);
      deliveries[index] = updatedStore;

      if(index < deliveries.length - 1){
        final next = deliveries[index + 1];
        if(next.status == DeliveryStatus.pending){
          deliveries[index + 1] = next.copyWith(status: DeliveryStatus.delivering);
        }
      }
      final nextStore = getNextStore(updatedStore);

      if (nextStore != null) {
        Get.offNamed(
          Routes.STORE_DETAILS,
          arguments: nextStore,
          preventDuplicates: false,
        );
      } else {
        Get.back(); // Correctly return to the Route list view
      }

      Get.snackbar("Success", "${store.storeName} delivered ");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  //START COLLECTION
  Future<void> initiateCollection() async {
    try {
      isLoading.value = true;
      appMode.value = AppMode.collection;
      await fetchRouteBooths();
      
      if (deliveries.isNotEmpty) {
        currentCollectingIndex.value = deliveries.length - 1;
        openStoreDetails(deliveries.last);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to start collection: $e");
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
              foregroundColor: const Color(0xff1BA6C8),
              side: const BorderSide(color: Color(0xff1BA6C8)),
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
              backgroundColor: const Color(0xff1BA6C8),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              elevation: 0,
            ),
            child: const Text("Submit"),
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
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      }
      await api.endTrip(tripId, lat, lng);
      
      // Close the app or return to login/home
      SystemNavigator.pop();
    } catch (e) {
      Get.snackbar("Error", "Failed to end trip: $e");
    } finally {
      isLoading.value = false;
    }
  }


  @override
  void onClose() {
    deliveries.clear();
    super.onClose();
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
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      }

      int boothId = int.tryParse(store.id.toString()) ?? 0;
      await api.markCollected(tripId, boothId, trays, lat, lng);

      final index = _getIndexById(store.id);
      if (index == -1) return;

      final updatedStore = store.copyWith(collectedTrays: trays);
      deliveries[index] = updatedStore;

      if (appMode.value == AppMode.collection && index > 0) {
        currentCollectingIndex.value = index - 1;
      }

      Get.snackbar("Success", "${store.storeName} collected");

      final nextStore = getNextStore(updatedStore);

      if (nextStore != null) {
        Get.offNamed(
          Routes.STORE_DETAILS,
          arguments: nextStore,
          preventDuplicates: false,
        );
      } else {
        Get.back(); // Correctly return to the Route list view
        showCompletionDialog();
      }
    } catch (e) {
      Get.snackbar("Error", "Collection failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  DeliveryModel? getNextStore(DeliveryModel currentStore) {
    try {
      final index = _getIndexById(currentStore.id);

      if (index == -1 || deliveries.isEmpty) return null;

      if (appMode.value == AppMode.delivery) {
        if (index < deliveries.length - 1) {
          return deliveries[index + 1];
        }
      } else {
        if (index > 0) {
          return deliveries[index - 1];
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