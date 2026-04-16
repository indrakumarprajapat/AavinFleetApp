import 'package:aavin/app/modules/agent/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_enums.dart';
import '../../../models/DeviceInfo.dart';
import '../../../models/booth_model.dart';
import '../../../models/agent_model.dart';
import '../../../routes/app_pages.dart';
import '../../../api/api_service.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utils/device-util.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  /// 🔹 Reactive State
  final _isLoading = false.obs;
  final _isOtpSent = false.obs;
  final _isPasswordLogin = true.obs; // ✅ default password login
  final _selectedUserType = UserType.society.obs;
  final _customerId = 0.obs;
  final _accessToken = ''.obs;
  final tempToken = ''.obs;
  final resetToken = ''.obs;

  final apiService = Get.find<ApiService>();
  final storage = GetStorage();

  /// 🔹 Getters (UI uses these)
  bool get isLoading => _isLoading.value;
  bool get isOtpSent => _isOtpSent.value;
  bool get isPasswordLogin => _isPasswordLogin.value;
  UserType get selectedUserType => _selectedUserType.value;
  int get customerId => _customerId.value;

  /// 🔹 Force Agent Mode
  @override
  void onInit() {
    super.onInit();
    _selectedUserType.value = UserType.society;
    _isPasswordLogin.value = true; // always password login
  }

  void setUserType(UserType type) {
    _selectedUserType.value = type;
  }

  /// 🔹 OPTIONAL (kept but not used in UI)
  void toggleLoginMethod() {
    _isPasswordLogin.value = !_isPasswordLogin.value;
    _isOtpSent.value = false;
    resetToken.value = '';
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

  /// ===========================
  /// PASSWORD LOGIN (MAIN FLOW)
  /// ===========================
  Future<void> loginWithPassword() async {
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter Username and Password');
      return;
    }

    _isLoading.value = true;

    try {
      final response = await apiService.loginWithPassword(
        phoneController.text.trim(),
        passwordController.text.trim(),
      );

      /// 🔹 Force password reset case
      if (response['isForcePasswordReset'] == true) {
        await forgotPassword();
        return;
      }

      /// 🔹 Store token
      await storage.write('access_token', response['token'] ?? '');
      await storage.write('user_type', UserType.society.index);

      /// 🔹 Agent Data
      if (response['societyUser'] != null) {
        Map<String, dynamic>? societyUserData;

        if (response['societyUser'] is Map &&
            response['societyUser']['societyUser'] != null) {
          societyUserData = response['societyUser']['societyUser'];
        } else {
          societyUserData = response['societyUser'];
        }

        if (societyUserData != null) {
          var agentData = SocietyUser.fromJson(societyUserData);

          await storage.write('agent', agentData.toJson());
          await storage.write(
              'razorpay_key', response['societyUser']['key'] ?? '');

          await storage.write(
              'isAadhaarKycVerified', agentData.isAadhaarKycVerified ?? false);
          await storage.write(
              'isPanKycVerified', agentData.isPanKycVerified ?? false);
          await storage.write('hasBankAccountVerified',
              agentData.hasBankAccountVerified ?? false);
        }
      }

      /// 🔹 Society Data
      if (response['societyDetails'] != null) {
        var societyData = Society.fromJson(response['societyDetails']);
        await storage.write('societyDetails', societyData.toJson());
      }

      Get.snackbar('Success', response['message'] ?? 'Login successful');

      /// 🔹 Navigate to PDF Screen first as per flow
      Get.offAllNamed(Routes.PDF);

    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// ===========================
  /// 🔹 FORGOT PASSWORD (USED)
  /// ===========================
  Future<void> forgotPassword() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter username');
      return;
    }

    _isLoading.value = true;

    try {
      final response =
      await apiService.agentForgotPassword(phoneController.text.trim());

      resetToken.value = response['resetToken'] ?? '';
      _isOtpSent.value = true;

      Get.snackbar(
          'Success', response['message'] ?? 'OTP sent for password reset');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// ===========================
  /// ❌ UNUSED (OTP LOGIN)
  /// ===========================
  Future<void> sendOtp() async {
    _isLoading.value = true;

    try {
      var deviceInfo = await DeviceUtil.getDeviceDetails();
      var version = await DeviceUtil.getAppVersion();

      final response = await apiService.agentLogin(
          phoneController.text, deviceInfo, version);

      _accessToken.value = response.accessToken ?? '';
      tempToken.value = response.accessToken ?? '';
      _customerId.value = response.agentId ?? 0;

      _isOtpSent.value = true;

      Get.snackbar('Success', response.message ?? 'OTP sent successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length != 4) {
      Get.snackbar('Error', 'Enter valid OTP');
      return;
    }

    _isLoading.value = true;

    try {
      if (resetToken.value.isNotEmpty) {
        final response = await apiService.verifyResetOtp(
          resetToken.value,
          otpController.text,
        );

        Get.toNamed('/reset-password', arguments: resetToken.value);
      } else {
        final response = await apiService.agentVerifyOtp(
          _accessToken.value,
          otpController.text,
        );

        await storage.write('access_token', response.token ?? '');

        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// 🔹 Dispose Safety
  bool isDisposed = false;

  @override
  void onClose() {
    isDisposed = true;
    phoneController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }
}



//recent commented
/*

import '../../../../app/modules/delivery/delivery_points_screen.dart';
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
import '../../../../app/route_assignment(home)/route_assignment_screen.dart';

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
      await storage.write('access_token', response['token'] ?? '');
      await storage.write('user_type', UserType.society.index);
      
      if (response['societyUser'] != null) {
        Map<String, dynamic>? societyUserData;
        if (response['societyUser'] is Map && response['societyUser']['societyUser'] != null) {
          societyUserData = response['societyUser']['societyUser'];
        } else {
          societyUserData = response['societyUser'];
        }
        
        if (societyUserData != null) {
          var agentData = SocietyUser.fromJson(societyUserData);
          await storage.write('agent', agentData.toJson());
          await storage.write('razorpay_key', response['societyUser']['key'] ?? '');
          await storage.write('isAadhaarKycVerified', agentData.isAadhaarKycVerified ?? false);
          await storage.write('isPanKycVerified', agentData.isPanKycVerified ?? false);
          await storage.write('hasBankAccountVerified', agentData.hasBankAccountVerified ?? false);
        }
      }

      if (response['societyDetails'] != null) {
        var societyData = Society.fromJson(response['societyDetails']);
        await storage.write('societyDetails', societyData.toJson());
      }
      
      Get.snackbar('Success', response['message'] ?? 'Login successful');
      
      // ✅ NAVIGATE TO FLEET MODULE
      Get.offAll(() => const RouteAssignmentScreen());

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
    _isLoading.value = true;
    try {
      if (_selectedUserType.value == UserType.society) {
        var deviceInfo = DeviceInfo();
        var version = '';
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
      Get.snackbar('Error', e.toString());
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
        if (resetToken.value.isNotEmpty) {
          final response = await apiService.verifyResetOtp(
            resetToken.value,
            otpController.text
          );
          Get.snackbar('Success', response['message'] ?? 'OTP verified successfully');
          Get.toNamed('/reset-password', arguments: resetToken.value);
        } else {
          final response = await apiService.agentVerifyOtp(
            _accessToken.value,
            otpController.text
          );
          await storage.write('access_token', response.token ?? '');
          await storage.write('agent', response.agent?.toJson() ?? {});
          await storage.write('societyDetails', response.boothDetails?.toJson() ?? {});
          await storage.write('isAadhaarKycVerified', response.agent?.isAadhaarKycVerified ?? false);
          await storage.write('isPanKycVerified', response.agent?.isPanKycVerified ?? false);
          await storage.write('hasBankAccountVerified', response.agent?.hasBankAccountVerified ?? false);
          await storage.write('user_type',UserType.society.index);
          
          Get.snackbar('Success', response.message ?? 'Login successful');
          
          // NAVIGATE TO FLEET MODULE
          Get.offAll(() => const DeliveryPointsScreen());
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


 */