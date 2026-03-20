class CartSummary {
  final double subtotal;
  final double tax;
  final double totalAmount;
  final int totalDays;

  CartSummary({
    required this.subtotal,
    required this.tax,
    required this.totalAmount,
    required this.totalDays,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      totalDays: json['totalDays'] ?? 30,
    );
  }
}