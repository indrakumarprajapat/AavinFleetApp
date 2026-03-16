class CartModel {
  final int? id;
  final int? agentId;
  final int? productId;
  final double? quantity;
  final double? eveningQuantity;
  final double? morningQuantity;
  final int? shiftType;
  final String? productName;
  final String? productCode;
  final double? price;
  final int? trayCount;
  final double? gstPercentage;
  final String? createdAt;
  final double? incrementBy;
  final int? itemUnitType;
  final int? orderType;


  CartModel({
    this.id,
    this.agentId,
    this.productId,
    this.quantity,
    this.eveningQuantity,
    this.morningQuantity,
    this.shiftType,
    this.productName,
    this.productCode,
    this.price,
    this.trayCount,
    this.gstPercentage,
    this.createdAt,
    this.incrementBy,
    this.itemUnitType,
    this.orderType,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as int?,
      agentId: json['agent_id'] as int?,
      productId: json['product_id'] as int?,
      quantity: double.parse(json['quantity'].toString()),
      morningQuantity: double.parse(json['morning_quantity'].toString()),
      eveningQuantity: double.parse(json['evening_quantity'].toString()),
      shiftType: json['shift_type'] as int?,
      productName: json['product_name']?.toString(),
      productCode: json['product_code']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      trayCount: json['tray_capacity'] != null ? int.tryParse(json['tray_capacity'].toString()) : null,
      gstPercentage: json['gst_percentage'] != null ? double.tryParse(json['gst_percentage'].toString()) : null,
      createdAt: json['created_at']?.toString(),
      incrementBy: double.parse(json['increment_by'].toString()),
      itemUnitType: json['item_unit_type']??1,
      orderType: json['order_type']??1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_id': agentId,
      'product_id': productId,
      'quantity': quantity,
      'morning_quantity': morningQuantity,
      'evening_quantity': eveningQuantity,
      'shift_type': shiftType,
      'product_name': productName,
      'product_code': productCode,
      'price': price,
      'tray_capacity': trayCount,
      'gst_percentage': gstPercentage,
      'created_at': createdAt,
      'increment_by': incrementBy,
      'item_unit_type': itemUnitType,
      'order_type': orderType
    };
  }
}

class CartResponseModel {
  final double? subtotalAmount;
  final double? totalTax;
  final double? totalAmount;
  final double? totalDiscount;
  final List<CartModel>? items;
  final bool? enableMorningSlot;
  final bool? enableEveningSlot;

  CartResponseModel({
    this.subtotalAmount,
    this.totalTax,
    this.totalAmount,
    this.items,
    this.totalDiscount,
    this.enableMorningSlot,
    this.enableEveningSlot
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      subtotalAmount: json['subtotalAmount'] != null ? double.tryParse(json['subtotalAmount'].toString()) : null,
      totalTax: json['totalTax'] != null ? double.tryParse(json['totalTax'].toString()) : null,
      totalDiscount: json['totalDiscount'] != null ? double.tryParse(json['totalDiscount'].toString()) : null,
      totalAmount: json['totalAmount'] != null ? double.tryParse(json['totalAmount'].toString()) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((item) => CartModel.fromJson(item)).toList()
          : null,
      enableMorningSlot: json['enableMorningSlot'] as bool?,
      enableEveningSlot: json['enableEveningSlot'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotalAmount': subtotalAmount,
      'totalTax': totalTax,
      'totalAmount': totalAmount,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}