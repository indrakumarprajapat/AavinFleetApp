class RazorpayOrderResponse {
  final int amount;
  final String id;
  final String receipt;
  final String status;

  RazorpayOrderResponse({
    required this.amount,
    required this.id,
    required this.receipt,
    required this.status,
  });

  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderResponse(
      amount: json['amount'],
      id: json['id'],
      receipt: json['receipt'] ?? "",
      status: json['status'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'id': id, 'receipt': receipt, 'status': status};
  }
}
