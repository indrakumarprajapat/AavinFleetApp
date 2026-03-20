class ProductImageModel {
  final int? id;
  final int? productId;
  final String? imageUrl;
  final int? urlType;
  final bool? isThumbnail;
  final int? createdBy;
  final String? createdAt;

  ProductImageModel({
    this.id,
    this.productId,
    this.imageUrl,
    this.urlType,
    this.isThumbnail,
    this.createdBy,
    this.createdAt,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as int?,
      productId: json['productId'] as int?,
      imageUrl: json['imageUrl']?.toString(),
      urlType: json['urlType'] as int?,
      isThumbnail: json['isThumbnail'] as bool?,
      createdBy: json['createdBy'] as int?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'imageUrl': imageUrl,
      'urlType': urlType,
      'isThumbnail': isThumbnail,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}