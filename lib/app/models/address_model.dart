class AddressModel {
  final int id;
  final int customerId;
  final String address;
  final double? lat;
  final double? lng;
  final bool isPrimary;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.customerId,
    required this.address,
    this.lat,
    this.lng,
    required this.isPrimary,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? json['customerId'] ?? 0,
      address: json['address'] ?? '',
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      isPrimary: json['is_primary'] == 1 || json['is_primary'] == true || json['isPrimary'] == 1 || json['isPrimary'] == true,
      isDeleted: json['is_deleted'] == 1 || json['isDeleted'] == true,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'address': address,
      'lat': lat,
      'lng': lng,
      'isPrimary': isPrimary,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}