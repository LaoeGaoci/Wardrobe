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

  /// 衣物存放位置，例如：
  /// 主衣柜左侧第二层 / 收纳箱 A。
  final String location;

  final String? brand;
  final String category;
  final String color;
  final String season;

  final double? price;

  /// local:
  /// Android 本地文件路径。
  ///
  /// remote:
  /// 后端返回：
  /// /api/clothing/:id/image
  final String imagePath;

  final ClothingImageType imageType;

  final ClothingVisibility visibility;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Clothing({
    required this.id,
    required this.ownerId,
    required this.location,
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

  // ============================================================
  // Backend JSON
  // ============================================================

  factory Clothing.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawPrice = json['price'];

    final imageUrl =
        json['imageUrl'] as String? ?? '';

    return Clothing(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      location: json['location'] as String,
      brand: json['brand'] as String?,
      category: json['category'] as String,
      color: json['color'] as String,
      season: json['season'] as String,
      price: rawPrice is num
          ? rawPrice.toDouble()
          : null,
      imagePath: imageUrl,
      imageType: ClothingImageType.remote,
      visibility: _visibilityFromJson(
        json['visibility'],
      ),
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String,
      ),
    );
  }

  /// POST / PATCH 使用。
  ///
  /// id / ownerId / imagePath /
  /// createdAt / updatedAt
  /// 都由后端负责，
  /// 不应该从客户端提交。
  Map<String, dynamic> toRequestJson() {
    return {
      'location': location,
      'brand': brand,
      'category': category,
      'color': color,
      'season': season,
      'price': price,
      'visibility': visibility.name,
    };
  }

  static ClothingVisibility _visibilityFromJson(
    dynamic value,
  ) {
    switch (value) {
      case 'public':
        return ClothingVisibility.public;

      case 'private':
        return ClothingVisibility.private;

      default:
        return ClothingVisibility.private;
    }
  }

  // ============================================================
  // Copy
  // ============================================================

  Clothing copyWith({
    String? id,
    String? ownerId,
    String? location,
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
      location: location ?? this.location,
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
