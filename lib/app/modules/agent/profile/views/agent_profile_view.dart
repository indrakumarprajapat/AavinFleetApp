import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../../../../config/app_config.dart';
import '../../../../constants/app_enums.dart';
import '../../../../models/fleet_user.dart';
import '../../../../routes/app_pages.dart';
import '../../../../api/api_service.dart';

class AgentProfileView extends StatelessWidget {
  const AgentProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AgentProfileController());

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: Color(0xFFF8F8F8),
          body: Stack(
            children: [
              _buildHeader(context),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00ADD9)),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final firstName = controller.profileData.value?.name ?? 'Fleet';
      final mobileNumber = controller.profileData.value?.mobileNumber ?? '';
      // final aadharNumber = controller.profileData.value?.aadharNumber ?? 'Not provided';
      // final panNumber = controller.profileData.value?.panNumber ?? 'Not provided';
      // final hasAadharVerified = controller.profileData.value?.hasAadharVerified ?? false;
      // final hasPancardVerified = controller.profileData.value?.hasPancardVerified ?? false;
      // final aadharLink = controller.profileData.value?.aadharLink;
      // final panCardLink = controller.profileData.value?.panCardLink;
      // final accountNumber = controller.profileData.value?.accountNumber ?? 'Not provided';
      // final bankName = controller.profileData.value?.bankName ?? 'Not provided';
      // final ifscCode = controller.profileData.value?.ifscCode ?? 'Not provided';
      // final accountHolderName = controller.profileData.value?.accountHolderName ?? 'Not provided';
      controller.networkImageUrl.value = controller.profileData.value?.profilePhoto;

      return Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        body: Stack(
          children: [
            _buildHeader(context),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileHeader(firstName, mobileNumber, controller),
                      SizedBox(height: 20),
                      // _buildInfoCard('KYC Information', [
                      //   _buildKycInfoRow('Aadhaar', _maskAadhaar(aadharNumber), hasAadharVerified, aadharLink, controller, context),
                      //   _buildKycInfoRow('PAN', panNumber, hasPancardVerified, panCardLink, controller, context),
                      // ]),
                      // SizedBox(height: 16),
                      // _buildInfoCard('Bank Details', [
                      //   _buildInfoRow('Account Holder', accountHolderName),
                      //   _buildInfoRow('Account Number', _maskAccount(accountNumber)),
                      //   _buildInfoRow('IFSC Code', ifscCode),
                      //   _buildInfoRow('Bank Name', bankName),
                      // ]),
                      SizedBox(height: 16),
                      _buildChangePasswordCard(controller),
                      SizedBox(height: 16),
                      _buildActionCard(controller),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              launchUrl(Uri.parse("https://www.aavincoimbatore.com/assets/privacy-policy.html"));
                            },
                            child: const Text(
                              "Privacy Policy",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.25,
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/Vector.svg',
                fit: BoxFit.fill,
                width: double.infinity,
                colorFilter: ColorFilter.mode(
                  Color(0xFF00ADD9),
                  BlendMode.srcIn,
                ),
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
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String mobile, AgentProfileController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF).withValues(alpha:0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ABD5).withValues(alpha:0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withValues(alpha:0.9),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mobile,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withValues(alpha:0.8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: () => controller.showImagePopup(),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF05967B).withValues(alpha:0.1),
                  backgroundImage: controller.profileImage.value != null 
                      ? FileImage(controller.profileImage.value!) 
                      : (controller.networkImageUrl.value != null && controller.networkImageUrl.value!.isNotEmpty 
                          ? NetworkImage(controller.networkImageUrl.value!) : null),
                  child: controller.profileImage.value == null && (controller.networkImageUrl.value == null || controller.networkImageUrl.value!.isEmpty) ? Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF05967B),
                  ) : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => controller.showImageOptions(),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFF05967B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: Colors.white,
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

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF).withValues(alpha:0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ABD5).withValues(alpha:0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycInfoRow(String label, String value, bool isVerified, String? documentLink, AgentProfileController controller, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (isVerified)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.verified,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              if (documentLink != null && documentLink.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => controller.showDocumentImage(documentLink, label, context),
                    child: Icon(
                      Icons.visibility,
                      color: Color(0xFF00ADD9),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordCard(AgentProfileController controller) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF).withValues(alpha:0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00ABD5).withValues(alpha:0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFF00ADD9).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lock_outline,
                color: Color(0xFF00ADD9),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Update your account password',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(AgentProfileController controller) {
    return GestureDetector(
      onTap: () => controller.showLogoutDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF).withValues(alpha:0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00ABD5).withValues(alpha:0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFFE74C3C).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_outlined,
                color: Color(0xFFE74C3C),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign out from your account',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length >= 4) {
      return 'XXXX XXXX ${aadhaar.substring(aadhaar.length - 4)}';
    }
    return aadhaar;
  }

  String _maskAccount(String account) {
    if (account.length >= 4) {
      return 'XXXXXX${account.substring(account.length - 4)}';
    }
    return account;
  }
}

