import 'product_image_model.dart';

class ProductModel {
  final int? id;
  final String? productCode;
  final int? unionId;
  final int? categoryId;
  final String? name;
  final double? measure;
  final String? unit;
  final double? gst;
  final double? mrpBasic;
  final double? retailBasic;
  final double? wsdBasic;
  final double? unionBasic;
  final double? fedBasic;
  final double? quantity;
  final int? createdBy;
  final String? createdDate;
  final int? updateBy;
  final String? updatedDate;
  final int? status;
  final int? trayCapacity;
  final int? hasPopular;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? categoryName;
  final double? price;
  final double? morningCartQuantity;
  final double? eveningCartQuantity;
  final double? incrementBy;
  final List<ProductImageModel>? productImages;
  final int? itemUnitType;
  final int? cartQuantity;

  ProductModel({
    this.id,
    this.productCode,
    this.unionId,
    this.categoryId,
    this.name,
    this.measure,
    this.unit,
    this.gst,
    this.mrpBasic,
    this.retailBasic,
    this.wsdBasic,
    this.unionBasic,
    this.fedBasic,
    this.quantity,
    this.createdBy,
    this.createdDate,
    this.updateBy,
    this.updatedDate,
    this.status,
    this.trayCapacity,
    this.hasPopular,
    this.imageUrl,
    this.thumbnailUrl,
    this.categoryName,
    this.price,
    this.morningCartQuantity,
    this.eveningCartQuantity,
    this.productImages,
    this.incrementBy,
    this.itemUnitType,
    this.cartQuantity
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      productCode: json['product_code']?.toString(),
      unionId: json['union_id'] as int?,
      categoryId: json['category_id'] as int?,
      name: json['name']?.toString(),
      measure: json['measure'] != null ? double.tryParse(json['measure'].toString()) : null,
      unit: json['unit']?.toString(),
      gst: json['gst'] != null? double.tryParse(json['gst'].toString()):0.0,
      mrpBasic: json['mrp_basic'] != null ? double.tryParse(json['mrp_basic'].toString()) : null,
      retailBasic: json['retail_basic'] != null ? double.tryParse(json['retail_basic'].toString()) : null,
      wsdBasic: json['wsd_basic'] != null ? double.tryParse(json['wsd_basic'].toString()) : null,
      unionBasic: json['union_basic'] != null ? double.tryParse(json['union_basic'].toString()) : null,
      fedBasic: json['fed_basic'] != null ? double.tryParse(json['fed_basic'].toString()) : null,
      quantity: json['quantity'] != null ?  double.tryParse(json['quantity'].toString()) : 0.0,
      createdBy: json['created_by'] as int?,
      createdDate: json['created_date']?.toString(),
      updateBy: json['update_by'] as int?,
      updatedDate: json['updated_date']?.toString(),
      status: json['status'] as int?,
      trayCapacity: json['tray_capacity'] as int?,
      hasPopular: json['has_popular'] as int?,
      imageUrl: json['image_url']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      categoryName: json['category_name']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      morningCartQuantity: double.tryParse(json['morning_cart_quantity'].toString()) ?? 0,
      eveningCartQuantity: double.tryParse(json['evening_cart_quantity'].toString()) ?? 0,
      incrementBy: double.tryParse(json['increment_by'].toString()) ?? 0,
      productImages: json['productImages'] != null
          ? (json['productImages'] as List).map((e) => ProductImageModel.fromJson(e)).toList()
          : null,
      itemUnitType: json['item_unit_type'] as int? ?? 2,
      cartQuantity: (double.tryParse(json['cart_quantity']?.toString() ?? '0') ?? 0).toInt()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_code': productCode,
      'union_id': unionId,
      'category_id': categoryId,
      'name': name,
      'measure': measure,
      'unit': unit,
      'gst': gst,
      'mrp_basic': mrpBasic,
      'retail_basic': retailBasic,
      'wsd_basic': wsdBasic,
      'union_basic': unionBasic,
      'fed_basic': fedBasic,
      'quantity': quantity,
      'created_by': createdBy,
      'created_date': createdDate,
      'update_by': updateBy,
      'updated_date': updatedDate,
      'status': status,
      'tray_capacity': trayCapacity,
      'has_popular': hasPopular,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'category_name': categoryName,
      'price': price,
      'cart_quantity': cartQuantity,
      'productImages': productImages?.map((e) => e.toJson()).toList(),
    };
  }
}