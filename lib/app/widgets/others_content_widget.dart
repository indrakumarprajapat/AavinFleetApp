import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/slot_model.dart';
import '../modules/agent/home/controllers/home_controller.dart';
import '../modules/agent/others/others_controller.dart';
import '../api/api_service.dart';
import '../services/global_cart_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class OthersContentWidget extends StatefulWidget {
  const OthersContentWidget({super.key});

  @override
  State<OthersContentWidget> createState() => _OthersContentWidgetState();
}

class _OthersContentWidgetState extends State<OthersContentWidget> with TickerProviderStateMixin {
  late final OthersController controller;

  late AnimationController shimmerController;
  late PageController bannerPageController;
  Timer? bannerTimer;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OthersController(), permanent: true);
    shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    bannerPageController = PageController(initialPage: 5000);
    _startBannerAutoSlide();
    controller.refreshData();
  }

  @override
  void dispose() {
    shimmerController.dispose();
    bannerPageController.dispose();
    bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerAutoSlide() {
    bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (bannerPageController.hasClients && controller.banners.isNotEmpty) {
        bannerPageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }




  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'butter': return Icons.local_grocery_store;
      case 'ghee': return Icons.opacity;
      case 'ice cream': return Icons.icecream;
      case 'paneer': return Icons.food_bank;
      case 'sweets': return Icons.cookie;
      case 'flavoured milk & drinks': return Icons.local_drink;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(
                //   height: Get.height * 0.6,
                //   width: Get.height * 0.6,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       SvgPicture.asset(
                //         'assets/icons/otherIcon.svg',
                //         width: 80,
                //         height: 85,
                //       ),
                //       SizedBox(height: 16),
                //       Text(
                //         'No Products available',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.w500,
                //           color: Colors.grey[600],
                //           fontFamily: 'Poppins',
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                _buildPromotionalBanners(bannerPageController),
                Visibility(
                    visible: controller.banners.isNotEmpty,
                    child: SizedBox(height: 24)),
                _buildOtherProductsSection(),
                SizedBox(height: 24),
                _buildMostPopularSection(context, shimmerController),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildCartSummary(),
        ),
      ],
    );
  }

  Widget _buildPromotionalBanners(PageController bannerPageController) {
    return Obx(() {
      if (controller.banners.isEmpty) {
        return SizedBox.shrink();
      }
      
      return SizedBox(
        height: 120,
        child: PageView.builder(
          controller: bannerPageController,
          itemCount: controller.banners.isNotEmpty ? 10000 : 0,
          itemBuilder: (context, index) {
            final actualIndex = index % controller.banners.length;
            final banner = controller.banners[actualIndex];
            return GestureDetector(
              onTap: () {
                if (banner['redirectUrl'] != null && banner['redirectUrl'].toString().isNotEmpty) {
                  _launchURL(banner['redirectUrl']);
                }
              },
              child: Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        banner['bannerUrl'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      ),
                      if (banner['title'] != null || banner['description'] != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (banner['title'] != null)
                                  Text(
                                    banner['title'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (banner['description'] != null)
                                  Text(
                                    banner['description'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not launch $url: $e');
    }
  }

  Widget _buildOtherProductsSection() {
    return GetBuilder<OthersController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Category\'s',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Obx(() => SizedBox(
            height: 100,
            child: controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      final categoryId = category.id;
                      final categoryName = category.name ?? '';
                      final imageUrl = category.imageUrl ?? '';
                      final isSelected = controller.selectedCategoryId.value == categoryId;
                      
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          controller.selectCategory(category);
                        },
                        child: Container(
                          width: 80,
                          margin: EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [Color(0xFF00ADD9), Color(0xFF0088CC)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [Color(0xFF00ADD9).withValues(alpha:0.1), Color(0xFF00ADD9).withValues(alpha:0.05)],
                                        ),
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Color(0xFF00ADD9).withValues(alpha:0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ClipOval(
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              _getCategoryIcon(categoryName),
                                              size: 28,
                                              color: isSelected ? Colors.white : Color(0xFF00ADD9),
                                            );
                                          },
                                        )
                                      : Icon(
                                          _getCategoryIcon(categoryName),
                                          size: 28,
                                          color: isSelected ? Colors.white : Color(0xFF00ADD9),
                                        ),
                                ),
                              ),
                              SizedBox(height: 8),
                              AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Color(0xFF00ADD9)
                                      : CupertinoColors.label,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                child: Text(
                                  categoryName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )),
        ],
      ),
    );
  }

  Future<void> _showProductDetails(int productId,context) async {
    try {
      final apiService = Get.find<ApiService>();
      final productDetailsMap = await apiService.getProductById(productId);
      var productDetails = ProductModel.fromJson(productDetailsMap);
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        transitionAnimationController: AnimationController(
          duration: Duration(milliseconds: 500),
          vsync: this,
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OverflowBar(
                alignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF363A3E),
                      shape: BoxShape.circle,
                      // border: Border.all(color: Colors.grey),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEAE9EC),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 35,),
              GestureDetector(onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: productDetails.productImages != null && productDetails.productImages!.isNotEmpty
                                  ? PageView.builder(
                                itemCount: productDetails.productImages!.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      productDetails.productImages![index].imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return AnimatedBuilder(
                                          animation: shimmerController,
                                          builder: (context, child) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
                                                  stops: [0.0, 0.5, 1.0],
                                                  begin: Alignment(-1.0 + shimmerController.value * 2, 0.0),
                                                  end: Alignment(1.0 + shimmerController.value * 2, 0.0),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            _getCategoryIcon(productDetails.categoryName ?? ''),
                                            size: 80,
                                            color: Color(0xFF00ADD9),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              )
                                  : Center(
                                child: Icon(
                                  _getCategoryIcon(productDetails.categoryName ?? ''),
                                  size: 80,
                                  color: Color(0xFF00ADD9),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Wrap(
                              children: [
                                Text(
                                  productDetails.name ?? 'Product',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  ' (${productDetails.measure?.toString() ?? ''} ${productDetails.unit ?? ''})',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ...List.generate(5, (index) {
                                      if (index < 4) {
                                        return Icon(Icons.star, color: Colors.amber, size: 18);
                                      } else if (index == 4) {
                                        return Icon(Icons.star_half, color: Colors.amber, size: 18);
                                      } else {
                                        return Icon(Icons.star_border, color: Colors.grey[300], size: 18);
                                      }
                                    }),
                                    SizedBox(width: 6),
                                    Text(
                                      '4.5',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${productDetails.price?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Every Aavin milk and dairy product comes with a guarantee of purity, quality, and freshness. This product is 100% natural and rich in nutrition, ensuring the health and taste of your family.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20,right: 20, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha:0.1),
                            blurRadius: 10,
                            offset: Offset(0, -7),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: _buildModalCartButton(productDetails.toJson(), setModalState, (updatedProduct) {
                          productDetails = ProductModel.fromJson(updatedProduct);
                          setModalState(() {});
                        }),
                      ),
                    ),
                  ],
                ),
              ),)
            ],
          )),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load product details');
    }
  }



  Future<void> _addToCartModal(Map<String, dynamic> product, StateSetter setModalState, {bool isIncrement = true, Function(Map<String, dynamic>)? onProductUpdate}) async {
    try {
      int currentQuantity = product['cart_quantity'] ?? 0;
      double newQuantity = isIncrement ? currentQuantity + 1 : (currentQuantity > 0 ? currentQuantity - 1 : 0.0);
      
      final apiService = Get.find<ApiService>();
      final globalCartService = Get.find<GlobalCartService>();
      
      final homeController = Get.find<HomeController>();
      final slot = homeController.slots.firstWhere(
        (s) => s.shift == 0,
        orElse: () => homeController.slots.isNotEmpty ? homeController.slots.first : SlotModel(),
      );
      final slotId = slot.id ?? 1;
      
      await apiService.updateCart(
        productId: product['id'],
        quantity: newQuantity,
        shiftType: 0,
        slotId: slotId,
        orderType: 2
      );
      
      await globalCartService.refreshCartEstimate(shiftType: 0);
      
      final updatedProduct = await apiService.getProductById(product['id']);
      product['cart_quantity'] = updatedProduct['cart_quantity'] ?? newQuantity;
      
      if (onProductUpdate != null) {
        onProductUpdate(updatedProduct);
      }
      await controller.refreshData();
      
      // Get.snackbar(
      //   'Success',
      //   newQuantity > 0 ? '${product['name']} ${isIncrement ? 'added to' : 'updated in'} cart' : '${product['name']} removed from cart',
      //   backgroundColor: Colors.grey.withValues(alpha:0.2),
      //   colorText: Colors.white,
      //   duration: Duration(seconds: 1),
      // );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  Future<void> _removeFromCartModal(Map<String, dynamic> product, StateSetter setModalState, {Function(Map<String, dynamic>)? onProductUpdate}) async {
    try {
      final apiService = Get.find<ApiService>();
      final globalCartService = Get.find<GlobalCartService>();
      
      final homeController = Get.find<HomeController>();
      final slot = homeController.slots.firstWhere(
        (s) => s.shift == 0,
        orElse: () => homeController.slots.isNotEmpty ? homeController.slots.first : SlotModel(),
      );
      final slotId = slot.id ?? 1;
      
      await apiService.updateCart(
        productId: product['id'],
        quantity: 0.0,
        shiftType: 0,
        slotId: slotId,
        orderType: 2
      );
      
      await globalCartService.refreshCartEstimate(shiftType: 0);
      
      final updatedProduct = await apiService.getProductById(product['id']);
      product['cart_quantity'] = updatedProduct['cart_quantity'] ?? 0;
      
      if (onProductUpdate != null) {
        onProductUpdate(updatedProduct);
      }
      await controller.refreshData();
      
      Get.snackbar(
        'Success',
        '${product['name']} removed from cart',
        backgroundColor: Colors.grey.withValues(alpha:0.2),
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }



  Widget _buildMostPopularSection(context, AnimationController shimmerController) {
    return Obx(() {
      if (controller.selectedCategoryId.value != null) {
        return _buildCategoryProductsSection(context, shimmerController);
      }
    


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Popular',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: controller.isLoadingPopular.value ? 4 : (controller.popularProducts.isEmpty ? 1 : controller.popularProducts.length),
          itemBuilder: (context, index) {
            if (controller.isLoadingPopular.value) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: shimmerController,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
                                  stops: [0.0, 0.5, 1.0],
                                  begin: Alignment(-1.0 + shimmerController.value * 2, 0.0),
                                  end: Alignment(1.0 + shimmerController.value * 2, 0.0),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 14,
                        color: Colors.grey[200],
                      ),
                      SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 60,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (controller.popularProducts.isEmpty) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_basket_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No popular products available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            final product = controller.popularProducts[index];
            return GestureDetector(
              onTap: () => _showProductDetails(product.id!,context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF00ADD9).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(product.categoryName ?? ''),
                              size: 40,
                              color: Color(0xFF00ADD9),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 8),
                    Text(
                      product.name ?? 'Unknown Product',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${product.measure ?? ''} ${product.unit ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00ADD9),
                          ),
                        ),
                        _buildCartButton(product),
                      ],
                    ),
                  ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
      );
    });
  }

  Widget _buildCartButton(ProductModel product) {
    int cartQuantity = product.cartQuantity ?? 0;
    
    if (cartQuantity == 0) {
      return CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
        onPressed: () => controller.addToCart(product), minimumSize: Size(0, 0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00ADD9), Color(0xFF0088CC)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00ADD9).withValues(alpha:0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'ADD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00ADD9), Color(0xFF0088CC)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ADD9).withValues(alpha:0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.only(left:5,top: 5,bottom: 5),
            onPressed: () => controller.addToCart(product, isIncrement: false),
            minimumSize: Size(0, 0),
            child: Icon(
              CupertinoIcons.minus,
              color: Colors.white,
              size: 12,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$cartQuantity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.only(right:5,top: 5,bottom: 5),
            onPressed: () => controller.addToCart(product),
            minimumSize: Size(0, 0),
            child: Icon(
              CupertinoIcons.plus,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalCartButton(Map<String, dynamic> product, StateSetter setModalState, [Function(Map<String, dynamic>)? onProductUpdate]) {
    int cartQuantity = product['cart_quantity'] ?? 0;
    
    if (cartQuantity == 0) {
      return SizedBox(
        width: double.infinity,
        // height: 50,
        child: ElevatedButton(
          onPressed: () async {
            await _addToCartModal(product, setModalState, onProductUpdate: onProductUpdate);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00ADD9),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'ADD TO CART',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: Container(
            // height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF00ADD9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00ADD9).withValues(alpha:0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await _addToCartModal(product, setModalState, isIncrement: false, onProductUpdate: onProductUpdate);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$cartQuantity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await _addToCartModal(product, setModalState, onProductUpdate: onProductUpdate);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        SizedBox(
          height: 40,
          width: 40,
          child: ElevatedButton(
            onPressed: () async {
              await _removeFromCartModal(product, setModalState, onProductUpdate: onProductUpdate);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              elevation: 2,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Icon(
              Icons.delete,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProductsSection(context, AnimationController shimmerController) {
    CategoryModel? selectedCategory;
    try {
      selectedCategory = controller.categories.firstWhere(
        (cat) => cat.id == controller.selectedCategoryId.value,
      );
    } catch (e) {
      selectedCategory = null;
    }
    
    final categoryName = selectedCategory?.name ?? 'Category';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.isLoadingProducts.value ? 4 : (controller.categoryProducts.isEmpty ? 1 : controller.categoryProducts.length),
            itemBuilder: (context, index) {
              if (controller.isLoadingProducts.value) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AnimatedBuilder(
                              animation: shimmerController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
                                      stops: [0.0, 0.5, 1.0],
                                      begin: Alignment(-1.0 + shimmerController.value * 2, 0.0),
                                      end: Alignment(1.0 + shimmerController.value * 2, 0.0),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 14,
                          color: Colors.grey[200],
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: 60,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (controller.categoryProducts.isEmpty) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No products found in this category',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final product = controller.categoryProducts[index];
              return GestureDetector(
                onTap: () => _showProductDetails(product.id!,context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF00ADD9).withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                _getCategoryIcon(product.categoryName ?? ''),
                                size: 40,
                                color: Color(0xFF00ADD9),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 8),
                      Text(
                        product.name ?? 'Unknown Product',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${product.measure ?? ''} ${product.unit ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${product.price?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00ADD9),
                            ),
                          ),
                          _buildCartButton(product),
                        ],
                      ),
                    ],
                  ),
                  ),
                ));
              },
          ),
      ],
    );
  }

  Widget _buildCartSummary() {
    final globalCartService = Get.find<GlobalCartService>();
    return Obx(() {
      final totalItems = globalCartService.totalItems;
      final totalAmount = globalCartService.totalAmount;
      
      if (totalItems == 0) {
        return SizedBox.shrink();
      }
      
      return Container(
        margin: const EdgeInsets.only(left:40,right: 40,bottom: 4),
        padding: const EdgeInsets.only(left:20,right: 20,top:8,bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha:0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalItems items Added',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await Get.toNamed('/cart');
                controller.refreshData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'OPEN CART',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}