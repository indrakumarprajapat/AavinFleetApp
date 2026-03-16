import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/DeviceInfo.dart';

class LoginDeviceType {
  static const int android = 1;
  static const int ios = 2;
  static const int web = 3;
  static const int unknown = 0;
}
class DeviceUtil {
  static Future<DeviceInfo> getDeviceDetails() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfoPlugin.androidInfo;
      return DeviceInfo(loginDevice: LoginDeviceType.android, dOsApi: info.version.sdkInt.toString(),
    dManufacture: info.manufacturer, dModel: info.model,dOsVersion: info.version.release);
    } else if (Platform.isIOS) {
      final info = await deviceInfoPlugin.iosInfo;
      return DeviceInfo(loginDevice: LoginDeviceType.ios, dOsApi: info.systemVersion,
          dManufacture: "Apple", dModel: info.utsname.machine,dOsVersion: info.systemVersion);
    }

    return DeviceInfo();
  }

  static Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}
