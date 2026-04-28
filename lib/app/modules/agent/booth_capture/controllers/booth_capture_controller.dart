import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../api/api_service.dart';
import '../../../../config/app_config.dart';
import '../../../../utils/location-utils.dart';
import '../views/kyc-success-view.dart';

class BoothCaptureController extends GetxController {
  var currentLatLng = const LatLng(0.0, 0.0).obs;
  var boothImage = Rx<File?>(null);
  var address = "".obs;
  final isLoading = false.obs;
  final config = Get.find<ClientConfig>();
  final storage = GetStorage();
  
  // KYC status
  final isAadhaarVerified = false.obs;
  final isPanVerified = false.obs;
  final isBankVerified = false.obs;
  final isLocationSubmitted = false.obs;
  
  // Controllers for KYC details
  final nameController = TextEditingController();
  final aadharController = TextEditingController();
  final panController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountHolderController = TextEditingController();
  final ifscController = TextEditingController();
  final bankNameController = TextEditingController();
  final bankBranchController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    _loadKycStatus();
  }
  
  void _loadKycStatus() {
    isAadhaarVerified.value = storage.read('isAadhaarKycVerified') ?? false;
    isPanVerified.value = storage.read('isPanKycVerified') ?? false;
    isBankVerified.value = storage.read('hasBankAccountVerified') ?? false;
    
    final societyDetails = storage.read('societyDetails');
    if (societyDetails != null && societyDetails is Map) {
      isLocationSubmitted.value = societyDetails['isLocSubmit'] ?? false;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      boothImage.value = File(pickedFile.path);
      await refreshLocation();
    }
  }

  Future<void> refreshLocation() async {
    address.value = "Refreshing location...";
    currentLatLng.value = const LatLng(0.0, 0.0);
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      address.value = "Getting location...";

      final allowed = await LocationUtils.ensureLocationPermission();
      if (!allowed) {
        address.value = 'Location permission required';
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // LocationPermission permission = await Geolocator.requestPermission();
      //
      // Position position = await Geolocator.getCurrentPosition();
      
      currentLatLng.value = LatLng(position.latitude, position.longitude);
      
      await _getAddressFromLatLng(currentLatLng.value);
      
    } catch (e) {
      address.value = "Error: $e";
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address.value =
        "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        address.value = "Address not found";
      }
    } catch (e) {
      address.value = "Error fetching address";
    }
  }

  void previewImage(File image) {
    // Show fullscreen preview / dialog as needed
  }

  void submitBoothInfo() async {
    try {
      // Check if KYC details are filled
      // if (!isAadhaarVerified.value || !isPanVerified.value || !isBankVerified.value) {
      //   Get.snackbar("Error", "Please complete KYC details first");
      //   return;
      // }
      
      if (boothImage.value == null) {
        Get.snackbar("Error", "Please capture booth image first");
        return;
      }
      isLoading.value = true;

      final apiService = Get.find<ApiService>();
       await apiService.updateBoothLocation(
        file: boothImage.value!,
        lat: currentLatLng.value.latitude,
        lng: currentLatLng.value.longitude,
      );

    } catch (e) {
      Get.snackbar("Error", "Failed to submit booth data: $e");
    }finally {
      isLoading.value = false;
    }
  }
  
  Future<void> submitKycDetails() async {
    try {
      isLoading.value = true;
      final apiService = Get.find<ApiService>();
      
      // Submit all details in one API call
      await apiService.updateAgentDetails(
        name: nameController.text.isNotEmpty ? nameController.text : null,
        aadharNumber: aadharController.text.isNotEmpty ? aadharController.text : null,
        panNumber: panController.text.isNotEmpty ? panController.text : null,
        accountNumber: accountNumberController.text.isNotEmpty ? accountNumberController.text : null,
        accountHolderName: accountHolderController.text.isNotEmpty ? accountHolderController.text : null,
        ifscCode: ifscController.text.isNotEmpty ? ifscController.text : null,
        bankName: bankNameController.text.isNotEmpty ? bankNameController.text : null,
        bankBranch: bankBranchController.text.isNotEmpty ? bankBranchController.text : null,
        reqType: 1,
      );
      
      // Auto-verify after submission
      await apiService.verifyKyc(
        isAadhaarKycVerified: true,
        isPanKycVerified: true,
        hasBankAccountVerified: true,
      );
      
      isAadhaarVerified.value = true;
      isPanVerified.value = true;
      isBankVerified.value = true;
      await storage.write('isAadhaarKycVerified', true);
      await storage.write('isPanKycVerified', true);
      await storage.write('hasBankAccountVerified', true);
      
      Get.snackbar('Success', 'KYC details submitted successfully');
      _loadKycStatus();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    nameController.dispose();
    aadharController.dispose();
    panController.dispose();
    accountNumberController.dispose();
    accountHolderController.dispose();
    ifscController.dispose();
    bankNameController.dispose();
    bankBranchController.dispose();
    super.onClose();
  }
}

