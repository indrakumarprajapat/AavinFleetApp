class Product {
  final int id;
  final String name;
  final String productCode;
  final double price;
  final String? categoryName;
  final int? categoryId;
  final int cartQuantity;
  final int trayCount;
  final double? gst;
  final double? totalAmount;
  Product({
    required this.id,
    required this.name,
    required this.productCode,
    required this.price,
    this.categoryName,
    this.categoryId,
    this.cartQuantity = 0,
    this.trayCount = 0,
    this.gst = 0,
    this.totalAmount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'] ?? 0;
    final price = priceValue is String ? double.tryParse(priceValue) ?? 0.0 : (priceValue as num).toDouble();
    final gstValue =  json['gst']??0;
    final gst = gstValue is String ? double.tryParse(gstValue) ?? 0.0 : (gstValue as num).toDouble();
    final totalAmount = json['total_amount'] ?? 0;
    final totalAmountValue = totalAmount is String ? double.tryParse(totalAmount) ?? 0.0 : (totalAmount as num).toDouble();
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      productCode: json['product_code'] ?? '',
      price: price,
      categoryName: json['category_name'],
      categoryId: json['category_id'],
      cartQuantity: json['cart_quantity'] ?? 0,
      trayCount: json['tray_capacity'] ?? 0,
      gst:gst,
      totalAmount: totalAmountValue
    );
  }

  bool get isMilkProduct => 
    (categoryName?.toLowerCase().contains('milk') ?? false) ||
    (name.toLowerCase().contains('milk'));

  bool get isCurdProduct => 
    (categoryName?.toLowerCase().contains('curd') ?? false) ||
    (name.toLowerCase().contains('curd'));
}