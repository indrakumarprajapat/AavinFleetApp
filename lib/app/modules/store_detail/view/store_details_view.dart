import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../models/delivery_model.dart';
import '../../delivery/controllers/delivery_controller.dart';
import '../controller/store_details_controller.dart';

class StoreDetailsView extends GetView<StoreDetailsController> {
  const StoreDetailsView({super.key});

  // ── Brand Palette (Synced with Home/Delivery) ──────────────────
  static const _teal1 = Color(0xFF005F80);
  static const _teal2 = Color(0xFF007EA7);
  static const _teal3 = Color(0xFF009CBF);
  static const _teal4 = Color(0xFF1BA6C8);
  static const _tealBg = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back(); // Standard back within the trip is allowed
      },
      child: Scaffold(
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
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                /// STORE CARD
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                                  child: Container(
                                    padding: EdgeInsets.all(w * 0.04),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color: _teal3.withOpacity(0.1)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
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
                                            borderRadius: BorderRadius.circular(16),
                                            color: _tealBg,
                                          ),
                                          child: Icon(Icons.store_rounded,
                                              size: w * 0.08, color: _teal2),
                                        ),
                                        SizedBox(width: w * 0.04),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Booth ${s.number}",
                                                style: TextStyle(
                                                  fontSize: w * 0.048,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1A2E3A),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                s.address,
                                                style: TextStyle(
                                                    color: Colors.blueGrey.shade400,
                                                    fontSize: w * 0.034,
                                                    height: 1.2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: h * 0.015),

                                /// AGENT INFO CARD
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                                  child: Container(
                                    padding: EdgeInsets.all(w * 0.04),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFEDF2F7)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: _tealBg,
                                          child: const Icon(Icons.person, color: _teal2),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s.agentName ?? "Booth Agent",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF1A2E3A),
                                                ),
                                              ),
                                              if (s.agentPhone != null)
                                                Text(
                                                  s.agentPhone!,
                                                  style: TextStyle(color: Colors.blueGrey.shade400),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (s.agentPhone != null)
                                          IconButton(
                                            onPressed: () => controller.callAgent(),
                                            icon: const Icon(Icons.call, color: Colors.green),
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.green.shade50,
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
                                              color: const Color(0xFFFFF7ED),
                                              borderRadius: BorderRadius.circular(15),
                                              border:
                                                  Border.all(color: const Color(0xFFFFEDD5)),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.history_rounded,
                                                    color: Color(0xFFC2410C)),
                                                SizedBox(width: w * 0.03),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "Remaining Trays",
                                                        style: TextStyle(
                                                          color: Color(0xFF7C2D12),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Pending from previous trip",
                                                        style: TextStyle(
                                                          color: const Color(0xFF9A3412).withOpacity(0.8),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  "${s.remainingTrays}",
                                                  style: const TextStyle(
                                                    color: Color(0xFF7C2D12),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (controller.isLoading.value)
                                        const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: CircularProgressIndicator(color: _teal2),
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
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, double h) {
    return Container(
      width: double.infinity,
      height: h * 0.14,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10, left: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_teal1, _teal2, _teal3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30, right: -30,
            child: _circle(120, Colors.white.withOpacity(0.08)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 40),
                    child: Text(
                      "BOOTH DETAILS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  /// DELIVERY UI
  Widget _buildDeliverySection(StoreDetailsController controller, DeliveryModel s, double w, double h) {
    const headerStyle = TextStyle(
        fontWeight: FontWeight.bold, color: Color(0xFF1A2E3A), fontSize: 15);
    const itemStyle = TextStyle(fontSize: 15, color: Color(0xFF4A5568));

    if (s.products.isEmpty && s.totalTrays == 0 && s.totalPackets == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (s.products.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
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
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: Divider(thickness: 1, color: const Color(0xFFEDF2F7), height: 1),
          ),
          const SizedBox(height: 6),
          ...s.products.map((product) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 8),
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
                ),
              ],
            );
          }),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: Divider(thickness: 1, color: const Color(0xFFEDF2F7), height: 1),
          ),
          const SizedBox(height: 6),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 8),
          child: Row(
            children: [
              const Expanded(
                  flex: 4,
                  child: Text("Total Inventory",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A2E3A)))),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("${s.totalTrays}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15, color: _teal2)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text("${s.totalPackets}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15, color: _teal2)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _issueBadge({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  /// COLLECTION UI
  Widget _buildCollectionSection(StoreDetailsController controller, DeliveryModel s, double w, double h) {
    final int expectedCount = s.totalTrays > 0 ? s.totalTrays : s.remainingTrays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: const Text(
            "Tray Collection",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E3A),
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
                  "Expected",
                  "$expectedCount",
                  w,
                  h,
                ),
              ),
              SizedBox(width: w * 0.04),
              Expanded(
                child: (s.status == DeliveryStatus.collected)
                    ? _infoBox(
                        "Collected",
                        "${s.collectedTrays}",
                        w,
                        h,
                        isCollected: true,
                      )
                    : Container(
                        height: h * 0.11,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _teal2,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _teal2.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _teal1,
                          ),
                          decoration: const InputDecoration(
                            hintText: "0",
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

  Widget _infoBox(String title, String value, double w, double h, {bool isCollected = false}) {
    return Container(
      height: h * 0.11,
      decoration: BoxDecoration(
        color: isCollected ? const Color(0xFFF0FDF4) : _tealBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCollected ? const Color(0xFFDCFCE7) : Colors.transparent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  color: isCollected ? const Color(0xFF166534) : Colors.blueGrey, 
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCollected ? const Color(0xFF166534) : _teal1)),
        ],
      ),
    );
  }

  Widget _statusBox(String text, Color color, double w, double h) {
    return Container(
      width: double.infinity,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
          SizedBox(width: w * 0.03),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.1),
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

    final isLastBooth = controller.deliveryController.getNextStore(s) == null;

    String actionText = isCollection
        ? (isLastBooth ? "Submit Trip" : "Mark Collected")
        : "Mark Delivered";
    String doneText = isCollection ? "Collected" : "Delivered";

    return Container(
      padding: EdgeInsets.fromLTRB(w * 0.05, 12, w * 0.05, MediaQuery.of(Get.context!).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDone) ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: _teal2,
                side: const BorderSide(color: _teal2, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => controller.openMap(),
              icon: const Icon(Icons.near_me_rounded, size: 20),
              label: const Text("GET DIRECTIONS", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: isLastBooth && isCollection ? Colors.green.shade600 : _teal2,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: isLoading
                  ? null
                  : () => isCollection
                      ? controller.markCollected()
                      : controller.markDelivered(),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(actionText.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
            ),
          ] else ...[
            _statusBox(doneText, const Color(0xFF166534), w, h),
          ]
        ],
      ),
    );
  }
}
