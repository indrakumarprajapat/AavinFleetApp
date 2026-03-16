import '../constants/app_enums.dart';

class DeliveredOrderModel {
  final int id;
  final double totalAmount;
  final String createdAt;
  final OrderShift? shift;
  final String? orderDate;
  final int? itemUnitType;

  DeliveredOrderModel({
    required this.id,
    required this.totalAmount,
    required this.createdAt,
    this.shift,
    this.orderDate,
    this.itemUnitType
  });

  factory DeliveredOrderModel.fromJson(Map<String, dynamic> json) {
    return DeliveredOrderModel(
      id: json['id'] as int,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      shift: (int.tryParse(json['shift'].toString()) ?? 0) == 1 ? OrderShift.morning: OrderShift.evening ,
      orderDate: json['order_date']?.toString() ?? '',
      itemUnitType: int.tryParse(json['item_unit_type'].toString()) ?? 1
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'created_at': createdAt,
    };
  }
}