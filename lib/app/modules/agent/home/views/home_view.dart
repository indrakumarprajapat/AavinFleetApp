import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../config/app_config.dart';
import '../../../../services/global_cart_service.dart';
import '../../../../utils/parse-util.dart';
import '../../../delivery/view/delivery_route_view.dart';
import '../controllers/home_controller.dart';
import '../../drawer/views/agent_drawer_view.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final config = Get.find<ClientConfig>();

  // ── Brand colours ──────────────────────────────────────────────
  static const _teal1 = Color(0xFF005F80);
  static const _teal2 = Color(0xFF007EA7);
  static const _teal3 = Color(0xFF009CBF);
  static const _teal4 = Color(0xFF1BA6C8);
  static const _teal5 = Color(0xFF00ADD3);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isTripStarted.value) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: AgentDrawer(),
          body: const DeliveryRouteView(),
        );
      }

      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF0F4F8),
        drawer: AgentDrawer(),
        body: RefreshIndicator(
          color: _teal2,
          onRefresh: () async => controller.loadRouteDetails(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildHomeContent()),
            ],
          ),
        ),
        bottomNavigationBar: _buildFooter(),
      );
    });
  }

  // ────────────────────────────────────────────────────────────────
  //  SLIVER APP BAR
  // ────────────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return Obx(() {
      final isLocSubmitted = controller.boothDetails?.isLocSubmit == true;
      final routeName = controller.routeDetail.value?.routeName ??
          controller.routeDetail.value?.routeId?.toString() ??
          controller.fleetUser?.routeName ??
          '';
      final regNumber =
          controller.fleetUser?.vehicleRegistrationNumber ?? '';
      final shift = controller.routeDetail.value?.shift;
      final shiftText = shift == 1
          ? 'Morning'
          : shift == 2
          ? 'Evening'
          : '';

      return SliverAppBar(
        expandedHeight: 178,
        pinned: true,
        stretch: true,
        backgroundColor: _teal1,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: FlexibleSpaceBar(
          background: _buildHeader(
            isLocSubmitted: isLocSubmitted,
            routeName: routeName,
            regNumber: regNumber,
            shiftText: shiftText,
          ),
          stretchModes: const [
            StretchMode.zoomBackground,
            StretchMode.blurBackground,
          ],
        ),
      );
    });
  }

  Widget _buildHeader({
    required bool isLocSubmitted,
    required String routeName,
    required String regNumber,
    required String shiftText,
  }) {
    final now = DateTime.now();
    final dateText =
        '${now.day} ${_monthName(now.month)} ${now.year}';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_teal1, _teal2, _teal3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            top: -40, right: -40,
            child: _circle(180, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            bottom: -20, left: 60,
            child: _circle(120, Colors.white.withOpacity(0.04)),
          ),
          // content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top row
                Row(
                  children: [
                    _iconBtn(
                      icon: Icons.menu_rounded,
                      onTap: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.app_title.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                          Text(
                            controller.fleetUser?.name ??
                                'Delivery Partner',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCartIcon(isLocSubmitted),
                  ],
                ),
                const SizedBox(height: 16),
                // route
                Text(
                  'CURRENT ROUTE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  routeName.isEmpty ? 'No Route Assigned' : routeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                // badges row (Date left, Vehicle right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (shiftText.isNotEmpty) ...[
                          _headerBadge(
                            icon: shiftText == 'Morning'
                                ? Icons.wb_sunny_rounded
                                : Icons.nights_stay_rounded,
                            label: shiftText,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _headerBadge(
                          icon: Icons.calendar_today_rounded,
                          label: dateText,
                        ),
                      ],
                    ),
                    if (regNumber.isNotEmpty)
                      _headerBadge(
                        icon: Icons.local_shipping_outlined,
                        label: regNumber,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  HOME CONTENT
  // ────────────────────────────────────────────────────────────────
  Widget _buildHomeContent() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: Get.height * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
      child: Obx(() {
        if (controller.isLoading) {
          return const SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(color: _teal2),
            ),
          );
        }

        if (controller.products.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 14),
            _buildCategoryFilters(),
            const SizedBox(height: 20),
            _buildListHeader(),
            const SizedBox(height: 14),
            _buildProductList(),
            const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: TextField(
        onChanged: (v) => controller.searchQuery.value = v,
        style: const TextStyle(fontSize: 14, color: Color(0xFF263238)),
        decoration: InputDecoration(
          hintText: 'Search products…',
          hintStyle: TextStyle(
              color: Colors.blueGrey.shade200, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.blueGrey.shade200,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ── Category chips ──────────────────────────────────────────────
  Widget _buildCategoryFilters() {
    final categories = ['All', 'Milk', 'Curd'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          return Obx(() {
            final isSelected =
                controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.selectedCategory.value = cat,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _teal2 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? _teal2
                        : const Color(0xFFE2ECF2),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: _teal2.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF607D8B),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────
  Widget _buildListHeader() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _teal2,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Trip Inventory',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2E3A),
          ),
        ),
        const Spacer(),
        Obx(() => Text(
          '${controller.filteredProducts.length} Items',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFFA0B4C4),
            fontWeight: FontWeight.w500,
          ),
        )),
      ],
    );
  }

  // ── Product list ────────────────────────────────────────────────
  Widget _buildProductList() {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(40),
          width: double.infinity,
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No matching products found',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredProducts.length,
        itemBuilder: (_, i) =>
            _buildProductCard(controller.filteredProducts[i]),
      );
    });
  }

  // ────────────────────────────────────────────────────────────────
  //  PRODUCT CARD
  // ────────────────────────────────────────────────────────────────
  Widget _buildProductCard(dynamic product) {
    final leak = ParseUtil.parseInt(product['leak']) ?? 0;
    final minus = ParseUtil.parseInt(product['pkt_minus']) ?? 0;
    final plus = ParseUtil.parseInt(product['pkt_plus']) ?? 0;
    final hasIssues = leak > 0 || minus > 0 || plus > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasIssues
              ? const Color(0xFF99C9D7)
              : const Color(0xFFEDF2F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── card header ──
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasIssues
                  ? const Color(0xFFE6F7F9)
                  : const Color(0xFFF9FBFC),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                bottom: BorderSide(
                  color: hasIssues
                      ? const Color(0xFFB2EBF2)
                      : const Color(0xFFF0F5F8),
                ),
              ),
            ),
            child: Row(
              children: [
                // icon box
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _productIcon(
                        product['product_name']?.toString() ?? ''),
                    size: 18,
                    color: _teal2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    product['product_name']?.toString() ??
                        'Unknown Product',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2E3A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── stats row ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _statItem(
                        label: 'Packets',
                        value:
                        '${product['qty_pkt'] ?? product['pkt_qty'] ?? 0}',
                        color: _teal2,
                      ),
                      _verticalDivider(),
                      _statItem(
                        label: 'Trays',
                        value:
                        '${product['tray'] ?? product['total_tray'] ?? 0}',
                        color: _teal4,
                      ),
                      _verticalDivider(),
                      _statItem(
                        label: 'Litres',
                        value:
                        '${product['qty_ltr'] ?? product['litre'] ?? 0}L',
                        color: _teal5,
                      ),
                    ],
                  ),
                ),

                // ── issue badges ──
                if (hasIssues) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFF0F4F7),
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (leak > 0)
                          _issueBadge(
                            icon: Icons.water_damage_rounded,
                            label: 'Leak: $leak',
                            bg: const Color(0xFFFEE2E2),
                            fg: const Color(0xFFC0392B),
                          ),
                        if (minus > 0)
                          _issueBadge(
                            icon: Icons.remove_circle_outline_rounded,
                            label: 'Short: $minus',
                            bg: const Color(0xFFFCE8B5),
                            fg: const Color(0xFFCE8211),
                          ),
                        if (plus > 0)
                          _issueBadge(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'Extra: $plus',
                            bg: const Color(0xFFD4F0E0),
                            fg: const Color(0xFF1A7A42),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  FOOTER
  // ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Obx(() {
            final hasTrip = controller.tripId.value != 0;
            return SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: hasTrip
                      ? const LinearGradient(
                          colors: [_teal3, _teal2],
                        )
                      : null,
                  color: hasTrip ? null : Colors.grey.shade300,
                  boxShadow: hasTrip
                      ? [
                          BoxShadow(
                            color: _teal2.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: (controller.isLoading || !hasTrip)
                      ? null
                      : controller.startDelivery,
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          hasTrip ? 'START DELIVERY' : 'NO TRIP ASSIGNED',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  EMPTY STATE
  // ────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/namakkalanimation.json',
            height: 220,
            repeat: true,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found for this trip',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh or check later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: controller.loadRouteDetails,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh Now'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal2,
              side: const BorderSide(color: _teal2),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  CART ICON
  // ────────────────────────────────────────────────────────────────
  Widget _buildCartIcon(bool isLocSubmitted) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _iconBtn(
          icon: Icons.shopping_cart_outlined,
          onTap: isLocSubmitted ? () => Get.toNamed('/cart') : null,
        ),
        Obx(() {
          try {
            final count = Get.find<GlobalCartService>().itemsCount;
            if (count > 0) {
              return Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                      minWidth: 16, minHeight: 16),
                  child: Text(
                    '$count',
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
          } catch (_) {}
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  SMALL HELPERS
  // ────────────────────────────────────────────────────────────────
  Widget _iconBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _headerBadge({required IconData icon, required String label}) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94AAB8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
    width: 1,
    margin: const EdgeInsets.symmetric(vertical: 4),
    color: const Color(0xFFEDF2F7),
  );

  Widget _issueBadge({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  IconData _productIcon(String name) {
    final n = name.toLowerCase();
    bool isMilk = n.contains('milk') || 
                 n.contains('tm ') || 
                 n.contains('std ') || 
                 n.contains('fcm ') || 
                 n.contains('sgm ');
                 
    bool isCurd = n.contains('curd') || 
                 n.contains('bm jar');

    if (isMilk) return Icons.water_drop_rounded;
    if (isCurd) return Icons.egg_rounded;
    if (n.contains('ghee')) return Icons.local_fire_department_rounded;
    if (n.contains('butter')) return Icons.breakfast_dining_rounded;
    return Icons.category_rounded;
  }

  String _monthName(int m) => [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];
}
