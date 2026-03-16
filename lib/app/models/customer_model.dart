import '../utils/parse-util.dart';

class Customer {
  final int id;
  final int? unionId;
  final String? fullName;
  final String mobileNumber;
  final String? email;
  final String? address;
  final String? gender;
  final int? otp;
  final int? status;
  final bool isVerified;
  final String? accessToken;
  final int userType;
  final String? profilePhoto;
  final String? key;
  final String? iosPushToken;
  final String? androidPushToken;
  final double lat;
  final double lng;
  final String? appCurVersion;
  final String? dOsApi;
  final String? dManufacture;
  final String? dModel;
  final String? dOsVersion;
  final int? loginDevice;
  final DateTime? lastLoginTime;
  final DateTime? lastAutologinTime;

  Customer({
    required this.id,
    this.unionId,
    this.fullName,
    required this.mobileNumber,
    this.email,
    this.address,
    this.gender,
    this.otp,
    this.status,
    required this.isVerified,
    this.accessToken,
    this.userType = 1,
    this.profilePhoto,
    this.key,
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

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      unionId: json['unionId'],
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      email: json['email'],
      address: json['address'],
      gender: json['gender'],
      otp: json['otp'],
      status: json['status'],
      isVerified: ParseUtil.parseBool(json['isVerified']),
      accessToken: json['accessToken'],
      userType: json['userType'] ?? 1,
      profilePhoto: json['profilePhoto'],
      key: json['key']?.toString()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unionId': unionId,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'email': email,
      'address': address,
      'gender': gender,
      'otp': otp,
      'status': status,
      'isVerified': isVerified,
      'accessToken': accessToken,
      'userType': userType,
      'profilePhoto': profilePhoto,
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