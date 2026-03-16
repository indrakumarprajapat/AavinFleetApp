class EarningsModel {
  final String month;
  final double totalEarnings;
  final double commissionAmount;
  final double leakageAmount;

  EarningsModel({
    required this.month,
    required this.totalEarnings,
    required this.commissionAmount,
    required this.leakageAmount,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      month: json['month'] ?? '',
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      commissionAmount: (json['commissionAmount'] ?? 0.0).toDouble(),
      leakageAmount: (json['leakageAmount'] ?? 0.0).toDouble(),
    );
  }
}
