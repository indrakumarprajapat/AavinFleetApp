import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/delivery_model.dart';
import '../delivery_points_screen.dart';
import '../../store_detail/store_details_screen.dart';

enum AppMode {
  delivery,
  collection,
}

class DeliveryController extends GetxController {

  var name = "Rajesh Kumar".obs;
  var vehicleNumber = "TN22CB2871".obs;
  var appMode = AppMode.delivery.obs;
  var currentCollectingIndex = 0.obs;
  var isLoading = false.obs;

  var deliveries = <DeliveryModel>[

    DeliveryModel(
      number: "01",
      storeName: "Balaji Stores",
      address: "No.21 AA Block 3rd St, Anna Nagar",
      status: DeliveryStatus.delivered,
      products: [
        ProductModel(name: "Milk (250ml)", trays: 8, packets: 12, tubs: 0),
        ProductModel(name: "Milk (500ml)", trays: 10, packets: 9, tubs: 0),
        ProductModel(name: "Curd (500ml)", trays: 4, packets: 5, tubs: 4),
      ],
    ),

    DeliveryModel(
      number: "02",
      storeName: "Sivanesh Stores",
      address: "No.21 AA Block 3rd St, Anna Nagar",
      status: DeliveryStatus.delivering,
      products: [
        ProductModel(name: "Milk (250ml)", trays: 6, packets: 9, tubs: 0),
        ProductModel(name: "Milk (500ml)", trays: 8, packets: 0, tubs: 4),
        ProductModel(name: "Curd (500ml)", trays: 2, packets: 0, tubs: 5),
      ],
    ),

    DeliveryModel(
      number: "03",
      storeName: "Kishore Stall",
      address: "No.21 AA Block 3rd St, Anna Nagar",
      status: DeliveryStatus.pending,
      products: [
        ProductModel(name: "Milk (250ml)", trays: 5, packets: 6, tubs: 0),
        ProductModel(name: "Milk (500ml)", trays: 6, packets: 3, tubs: 0),
      ],
    ),

    DeliveryModel(
      number: "04",
      storeName: "Murugan Stores",
      address: "No.21 AA Block 3rd St, Anna Nagar",
      status: DeliveryStatus.pending,
      products: [
        ProductModel(name: "Milk (250ml)", trays: 7, packets: 10, tubs: 2),
        ProductModel(name: "Milk (500ml)", trays: 9, packets: 0, tubs: 0),
        ProductModel(name: "Curd (500ml)", trays: 3, packets: 6, tubs: 0),
      ],
    ),

    DeliveryModel(
      number: "05",
      storeName: "Lakshmi Dairy Store",
      address: "12 Market Road, T. Nagar",
      status: DeliveryStatus.pending,
      products: [
        ProductModel(name: "Milk (250ml)", trays: 5, packets: 8, tubs: 1),
        ProductModel(name: "Milk (500ml)", trays: 7, packets: 0, tubs: 0),
        ProductModel(name: "Curd (500ml)", trays: 4, packets: 5, tubs: 0),
      ],
    ),

    DeliveryModel(
      number: "06",
      storeName: "Sri Balaji Milk Center",
      address: "45 Gandhi Road, Velachery",
      status: DeliveryStatus.pending,
      products: [
        ProductModel(name: "Milk (250ml)", trays: 8, packets: 12, tubs: 2),
        ProductModel(name: "Milk (500ml)", trays: 6, packets: 0, tubs: 0),
        ProductModel(name: "Curd (500ml)", trays: 5, packets: 4, tubs: 1),
      ],
    ),

  ].obs;

  // ✅ FIXED INDEX (USING ID)
  int _getIndexById(String id) {
    return deliveries.indexWhere((s) => s.id == id);
  }

  // ================== START COLLECTION ==================
  void startCollection() {
    appMode.value = AppMode.collection;
    deliveries.value = deliveries.reversed.toList();
    currentCollectingIndex.value = 0;
  }

  // ================== NAVIGATION ==================
  void openStoreDetails(DeliveryModel store) {
    Get.to(
          () =>  StoreDetailsScreen(),
      arguments: store,
    );
  }

  // ================== DELIVERY ==================
  Future<void> markDeliveredAndGoBack(DeliveryModel store) async{
    isLoading.value = true;

    final index = _getIndexById(store.id);

    if (index == -1) {
      isLoading.value = false;
      return;
    }

    deliveries[index].markDelivered();

    if (index < deliveries.length - 1) {
      deliveries[index + 1].markDelivering();
    }

    deliveries.refresh();

    Get.snackbar(
      "Success",
      "${store.storeName} marked as delivered",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );

    isLoading.value = false;
  }

  // ================== COLLECTION ==================
  Future<void> markCollectedAndGoBack (
      DeliveryModel store,
      int trays,
      int tubs,
      ) async {
    isLoading.value = true;

    final index = _getIndexById(store.id);

    if (index == -1) {
      isLoading.value = false;
      return;
    }

    deliveries[index].markCollected(trays, tubs);

    if (index < deliveries.length - 1) {
      currentCollectingIndex.value = index + 1;
    } else {
      appMode.value = AppMode.delivery;

      Get.snackbar(
        "Completed",
        "All collections finished",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    deliveries.refresh();

    Get.snackbar(
      "Success",
      "${store.storeName} marked as collected",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );

    isLoading.value = false;
  }

  // ================== GET NEXT STORE ==================
  DeliveryModel? getNextStore(DeliveryModel currentStore) {
    final index = _getIndexById(currentStore.id);

    if (index != -1 && index < deliveries.length - 1) {
      return deliveries[index + 1];
    }
    return null;
  }

  // ================== MAP ==================
  void openMap() async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=Anna+Nagar",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}