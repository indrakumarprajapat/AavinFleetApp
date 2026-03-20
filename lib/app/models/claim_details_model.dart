import 'claim_model.dart';

class ClaimDetailsModel {
  final ClaimDetailModel claim;
  final List<ClaimItemModel> items;

  ClaimDetailsModel({
    required this.claim,
    required this.items,
  });

  factory ClaimDetailsModel.fromJson(Map<String, dynamic> json) {
    return ClaimDetailsModel(
      claim: ClaimDetailModel.fromJson(json['claim']),
      items: (json['items'] as List)
          .map((item) => ClaimItemModel.fromJson(item))
          .toList(),
    );
  }
}

class ClaimDetailModel extends ClaimModel {
  final String? orderDate;

  ClaimDetailModel({
    super.id,
    required super.orderId,
    required super.agentId,
    required super.boothId,
    required super.reason,
    super.description,
    super.remarks,
    super.photoUrls,
    super.status = 1,
    super.createdAt,
    super.statusText,
    super.totalAmount,
    super.shift,
    this.orderDate,
  });

  factory ClaimDetailModel.fromJson(Map<String, dynamic> json) {
    List<String>? urls;
    if (json['photo_urls'] != null) {
      if (json['photo_urls'] is List) {
        urls = (json['photo_urls'] as List).map((e) => e.toString()).toList();
      }
    }

    return ClaimDetailModel(
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
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0'),
      shift: json['shift'],
      orderDate: json['order_date'],
    );
  }
}