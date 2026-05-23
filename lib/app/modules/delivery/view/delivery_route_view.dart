import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../agent/drawer/views/agent_drawer_view.dart';
import '../../agent/home/controllers/home_controller.dart';
import '../../../config/app_config.dart';
import '../../../models/delivery_model.dart';
import '../../../widgets/delivery_card.dart';
import '../controllers/delivery_controller.dart';

class DeliveryRouteView extends GetView<DeliveryController> {
  const DeliveryRouteView({super.key});


  // ── Brand Palette (Professional Theme) ────────────────────────
  static const _teal1 = Color(0xFF005F80);
  static const _teal2 = Color(0xFF007EA7);
  static const _teal3 = Color(0xFF009CBF);
  static const _teal4 = Color(0xFF1BA6C8);
  static const _teal5 = Color(0xFF00ADD3);
  static const _tealBg = Color(0xFFF4F7F9);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final config = Get.find<ClientConfig>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.isTripCompleted.value) {
          Get.offAllNamed(Routes.HOME);
          return;
        }
        Get.snackbar(
          "Trip in Progress",
          "You cannot go back until the trip is submitted or cancelled.",
          snackPosition: SnackPosition.TOP,
        );
      },
      child: Scaffold(
        backgroundColor: _tealBg,
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 160), // Adjusted for simplified header
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: _teal2),
                      );
                    }

                    if (controller.isTripCompleted.value) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                  )
                                ],
                              ),
                              child: Icon(Icons.route_outlined, size: 64, color: Colors.blueGrey.shade200),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "No active trip",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.blueGrey.shade800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "You don't have any trips in progress.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey.shade400,
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => Get.offAllNamed(Routes.HOME),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _teal2,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "GO TO HOME",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final isCollection =
                        controller.appMode.value == AppMode.collection;

                    final originalDeliveries = controller.deliveries;
                    final deliveries = isCollection
                        ? originalDeliveries.reversed.toList()
                        : originalDeliveries;

                    if (deliveries.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined, size: 64, color: Colors.blueGrey.shade100),
                            const SizedBox(height: 16),
                            Text(
                              "No deliveries available",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey.shade300,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(w * 0.05, 10, w * 0.05, 40),
                            physics: const BouncingScrollPhysics(),
                            itemCount: deliveries.length,
                            itemBuilder: (context, index) {
                              final delivery = deliveries[index];

                              DeliveryStatus status;

                              if (isCollection) {
                                final originalIndex = originalDeliveries.indexOf(delivery);
                                final currentActive = controller.currentCollectingIndex.value;

                                if (delivery.apiIsCollected ||
                                    delivery.collectedTrays > 0 ||
                                    delivery.status == DeliveryStatus.collected) {
                                  status = DeliveryStatus.collected;
                                } else if (originalIndex == currentActive) {
                                  status = DeliveryStatus.collecting;
                                } else {
                                  status = DeliveryStatus.toBeCollected;
                                }
                              } else {
                                status = delivery.status;
                              }

                              return Padding(
                                padding: EdgeInsets.only(bottom: h * 0.015),
                                child: DeliveryCard(
                                  store: delivery,
                                  isCollection: isCollection,
                                  status: status,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
            _buildCustomHeader(h, w, config),
          ],
        ),
        bottomNavigationBar: Obx(() => controller.isTripCompleted.value 
            ? const SizedBox.shrink() 
            : _buildBottomActions(h, w)),
      ),
    );
  }

  Widget _buildBottomActions(double h, double w) {
    return Obx(() {
      final isCollection = controller.appMode.value == AppMode.collection;
      final deliveries = controller.deliveries;

      bool showCollectionBtn = controller.appMode.value == AppMode.delivery &&
          deliveries.isNotEmpty &&
          deliveries.every((d) => d.status == DeliveryStatus.delivered || d.status == DeliveryStatus.collected);

      bool showSubmitBtn = controller.appMode.value == AppMode.collection &&
          deliveries.isNotEmpty &&
          deliveries.every((d) => d.apiIsCollected ||
                                  d.collectedTrays > 0 ||
                                  d.status == DeliveryStatus.collected);

      if (!showCollectionBtn && !showSubmitBtn) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: showSubmitBtn ? Colors.green.shade600 : _teal2,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                if (showSubmitBtn) {
                  controller.showCompletionDialog();
                } else {
                  controller.initiateCollection();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    showSubmitBtn ? "SUBMIT TRIP" : "START COLLECTION",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCustomHeader(double h, double w, ClientConfig config) {
    final now = DateTime.now();
    final dateText = "${now.day} ${_getMonthName(now.month)} ${now.year}";

    return Obx(() {
      final isCollection = controller.appMode.value == AppMode.collection;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_teal1, _teal2, _teal3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative circles matching HomeView style
            Positioned(
              top: -45,
              right: -45,
              child: _circle(160, Colors.white.withOpacity(0.07)),
            ),
            Positioned(
              bottom: -40,
              left: 30,
              child: _circle(100, Colors.white.withOpacity(0.05)),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBtn(
                      icon: Icons.arrow_back,
                      onTap: () {
                        if (controller.isTripCompleted.value) {
                          Get.offAllNamed(Routes.HOME);
                        } else {
                          Get.snackbar(
                            "Trip in Progress",
                            "You cannot go back until the trip is submitted or cancelled.",
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isCollection ? "Collection Mode" : "Delivery Mode",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _headerBadge(
                      icon: Icons.calendar_today_rounded,
                      label: dateText,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _iconBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _headerBadge({required IconData icon, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  String _getMonthName(int month) {
    return [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ][month];
  }
}
