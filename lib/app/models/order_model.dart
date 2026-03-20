class OrderModel {
  final int? id;
  final String? orderNumber;
  final int? agentId;
  final int? slotId;
  final double? totalAmount;
  final int? status;
  final int? orderType;
  final int? shift;
  final String? orderDate;
  final List<OrderItemModel>? items;
  final String? createdAt;
  final String? updatedAt;
  final String? agentName;
  final String? agentMobile;
  final String? boothCode;
  final String? boothAddress;
  final String? boothName;
  final bool? canCancel;
  final double? sGst;
  final double? cGst;
  final double? iGst;
  final String? invoiceUrl;

  OrderModel({
    this.id,
    this.orderNumber,
    this.agentId,
    this.slotId,
    this.totalAmount,
    this.status,
    this.orderType,
    this.shift,
    this.orderDate,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.agentName,
    this.agentMobile,
    this.boothCode,
    this.boothAddress,
    this.boothName,
    this.canCancel = false,
    this.sGst = 0,
    this.cGst = 0,
    this.iGst = 0,
    this.invoiceUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      orderNumber: json['order_number']?.toString(),
      agentId: json['agent_id'] as int?,
      slotId: json['slot_id'] as int?,
      totalAmount: json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) : null,
      status: json['status'] as int?,
      orderType: json['order_type'] as int?,
      shift: json['shift'] as int?,
      orderDate: json['order_date']?.toString(),
      items: json['items'] != null
          ? (json['items'] as List).map((item) => OrderItemModel.fromJson(item)).toList()
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      agentName: json['agent_name']?.toString(),
      agentMobile: json['agent_mobile']?.toString(),
      boothCode: json['booth_code']?.toString(),
      boothAddress: json['booth_address']?.toString(),
      boothName: json['booth_name']?.toString(),
      canCancel: json['can_cancel'] ?? false,
      sGst: json['sgst'] != null ? double.tryParse(json['sgst'].toString()) : 0,
      cGst: json['cgst'] != null ? double.tryParse(json['cgst'].toString()) : 0,
      iGst: json['igst'] != null ? double.tryParse(json['igst'].toString()) : 0,
      invoiceUrl: json['invoice_url']?.toString(),
    );
  }

  OrderModel copyWith({
    int? id,
    String? orderNumber,
    int? agentId,
    int? slotId,
    double? totalAmount,
    int? status,
    int? orderType,
    int? shift,
    String? orderDate,
    List<OrderItemModel>? items,
    String? createdAt,
    String? updatedAt,
    String? agentName,
    String? agentMobile,
    String? boothCode,
    String? boothAddress,
    String? boothName,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      agentId: agentId ?? this.agentId,
      slotId: slotId ?? this.slotId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      shift: shift ?? this.shift,
      orderDate: orderDate ?? this.orderDate,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      agentName: agentName ?? this.agentName,
      agentMobile: agentMobile ?? this.agentMobile,
      boothCode: boothCode ?? this.boothCode,
      boothAddress: boothAddress ?? this.boothAddress,
      boothName: boothName ?? this.boothName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'agent_id': agentId,
      'slot_id': slotId,
      'total_amount': totalAmount,
      'status': status,
      'order_type': orderType,
      'shift': shift,
      'order_date': orderDate,
      'items': items?.map((item) => item.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'agent_name': agentName,
      'agent_mobile': agentMobile,
      'booth_code': boothCode,
      'booth_address': boothAddress,
      'booth_name': boothName,
    };
  }
}

class OrderItemModel {
  final int? id;
  final int? orderId;
  final int? productId;
  final String? productName;
  final String? productCode;
  final double? quantity;
  final double? gst;
  final double? price;
  final double? totalPrice;
  final int? trayCount;
  final double? measure;
  final int? categoryId;
  final bool ? isClaim;
  final int? itemUnitType;

  OrderItemModel({
    this.id,
    this.orderId,
    this.productId,
    this.productName,
    this.productCode,
    this.quantity,
    this.gst,
    this.price,
    this.totalPrice,
    this.trayCount,
    this.measure,
    this.categoryId,
    this.isClaim,
    this.itemUnitType,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      productId: json['product_id'] as int?,
      productName: json['product_name']?.toString(),
      productCode: json['product_code']?.toString(),
      quantity: double.parse(json['quantity'].toString()),
      gst: json['gst'] != null ? double.tryParse(json['gst'].toString()) : 0,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : 0,
      totalPrice: json['price_total'] != null ? double.tryParse(json['price_total'].toString()) : 0,
      trayCount: json['tray_capacity'] != null ? int.tryParse(json['tray_capacity'].toString()) : 0,
      measure: json['measure'] != null ? double.tryParse(json['measure'].toString()) : 0,
      categoryId: json['category_id'] as int?,
      isClaim: json['is_claim'] == 1,
      itemUnitType: json['item_unit_type'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_code': productCode,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
      'tray_capacity': trayCount,
      'measure': measure,
      'category_id': categoryId,
    };
  }
}