import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:aavin/app/models/delivery_model.dart';
import 'package:aavin/app/models/app_mode.dart';
import 'package:aavin/app/modules/delivery/controllers/delivery_controller.dart';
import 'package:aavin/app/modules/store_detail/controller/store_details_controller.dart';

class StoreDetailsView extends GetView<StoreDetailsController> {
  const StoreDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Capture the controller instance locally to avoid "Controller not found" 
    // during route transitions when GetX disposes the controller.
    final controller = this.controller;
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: h * 0.16),
              Expanded(
                child: Obx(() {
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
                                          color: const Color(0xffBBDEFB),
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
                                              ],
                                            ),
                                            SizedBox(height: h * 0.005),
                                            Text(
                                              s.address,
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: w * 0.034,
                                                  height: 1.2),
                                            ),
                                            if (s.agentName != null || s.agentPhone != null) ...[
                                              const SizedBox(height: 12),
                                              Divider(color: Colors.grey.shade200, thickness: 1),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.person_outline_rounded, size: 16, color: Colors.blue.shade700),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      s.agentName ?? "Agent Name N/A",
                                                      style: TextStyle(
                                                        fontSize: w * 0.036,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  if (s.agentPhone != null)
                                                    GestureDetector(
                                                      onTap: () => controller.callAgent(),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.shade50,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(Icons.call, size: 18, color: Colors.green.shade700),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              if (s.agentPhone != null) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.phone_android_rounded, size: 16, color: Colors.blue.shade700),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      s.agentPhone!,
                                                      style: TextStyle(
                                                        fontSize: w * 0.034,
                                                        color: Colors.grey.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: h * 0.015),

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
                                            color: const Color(0xFFBBDEFB),
                                            borderRadius: BorderRadius.circular(15),
                                            border:
                                                Border.all(color: const Color(0xFF00ADD3).withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.history,
                                                  color: Color(0xFF007EA7)),
                                              SizedBox(width: w * 0.03),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Remaining Trays",
                                                      style: TextStyle(
                                                        color: const Color(0xFF007EA7),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: w * 0.035,
                                                      ),
                                                    ),
                                                    Text(
                                                      "These trays were not collected in the last trip.",
                                                      style: TextStyle(
                                                        color: const Color(0xFF007EA7).withValues(alpha: 0.7),
                                                        fontSize: w * 0.03,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${s.remainingTrays}",
                                                style: TextStyle(
                                                  color: const Color(0xFF007EA7),
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
                                      if (!isCollection)
                                        _buildDeliverySection(controller, s, w, h),
                                      if (isCollection)
                                        _buildCollectionSection(controller, s, w, h),
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
                        return _buildStickyActions(controller, s, w, h, isCollection, isGlobalLoading);
                      }),
                    ],
                  );
                }),
              ),
            ],
          ),
          _buildCustomHeader(context, h),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, double h) {
    return Container(
      width: double.infinity,
      height: h * 0.14,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 5),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 25),
          const Text(
            "Booth Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// DELIVERY UI (Scrollable Table)
  Widget _buildDeliverySection(StoreDetailsController controller, DeliveryModel s, double w, double h) {
    const headerStyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15);
    const itemStyle = TextStyle(fontSize: 15, color: Colors.black87);

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
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Divider(thickness: 1, color: Colors.grey.shade300, height: 1),
          ),
          const SizedBox(height: 6),
          ...s.products.map((product) => Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 6),
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
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: Divider(thickness: 1, color: Colors.grey.shade300, height: 1),
          ),
          const SizedBox(height: 6),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 6),
          child: Row(
            children: [
              const Expanded(
                  flex: 4,
                  child: Text("Total",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("${s.totalTrays}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("${s.totalPackets}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// COLLECTION UI (Scrollable Content)
  Widget _buildCollectionSection(StoreDetailsController controller, DeliveryModel s, double w, double h) {
    // Prioritize totalTrays (today's delivery) as the expected return.
    // Fallback to remainingTrays (residue) if totalTrays is 0.
    final int expectedCount = s.totalTrays > 0 ? s.totalTrays : s.remainingTrays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Text(
            "Collection ",
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
                  "Trays",
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
                            color: Colors.blue.shade100,
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
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                          decoration: const InputDecoration(
                            hintText: "0",
                            hintStyle: TextStyle(color: Colors.grey),
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
        mainAxisSize: MainAxisSize.min,
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 24),
          SizedBox(width: w * 0.03),
          Text(
            text.toUpperCase(),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  /// STICKY ACTIONS BAR
  Widget _buildStickyActions(
    StoreDetailsController controller,
    DeliveryModel s,
    double w,
    double h,
    bool isCollection,
    bool isLoading,
  ) {
    bool isDone = isCollection
        ? s.status == DeliveryStatus.collected
        : s.status == DeliveryStatus.delivered;

    // Check if this is the last booth in collection mode to show "Submit Trip"
    final isLastBooth = controller.deliveryController.getNextStore(s) == null;

    String actionText = isCollection
        ? (isLastBooth ? "Submit Trip" : "Mark Collected")
        : "Mark Delivered";
    String doneText = isCollection ? "Collected" : "Delivered";

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDone) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, h * 0.06),
                  backgroundColor: const Color(0xFFBBDEFB),
                  foregroundColor: const Color(0xFF007EA7),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  side: BorderSide(color: const Color(0xFF00ADD3).withOpacity(0.6), width: 1.5),
                ),
                onPressed: () => controller.openMap(),
                icon: const Icon(Icons.near_me_rounded, size: 20),
                label: const Text("GET DIRECTIONS",
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              ),
              SizedBox(height: h * 0.015),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, h * 0.065),
                  backgroundColor: const Color(0xFFC8E6C9),
                  foregroundColor: const Color(0xFF2E7D32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  side: BorderSide(color: const Color(0xFF81C784).withOpacity(0.6), width: 1.5),
                ),
                onPressed: isLoading
                    ? null
                    : () => isCollection ? controller.markCollected() : controller.markDelivered(),
                icon: isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Color(0xFF2E7D32), strokeWidth: 2))
                    : Text(actionText.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              ),
            ] else ...[
              _statusBox(doneText, const Color(0xFF2E7D32), w, h),
            ]
          ],
        ),
      ),
    );
  }
}
