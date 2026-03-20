import 'dart:async';
import 'package:get/get.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../models/slot_model.dart';
import '../../../api/api_service.dart';
import '../../../services/global_cart_service.dart';
import '../home/controllers/home_controller.dart';

class OthersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GlobalCartService _globalCartService = Get.find<GlobalCartService>();
  
  final categories = <CategoryModel>[].obs;
  final categoryProducts = <ProductModel>[].obs;
  final popularProducts = <ProductModel>[].obs;
  final banners = <dynamic>[].obs;
  final isLoading = true.obs;
  final isLoadingProducts = false.obs;
  final isLoadingPopular = true.obs;
  final isLoadingBanners = false.obs;
  final selectedCategoryId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _globalCartService.refreshCartEstimate(shiftType: 0);
    _fetchCategories();
    _fetchPopularProducts();
    _fetchBanners();
    ever(selectedCategoryId, (categoryId) {
      update();
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _apiService.getCategories();
      categories.value = response ?? [];
      isLoading.value = false;
    } catch (e) {
      categories.value = [];
      isLoading.value = false;
    }
  }

  Future<void> _fetchPopularProducts() async {
    try {
      final response = await _apiService.getPopularProducts();
      popularProducts.value = response;
      isLoadingPopular.value = false;
    } catch (e) {
      popularProducts.value = [];
      isLoadingPopular.value = false;
    }
  }

  Future<void> _fetchBanners() async {
    try {
      isLoadingBanners.value = true;
      final response = await _apiService.getBanners();
      banners.value = response;
    } catch (e) {
      banners.value = [];
    } finally {
      isLoadingBanners.value = false;
    }
  }

  Future<void> refreshData() async {
    await _globalCartService.refreshCartEstimate(shiftType: 0);
    await _fetchPopularProducts();
    await _fetchBanners();
    if (selectedCategoryId.value != null) {
      try {
        final products = await _apiService.getOtherProducts(selectedCategoryId.value!);
        categoryProducts.value = products;
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void selectCategory(CategoryModel category) {
    final categoryId = category.id;
    if (selectedCategoryId.value == categoryId) {
      selectedCategoryId.value = null;
      categoryProducts.value = [];
    } else {
      selectedCategoryId.value = categoryId;
      _loadCategoryProducts(categoryId!);
    }
  }

  Future<void> _loadCategoryProducts(int categoryId) async {
    isLoadingProducts.value = true;
    try {
      final products = await _apiService.getOtherProducts(categoryId);
      categoryProducts.value = products;
    } catch (e) {
      categoryProducts.value = [];
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> addToCart(ProductModel product, {bool isIncrement = true}) async {
    try {
      num currentQuantity = product.cartQuantity ?? 0;
      double newQuantity = isIncrement ? (currentQuantity + 1) : (currentQuantity > 0 ? (currentQuantity - 1) : 0.0);

      final homeController = Get.find<HomeController>();
      final slot = homeController.slots.firstWhere(
        (s) => s.shift == 0,
        orElse: () => homeController.slots.isNotEmpty ? homeController.slots.first : SlotModel(),
      );
      final slotId = slot.id ?? 1;
      
      await _apiService.updateCart(
        productId: product.id??0,
        quantity: newQuantity,
        shiftType: 0,
        slotId: 0,
        orderType: 2,
      );
      await _globalCartService.refreshCartEstimate(shiftType: 0);
      await refreshData();
      
      // Get.snackbar(
      //   'Success',
      //   newQuantity > 0 ? '${product.name} ${isIncrement ? 'added to' : 'updated in'} cart' : '${product.name} removed from cart',
      //   backgroundColor: Get.theme.colorScheme.surface.withValues(alpha:0.2),
      //   colorText: Get.theme.colorScheme.onSurface,
      //   duration: Duration(seconds: 1),
      // );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update cart',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: Duration(seconds: 2),
      );
    }
  }
}