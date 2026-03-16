import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../models/product_model.dart';
import '../../../../models/slot_model.dart';
import '../../../../api/api_service.dart';
import '../../../../services/global_cart_service.dart';
import '../../../../data/data_service.dart';
import '../../home/controllers/home_controller.dart';

class ProductSelectionController extends GetxController {
  final apiService = Get.find<ApiService>();
  final globalCartService = Get.find<GlobalCartService>();
  final _products = <ProductModel>[].obs;
  final _isLoading = false.obs;
  final enableSingleSlotOnly = false.obs;
  final shiftType = 1.obs;
  final _quantities = <int, double>{}.obs;
  final _morningTextControllers = <int, TextEditingController>{};
  final _eveningTextControllers = <int, TextEditingController>{};
  Timer? _debounceTimer;
  final storage = GetStorage();
  final Map<String, double> _pendingUpdates = {}; // Track pending changes
  // final RxInt itemUnitType = 1.obs;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading.value;
  Map<String, dynamic> get cartEstimate => globalCartService.cartEstimate;
  Map<int, double> get quantities => _quantities;
  final config = Rxn<Map<String, dynamic>>();
  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final orderType = arguments['shift'] == 2 ? 1 : 1; // 1 for milk/curd
    shiftType.value = arguments['shift'] ?? 1; // 1: morning, 2: evening
    // final dataService = Get.find<DataService>();
    // final agentModel = dataService.agentModel;
    // itemUnitType.value = agentModel?.itemUnitType ?? storage.read('itemUnitType') ?? 1;
    loadProducts(orderType);
    loadCachedConfig();
    globalCartService.refreshCartEstimate();
  }

  void loadCachedConfig() {
    final cachedConfig = storage.read('app_config');
    if (cachedConfig != null) {
      config.value = Map<String, dynamic>.from(cachedConfig);
      enableSingleSlotOnly(config.value?['enable_single_slot_only'] ?? false);
    } else {
      print('ConfigService: No cached config found');
    }
  }
  
  bool isSlotExpired(int shiftType) {
    try {
      final homeController = Get.find<HomeController>();
      final slot = homeController.slots.firstWhere(
        (s) => s.shift == shiftType,
        orElse: () => SlotModel(),
      );
      
      if (slot.createdAt == null || slot.cutoffTime == null) return false;
      
      final now = DateTime.now();
      final slotDate = DateTime.parse(slot.createdAt!);
      final cutoffParts = slot.cutoffTime!.split(':');
      final cutoffDateTime = DateTime(
        slotDate.year,
        slotDate.month,
        slotDate.day,
        int.parse(cutoffParts[0]),
        int.parse(cutoffParts[1]),
      );
      
      return now.isAfter(cutoffDateTime);
    } catch (e) {
      return false;
    }
  }

  Future<void> loadProducts(int orderType) async {
    try {
      // _isLoading.value = true;
      final products = await apiService.getProductsByOrderType(orderType);
      // final eveningProducts = await apiService.getProductsByOrderType(orderType);
      final Map<int, ProductModel> mergedProducts = {};
      for (var product in products) {
        if (product.id != null) {
          mergedProducts[product.id!] = product;
        }
      }
      for (var product in products) {
        if (product.id != null) {
          if (mergedProducts.containsKey(product.id!)) {
            final existing = mergedProducts[product.id!]!;
            mergedProducts[product.id!] = ProductModel(
              id: existing.id,
              productCode: existing.productCode,
              unionId: existing.unionId,
              categoryId: existing.categoryId,
              name: existing.name,
              measure: existing.measure,
              unit: existing.unit,
              gst: existing.gst,
              mrpBasic: existing.mrpBasic,
              retailBasic: existing.retailBasic,
              wsdBasic: existing.wsdBasic,
              unionBasic: existing.unionBasic,
              fedBasic: existing.fedBasic,
              quantity: existing.quantity,
              createdBy: existing.createdBy,
              createdDate: existing.createdDate,
              updateBy: existing.updateBy,
              updatedDate: existing.updatedDate,
              status: existing.status,
              trayCapacity: existing.trayCapacity,
              hasPopular: existing.hasPopular,
              imageUrl: existing.imageUrl,
              thumbnailUrl: existing.thumbnailUrl,
              categoryName: existing.categoryName,
              price: existing.price,
              morningCartQuantity: existing.morningCartQuantity,
              eveningCartQuantity: product.eveningCartQuantity,
              productImages: existing.productImages,
              incrementBy: product.incrementBy,
              itemUnitType: product.itemUnitType,
            );
          } else {
            mergedProducts[product.id!] = product;
          }
        }
      }
      
      _products.value = mergedProducts.values.toList();
    } catch (e) {
      print('Load products error: $e');
    } finally {
      // _isLoading.value = false;
    }
  }

  Future<void> updateCart(int productId, double quantity, int shiftType) async {
    _quantities[productId] = quantity;

    final key = '${productId}_$shiftType';
    _pendingUpdates[key] = quantity;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 2), () async {
      try {
        final homeController = Get.find<HomeController>();

        final List<Future> updateFutures = [];
        final Map<String, double> currentPending = Map.from(_pendingUpdates);
        _pendingUpdates.clear();
        
        for (final entry in currentPending.entries) {
          final parts = entry.key.split('_');
          final pId = int.parse(parts[0]);
          final sType = int.parse(parts[1]);
          final qty = entry.value;
          
          final slot = homeController.slots.firstWhere(
            (s) => s.shift == sType,
            orElse: () => SlotModel(),
          );
          final slotId = slot.id ?? 1;
          
          updateFutures.add(
            globalCartService.updateCart(pId, qty, sType, slotId, 1)
          );
        }

        await Future.wait(updateFutures);
        
        final arguments = Get.arguments as Map<String, dynamic>? ?? {};
        final orderType = arguments['shift'] == 2 ? 1 : 1;
        await loadProducts(orderType);
      } catch (e) {
        print('Cart update error: $e');
      }
    });
  }

  double getQuantity(int productId) {
    return _quantities[productId] ?? 0;
  }

  TextEditingController getMorningTextController(int productId) {
    if (!_morningTextControllers.containsKey(productId)) {
      _morningTextControllers[productId] = TextEditingController();
    }
    return _morningTextControllers[productId]!;
  }
  
  TextEditingController getEveningTextController(int productId) {
    if (!_eveningTextControllers.containsKey(productId)) {
      _eveningTextControllers[productId] = TextEditingController();
    }
    return _eveningTextControllers[productId]!;
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    for (var controller in _morningTextControllers.values) {
      controller.dispose();
    }
    for (var controller in _eveningTextControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}