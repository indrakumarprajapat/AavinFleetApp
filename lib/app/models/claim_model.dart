class ClaimModel {
  final int? id;
  final int orderId;
  final int agentId;
  final int boothId;
  final String reason;
  final String? description;
  final String? remarks;
  final List<String>? photoUrls;
  final int status; // 1: pending, 2: approved, 3: rejected
  final String? createdAt;
  final String? statusText;
  final double? totalAmount;
  final int? shift;


  ClaimModel({
    this.id,
    required this.orderId,
    required this.agentId,
    required this.boothId,
    required this.reason,
    this.description,
    this.photoUrls,
    this.status = 1,
    this.createdAt,
    this.statusText,
    this.totalAmount,
    this.shift,
    this.remarks
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    List<String>? urls;
    if (json['photo_urls'] != null) {
      if (json['photo_urls'] is List) {
        urls = (json['photo_urls'] as List).map((e) => e.toString()).toList();
      }
    }
    double? totalAmount;
    if (json['total_amount'] != null) {
      if (json['total_amount'] is String) {
        totalAmount = double.tryParse(json['total_amount']);
      } else if (json['total_amount'] is num) {
        totalAmount = json['total_amount'].toDouble();
      }
    }
    return ClaimModel(
      id: json['id'],
      orderId: json['order_id'],
      agentId: json['agent_id'],
      boothId: json['booth_id'],
      reason: json['reason'] ?? '',
      description: json['description'],
      remarks: json['remarks'],
      photoUrls: urls,
      status: json['status'] ?? 1,
      createdAt: json['created_at'],
      statusText: json['status_text'],
      totalAmount: totalAmount,
      shift: json['shift'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'agent_id': agentId,
      'booth_id': boothId,
      'reason': reason,
      'description': description,
      'photo_urls': photoUrls,
      'status': status,
      'created_at': createdAt,
      'status_text': statusText,
      'total_amount': totalAmount,
      'shift': shift,
    };
  }
}

class ClaimItemModel {
  final int? id;
  final int claimId;
  final int productId;
  final int damagedQuantity;
  final int? originalQuantity;
  final String? notes;
  final String? productName;
  final String? productCode;

  ClaimItemModel({
    this.id,
    required this.claimId,
    required this.productId,
    required this.damagedQuantity,
    this.originalQuantity,
    this.notes,
    this.productName,
    this.productCode,
  });

  factory ClaimItemModel.fromJson(Map<String, dynamic> json) {
    return ClaimItemModel(
      id: json['id'],
      claimId: json['claim_id'],
      productId: json['product_id'],
      damagedQuantity: json['damaged_quantity'],
      originalQuantity: json['original_quantity'],
      notes: json['notes'],
      productName: json['product_name'],
      productCode: json['product_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claim_id': claimId,
      'product_id': productId,
      'damaged_quantity': damagedQuantity,
      'original_quantity': originalQuantity,
      'notes': notes,
      'product_name': productName,
      'product_code': productCode,
    };
  }
}