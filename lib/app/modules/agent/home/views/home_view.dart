import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_config.dart';
import '../../../../services/global_cart_service.dart';
import '../../../delivery/view/delivery_route_view.dart';
import '../controllers/home_controller.dart';
import '../../drawer/views/agent_drawer_view.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final config = Get.find<ClientConfig>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;
      final isTripStarted = controller.isTripStarted.value;

      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8F8F8),
        drawer: AgentDrawer(),
        body: Stack(
          children: [
            isTripStarted ? const DeliveryRouteView() : _buildHomeContent(controller),
            if (!isTripStarted)
              Obx(() => _buildCustomHeader(
                    isLocationSubmitted,
                    controller.routeDetail.value?.routeName ??
                        controller.routeDetail.value?.routeId?.toString() ??
                        controller.fleetUser?.routeName ??
                        '',
                    controller.fleetUser?.vehicleRegistrationNumber ?? '',
                  )),
          ],
        ),
        bottomNavigationBar: isTripStarted ? null : _buildFooterView(),
      );
    });
  }

  Widget _buildHomeContent(HomeController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadRouteDetails();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.height * 0.18),

            /// Body Container
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
              child: Obx(() {
                if (controller.isLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF007EA7),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRouteView(),
                    const SizedBox(height: 10),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: Obx(
                () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1BA6C8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: controller.isLoading
                  ? null
                  : controller.startDelivery,
              child: controller.isLoading
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text(
                "START DELIVERY",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildRouteView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Obx(() {
          if (controller.products.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  "No products found for this trip.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return _buildProductCard(product);
            },
          );
        }),
      ],
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF01789D).withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          /// 🔹 Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFC1E7EF), // Light blue background
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // const Icon(Icons.inventory_2_rounded,
                //     size: 18, color: Color(0xFF007EA7)),
                // const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product['product_name']?.toString() ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF013B4B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                /// 🔹 Primary Stats
                Row(
                  children: [
                    _buildHighlightBox(
                      title: "Packet Qty",
                      value: "${product['qty_pkt'] ?? product['pkt_qty'] ?? 0}",
                      color: const Color(0xFF007EA7),
                      icon: Icons.grid_view_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildHighlightBox(
                      title: "Total Litre",
                      value: "${product['qty_ltr'] ?? product['litre'] ?? 0} L",
                      color: const Color(0xFF1BA6C8),
                      icon: Icons.water_drop_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// 🔹 Secondary Stats
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      _buildStatChip("Tray", "${product['tray'] ?? product['total_tray'] ?? 0}"),
                      _buildStatChip("+Pkt", "${product['pkt_plus'] ?? 0}", color: Colors.green),
                      _buildStatChip("-Pkt", "${product['pkt_minus'] ?? 0}", color: Colors.orange),
                      _buildStatChip("Leak", "${product['leak'] ?? product['leakes'] ?? 0}", color: Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, {Color color = Colors.blueGrey}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildCustomHeader(
    bool isLocationSubmitted,
    String routeName,
    String regNumber,
  ) {
    final now = DateTime.now();
    final dateText = "${now.day}-${now.month}-${now.year}";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: Get.height * 0.22,
          padding: const EdgeInsets.only(top: 35, left: 20, right: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00ADD3), Color(0xFF007EA7), Color(0xFF005F7A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 TOP BAR
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(Icons.menu, color: Colors.white, size: 26),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        config.app_title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  isLocationSubmitted
                      ? _buildCartIcon()
                      : CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                ],
              ),

              const SizedBox(height: 10),

              /// 🔹 ROUTE NAME
              Text(
                'Route: $routeName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  /// 🔹 VEHICLE NUMBER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Vehicle: $regNumber",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),

                  /// 🔥 DATE CHIP
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          dateText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartIcon() {
    return Stack(
      children: [
        Obx(() {
          final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;
          return IconButton(
            onPressed: isLocationSubmitted ? () => Get.toNamed('/cart') : null,
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 30,
            ),
          );
        }),
        Obx(() {
          try {
            final cartService = Get.find<GlobalCartService>();
            final totalItems = cartService.itemsCount;
            if (totalItems > 0) {
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$totalItems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } catch (e) {}
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
