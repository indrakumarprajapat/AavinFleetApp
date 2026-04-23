import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../controller/pdf_controller.dart';

class PdfView extends GetView<PdfController> {
  const PdfView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Route PDF"),
        backgroundColor: const Color(0xff1BA6C8),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.retry,
          )
        ],
      ),

      body: Obx(() {
        /// LOADING STATE
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        /// ERROR STATE
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 50, color: Colors.red),
                const SizedBox(height: 10),
                const Text("Failed to load PDF"),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: controller.retry,
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }

        /// EMPTY STATE
        if (controller.pdfUrl.value.isEmpty) {
          return const Center(child: Text("No PDF available"));
        }

        /// PDF VIEWER
        return Column(
          children: [
            Expanded(
              child: SfPdfViewer.network(
                controller.pdfUrl.value,
                onDocumentLoaded: (details) {
                  // optional: analytics / tracking
                },
                onDocumentLoadFailed: (details) {
                  controller.hasError.value = true;
                },
              ),
            ),

            /// BUTTON
            Padding(
              padding: EdgeInsets.all(w * 0.04),
              child: SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1BA6C8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.startDelivery,
                  child: Text(
                    "Start Delivery",
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}