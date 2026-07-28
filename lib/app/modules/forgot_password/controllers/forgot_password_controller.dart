import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../../../routes/app_pages.dart';

class ForgotPasswordController extends GetxController {
  final apiService = Get.find<ApiService>();

  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  Future<void> sendOtp() async {
    if (mobileController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your mobile number');
      return;
    }

    isLoading.value = true;
    try {
      final response = await apiService.forgotPassword(
        mobileNumber: mobileController.text.trim(),
      );

      if (response['success'] == true) {
        isOtpSent.value = true;
        Get.snackbar('Success', response['message'] ?? 'OTP sent successfully');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (otpController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    isLoading.value = true;
    try {
      final response = await apiService.verifyOtpAndResetPassword(
        mobileNumber: mobileController.text.trim(),
        otp: otpController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );

      // ApiService now throws if success is false, so if we're here, it succeeded
      Get.snackbar('Success', response['message'] ?? 'Password reset successful',
          duration: const Duration(seconds: 3));
      
      // Delay slightly to allow the snackbar to be seen, then redirect
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed(Routes.LOGIN);
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
