class CustomerOrderDetailsModel {
  final CustomerOrderModel order;
  final List<CustomerOrderItemModel> items;

  CustomerOrderDetailsModel({
    required this.order,
    required this.items,
  });

  factory CustomerOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderDetailsModel(
      order: CustomerOrderModel.fromJson(json['order'] ?? {}),
      items: (json['items'] as List? ?? [])
          .map((item) => CustomerOrderItemModel.fromJson(item))
          .toList(),
    );
  }
}

class CustomerOrderModel {
  final int id;
  final int customerId;
  final int addressId;
  final int boothId;
  final int deliveryType;
  final String orderDate;
  final int shift;
  final String totalAmount;
  final int status;
  final int subscriptionId;
  final String createdAt;
  final String boothName;
  final String boothAddress;
  final String address;

  CustomerOrderModel({
    required this.id,
    required this.customerId,
    required this.addressId,
    required this.boothId,
    required this.deliveryType,
    required this.orderDate,
    required this.shift,
    required this.totalAmount,
    required this.status,
    required this.subscriptionId,
    required this.createdAt,
    required this.boothName,
    required this.boothAddress,
    required this.address,
  });

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      addressId: json['address_id'] ?? 0,
      boothId: json['booth_id'] ?? 0,
      deliveryType: json['delivery_type'] ?? 0,
      orderDate: json['order_date'] ?? '',
      shift: json['shift'] ?? 0,
      totalAmount: json['total_amount'] ?? '0.00',
      status: json['status'] ?? 0,
      subscriptionId: json['subscription_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      boothName: json['booth_name'] ?? '',
      boothAddress: json['booth_address'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class CustomerOrderItemModel {
  final int id;
  final int customerOrderId;
  final int productId;
  final String quantity;
  final String unitPrice;
  final String totalPrice;
  final String createdAt;
  final String productName;
  final String productCode;
  final String categoryName;

  CustomerOrderItemModel({
    required this.id,
    required this.customerOrderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
    required this.productName,
    required this.productCode,
    required this.categoryName,
  });

  factory CustomerOrderItemModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderItemModel(
      id: json['id'] ?? 0,
      customerOrderId: json['customer_order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? '0.00',
      unitPrice: json['unit_price'] ?? '0.00',
      totalPrice: json['total_price'] ?? '0.00',
      createdAt: json['created_at'] ?? '',
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      categoryName: json['category_name'] ?? '',
    );
  }
}