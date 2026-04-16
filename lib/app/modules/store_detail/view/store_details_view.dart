import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../models/delivery_model.dart';
import '../../delivery/controllers/delivery_controller.dart';
import '../../delivery/view/delivery_route_view.dart';

class StoreDetailsView extends StatefulWidget {
  const StoreDetailsView({super.key});

  @override
  State<StoreDetailsView> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsView> {
  final DeliveryController controller = Get.find();

  late TextEditingController collectedTraysController;
  DeliveryModel? store;

  @override
  void initState() {
    super.initState();

    store = Get.arguments;

    collectedTraysController = TextEditingController(
      text: (store?.collectedTrays ?? 0) == 0
          ? ""
          : store!.collectedTrays.toString(),
    );
  }

  @override
  void dispose() {
    collectedTraysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    if (store == null) {
      return const Scaffold(
        body: Center(child: Text("Store data not found")),
      );
    }

    final s = store!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(s.storeName, style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.w500, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xff1BA6C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
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
                        border: Border.all(color: Colors.blue.shade100.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                                        s.storeName,
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
                                        "#${s.number}",
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
                        controller.appMode.value == AppMode.collection;

                    return Column(
                      children: [
                        if (!isCollection)
                          _buildDeliverySection(s, w, h),

                        if (isCollection)
                          _buildCollectionSection(s, w, h),
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
            final isCollection = controller.appMode.value == AppMode.collection;
            return _buildStickyActions(s, w, h, isCollection);
          }),
        ],
      ),
    );
  }

  /// DELIVERY UI (Scrollable Table)
  Widget _buildDeliverySection(DeliveryModel s, double w, double h) {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text("Items", style: headerStyle)),
              Expanded(child: Center(child: Text("Tray", style: headerStyle))),
              Expanded(child: Center(child: Text("Packet", style: headerStyle))),
              Expanded(child: Center(child: Text("Tub", style: headerStyle))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Divider(thickness: 1, color: Colors.grey.shade300, height: 1),
        ),
        const SizedBox(height: 8),

        ...s.products.map((product) => Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: 8),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(product.name, style: const TextStyle(fontSize: 15, color: Colors.black87))),
              Expanded(child: Center(child: Text("${product.trays}", style: const TextStyle(fontSize: 15)))),
              Expanded(child: Center(child: Text("${product.packets}", style: const TextStyle(fontSize: 15)))),
              Expanded(child: Center(child: Text("${product.tubs}", style: const TextStyle(fontSize: 15)))),
            ],
          ),
        )),
        
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Divider(thickness: 1, color: Colors.grey.shade300, height: 1),
        ),
        const SizedBox(height: 8),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: 8),
          child: Row(
            children: [
              const Expanded(flex: 3, child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Expanded(child: Center(child: Text("${s.totalTrays}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
              Expanded(child: Center(child: Text("${s.totalPackets}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
              Expanded(child: Center(child: Text("${s.totalTubs}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
            ],
          ),
        ),
      ],
    );
  }

  /// COLLECTION UI (Scrollable Content)
  Widget _buildCollectionSection(DeliveryModel s, double w, double h) {
    final isCollected = s.collectedTrays > 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
      child: Row(
        children: [
          Expanded(
            child: _infoBox("Total Trays", "${s.totalTrays}", w, h),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: isCollected
                ? _infoBox("Collected", "${s.collectedTrays}", w, h)
                : TextField(
              controller: collectedTraysController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Collected",
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STICKY ACTIONS BAR
  Widget _buildStickyActions(DeliveryModel s, double w, double h, bool isCollection) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCollection) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, h * 0.07),
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 2,
                shadowColor: Colors.blue.withOpacity(0.3),
              ),
              onPressed: () => controller.openMap(s.address),
              icon: const Icon(Icons.gps_fixed, size: 20),
              label: const Text("Get Directions", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            ),
            SizedBox(height: h * 0.02),
            s.isDelivered
                ? _statusBox("Delivered", const Color(0xFF4CAF50), w, h)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, h * 0.07),
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 2,
                      shadowColor: Colors.green.withOpacity(0.3),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => _handleDeliveryMark(s),
                    child: controller.isLoading.value
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text("Mark Delivered", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                  ),
          ] else ...[
            s.collectedTrays > 0
                ? _statusBox("Collection Completed", const Color(0xFF4CAF50), w, h)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, h * 0.07),
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 2,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                      if (collectedTraysController.text.trim().isEmpty) {
                        Get.snackbar("Error", "Please enter collected trays",
                            snackPosition: SnackPosition.TOP,
                            colorText: Colors.red);
                        return;
                      }

                      final trays = int.tryParse(collectedTraysController.text) ?? 0;

                      if (trays < 0) {
                        Get.snackbar("Error", "Trays cannot be negative",
                            snackPosition: SnackPosition.TOP,
                            colorText: Colors.red);
                        return;
                      }

                      if (trays > s.totalTrays) {
                        Get.snackbar("Error", "Cannot exceed total trays",
                            snackPosition: SnackPosition.TOP,
                            colorText: Colors.red);
                        return;
                      }

                      _handleCollectionMark(s, trays);
                    },
                    child: controller.isLoading.value
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text("Mark Collected", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                  ),
          ],
        ],
      ),
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
          Text(title, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style:
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ],
      ),
    );
  }

  void _handleDeliveryMark(DeliveryModel store) async {
    await controller.markDelivered(store);
  }

  void _handleCollectionMark(DeliveryModel store, int trays) async {
    await controller.markCollected(store, trays);
  }
}