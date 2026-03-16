import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_enums.dart';
import '../../../models/DeviceInfo.dart';
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

    if(config.name != ClientConfig.CLIENT_NAMAKKAL){
      _checkAutoLogin();
    }
  }

  /// call this manually AFTER animation
  void startSplashFlow() {
    _checkAutoLogin();
  }

  void _checkAutoLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final shouldUpdate = await _checkForceUpdate();
    if (shouldUpdate) return;

    final accessToken = storage.read('access_token');

    if (accessToken != null) {
      try {
        final userType = storage.read('user_type') ?? UserType.society.index;
        LoginResponseModel response;
        var  deviceInfo = DeviceInfo();
        var  version = '';
        try{
          deviceInfo = await DeviceUtil.getDeviceDetails();
          version = await DeviceUtil.getAppVersion();

        }catch(err){
          print(err);
        }

        // if (userType == UserType.customer.index) {
        //   response = await apiService.autoLogin(accessToken,deviceInfo,version);
        //   await storage.write('customer', response.customer ?? {});
        //   try {
        //     final configService = Get.find<ConfigService>();
        //     await configService.fetchConfig();
        //   } catch (e) {
        //     print('Config fetch error: $e');
        //   }
        //
        //   Get.offAllNamed(Routes.CUSTOMER_HOME);
        // } else {
          response = await apiService.agentAutoLogin(accessToken,deviceInfo,version);
          await storage.write('agent', response.agent?.toJson() ?? {});
          await storage.write('societyDetails', response.boothDetails?.toJson() ?? {});
          await storage.write('razorpay_key', response.agent?.key ?? '');
          // await storage.write('itemUnitType', response.agent?.itemUnitType);
          try {
            final configService = Get.find<ConfigService>();
            await configService.fetchConfig();
          } catch (e) {
            print('Config fetch error: $e');
          }
          
          Get.offAllNamed(Routes.HOME);
        // }
      } catch (e) {
        storage.erase();
        if(config.name == ClientConfig.CLIENT_CBE){
          Get.offNamed(Routes.USER_TYPE);
        }else{
          Get.offNamed(Routes.LOGIN, arguments: UserType.society);
        }
      }
    } else {
      if(config.name == ClientConfig.CLIENT_CBE){
        Get.offNamed(Routes.USER_TYPE);
      }else{
        Get.offNamed(Routes.LOGIN, arguments: UserType.society);
      }
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
