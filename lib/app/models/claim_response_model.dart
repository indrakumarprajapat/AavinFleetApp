class ClaimResponseModel {
  final int id;
  final int orderId;
  final int agentId;
  final int boothId;
  final String reason;
  final String? description;
  final List<String> photoUrls;
  final int status;
  final String createdAt;
  final String? updatedAt;
  final int createdBy;
  final String totalAmount;
  final int shift;
  final String statusText;

  ClaimResponseModel({
    required this.id,
    required this.orderId,
    required this.agentId,
    required this.boothId,
    required this.reason,
    this.description,
    required this.photoUrls,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    required this.totalAmount,
    required this.shift,
    required this.statusText,
  });

  factory ClaimResponseModel.fromJson(Map<String, dynamic> json) {
    return ClaimResponseModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      agentId: json['agent_id'] ?? 0,
      boothId: json['booth_id'] ?? 0,
      reason: json['reason'] ?? '',
      description: json['description'],
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      createdBy: json['created_by'] ?? 0,
      totalAmount: json['total_amount'] ?? '0.00',
      shift: json['shift'] ?? 0,
      statusText: json['status_text'] ?? '',
    );
  }
}