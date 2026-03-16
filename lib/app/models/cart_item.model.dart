class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String productCode;
  final double price;
  final int quantity;
  final int shiftType;
  final String? categoryName;
  final double gstPercentage;
  final int trayCount;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.price,
    required this.quantity,
    required this.shiftType,
    this.categoryName,
    this.gstPercentage = 0.0,
    this.trayCount = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'] ?? 0;
    final price = priceValue is String ? double.tryParse(priceValue) ?? 0.0 : (priceValue as num).toDouble();
    
    return CartItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      price: price,
      quantity: json['quantity'] ?? 0,
      shiftType: json['shift_type'] ?? 1,
      categoryName: json['category_name'],
      gstPercentage: (json['gst_percentage'] ?? 0).toDouble(),
      trayCount: json['tray_capacity'] ?? 1,
    );
  }

  String get shiftName => shiftType == 1 ? 'Morning' : 'Evening';
  double get totalPrice => price * quantity;
}