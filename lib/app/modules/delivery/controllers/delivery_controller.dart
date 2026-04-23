import 'dart:convert';

import 'package:aavin/app/api/api_service.dart';
import 'package:aavin/app/modules/dashboard/view/dashboard_view.dart';
import 'package:aavin/app/modules/store_detail/view/store_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/booth_model.dart';
import '../../../models/agent_model.dart';
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
    loadTripSummary();
  }

  void _loadUserInfo() {
    try {
      final agentData = storage.read('agent');
      if (agentData != null) {
        if (agentData is Map) {
          name.value = agentData['name']?.toString() ?? "Driver";
        } else {
          // If it was stored as a string for some reason
          final decoded = json.decode(agentData.toString());
          name.value = decoded['name']?.toString() ?? "Driver";
        }
      }

      if (name.value.isEmpty || name.value == "Driver") {
        final societyData = storage.read('societyDetails');
        if (societyData != null && societyData is Map) {
          name.value = societyData['name']?.toString() ?? name.value;
        }
      }
    } catch (e) {
      debugPrint("Error loading user info: $e");
    }
  }

  //FETCH BOOTHS
  Future<void> fetchRouteBooths() async {
    try {
      isLoading.value = true;
      final data = await api.getTripBooths(tripId, "DELIVERY");
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
      
      await api.markDelivered(tripId, int.parse(store.id));

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
        Get.offNamed(Routes.DELIVERY_ROUTE);
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
      await api.startCollection(tripId);
      appMode.value = AppMode.collection;
      if (deliveries.isNotEmpty) {
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

  //DASHBOARD
 Future<void> loadTripSummary() async {
    try{
      isSummaryLoading.value = true;
      final data = await api.getTripSummary(tripId);
      summary.value = data;
      
      // Update vehicle number and name from summary if available
      final summaryData = data['data'] ?? data;
      
      if (summaryData['vehicleNumber'] != null) {
        vehicleNumber.value = summaryData['vehicleNumber'].toString();
      } else if (summaryData['vehicle'] != null && summaryData['vehicle']['number'] != null) {
        vehicleNumber.value = summaryData['vehicle']['number'].toString();
      }

      if (summaryData['driverName'] != null) {
        name.value = summaryData['driverName'].toString();
      } else if (summaryData['driver'] != null && summaryData['driver']['name'] != null) {
        name.value = summaryData['driver']['name'].toString();
      }
      
    }catch(e){
      debugPrint("Error loading trip summary: $e");
    }finally{
      isSummaryLoading.value = false;
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
            onPressed: () {
              isDialogShown.value = false;
              Get.back();
              Get.offAllNamed(Routes.DASHBOARD);
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
  

  @override
  void onClose() {
    deliveries.clear();
    super.onClose();
  }

  // Future<void> fetchRouteBooths() async {
  //   try {
  //     isLoading.value = true;
  //     loadDummyData();
  //
  //   } catch (e) {
  //     loadDummyData();
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void loadDummyData() {
    deliveries.assignAll([
      DeliveryModel(
        id: "D1",
        number: "01",
        storeName: "Balaji Stores",
        address: "No.21 AA Block 3rd St, Anna Nagar",
        status: DeliveryStatus.delivered,
        remainingTrays: 2,
        products: [
          const ProductModel(name: "Aavin Nice (500ml)", trays: 5, packets: 50, tubs: 2),
          const ProductModel(name: "Aavin Premium (500ml)", trays: 3, packets: 30, tubs: 1),
        ],
      ),
      DeliveryModel(
        id: "D2",
        number: "02",
        storeName: "Sivanesh Stores",
        address: "T Nagar",
        status: DeliveryStatus.delivering,
        products: [
          const ProductModel(name: "Aavin Nice (500ml)", trays: 10, packets: 100, tubs: 4),
        ],
      ),
      DeliveryModel(
        id: "D3",
        number: "03",
        storeName: "Kishore Stall",
        address: "Velachery",
        status: DeliveryStatus.pending,
        remainingTrays: 5,
        products: [
          const ProductModel(name: "Aavin Green (500ml)", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Nice (500ml)", trays: 5, packets: 50, tubs: 2),
          const ProductModel(name: "Aavin Premium (500ml)", trays: 4, packets: 40, tubs: 1),
          const ProductModel(name: "Aavin Diet (500ml)", trays: 2, packets: 20, tubs: 1),
          const ProductModel(name: "Aavin Tea Milk", trays: 10, packets: 100, tubs: 4),
          const ProductModel(name: "Aavin Coffee Milk", trays: 6, packets: 60, tubs: 2),
          const ProductModel(name: "Aavin Butter Milk", trays: 15, packets: 150, tubs: 5),
          const ProductModel(name: "Aavin Lassi", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Curd (200g)", trays: 20, packets: 200, tubs: 8),
          const ProductModel(name: "Aavin Curd (500g)", trays: 12, packets: 120, tubs: 5),
          const ProductModel(name: "Aavin Paneer (200g)", trays: 5, packets: 50, tubs: 2),
          const ProductModel(name: "Aavin Ghee (100ml)", trays: 2, packets: 20, tubs: 1),
          const ProductModel(name: "Aavin Ghee (500ml)", trays: 1, packets: 10, tubs: 1),
          const ProductModel(name: "Aavin Flavored Milk - Rose", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Flavored Milk - Pista", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Flavored Milk - Cardamom", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Khoa", trays: 4, packets: 40, tubs: 1),
          const ProductModel(name: "Aavin Gulab Jamun", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Rasgulla", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Skimmed Milk Powder", trays: 5, packets: 50, tubs: 2),
          const ProductModel(name: "Aavin Green (500ml)", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Nice (500ml)", trays: 5, packets: 50, tubs: 2),
          const ProductModel(name: "Aavin Premium (500ml)", trays: 4, packets: 40, tubs: 1),
          const ProductModel(name: "Aavin Diet (500ml)", trays: 2, packets: 20, tubs: 1),
          const ProductModel(name: "Aavin Tea Milk", trays: 10, packets: 100, tubs: 4),
          const ProductModel(name: "Aavin Coffee Milk", trays: 6, packets: 60, tubs: 2),
          const ProductModel(name: "Aavin Butter Milk", trays: 15, packets: 150, tubs: 5),
          const ProductModel(name: "Aavin Lassi", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Curd (200g)", trays: 20, packets: 200, tubs: 8),
          const ProductModel(name: "Aavin Curd (500g)", trays: 12, packets: 120, tubs: 5),
          const ProductModel(name: "Aavin Paneer (200g)", trays: 5, packets: 50, tubs: 2),
          const ProductModel(name: "Aavin Ghee (100ml)", trays: 2, packets: 20, tubs: 1),
          const ProductModel(name: "Aavin Ghee (500ml)", trays: 1, packets: 10, tubs: 1),
          const ProductModel(name: "Aavin Flavored Milk - Rose", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Flavored Milk - Pista", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Flavored Milk - Cardamom", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Khoa", trays: 4, packets: 40, tubs: 1),
          const ProductModel(name: "Aavin Gulab Jamun", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Rasgulla", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Skimmed Milk Powder", trays: 5, packets: 50, tubs: 2), const ProductModel(name: "Aavin Green (500ml)", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Nice (500ml)", trays: 5, packets: 50, tubs: 2),
          const ProductModel(name: "Aavin Premium (500ml)", trays: 4, packets: 40, tubs: 1),
          const ProductModel(name: "Aavin Diet (500ml)", trays: 2, packets: 20, tubs: 1),
          const ProductModel(name: "Aavin Tea Milk", trays: 10, packets: 100, tubs: 4),
          const ProductModel(name: "Aavin Coffee Milk", trays: 6, packets: 60, tubs: 2),
          const ProductModel(name: "Aavin Butter Milk", trays: 15, packets: 150, tubs: 5),
          const ProductModel(name: "Aavin Lassi", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Curd (200g)", trays: 20, packets: 200, tubs: 8),
          const ProductModel(name: "Aavin Curd (500g)", trays: 12, packets: 120, tubs: 5),
          const ProductModel(name: "Aavin Paneer (200g)", trays: 5, packets: 50, tubs: 2),
          const ProductModel(name: "Aavin Ghee (100ml)", trays: 2, packets: 20, tubs: 1),
          const ProductModel(name: "Aavin Ghee (500ml)", trays: 1, packets: 10, tubs: 1),
          const ProductModel(name: "Aavin Flavored Milk - Rose", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Flavored Milk - Pista", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Flavored Milk - Cardamom", trays: 8, packets: 80, tubs: 3),
          const ProductModel(name: "Aavin Khoa", trays: 4, packets: 40, tubs: 1),
          const ProductModel(name: "Aavin Gulab Jamun", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Rasgulla", trays: 3, packets: 30, tubs: 1),
          const ProductModel(name: "Aavin Skimmed Milk Powder", trays: 5, packets: 50, tubs: 2),
        ],
      ),
      DeliveryModel(
        id: "D4",
        number: "04",
        storeName: "Murugan Stores",
        address: "Anna Nagar",
        status: DeliveryStatus.pending,
        remainingTrays: 1,
        products: [
          const ProductModel(name: "Aavin Nice (500ml)", trays: 12, packets: 120, tubs: 5),
        ],
      ),
      DeliveryModel(
        id: "D5",
        number: "05",
        storeName: "Senthi Milk Agency",
        address: "Salem Road",
        status: DeliveryStatus.pending,
        products: [
          const ProductModel(name: "Aavin Green (500ml)", trays: 6, packets: 60, tubs: 2),
        ],
      ),
      DeliveryModel(
        id: "D6",
        number: "06",
        storeName: "Vetrivel Traders",
        address: "Paramathi Road",
        status: DeliveryStatus.pending,
        products: [
          const ProductModel(name: "Aavin Diet (500ml)", trays: 4, packets: 40, tubs: 1),
        ],
      ),
    ]);
  }

  int _getIndexById(String id) {
    return deliveries.indexWhere((s) => s.id == id);
  }

  DeliveryStatus _parseStatus(String status) {
    switch (status) {
      case "delivered":
        return DeliveryStatus.delivered;
      case "delivering":
        return DeliveryStatus.delivering;
      default:
        return DeliveryStatus.pending;
    }
  }
  // //
  // // void startCollection() {
  // //   appMode.value = AppMode.collection;
  // //   currentCollectingIndex.value = deliveries.length - 1;
  // //   isDialogShown.value = false;
  // //
  // //   if (deliveries.isNotEmpty) {
  // //     Get.toNamed(Routes.STORE_DETAILS, arguments: deliveries.last);
  // //   }
  // // }
  //
  // Future<void> markDelivered(DeliveryModel store) async {
  //   if (isLoading.value) return;
  //   isLoading.value = true;
  //
  //   final index = _getIndexById(store.id);
  //   if (index == -1) {
  //     isLoading.value = false;
  //     return;
  //   }
  //
  //   final updatedStore = store.copyWith(status: DeliveryStatus.delivered);
  //   deliveries[index] = updatedStore;
  //
  //   if (index < deliveries.length - 1) {
  //     final next = deliveries[index + 1];
  //     if (next.status == DeliveryStatus.pending) {
  //       deliveries[index + 1] = next.copyWith(status: DeliveryStatus.delivering);
  //     }
  //   }
  //
  //   isLoading.value = false;
  //   Get.snackbar("Success", "${store.storeName} marked delivered",
  //       snackPosition: SnackPosition.TOP);
  //
  //   final nextStore = getNextStore(store);
  //   if (nextStore != null) {
  //     Get.offNamed(Routes.STORE_DETAILS, arguments: nextStore, preventDuplicates: false);
  //   } else {
  //     Get.offNamed(Routes.DELIVERY_ROUTE);
  //   }
  // }

  Future<void> markCollected(DeliveryModel store, int trays) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      await api.submitTrayCollection(tripId, int.parse(store.id), trays);

      final index = _getIndexById(store.id);
      if (index == -1) return;

      final updatedStore =
      store.copyWith(collectedTrays: trays);
      deliveries[index] = updatedStore;

      Get.snackbar("Success", "${store.storeName} collected");

      final nextStore = getNextStore(updatedStore);

      if (nextStore != null) {
        Get.offNamed(
          Routes.STORE_DETAILS,
          arguments: nextStore,
          preventDuplicates: false,
        );
      } else {
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