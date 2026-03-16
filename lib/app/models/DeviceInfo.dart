class DeviceInfo {
  String? iosPushToken;
  String? androidPushToken;
  double lat;
  double lng;
  String? appCurVersion;
  String? dOsApi;
  String? dManufacture;
  String? dModel;
  String? dOsVersion;
  int? loginDevice;
  DateTime? lastLoginTime;
  DateTime? lastAutologinTime;

  DeviceInfo({
    this.iosPushToken,
    this.androidPushToken,
    this.lat = 0.0,
    this.lng = 0.0,
    this.appCurVersion,
    this.dOsApi,
    this.dManufacture,
    this.dModel,
    this.dOsVersion,
    this.loginDevice,
    this.lastLoginTime,
    this.lastAutologinTime,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      iosPushToken: json['ios_push_token'],
      androidPushToken: json['android_push_token'],
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      appCurVersion: json['app_cur_version'],
      dOsApi: json['d_os_api'],
      dManufacture: json['d_manufacture'],
      dModel: json['d_model'],
      dOsVersion: json['d_os_version'],
      loginDevice: json['login_device'],
      lastLoginTime: json['last_login_time'] != null
          ? DateTime.parse(json['last_login_time'])
          : null,
      lastAutologinTime: json['last_autologin_time'] != null
          ? DateTime.parse(json['last_autologin_time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ios_push_token': iosPushToken,
      'android_push_token': androidPushToken,
      'lat': lat,
      'lng': lng,
      'app_cur_version': appCurVersion,
      'd_os_api': dOsApi,
      'd_manufacture': dManufacture,
      'd_model': dModel,
      'd_os_version': dOsVersion,
      'login_device': loginDevice,
      'last_login_time': lastLoginTime?.toIso8601String(),
      'last_autologin_time': lastAutologinTime?.toIso8601String(),
    };
  }
}
