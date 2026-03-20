class CreditOutstandingModel {
  final int? boothId;
  final double outstandingAmount;

  CreditOutstandingModel({
    this.boothId,
    required this.outstandingAmount,
  });

  factory CreditOutstandingModel.fromJson(Map<String, dynamic> json) {
    return CreditOutstandingModel(
      boothId: json['boothId'],
      outstandingAmount: (json['outstandingAmount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boothId': boothId,
      'outstandingAmount': outstandingAmount,
    };
  }
}