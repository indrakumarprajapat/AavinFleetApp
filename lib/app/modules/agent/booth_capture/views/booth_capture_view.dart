import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/booth_capture_controller.dart';

class BoothCaptureView extends GetView<BoothCaptureController> {
  const BoothCaptureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() {
                    final _ = controller.isLoading.value;
                    return _buildLocationCapture();
                  }),
                ),
              ),
            ],
          ),
          // Loading Overlay
          Obx(() => controller.isLoading.value
              ? Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00ADD9),
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),

    );
  }
  
  // Widget _buildKycForm() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'KYC Details',
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 20),
  //
  //       // Aadhaar & PAN Section
  //       if (!controller.isAadhaarVerified.value || !controller.isPanVerified.value)
  //         Column(
  //           children: [
  //             TextField(
  //               controller: controller.nameController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Name',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: controller.aadharController,
  //               keyboardType: TextInputType.number,
  //               maxLength: 12,
  //               decoration: const InputDecoration(
  //                 labelText: 'Aadhaar Number',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: controller.panController,
  //               textCapitalization: TextCapitalization.characters,
  //               maxLength: 10,
  //               decoration: const InputDecoration(
  //                 labelText: 'PAN Number',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //           ],
  //         ),
  //
  //       // Bank Details Section
  //       if (!controller.isBankVerified.value)
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'Bank Account Details',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: controller.accountNumberController,
  //               keyboardType: TextInputType.number,
  //               decoration: const InputDecoration(
  //                 labelText: 'Account Number',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: controller.accountHolderController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Account Holder Name',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: controller.ifscController,
  //               textCapitalization: TextCapitalization.characters,
  //               decoration: const InputDecoration(
  //                 labelText: 'IFSC Code',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: controller.bankNameController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Bank Name',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: controller.bankBranchController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Bank Branch',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //           ],
  //         ),
  //
  //       ElevatedButton(
  //         onPressed: controller.submitKycDetails,
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: const Color(0xFF00ADD9),
  //           minimumSize: const Size(double.infinity, 50),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //         child: const Text(
  //           'Submit KYC Details',
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  Widget _buildLocationCapture() {
    return Column(
      children: [
        // Booth Image Placeholder + Upload Button
        Obx(() {
          final image = controller.boothImage.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image == null
                    ? Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.white70,
                        ),
                      )
                    : GestureDetector(
                        onTap: () => controller.previewImage(image),
                        child: Image.file(
                          image,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              Positioned(
                bottom: 16,
                child: ElevatedButton.icon(
                  onPressed: () => controller.pickImage(),
                  icon: const Icon(
                    Icons.upload_file,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Upload Society Image",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ADD9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),

        const SizedBox(height: 16),

        // Show Address after image is captured
        Obx(() {
          if (controller.boothImage.value == null) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              Text(
                controller.address.value.isNotEmpty
                    ? controller.address.value
                    : "Fetching address...",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }),

        const SizedBox(height: 20),

        Obx(() {
          if (controller.boothImage.value == null) {
            return const SizedBox.shrink();
          }
          return const Text(
            "Image captured successfully (tap to view)",
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.green,
            ),
          );
        }),

        const SizedBox(height: 20),

        // Privacy Notice
        const Text(
          "Privacy Notice: This location is being collected for verification purposes only. "
          "Your location data will not be stored or used for any other purposes.",
          style: TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: controller.submitBoothInfo,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00ADD9),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Submit",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.25,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/Vector.svg',
              fit: BoxFit.fill,
              width: double.infinity,
              colorFilter: ColorFilter.mode(Color(0xFF00ADD9), BlendMode.srcIn),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // IconButton(
                  //   onPressed: () {
                  //     Get.back();
                  //   },
                  //   icon: Icon(
                  //     Icons.arrow_back_outlined,
                  //     color: Colors.white,
                  //     size: 30,
                  //   ),
                  // ),
                  Expanded(
                    child: Center(
                      child: Text(controller.config.app_title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                  ),
                  // Stack(
                  //   children: [
                  //       SizedBox(width: 48)
                  // //     IconButton(
                  // //       onPressed: () {},
                  // //       icon: Icon(
                  // //         Icons.shopping_cart_outlined,
                  // //         color: Colors.white,
                  // //         size: 30,
                  // //       ),
                  // //     ),
                  // //     Positioned(
                  // //       right: 8,
                  // //       top: 8,
                  // //       child: Container(
                  // //         width: 12,
                  // //         height: 12,
                  // //         decoration: BoxDecoration(
                  // //           color: Colors.red,
                  // //           borderRadius: BorderRadius.circular(6),
                  // //         ),
                  // //       ),
                  // //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
