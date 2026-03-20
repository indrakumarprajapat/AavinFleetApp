class TransactionModel {
  final String transactionType;
  final int id;
  final String amount;
  final int? walletType;
  final int? referenceType;
  final int? referenceId;
  final int? creditType;
  final int? orderId;
  final String? paymentMethod;
  final int? paymentStatus;
  final String? orderIds;
  final String? razorpayPaymentId;
  final String description;
  final String createdAt;
  final int status;

  TransactionModel({
    required this.transactionType,
    required this.id,
    required this.amount,
    this.walletType,
    this.referenceType,
    this.referenceId,
    this.creditType,
    this.orderId,
    this.paymentMethod,
    this.paymentStatus,
    this.orderIds,
    this.razorpayPaymentId,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionType: json['transaction_type'] ?? '',
      id: json['id'] ?? 0,
      amount: json['amount']?.toString() ?? '0',
      walletType: json['wallet_type'],
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      creditType: json['credit_type'],
      orderId: json['order_id'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      orderIds: json['order_ids'],
      razorpayPaymentId: json['razorpay_payment_id'],
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_type': transactionType,
      'id': id,
      'amount': amount,
      'wallet_type': walletType,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'credit_type': creditType,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_ids': orderIds,
      'razorpay_payment_id': razorpayPaymentId,
      'description': description,
      'created_at': createdAt,
      'status': status,
    };
  }
}