import 'package:aavin/app/models/agent_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_enums.dart';
import '../../../models/DeviceInfo.dart';
import '../../../models/booth_model.dart';
import '../../../models/subscription_details_model.dart';
import '../../../routes/app_pages.dart';
import '../../../api/api_service.dart';
import '../../../services/config_service.dart';
import 'package:get_storage/get_storage.dart';

import '../../../utils/device-util.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  
  final _isLoading = false.obs;
  final _isOtpSent = false.obs;
  final _isPasswordLogin = true.obs;
  final _selectedUserType = UserType.society.obs;
  final _customerId = 0.obs;
  final _accessToken = ''.obs;
  final tempToken = ''.obs;
  final resetToken = ''.obs;
  final apiService = Get.find<ApiService>();
  final storage = GetStorage();

  bool get isLoading => _isLoading.value;
  bool get isOtpSent => _isOtpSent.value;
  bool get isPasswordLogin => _isPasswordLogin.value;
  UserType get selectedUserType => _selectedUserType.value;
  int get customerId => _customerId.value;

  void setUserType(UserType type) {
    _selectedUserType.value = type;
  }

  void toggleLoginMethod() {
    _isPasswordLogin.value = !_isPasswordLogin.value;
    _isOtpSent.value = false;
    resetToken.value = ''; // Clear reset token when switching
    otpController.clear();
    passwordController.clear();
  }

  void resetLoginState() {
    _isOtpSent.value = false;
    _isPasswordLogin.value = true;
    resetToken.value = '';
    otpController.clear();
    passwordController.clear();
    phoneController.clear();
  }

  Future<void> loginWithPassword() async {
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter Username and Password');
      return;
    }
    
    _isLoading.value = true;
    try {
      final response = await apiService.loginWithPassword(
        phoneController.text,
        passwordController.text
      );

      if (response['isForcePasswordReset'] == true) {
        await forgotPassword();
        return;
      }
      
      // Store the token from password login response
      print('=== Password Login Response ===');
      print('Token: ${response['token']}');
      print('Response keys: ${response.keys}');
      
      await storage.write('access_token', response['token'] ?? '');
      await storage.write('user_type', UserType.society.index);
      
      // Store agent and booth data from login response
      // Handle nested societyUser structure
      if (response['societyUser'] != null) {
        Map<String, dynamic>? societyUserData;
        if (response['societyUser'] is Map && response['societyUser']['societyUser'] != null) {
          societyUserData = response['societyUser']['societyUser'];
        } else {
          societyUserData = response['societyUser'];
        }
        
        if (societyUserData != null) {
          print('Raw societyUserData: $societyUserData');
          var agentData = SocietyUser.fromJson(societyUserData);
          print('Parsed KYC - Aadhaar: ${agentData.isAadhaarKycVerified}, PAN: ${agentData.isPanKycVerified}, Bank: ${agentData.hasBankAccountVerified}');
          await storage.write('agent', agentData.toJson());
          await storage.write('razorpay_key', response['societyUser']['key'] ?? '');
          await storage.write('isAadhaarKycVerified', agentData.isAadhaarKycVerified ?? false);
          await storage.write('isPanKycVerified', agentData.isPanKycVerified ?? false);
          await storage.write('hasBankAccountVerified', agentData.hasBankAccountVerified ?? false);
          
          print('KYC Status - Aadhaar: ${agentData.isAadhaarKycVerified}, PAN: ${agentData.isPanKycVerified}, Bank: ${agentData.hasBankAccountVerified}');
        }
      }
      Society? societyData;
      if (response['societyDetails'] != null) {
        print('=== Raw societyDetails from API ===');
        print('societyDetails: ${response['societyDetails']}');
        societyData = Society.fromJson(response['societyDetails']);
        print('Parsed isLocSubmit: ${societyData.isLocSubmit}');
        await storage.write('societyDetails', societyData.toJson());
      }
      
      Get.snackbar('Success', response['message'] ?? 'Login successful');
      
      // Check KYC status and location submit
      final isAadhaarKycVerified = await storage.read('isAadhaarKycVerified') ?? false;
      final isPanKycVerified = await storage.read('isPanKycVerified') ?? false;
      final hasBankAccountVerified = await storage.read('hasBankAccountVerified') ?? false;
      final isLocSubmit = societyData?.isLocSubmit ?? false;
      
      print('KYC - Aadhaar: $isAadhaarKycVerified, PAN: $isPanKycVerified, Bank: $hasBankAccountVerified, LocSubmit: $isLocSubmit');
      
      // Priority: KYC details first, then location
      if (!isAadhaarKycVerified || !isPanKycVerified || !hasBankAccountVerified) {
        Get.offAllNamed(Routes.BOOTH_CAPTURE);
      } else if (!isLocSubmit) {
        Get.offAllNamed(Routes.BOOTH_CAPTURE);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter username');
      return;
    }
    
    _isLoading.value = true;
    try {
      final response = await apiService.agentForgotPassword(phoneController.text);
      resetToken.value = response['resetToken'] ?? '';
      _isOtpSent.value = true;
      Get.snackbar('Success', response['message'] ?? 'OTP sent for password reset');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> sendOtp() async {
    // if (phoneController.text.isEmpty || phoneController.text.length != 10) {
    //   Get.snackbar('Error', 'Please enter valid 10-digit mobile number');
    //   return;
    // }
    
    _isLoading.value = true;
    try {
      if (_selectedUserType.value == UserType.society) {
        var  deviceInfo = DeviceInfo();
        var  version = '';
        try{
          deviceInfo = await DeviceUtil.getDeviceDetails();
          version = await DeviceUtil.getAppVersion();

        }catch(err){
          print(err);
        }

        final response = await apiService.agentLogin(phoneController.text,deviceInfo,version);
        _accessToken.value = response.accessToken ?? '';
        tempToken.value = response.accessToken ?? '';
        _customerId.value = response.agentId ?? 0;
        
        _isOtpSent.value = true;
        Get.snackbar('Success', response.message ?? 'OTP sent successfully');
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('message:')) {
        final messageStart = errorMessage.indexOf('message:') + 8;
        final messageEnd = errorMessage.indexOf('}', messageStart);
        if (messageEnd != -1) {
          errorMessage = errorMessage.substring(messageStart, messageEnd).trim();
        }
      }
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty || otpController.text.length != 4) {
      Get.snackbar('Error', 'Please enter valid 4-digit OTP');
      return;
    }
    
    _isLoading.value = true;
    
    try {
      if (_selectedUserType.value == UserType.society) {
        // Check if this is for password reset
        if (resetToken.value.isNotEmpty) {
          final response = await apiService.verifyResetOtp(
            resetToken.value,
            otpController.text
          );
          Get.snackbar('Success', response['message'] ?? 'OTP verified successfully');
          Get.toNamed('/reset-password', arguments: resetToken.value);
        } else {
          // Normal OTP verification for login
          final response = await apiService.agentVerifyOtp(
            _accessToken.value,
            otpController.text
          );
          await storage.write('access_token', response.token ?? '');
          await storage.write('agent', response.agent?.toJson() ?? {});
          await storage.write('societyDetails', response.boothDetails?.toJson() ?? {});
          await storage.write('aadharNumber', response.agent?.aadharNumber ?? '');
          await storage.write('panNumber', response.agent?.panNumber ?? '');
          await storage.write('isAadhaarKycVerified', response.agent?.isAadhaarKycVerified ?? false);
          await storage.write('isPanKycVerified', response.agent?.isPanKycVerified ?? false);
          await storage.write('hasBankAccountVerified', response.agent?.hasBankAccountVerified ?? false);
          await storage.write('profilePhotoUrl', response.agent?.profilePhoto ?? '');
          await storage.write('razorpay_key', response.agent?.key ?? '');
          await storage.write('user_type',UserType.society.index);
         try {
            final configService = Get.find<ConfigService>();
            await configService.fetchConfig();
          } catch (e) {
            print('Config fetch error: $e');
          }
          
          Get.snackbar('Success', response.message ?? 'Login successful');
          
          // Check KYC status and location submit
          final isAadhaarKycVerified = response.agent?.isAadhaarKycVerified ?? false;
          final isPanKycVerified = response.agent?.isPanKycVerified ?? false;
          final hasBankAccountVerified = response.agent?.hasBankAccountVerified ?? false;
          final isLocSubmit = response.boothDetails?.isLocSubmit ?? false;
          
          // Priority: KYC details first, then location
          if (!isAadhaarKycVerified || !isPanKycVerified || !hasBankAccountVerified) {
            Get.offAllNamed(Routes.BOOTH_CAPTURE);
          } else if (!isLocSubmit) {
            Get.offAllNamed(Routes.BOOTH_CAPTURE);
          } else {
            Get.offAllNamed(Routes.HOME);
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }


  bool isDisposed = false;
  
  @override
  void onClose() {
    isDisposed = true;
    super.onClose();
  }
}