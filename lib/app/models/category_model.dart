class CategoryModel {
  final int? id;
  final String? name;
  final String? description;
  final int? unionId;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final String? imageUrl;

  CategoryModel({
    this.id,
    this.name,
    this.description,
    this.unionId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      unionId: json['union_id'] as int?,
      status: json['status'] as int?,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'union_id': unionId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_url': imageUrl,
    };
  }
}