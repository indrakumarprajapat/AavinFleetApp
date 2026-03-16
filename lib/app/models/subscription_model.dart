class SubscriptionModel {
  final int id;
  final int customerId;
  final String title;
  final String startDate;
  final String endDate;
  final int status;
  final double totalAmount;
  final String createdAt;
  final String updatedAt;

  SubscriptionModel({
    required this.id,
    required this.customerId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? 0,
      customerId: json['customerId'] ?? 0,
      title: json['title'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  String get statusText {
    switch (status) {
      case 1:
        return 'Upcoming';
      case 2:
        return 'Active';
      case 3:
        return 'Cancelled';
      case 4:
        return 'Paused';
      default:
        return 'Unknown';
    }
  }
}