class AgentProfileController extends GetxController {
  final profileData = Rxn<FleetUser>();
  final isLoading = true.obs;
  final profileImage = Rxn<File>();
  final networkImageUrl = RxnString();
  final ImagePicker _picker = ImagePicker();
  final config = Get.find<ClientConfig>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final apiService = Get.find<ApiService>();
      final agent = await apiService.getAgentProfile();
      
      final storage = GetStorage();
      final photoUrl = agent.profilePhoto ?? '';
      storage.write('profilePhotoUrl', photoUrl);
      
      profileData.value = agent;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load profile: $e');
    }
  }

  void showImageOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.gallery);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF05967B).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.photo_library,
                          size: 30,
                          color: Color(0xFF05967B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.camera);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF05967B).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Color(0xFF05967B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Camera',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final croppedFile = await cropImage(File(image.path));
        if (croppedFile != null) {
          final compressedFile = await compressImage(croppedFile);
          if (compressedFile != null) {
            profileImage.value = compressedFile;
            uploadProfilePhoto(compressedFile);
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<File?> cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: Color(0xFF00ADD9),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to crop image: $e');
      return null;
    }
  }

  void showImagePopup() {
    if (profileImage.value == null && (networkImageUrl.value == null || networkImageUrl.value!.isEmpty)) {
      return;
    }
    
    final imageProvider = profileImage.value != null 
        ? FileImage(profileImage.value!) as ImageProvider
        : NetworkImage(networkImageUrl.value!);
        
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> compressImage(File file) async {
    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 70,
        minWidth: 512,
        minHeight: 512,
      );
      return compressedFile != null ? File(compressedFile.path) : null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to compress image: $e');
      return null;
    }
  }

  Future<void> uploadProfilePhoto(File imageFile) async {
    try {
      Get.dialog(
        Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              margin: EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00ADD9),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Uploading photo...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      final apiService = Get.find<ApiService>();
      final response = await apiService.uploadProfilePhoto(imageFile);
      
      Get.back();
      Get.snackbar('Success', 'Profile photo updated successfully');

      loadProfile();

      final storage = GetStorage();
      final photoUrl = response.profilePhoto ?? '';
      print('Updating profilePhotoUrl: $photoUrl');
      storage.write('profilePhotoUrl', photoUrl);
      storage.write('profileUpdated', DateTime.now().millisecondsSinceEpoch);

      networkImageUrl.value = photoUrl;
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to upload photo: $e');
    }
  }

  void showDocumentImage(String imageUrl, String documentType, BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF00ADD9),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$documentType Document',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00ADD9),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final storage = GetStorage();
              storage.erase();
              Get.back();
              // Clear all controllers and add delay
              Get.deleteAll();
              await Future.delayed(Duration(milliseconds: 100));
              if( config.name == ClientConfig.CLIENT_CBE){
                Get.offNamed(Routes.USER_TYPE);
              }else{
                Get.offAllNamed(Routes.LOGIN, arguments: UserType.fleetUser);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}