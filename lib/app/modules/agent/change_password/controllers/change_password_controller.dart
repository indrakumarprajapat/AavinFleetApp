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
    final text = newPasswordController.text;
    final hasSpace = text.contains(' ');
    
    newPasswordError.value = text.isNotEmpty && (text.length < 6 || text.length > 20 || hasSpace);
    confirmPasswordError.value = confirmPasswordController.text.isNotEmpty && 
                               (confirmPasswordController.text.length < 6 || 
                                confirmPasswordController.text != text);
    
    isFormValid.value = oldPasswordController.text.isNotEmpty &&
                       text.length >= 6 &&
                       text.length <= 20 &&
                       !hasSpace &&
                       confirmPasswordController.text.isNotEmpty &&
                       text == confirmPasswordController.text;
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
    
    final text = newPasswordController.text;
    if (text.length < 6 || text.length > 20 || text.contains(' ')) {
      Get.snackbar('Info', 'Password must be 6-20 characters long and contain no spaces');
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