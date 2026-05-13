import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../models/delivery_model.dart';
import '../../delivery/controllers/delivery_controller.dart';
import '../controller/store_details_controller.dart';

class StoreDetailsView extends GetView<StoreDetailsController> {
  const StoreDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text("Booth ${controller.store?.number ?? ''}",
            style: TextStyle(
                fontSize: w * 0.05,
                fontWeight: FontWeight.w500,
                color: Colors.white))),
        centerTitle: true,
        backgroundColor: const Color(0xff1BA6C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final s = controller.store;
        if (s == null) {
          return const Center(child: Text("Store data not found"));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: h * 0.03),

                    /// STORE CARD
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                      child: Container(
                        padding: EdgeInsets.all(w * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.blue.shade100.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: w * 0.16,
                              width: w * 0.16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xffE3F2FD),
                              ),
                              child: Icon(Icons.store_rounded,
                                  size: w * 0.08, color: const Color(0xff1BA6C8)),
                            ),
                            SizedBox(width: w * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Booth ${s.number}",
                                          style: TextStyle(
                                            fontSize: w * 0.048,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: w * 0.02,
                                            vertical: h * 0.004),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff90CAF9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "#${s.boothId}",
                                          style: TextStyle(
                                            fontSize: w * 0.028,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: h * 0.005),
                                  Text(
                                    s.address,
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: w * 0.032,
                                        height: 1.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.04),

                    /// MODE SWITCH (Scrollable Content)
                    Obx(() {
                      final isCollection =
                          controller.deliveryController.appMode.value ==
                              AppMode.collection;

                      return Column(
                        children: [
                          if (s.remainingTrays > 0)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.05, vertical: h * 0.01),
                              child: Container(
                                padding: EdgeInsets.all(w * 0.04),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: Colors.orange.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.history,
                                        color: Colors.orange.shade800),
                                    SizedBox(width: w * 0.03),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Remaining Trays",
                                            style: TextStyle(
                                              color: Colors.orange.shade900,
                                              fontWeight: FontWeight.bold,
                                              fontSize: w * 0.035,
                                            ),
                                          ),
                                          Text(
                                            "These trays were not collected in the last trip.",
                                            style: TextStyle(
                                              color: Colors.orange.shade700,
                                              fontSize: w * 0.03,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "${s.remainingTrays}",
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: w * 0.06,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (controller.isLoading.value)
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            )
                          else ...[
                            _buildDeliverySection(s, w, h),
                            if (isCollection) ...[
                              SizedBox(height: h * 0.04),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(),
                              ),
                              SizedBox(height: h * 0.02),
                              _buildCollectionSection(s, w, h),
                            ]
                          ],
                        ],
                      );
                    }),

                    SizedBox(height: h * 0.02),
                  ],
                ),
              ),
            ),

            /// STICKY ACTIONS
            Obx(() {
              final isCollection =
                  controller.deliveryController.appMode.value == AppMode.collection;
              final isGlobalLoading = controller.deliveryController.isLoading.value;
              return _buildStickyActions(s, w, h, isCollection, isGlobalLoading);
            }),
          ],
        );
      }),
    );
  }

  /// DELIVERY UI (Scrollable Table)
  Widget _buildDeliverySection(DeliveryModel s, double w, double h) {
    const headerStyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13);
    const itemStyle = TextStyle(fontSize: 13, color: Colors.black87);

    // If no products and no totals, show nothing
    if (s.products.isEmpty && s.totalTrays == 0 && s.totalPackets == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (s.products.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Row(
              children: [
                const Expanded(flex: 4, child: Text("Products", style: headerStyle)),
                const Expanded(
                    flex: 2, child: Center(child: Text("Tray", style: headerStyle))),
                const Expanded(
                    flex: 2,
                    child: Center(child: Text("Packets", style: headerStyle))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Divider(thickness: 1, color: Colors.grey.shade300, height: 1),
          ),
          const SizedBox(height: 8),
          ...s.products.map((product) => Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: Text(product.name, style: itemStyle)),
                    Expanded(
                        flex: 2,
                        child: Center(child: Text("${product.trays}", style: itemStyle))),
                    Expanded(
                        flex: 2,
                        child:
                            Center(child: Text("${product.packets}", style: itemStyle))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Divider(thickness: 1, color: Colors.grey.shade300, height: 1),
          ),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 8),
          child: Row(
            children: [
              const Expanded(
                  flex: 4,
                  child: Text("Delivery Summary",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              Expanded(
                flex: 2,
                child: Center(
                  child: Obx(() => Text("${controller.store?.totalTrays ?? 0}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14))),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Obx(() => Text("${controller.store?.totalPackets ?? 0}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// COLLECTION UI (Scrollable Content)
  Widget _buildCollectionSection(DeliveryModel s, double w, double h) {
    // Prioritize totalTrays (today's delivery) as the expected return.
    // Fallback to remainingTrays (residue) if totalTrays is 0.
    final int expectedCount = s.totalTrays > 0 ? s.totalTrays : s.remainingTrays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Text(
            "Collection Entry",
            style: TextStyle(
              fontSize: w * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        SizedBox(height: h * 0.015),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Row(
            children: [
              Expanded(
                child: _infoBox(
                  "Expected Trays",
                  "$expectedCount",
                  w,
                  h,
                ),
              ),
              SizedBox(width: w * 0.05),
              Expanded(
                child: (s.status == DeliveryStatus.collected)
                    ? _infoBox(
                        "Collected",
                        "${s.collectedTrays}",
                        w,
                        h,
                      )
                    : Container(
                        height: h * 0.12,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blue.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: controller.collectedTraysController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onTap: () {
                            controller.collectedTraysController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: controller.collectedTraysController.text.length,
                            );
                          },
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Collected",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String title, String value, double w, double h) {
    return Container(
      height: h * 0.12,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900)),
        ],
      ),
    );
  }

  Widget _statusBox(String text, Color color, double w, double h) {
    return Container(
      width: double.infinity,
      height: h * 0.07,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: color,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
          SizedBox(width: w * 0.03),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ],
      ),
    );
  }

  /// STICKY ACTIONS BAR
  Widget _buildStickyActions(
    DeliveryModel s,
    double w,
    double h,
    bool isCollection,
    bool isLoading,
  ) {
    bool isDone = isCollection
        ? s.status == DeliveryStatus.collected
        : s.status == DeliveryStatus.delivered;

    String actionText = isCollection ? "Mark Collected" : "Mark Delivered";
    String doneText = isCollection ? "Collected" : "Delivered";

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDone) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, h * 0.07),
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () => controller.openMap(),
              icon: const Icon(Icons.gps_fixed, size: 20),
              label: const Text("Get Directions"),
            ),
            SizedBox(height: h * 0.02),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, h * 0.07),
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: isLoading
                  ? null
                  : () => isCollection
                      ? controller.markCollected()
                      : controller.markDelivered(),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(actionText,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            _statusBox(doneText, const Color(0xFF4CAF50), w, h),
          ]
        ],
      ),
    );
  }
}
