class SubscriptionDetailsModel {
  final SubscriptionDetail subscription;
  final BoothDetail booth;
  final List<TransactionDetail> transactions;

  SubscriptionDetailsModel({
    required this.subscription,
    required this.booth,
    required this.transactions,
  });

  factory SubscriptionDetailsModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetailsModel(
      subscription: SubscriptionDetail.fromJson(json['subscription']),
      booth: BoothDetail.fromJson(json['booth']),
      transactions: (json['transactions'] as List? ?? [])
          .map((t) => TransactionDetail.fromJson(t))
          .toList(),
    );
  }
}

class SubscriptionDetail {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final int status;
  final double? totalAmount;
  final int totalDays;
  final int totalOrders;

  SubscriptionDetail({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalAmount,
    required this.totalDays,
    required this.totalOrders,
  });

  factory SubscriptionDetail.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetail(
      id: json['id'],
      title: json['title'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      totalAmount: double.parse(json['totalAmount'].toString()),
      totalDays: json['totalDays'],
      totalOrders: json['totalOrders'],
    );
  }
}

class BoothDetail {
  final int id;
  final String name;
  final String address;
  final String landmark;
  final String boothCode;

  BoothDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.landmark,
    required this.boothCode,
  });

  factory BoothDetail.fromJson(Map<String, dynamic> json) {
    return BoothDetail(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      landmark: json['landmark'],
      boothCode: json['booth_code'],
    );
  }
}

class TransactionDetail {
  final int id;
  final int customerId;
  final String orderIds;
  final String totalAmount;
  final String paymentMethod;
  final int paymentStatus;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? failureReason;
  final String createdAt;
  final String paymentMethodName;

  TransactionDetail({
    required this.id,
    required this.customerId,
    required this.orderIds,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.failureReason,
    required this.createdAt,
    required this.paymentMethodName,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'],
      customerId: json['customer_id'],
      orderIds: json['order_ids'],
      totalAmount: json['total_amount'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpaySignature: json['razorpay_signature'],
      failureReason: json['failure_reason'],
      createdAt: json['created_at'],
      paymentMethodName: json['payment_method_name'],
    );
  }
}