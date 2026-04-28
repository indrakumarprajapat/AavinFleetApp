import '../utils/parse-util.dart';

class FleetUser {
  final String? id;
  final String? name;
  final String? mobileNumber;
  final String? gender;
  // final String? aadharNumber;
  // final String? panNumber;
  // final bool? isAadhaarKycVerified;
  // final bool? isPanKycVerified;
  // final bool? hasBankAccountVerified;
  final String? profilePhoto;
  // final String? accountNumber;
  // final String? bankName;
  // final String? ifscCode;
  // final String? accountHolderName;
  // final String? bankBranch;
  // final String? aadharLink;
  // final String? panCardLink;
  // final bool? hasAadharVerified;
  // final bool? hasPancardVerified;
  final String? unionId;
  final String? userType;
  final String? status;
  // final bool? gstRegistered;
  // final String? gstNumber;
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

  final String? contractReferenceNumber;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;
  final String? operatorName;
  final String? operatorMobile;
  final int? routeId;
  final String? routeName;
  final int? shift;
  final String? vehicleRegistrationNumber;
  final double? vehicleCurbWeight;
  final double? vehicleOffloadCapacity;
  final String? username;
  final String? accessToken;
  final String? refreshToken;

  FleetUser(
      {this.id,
      this.name,
      this.mobileNumber,
      this.gender,
      // this.aadharNumber,
      // this.panNumber,
      // this.isAadhaarKycVerified,
      // this.isPanKycVerified,
      // this.hasBankAccountVerified,
      this.profilePhoto,
      // this.accountNumber,
      // this.bankName,
      // this.ifscCode,
      // this.accountHolderName,
      // this.bankBranch,
      // this.aadharLink,
      // this.panCardLink,
      // this.hasAadharVerified,
      // this.hasPancardVerified,
      this.unionId,
      this.userType,
      this.status,
      // this.gstRegistered,
      // this.gstNumber,
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
        this.contractReferenceNumber,
        this.contractStartDate,
        this.contractEndDate,
        this.operatorName,
        this.operatorMobile,
        this.routeId,
        this.routeName,
        this.shift,
        this.vehicleRegistrationNumber,
        this.vehicleCurbWeight,
        this.vehicleOffloadCapacity,
        this.username,
        this.accessToken,
        this.refreshToken
      });

  factory FleetUser.fromJson(Map<String, dynamic> json) {
    return FleetUser(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      mobileNumber: json['mobile_number']?.toString() ?? json['mobileNumber']?.toString(),
      gender: json['gender']?.toString(),
      // aadharNumber: json['aadhar_number']?.toString() ?? json['aadharNumber']?.toString(),
      // panNumber: json['pan_number']?.toString() ?? json['panNumber']?.toString(),
      // isAadhaarKycVerified: ParseUtil.parseBool(json['is_aadhaar_kyc_verified'] ?? json['isAadhaarKycVerified']),
      // isPanKycVerified: ParseUtil.parseBool(json['is_pan_kyc_verified'] ?? json['isPanKycVerified']),
      // hasBankAccountVerified: ParseUtil.parseBool(json['has_bank_account_verified'] ?? json['hasBankAccountVerified']),
      profilePhoto: json['profile_photo']?.toString() ?? json['profilePhoto']?.toString(),
      // accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString(),
      // bankName: json['bank_name']?.toString() ?? json['bankName']?.toString(),
      // ifscCode: json['ifsc_code']?.toString() ?? json['ifscCode']?.toString(),
      // accountHolderName: json['account_holder_name']?.toString() ?? json['accountHolderName']?.toString(),
      // bankBranch: json['bank_branch']?.toString() ?? json['bankBranch']?.toString(),
      // aadharLink: json['aadhar_link']?.toString() ?? json['aadharLink']?.toString(),
      // panCardLink: json['pan_card_link']?.toString() ?? json['panCardLink']?.toString(),
      // hasAadharVerified: ParseUtil.parseBool(json['has_aadhar_verified'] ?? json['hasAadharVerified']),
      // hasPancardVerified: ParseUtil.parseBool(json['has_pancard_verified'] ?? json['hasPancardVerified']),
      unionId: json['union_id']?.toString() ?? json['unionId']?.toString(),
      userType: json['user_type']?.toString() ?? json['userType']?.toString(),
      status: json['status']?.toString(),
      // gstRegistered: ParseUtil.parseBool(json['gst_registered'] ?? json['gstRegistered']),
      // gstNumber: json['gst_number']?.toString() ?? json['gstNumber']?.toString(),
      key: json['key']?.toString(),

      contractReferenceNumber: json['contract_reference_number']?.toString() ?? json['contractReferenceNumber']?.toString(),
      contractStartDate: ParseUtil.parseDateTime(
          json['contract_start_date'] ?? json['contractStartDate']
      ),

      contractEndDate: ParseUtil.parseDateTime(
          json['contract_end_date'] ?? json['contractEndDate']
      ),

      operatorName: json['operator_name']?.toString() ?? json['operatorName']?.toString(),

      operatorMobile: json['operator_mobile']?.toString() ?? json['operatorMobile']?.toString(),

        routeId: ParseUtil.parseInt(
            json['route_id'] ?? json['routeId']
        ),
      routeName:
            json['route_name'] ?? json['route_name'],


      shift: ParseUtil.parseInt(
          json['shift']
      ),

      vehicleRegistrationNumber: json['vehicle_registration_number']?.toString()
          ?? json['vehicleRegistrationNumber']?.toString(),

      vehicleCurbWeight: ParseUtil.parseDouble(
          json['vehicle_curb_weight'] ?? json['vehicleCurbWeight']
      ),

      vehicleOffloadCapacity: ParseUtil.parseDouble(
          json['vehicle_offload_capacity'] ?? json['vehicleOffloadCapacity']
      ),

      username: json['username']?.toString(),

      accessToken: json['access_token']?.toString() ?? json['accessToken']?.toString(),

      refreshToken: json['refresh_token']?.toString() ?? json['refreshToken']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile_number': mobileNumber,
      'gender': gender,
      'profile_photo': profilePhoto,

      'union_id': unionId,
      'user_type': userType,
      'status': status,
      'key': key,

      'contract_reference_number': contractReferenceNumber,
      'contract_start_date': contractStartDate?.toIso8601String(),
      'contract_end_date': contractEndDate?.toIso8601String(),

      'operator_name': operatorName,
      'operator_mobile': operatorMobile,

      'route_id': routeId,
      'route_name': routeName,

      'shift': shift,

      'vehicle_registration_number': vehicleRegistrationNumber,
      'vehicle_curb_weight': vehicleCurbWeight,
      'vehicle_offload_capacity': vehicleOffloadCapacity,

      'username': username,

      'access_token': accessToken,
      'refresh_token': refreshToken,
    };

  }
}
