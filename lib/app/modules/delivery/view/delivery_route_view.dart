import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aavin/app/models/app_mode.dart';
import 'package:aavin/app/modules/agent/home/controllers/home_controller.dart';
import 'package:aavin/app/config/app_config.dart';
import 'package:aavin/app/models/delivery_model.dart';
import 'package:aavin/app/widgets/delivery_card.dart';
import 'package:aavin/app/modules/delivery/controllers/delivery_controller.dart';
import 'package:get_storage/get_storage.dart';

class DeliveryRouteView extends GetView<DeliveryController> {
  const DeliveryRouteView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.deliveries.isEmpty) {
              return const Center(child: Text("No stores found for this route"));
            }

            final isCollectionMode = controller.appMode.value == AppMode.collection;

            return RefreshIndicator(
              onRefresh: () => controller.fetchRouteBooths(silent: true),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 160, 16, 20),
                itemCount: controller.deliveries.length,
                physics: const AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final store = controller.deliveries[index];
                  return DeliveryCard(
                    store: store,
                    onTap: () => controller.openStoreDetails(store),
                    isCollection: isCollectionMode,
                  );
                },
              ),
            );
          }),

          // Dynamic Header
          _buildDynamicHeader(w, h),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildBottomButton() {
    return Obx(() {
      final isDeliveryMode = controller.appMode.value == AppMode.delivery;
      final allDelivered = controller.deliveries.isNotEmpty &&
          controller.deliveries.every((s) => s.status == DeliveryStatus.delivered);
      final allCollected = controller.deliveries.isNotEmpty &&
          controller.deliveries.every((s) => s.status == DeliveryStatus.collected);

      bool showButton = false;
      String buttonText = "";
      VoidCallback? onPressed;

      if (isDeliveryMode && allDelivered) {
        showButton = true;
        buttonText = "START COLLECTION";
        onPressed = () => controller.initiateCollection();
      } else if (!isDeliveryMode && allCollected) {
        showButton = true;
        buttonText = "SUBMIT TRIP";
        onPressed = () => controller.showCompletionDialog();
      }

      if (!showButton) return const SizedBox.shrink();

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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2289a4),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: controller.isLoading.value ? null : onPressed,
              child: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDynamicHeader(double w, double h) {
    return Obx(() {
      final isCollection = controller.appMode.value == AppMode.collection;
      final title = isCollection ? "Collection Route" : "Delivery Route";

      return Container(
        height: 140,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00ADD3), Color(0xFF007EA7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.only(top: 40, left: 30, right: 20),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isCollection ? "COLLECTION" : "DELIVERY",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
