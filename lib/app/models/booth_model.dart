import '../utils/parse-util.dart';

class Society {
  final String? id;
  final String? societyName;
  final String? societyCode;
  final String? address;
  final bool? isLocSubmit;
  final String? latitude;
  final String? longitude;
  final String? createdAt;
  final String? updatedAt;
  final String? unionId;
  final String? boothTypeId;
  final String? agentId;
  final double? lat;
  final double? lng;
  final String? landmark;
  final String? imageLink;
  final String? locExpireTime;
  final String? locationUrl;
  final String? code;
  final int? status;
  final bool? hasBankAccountVerified;
  final bool? isCredit;
  final bool? isOnlinePayAllow;
  final bool? isCreditPayAllow;
  final bool? isWalletPayAllow;
  final double? outstandingAmount;

  Society({
    this.id,
    this.societyName,
    this.societyCode,
    this.address,
    this.isLocSubmit,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.unionId,
    this.boothTypeId,
    this.agentId,
    this.lat,
    this.lng,
    this.landmark,
    this.imageLink,
    this.locExpireTime,
    this.locationUrl,
    this.code,
    this.status,
    this.hasBankAccountVerified,
    this.isCredit,
    this.isOnlinePayAllow,
    this.isCreditPayAllow,
    this.isWalletPayAllow,
    this.outstandingAmount
  });

  factory Society.fromJson(Map<String, dynamic> json) {
    // Parse isLocSubmit with detailed logging
    final rawIsLocSubmit = json['isLocSubmit'] ?? json['is_loc_submit'];
    final parsedIsLocSubmit = (() {
      if (rawIsLocSubmit == null) return false;
      if (rawIsLocSubmit is bool) return rawIsLocSubmit;
      if (rawIsLocSubmit is int) return rawIsLocSubmit == 1;
      if (rawIsLocSubmit is String) {
        return rawIsLocSubmit == '1' || rawIsLocSubmit.toLowerCase() == 'true';
      }
      return false;
    })();
    
    return Society(
      id: json['id']?.toString(),
      societyName:  json['societyName'] == null ? json['society_name']?.toString() : json['societyName'] ?? '',
      societyCode:   json['societyCode'] == null ? json['society_code']?.toString() : json['societyCode'] ?? '',
      address: json['address']?.toString(),
      isLocSubmit: parsedIsLocSubmit,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      unionId: json['unionId']?.toString(),
      boothTypeId: json['boothTypeId']?.toString(),
      agentId: json['agentId']?.toString(),
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      landmark: json['landmark']?.toString(),
      imageLink: json['imageLink']?.toString(),
      locExpireTime: json['locExpireTime']?.toString(),
      locationUrl: json['locationUrl']?.toString(),
      code: json['code']?.toString(),
      status:  ParseUtil.parseInt(json['status']),
      hasBankAccountVerified: ParseUtil.parseBool(json['hasBankAccountVerified']),
      isCredit: (() {
        final value = json['isCredit'];
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) return value == '1' || value.toLowerCase() == 'true';
        return false;
      })(),
      isOnlinePayAllow: (() {
        final value = json['isOnlinePayAllow'];
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) return value == '1' || value.toLowerCase() == 'true';
        return false;
      })(),
      isCreditPayAllow: (() {
        final value = json['isCreditPayAllow'];
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) return value == '1' || value.toLowerCase() == 'true';
        return false;
      })(),
      isWalletPayAllow: (() {
        final value = json['isWalletPayAllow'];
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) return value == '1' || value.toLowerCase() == 'true';
        return false;
      })(),
      // outstandingAmount: json['outstanding_amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'society_name': societyName,
      'society_code': societyCode,
      'address': address,
      'isLocSubmit': isLocSubmit,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'unionId': unionId,
      'boothTypeId': boothTypeId,
      'agentId': agentId,
      'lat': lat,
      'lng': lng,
      'landmark': landmark,
      'imageLink': imageLink,
      'locExpireTime': locExpireTime,
      'locationUrl': locationUrl,
      'code': code,
      'status': status,
      'hasBankAccountVerified': hasBankAccountVerified,
    };
  }
}