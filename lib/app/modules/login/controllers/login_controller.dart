import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_enums.dart';
import '../../../models/DeviceInfo.dart';
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
  final _selectedUserType = UserType.customer.obs;
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
    _selectedUserType.value = UserType.customer;
    resetToken.value = '';
    tempToken.value = '';
    _accessToken.value = '';
    _customerId.value = 0;
    otpController.clear();
    passwordController.clear();
    phoneController.clear();
  }

  Future<void> loginWithPassword() async {
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter Route Id/Username and password');
      return;
    }

    _isLoading.value = true;
    try {
      final response = await apiService.loginWithPassword(
          phoneController.text,
          passwordController.text
      );

      // if (response['isForcePasswordReset'] == true) {
      //   await forgotPassword();
      //   return;
      // }

      // Store the token from password login response
      await storage.write('access_token', response.fleetUser?.accessToken ?? '');
      await storage.write('user_type', UserType.fleetUser.index);

      // Store agent and booth data from login response
      if (response.fleetUser != null) {
        await storage.write('fleetUser', response.fleetUser);
        // await storage.write('razorpay_key', response.data['key'] ?? '');
      }

      Get.snackbar('Success', response.message ?? 'Login successful');
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter route id/username');
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
      if (_selectedUserType.value == UserType.fleetUser) {
        var  deviceInfo = DeviceInfo();
        var  version = '';
        try{
          deviceInfo = await DeviceUtil.getDeviceDetails();
          version = await DeviceUtil.getAppVersion();

        }catch(err){
          print(err);
        }

        // final response = await apiService.agentLogin(phoneController.text,deviceInfo,version);
        final response = await apiService.loginWithOtp(phoneController.text);
        _accessToken.value = response.fleetUser?.accessToken ?? '';
        tempToken.value = response.fleetUser?.accessToken ?? '';
        // _customerId.value = response.agentId ?? 0;

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
      if (_selectedUserType.value == UserType.fleetUser) {
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
          await storage.write('fleetUser', response.fleetUser ?? {});
          // await storage.write('boothDetails', response.boothDetails?.toJson() ?? {});
          await storage.write('aadharNumber', response.fleetUser?.aadharNumber ?? '');
          await storage.write('panNumber', response.fleetUser?.panNumber ?? '');
          await storage.write('isAadhaarKycVerified', response.fleetUser?.isAadhaarKycVerified ?? false);
          await storage.write('isPanKycVerified', response.fleetUser?.isPanKycVerified ?? false);
          await storage.write('profilePhotoUrl', response.fleetUser?.profilePhoto ?? '');
          await storage.write('razorpay_key', response.fleetUser?.key ?? '');
          await storage.write('user_type',UserType.fleetUser.index);
          try {
            final configService = Get.find<ConfigService>();
            await configService.fetchConfig();
          } catch (e) {
            print('Config fetch error: $e');
          }

          Get.snackbar('Success', response.message ?? 'Login successful');
          Get.offAllNamed(Routes.HOME);
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