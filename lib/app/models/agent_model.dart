import '../utils/parse-util.dart';

class SocietyUser {
  final String? id;
  final String? name;
  final String? mobileNumber;
  final String? gender;
  final String? aadharNumber;
  final String? panNumber;
  final bool? isAadhaarKycVerified;
  final bool? isPanKycVerified;
  final bool? hasBankAccountVerified;
  final String? profilePhoto;
  final String? accountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? accountHolderName;
  final String? bankBranch;
  final String? aadharLink;
  final String? panCardLink;
  final bool? hasAadharVerified;
  final bool? hasPancardVerified;
  final String? unionId;
  final String? userType;
  final String? status;
  final bool? gstRegistered;
  final String? gstNumber;
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

  SocietyUser(
      {this.id,
      this.name,
      this.mobileNumber,
      this.gender,
      this.aadharNumber,
      this.panNumber,
      this.isAadhaarKycVerified,
      this.isPanKycVerified,
      this.hasBankAccountVerified,
      this.profilePhoto,
      this.accountNumber,
      this.bankName,
      this.ifscCode,
      this.accountHolderName,
      this.bankBranch,
      this.aadharLink,
      this.panCardLink,
      this.hasAadharVerified,
      this.hasPancardVerified,
      this.unionId,
      this.userType,
      this.status,
      this.gstRegistered,
      this.gstNumber,
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

  factory SocietyUser.fromJson(Map<String, dynamic> json) {
    return SocietyUser(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      mobileNumber: json['mobile_number']?.toString() ?? json['mobileNumber']?.toString(),
      gender: json['gender']?.toString(),
      aadharNumber: json['aadhar_number']?.toString() ?? json['aadharNumber']?.toString(),
      panNumber: json['pan_number']?.toString() ?? json['panNumber']?.toString(),
      isAadhaarKycVerified: ParseUtil.parseBool(json['is_aadhaar_kyc_verified'] ?? json['isAadhaarKycVerified']),
      isPanKycVerified: ParseUtil.parseBool(json['is_pan_kyc_verified'] ?? json['isPanKycVerified']),
      hasBankAccountVerified: ParseUtil.parseBool(json['has_bank_account_verified'] ?? json['hasBankAccountVerified']),
      profilePhoto: json['profile_photo']?.toString() ?? json['profilePhoto']?.toString(),
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString(),
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString(),
      ifscCode: json['ifsc_code']?.toString() ?? json['ifscCode']?.toString(),
      accountHolderName: json['account_holder_name']?.toString() ?? json['accountHolderName']?.toString(),
      bankBranch: json['bank_branch']?.toString() ?? json['bankBranch']?.toString(),
      aadharLink: json['aadhar_link']?.toString() ?? json['aadharLink']?.toString(),
      panCardLink: json['pan_card_link']?.toString() ?? json['panCardLink']?.toString(),
      hasAadharVerified: ParseUtil.parseBool(json['has_aadhar_verified'] ?? json['hasAadharVerified']),
      hasPancardVerified: ParseUtil.parseBool(json['has_pancard_verified'] ?? json['hasPancardVerified']),
      unionId: json['union_id']?.toString() ?? json['unionId']?.toString(),
      userType: json['user_type']?.toString() ?? json['userType']?.toString(),
      status: json['status']?.toString(),
      gstRegistered: ParseUtil.parseBool(json['gst_registered'] ?? json['gstRegistered']),
      gstNumber: json['gst_number']?.toString() ?? json['gstNumber']?.toString(),
      key: json['key']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'gender': gender,
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'isAadhaarKycVerified': isAadhaarKycVerified,
      'isPanKycVerified': isPanKycVerified,
      'hasBankAccountVerified': hasBankAccountVerified,
      'profilePhoto': profilePhoto,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'bankBranch': bankBranch,
      'aadharLink': aadharLink,
      'panCardLink': panCardLink,
      'hasAadharVerified': hasAadharVerified,
      'hasPancardVerified': hasPancardVerified,
      'unionId': unionId,
      'userType': userType,
      'status': status,
      'gstRegistered': gstRegistered,
      'gstNumber': gstNumber,
      'ios_push_token': iosPushToken,
      'android_push_token': androidPushToken,
      'lat': lat,
      'lng': lng,
      'appCurVersion': appCurVersion,
      'dOsApi': dOsApi,
      'dManufacture': dManufacture,
      'dModel': dModel,
      'dOsVersion': dOsVersion,
      'loginDevice': loginDevice,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'lastAutologinTime': lastAutologinTime?.toIso8601String(),
    };

 }
}
