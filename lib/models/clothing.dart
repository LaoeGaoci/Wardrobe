enum ClothingVisibility {
  public,
  private,
}

enum ClothingImageType {
  local,
  remote,
}

class Clothing {
  final String id;
  final String ownerId;

  /// 衣物基本信息
  final String name;
  final String? brand;
  final String category;
  final String color;
  final String season;

  /// 价格
  final double? price;

  /// 图片
  final String imagePath;
  final ClothingImageType imageType;

  /// 可见性
  final ClothingVisibility visibility;

  /// 时间
  final DateTime createdAt;
  final DateTime updatedAt;

  const Clothing({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.imagePath,
    required this.imageType,
    required this.category,
    required this.color,
    required this.season,
    this.brand,
    this.price,
    this.visibility = ClothingVisibility.private,
    required this.createdAt,
    required this.updatedAt,
  });

  Clothing copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? brand,
    String? imagePath,
    ClothingImageType? imageType,
    String? category,
    String? color,
    String? season,
    double? price,
    ClothingVisibility? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Clothing(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imagePath: imagePath ?? this.imagePath,
      imageType: imageType ?? this.imageType,
      category: category ?? this.category,
      color: color ?? this.color,
      season: season ?? this.season,
      price: price ?? this.price,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}