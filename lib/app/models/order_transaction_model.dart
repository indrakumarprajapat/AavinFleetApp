class OrderTransactionModel {
  final int? id;
  final int? agentId;
  final String? orderIds;
  final double? totalAmount;
  final String? paymentMethod;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final int? paymentStatus;
  final String? failureReason;
  final String? createdAt;
  final String? updatedAt;

  OrderTransactionModel({
    this.id,
    this.agentId,
    this.orderIds,
    this.totalAmount,
    this.paymentMethod,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.paymentStatus,
    this.failureReason,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderTransactionModel.fromJson(Map<String, dynamic> json) {
    return OrderTransactionModel(
      id: json['id'] as int?,
      agentId: json['agent_id'] as int?,
      orderIds: json['order_ids']?.toString(),
      totalAmount: json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) : null,
      paymentMethod: json['payment_method']?.toString(),
      razorpayOrderId: json['razorpay_order_id']?.toString(),
      razorpayPaymentId: json['razorpay_payment_id']?.toString(),
      razorpaySignature: json['razorpay_signature']?.toString(),
      paymentStatus: json['payment_status'] as int?,
      failureReason: json['failure_reason']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_id': agentId,
      'order_ids': orderIds,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'payment_status': paymentStatus,
      'failure_reason': failureReason,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}