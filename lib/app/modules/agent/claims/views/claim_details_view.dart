import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../utils/date-util.dart';
import '../controllers/claims_controller.dart';
import 'photo_gallery_view.dart';

class ClaimDetailsView extends StatefulWidget {
  const ClaimDetailsView({super.key});

  @override
  State<ClaimDetailsView> createState() => _ClaimDetailsViewState();
}

class _ClaimDetailsViewState extends State<ClaimDetailsView> {
  late ClaimsController controller;
  
  @override
  void initState() {
    super.initState();
    controller = Get.find<ClaimsController>();
    final claimId = Get.arguments as int;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadClaimDetails(claimId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Claim Details'),
        backgroundColor: Color(0xFF00ADD9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return SizedBox(
            height: Get.height * 0.6,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00ADD9),
              ),
            ),
          );
        }
        
        final claim = controller.selectedClaim.value;
        if (claim == null) {
          return Center(child: CircularProgressIndicator(color: Color(0xFF00ADD9)));
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            final claimId = Get.arguments as int;
            await controller.loadClaimDetails(claimId);
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClaimHeader(claim.claim),
                SizedBox(height: 24),
                _buildClaimInfo(claim.claim),
                SizedBox(height: 24),
                _buildClaimItems(claim.items),
                if (claim.claim.photoUrls?.isNotEmpty == true) ...[
                  SizedBox(height: 24),
                  _buildPhotos(claim.claim.photoUrls!),
                ],
                SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildClaimHeader(claim) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00ADD9), Color(0xFF0088CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ADD9).withValues(alpha:0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Claim #${claim.id}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.getStatusText(claim.status),
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '₹${claim.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Order #${claim.orderId} | ${DateUtil.formatDateDDEEYY(claim.orderDate)} | ${claim.shift == 1 ? 'Morning' : 'Evening'} ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimInfo(claim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Claim Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Reason', claim.reason),
              if (claim.remarks?.isNotEmpty == true)
                _buildInfoRow('Remark', claim.remarks!),
              if (claim.description?.isNotEmpty == true)
                _buildInfoRow('Description', claim.description!),
              _buildInfoRow('Created At', _formatDate(claim.createdAt)),
              if (claim.orderDate != null)
                _buildInfoRow('Order Date', _formatDate(claim.orderDate)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClaimItems(List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Claimed Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        ...items.map((item) => _buildItemCard(item)).toList(),
      ],
    );
  }

  Widget _buildItemCard(item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.only(left: 12, right: 10, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.2),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.broken_image,
              color: Colors.red,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Unknown Product',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item.productCode ?? 'No Code',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (item.notes?.isNotEmpty == true) ...[
                  SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Damaged',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '${item.damagedQuantity}/${item.originalQuantity ?? 0}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotos(List<String> photoUrls) {
    final claim = controller.selectedClaim.value?.claim;
    final canAddImages = claim?.status == 1 && photoUrls.length < 15;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos (${photoUrls.length}/15)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (canAddImages)
              ElevatedButton.icon(
                onPressed: () => _showAddImagesDialog(),
                icon: Icon(Icons.add_photo_alternate, size: 16),
                label: Text('Add Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00ADD9),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: photoUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openPhotoGallery(photoUrls, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha:0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.network(
                      photoUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.error, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  void _openPhotoGallery(List<String> imageUrls, int initialIndex) {
    Get.to(() => PhotoGalleryView(
      imageUrls: imageUrls,
      initialIndex: initialIndex,
    ));
  }

  void _showAddImagesDialog() {
    final selectedImages = <File>[].obs;
    final claim = controller.selectedClaim.value?.claim;
    final currentPhotoCount = claim?.photoUrls?.length ?? 0;
    final maxAllowed = 15 - currentPhotoCount;
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_photo_alternate, color: Color(0xFF00ADD9), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Images',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add up to $maxAllowed more images (Current: $currentPhotoCount/15)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImageForUpdate(selectedImages, ImageSource.camera, maxAllowed),
                          icon: Icon(Icons.camera_alt, size: 18),
                          label: Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00ADD9),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      // SizedBox(width: 12),
                      // Expanded(
                      //   child: ElevatedButton.icon(
                      //     onPressed: () => _pickMultipleImagesForUpdate(selectedImages, maxAllowed),
                      //     icon: Icon(Icons.photo_library, size: 18),
                      //     label: Text('Gallery'),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.grey[600],
                      //       foregroundColor: Colors.white,
                      //       padding: EdgeInsets.symmetric(vertical: 12),
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Obx(() {
                    if (selectedImages.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_photo_alternate, color: Colors.grey[500], size: 20),
                            SizedBox(width: 8),
                            Text('No images selected', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Images (${selectedImages.length}):',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 12),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        selectedImages[index],
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => selectedImages.removeAt(index),
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha:0.2),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => ElevatedButton(
                          onPressed: selectedImages.isNotEmpty
                              ? () async {
                                final success = await _uploadAdditionalImages(selectedImages);
                                if (success) {
                                  selectedImages.clear();
                                  Navigator.of(context).pop();
                                }
                              }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedImages.isNotEmpty ? Color(0xFF00ADD9) : Colors.grey[400],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: selectedImages.isNotEmpty ? 2 : 0,
                          ),
                          child: Text('Upload Images', style: TextStyle(fontWeight: FontWeight.w600)),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _pickImageForUpdate(RxList<File> selectedImages, ImageSource source, int maxAllowed) async {
    if (selectedImages.length >= maxAllowed) {
      Get.snackbar('Limit Reached', 'You can only add $maxAllowed more images');
      return;
    }
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    
    if (pickedFile != null) {
      selectedImages.add(File(pickedFile.path));
    }
  }

  Future<void> _pickMultipleImagesForUpdate(RxList<File> selectedImages, int maxAllowed) async {
    final remainingSlots = maxAllowed - selectedImages.length;
    if (remainingSlots <= 0) {
      Get.snackbar('Limit Reached', 'You can only add $maxAllowed more images');
      return;
    }
    
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    
    if (pickedFiles.isNotEmpty) {
      final filesToAdd = pickedFiles.take(remainingSlots).map((xFile) => File(xFile.path)).toList();
      selectedImages.addAll(filesToAdd);
      
      if (pickedFiles.length > remainingSlots) {
        Get.snackbar(
          'Selection Limited',
          'Only ${filesToAdd.length} images were added due to the limit',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      }
    }
  }

  Future<bool> _uploadAdditionalImages(RxList<File> selectedImages) async {
    final claimId = controller.selectedClaim.value?.claim?.id;
    if (claimId == null) return false;
    return await controller.updateClaim(
      claimId: claimId,
      images: selectedImages,
    );
  }
}