import 'dart:io';
import 'package:aavin/app/modules/agent/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_enums.dart';
import '../../../data/session_manager.dart';
import '../../../models/device_info.dart';
import '../../../routes/app_pages.dart';
import '../../../api/api_service.dart';
import '../../../models/models.dart';
import '../../../services/config_service.dart';
import '../../../utils/device-util.dart';

class SplashController extends GetxController {
  final storage = GetStorage();
  final apiService = Get.find<ApiService>();
  final config = Get.find<ClientConfig>();

  @override
  void onInit() {
    super.onInit();

    // The splash flow is now controlled by SplashView's animation sequence
    // to ensure the Tamil Nadu Government logo is displayed before navigating.
  }

  /// call this manually AFTER animation
  Future<void> startSplashFlow() async {
    // await Future.delayed(const Duration(seconds: 1));
    final shouldUpdate = await _checkForceUpdate();
    if (shouldUpdate) return;

    _checkAutoLogin();
  }

  void _checkAutoLogin() async {
    final isLoggedIn = await _autoLoginCall();
    if (isLoggedIn) {
      final activeTripId = storage.read('active_trip_id');
      if (activeTripId != null) {
        Get.offAllNamed(Routes.DELIVERY_ROUTE, arguments: activeTripId);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<bool> _checkForceUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final response = await apiService.checkAppVersion();
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final latestVersion = platform == 'ios'
          ? response['ios_latest_version'] ?? ''
          : response['android_latest_version'] ?? '';
      final forceUpdate = response['force_update'] ?? false;
      final storeUrl = platform == 'ios'
          ? response['app_store_url'] ?? ''
          : response['play_store_url'] ?? '';
      if (forceUpdate && _isVersionOlder(currentVersion, latestVersion)) {
        _showForceUpdateDialog(storeUrl);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }


  bool _isVersionOlder(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      
      if (currentPart < latestPart) return true;
      if (currentPart > latestPart) return false;
    }
    return false;
  }


  _autoLoginCall() async {
    final session = Get.find<SessionManager>();
    session.loadSession();
    var fleetUser = session.fleetUser.value;

    // Check if we have a stored token
    final storedToken = fleetUser?.accessToken ?? storage.read('access_token');

    if (storedToken == null) return false;

    try {
      var deviceInfo = DeviceInfo();
      var version = '';
      try {
        deviceInfo = await DeviceUtil.getDeviceDetails();
        version = await DeviceUtil.getAppVersion();
      } catch (err) {
        // Silently continue
      }

      // Attempt auto-login with the token
      final responseFleetUser = await apiService.agentAutoLogin(storedToken, deviceInfo, version);
      
      // Save the refreshed session
      await session.saveSession(responseFleetUser);
      return true;
    } catch (e) {
      // If it's an Authentication error (401/403), the session is invalid -> Logout
      if (e.toString().contains('401') || e.toString().contains('403')) {
        await session.clearSession();
        return false;
      }
      
      // For network errors or server downtime, trust the existing local session
      // This allows the app to proceed to the Home/Delivery screen even if offline
      return fleetUser != null; 
    }
  }

  void _showForceUpdateDialog(String playStoreUrl) {
    Get.dialog(
      AlertDialog(
        title: Text('Update Required'),
        content: Text('A new version of the app is available. Please update to continue.'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (playStoreUrl.isNotEmpty) {
                await launchUrl(Uri.parse(playStoreUrl));
              }
            },
            child: Text('Update Now'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
