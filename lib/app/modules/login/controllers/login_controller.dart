import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_enums.dart';
import '../../../data/session_manager.dart';
import '../../../routes/app_pages.dart';
import '../../../api/api_service.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utils/location-utils.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final _isLoading = false.obs;
  final _selectedUserType = UserType.fleetUser.obs;
  final apiService = Get.find<ApiService>();
  final storage = GetStorage();

  bool get isLoading => _isLoading.value;
  UserType get selectedUserType => _selectedUserType.value;

  void setUserType(UserType type) {
    _selectedUserType.value = type;
  }

  void resetLoginState() {
    _selectedUserType.value = UserType.fleetUser;
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
      double? lat, lng;
      final allowed = await LocationUtils.ensureLocationPermission();
      if (allowed) {
        final pos = await LocationUtils.getCurrentLocation();
        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
        }
      }

      final fleetUser = await apiService.loginWithPassword(
          phoneController.text,
          passwordController.text,
          lat: lat,
          lng: lng,
      );

      if (fleetUser.accessToken == null || fleetUser.accessToken!.isEmpty) {
        Get.snackbar('Error', 'Invalid credentials or missing access token');
        return;
      }

      final session = Get.find<SessionManager>();
      await session.saveSession(fleetUser);

      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
