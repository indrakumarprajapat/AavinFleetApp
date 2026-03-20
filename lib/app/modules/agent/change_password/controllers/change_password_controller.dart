import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/api_service.dart';

class ChangePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ApiService _apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final obscureOldPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isFormValid = false.obs;
  final newPasswordError = false.obs;
  final confirmPasswordError = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    oldPasswordController.addListener(validateForm);
    newPasswordController.addListener(validateForm);
    confirmPasswordController.addListener(validateForm);
  }
  
  void validateForm() {
    newPasswordError.value = newPasswordController.text.isNotEmpty && newPasswordController.text.length < 8;
    confirmPasswordError.value = confirmPasswordController.text.isNotEmpty && 
                               (confirmPasswordController.text.length < 8 || 
                                confirmPasswordController.text != newPasswordController.text);
    
    isFormValid.value = oldPasswordController.text.isNotEmpty &&
                       newPasswordController.text.length >= 8 &&
                       confirmPasswordController.text.isNotEmpty &&
                       newPasswordController.text == confirmPasswordController.text;
  }

  void toggleOldPasswordVisibility() {
    obscureOldPassword.value = !obscureOldPassword.value;
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> changePassword() async {
    if (!isFormValid.value) return;
    
    if (newPasswordController.text.length < 8) {
      Get.snackbar('Info', 'New password must be at least 8 characters long');
      return;
    }
    
    try {
      isLoading.value = true;

      final response = await _apiService.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );
      
      Get.back();
      Get.snackbar('Success', response['message'] ?? 'Password changed successfully');
    } catch (e) {
      Get.snackbar('Info', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}