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

  // ================== USER INFO ==================
  var name = "".obs;
  var vehicleNumber = "".obs;
  var isDialogShown = false.obs;

  final storage = GetStorage();

  // ================== STATE ==================
  var appMode = AppMode.delivery.obs;
  var currentCollectingIndex = 0.obs;
  var isLoading = false.obs;

  var routeCode = "".obs;

  final deliveries = <DeliveryModel>[].obs;

  // ================== INIT ==================
  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    // Try API first
    fetchRouteBooths();
  }

  void _loadUserInfo() {
    // For testing: Hardcoded dummy data
    name.value = "Rajesh Kumar";
    vehicleNumber.value = "TN22CB2871";

    /* 
    try {
      final agentData = storage.read('agent');
      ...
    } catch (e) {
      ...
    }
    */
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

  // ================== API (SAFE WITH FALLBACK) ==================
  Future<void> fetchRouteBooths() async {
    try {
      isLoading.value = true;
      
      // Forces dummy data for testing
      loadDummyData();
      
    } catch (e) {
      loadDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  // ================== FALLBACK DATA (DO NOT REMOVE - UI DEPENDENCY) ==================
  void loadDummyData() {
    deliveries.assignAll([
      DeliveryModel(
        id: "D1",
        number: "01",
        storeName: "Balaji Stores",
        address: "No.21 AA Block 3rd St, Anna Nagar",
        status: DeliveryStatus.delivered,
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
        ],
      ),
      DeliveryModel(
        id: "D4",
        number: "04",
        storeName: "Murugan Stores",
        address: "Anna Nagar",
        status: DeliveryStatus.pending,
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

  // ================== HELPERS ==================
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

  // ================== COLLECTION ==================
  void startCollection() {
    appMode.value = AppMode.collection;
    // For reverse flow, we start at the last index
    currentCollectingIndex.value = deliveries.length - 1;
    isDialogShown.value = false;

    if (deliveries.isNotEmpty) {
      Get.toNamed(Routes.STORE_DETAILS, arguments: deliveries.last);
    }
  }

  Future<void> markDelivered(DeliveryModel store) async {
    if (isLoading.value) return;
    isLoading.value = true;

    final index = _getIndexById(store.id);
    if (index == -1) {
      isLoading.value = false;
      return;
    }

    // Update the store status
    final updatedStore = store.copyWith(status: DeliveryStatus.delivered);
    deliveries[index] = updatedStore;

    // Update next store to 'delivering' if applicable
    if (index < deliveries.length - 1) {
      final next = deliveries[index + 1];
      if (next.status == DeliveryStatus.pending) {
        deliveries[index + 1] = next.copyWith(status: DeliveryStatus.delivering);
      }
    }

    isLoading.value = false;
    Get.snackbar("Success", "${store.storeName} marked delivered",
        snackPosition: SnackPosition.TOP);

    // Navigate to next store or back to list
    final nextStore = getNextStore(store);
    if (nextStore != null) {
      Get.offNamed(Routes.STORE_DETAILS, arguments: nextStore, preventDuplicates: false);
    } else {
      Get.offNamed(Routes.DELIVERY_ROUTE);
    }
  }

  Future<void> markCollected(DeliveryModel store, int trays) async {
    if (isLoading.value) return;
    isLoading.value = true;

    final index = _getIndexById(store.id);
    if (index == -1) {
      isLoading.value = false;
      return;
    }

    // Update collected trays
    deliveries[index] = store.copyWith(collectedTrays: trays);

    isLoading.value = false;
    Get.snackbar("Success", "${store.storeName} collected",
        snackPosition: SnackPosition.TOP);

    // In reverse flow, move to the PREVIOUS store
    if (index > 0) {
      currentCollectingIndex.value = index - 1;
      final prevStore = deliveries[index - 1];
      Get.offNamed(Routes.STORE_DETAILS, arguments: prevStore, preventDuplicates: false);
    } else {
      // Index 0 reached, which is the end of reverse collection
      currentCollectingIndex.value = -1; // Flag for completion
      showCompletionDialog();
    }
  }

  DeliveryModel? getNextStore(DeliveryModel currentStore) {
    final index = _getIndexById(currentStore.id);
    if (index == -1) return null;

    if (appMode.value == AppMode.delivery) {
      // Normal flow: 1 -> 2 -> 3
      if (index < deliveries.length - 1) {
        return deliveries[index + 1];
      }
    } else {
      // Reverse flow: 6 -> 5 -> 4
      if (index > 0) {
        return deliveries[index - 1];
      }
    }
    return null;
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
    }
  }
}