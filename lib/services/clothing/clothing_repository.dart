import '../../models/clothing/clothing.dart';
import '../../network/api_client.dart';

/// 衣物 Repository
///
/// 负责与后端 Clothing API 通信：
///
/// GET    /api/clothing
/// POST   /api/clothing
/// PATCH  /api/clothing/:id
/// DELETE /api/clothing/:id
///
/// PUT    /api/clothing/:id/image
class ClothingRepository {
  ClothingRepository._();

  static final ClothingRepository instance = ClothingRepository._();

  final ApiClient _api = ApiClient.instance;

  /// 当前登录用户的衣物缓存。
  final List<Clothing> _clothes = [];

  List<Clothing> get clothes => List.unmodifiable(_clothes);

  // ============================================================
  // List
  // ============================================================

  /// 获取当前用户全部衣物。
  ///
  /// GET /api/clothing
  Future<List<Clothing>> fetchMyClothes() async {
    try {
      final data = await _api.get('/api/clothing');

      final rawClothes = data['clothes'];

      if (rawClothes is! List) {
        throw const ClothingRepositoryException('服务器返回的衣物列表格式不正确');
      }

      final fetched = rawClothes.map(_parseClothing).toList(growable: false);

      _clothes
        ..clear()
        ..addAll(fetched);

      return List.unmodifiable(_clothes);
    } on ApiException catch (e) {
      throw ClothingRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Detail / Cache
  // ============================================================

  Clothing? getById(String id) {
    for (final clothing in _clothes) {
      if (clothing.id == id) {
        return clothing;
      }
    }

    return null;
  }

  /// 清空当前衣物缓存。
  ///
  /// 登录、注册、退出登录、
  /// 注销账户时由 AuthService 调用。
  void clear() {
    _clothes.clear();
  }

  // ============================================================
  // Create
  // ============================================================

  /// 创建衣物。
  ///
  /// POST /api/clothing
  ///
  /// 图片不会在这里上传。
  /// 创建成功后再调用 uploadClothingImage。
  Future<Clothing> addClothing(Clothing clothing) async {
    try {
      final data = await _api.post(
        '/api/clothing',
        body: {
          'location': clothing.location,
          'brand': clothing.brand,
          'category': clothing.category,
          'color': clothing.color,
          'season': clothing.season,
          'price': clothing.price,
          'visibility': _visibilityToApi(clothing.visibility),
        },
      );

      final created = _parseClothing(data['clothing']);

      _clothes.removeWhere((item) => item.id == created.id);

      _clothes.insert(0, created);

      return created;
    } on ApiException catch (e) {
      throw ClothingRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Update
  // ============================================================

  /// 修改衣物基本信息。
  ///
  /// PATCH /api/clothing/:id
  Future<Clothing> updateClothing(Clothing clothing) async {
    if (clothing.id.trim().isEmpty) {
      throw const ClothingRepositoryException('衣物 ID 不能为空');
    }

    try {
      final data = await _api.patch(
        '/api/clothing/${clothing.id}',
        body: {
          'location': clothing.location,
          'brand': clothing.brand,
          'category': clothing.category,
          'color': clothing.color,
          'season': clothing.season,
          'price': clothing.price,
          'visibility': _visibilityToApi(clothing.visibility),
        },
      );

      final updated = _parseClothing(data['clothing']);

      _replaceCachedClothing(updated);

      return updated;
    } on ApiException catch (e) {
      throw ClothingRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Image
  // ============================================================

  /// 上传 / 更换衣物图片。
  ///
  /// PUT /api/clothing/:id/image
  ///
  /// multipart/form-data
  /// field = image
  Future<Clothing> uploadClothingImage({
    required String clothingId,
    required String imagePath,
  }) async {
    if (clothingId.trim().isEmpty) {
      throw const ClothingRepositoryException('衣物 ID 不能为空');
    }

    if (imagePath.trim().isEmpty) {
      throw const ClothingRepositoryException('图片路径不能为空');
    }

    try {
      final data = await _api.putMultipartFile(
        '/api/clothing/$clothingId/image',
        fieldName: 'image',
        filePath: imagePath,
      );

      final updated = _parseClothing(data['clothing']);

      _replaceCachedClothing(updated);

      return updated;
    } on ApiException catch (e) {
      throw ClothingRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Delete
  // ============================================================

  /// 删除衣物。
  ///
  /// DELETE /api/clothing/:id
  ///
  /// 后端负责：
  ///
  /// 1. 删除 D1 clothing row
  /// 2. 删除对应 R2 图片
  Future<void> deleteClothing(String clothingId) async {
    final id = clothingId.trim();

    if (id.isEmpty) {
      throw const ClothingRepositoryException('衣物 ID 不能为空');
    }

    try {
      final data = await _api.delete('/api/clothing/$id');

      final success = data['success'];

      if (success != true) {
        throw const ClothingRepositoryException('服务器未确认衣物删除成功');
      }

      _clothes.removeWhere((item) => item.id == id);
    } on ApiException catch (e) {
      throw ClothingRepositoryException(
        _mapDeleteError(e.message),
        statusCode: e.statusCode,
      );
    }
  }

  // ============================================================
  // Cache helper
  // ============================================================

  void _replaceCachedClothing(Clothing clothing) {
    final index = _clothes.indexWhere((item) => item.id == clothing.id);

    if (index == -1) {
      _clothes.insert(0, clothing);

      return;
    }

    _clothes[index] = clothing;
  }

  // ============================================================
  // Parse
  // ============================================================

  Clothing _parseClothing(dynamic value) {
    if (value is! Map) {
      throw const ClothingRepositoryException('服务器返回的衣物数据格式不正确');
    }

    final json = Map<String, dynamic>.from(value);

    final id = json['id'];

    final ownerId = json['ownerId'];

    final location = json['location'];

    final category = json['category'];

    final color = json['color'];

    final season = json['season'];

    final visibilityRaw = json['visibility'];

    final createdAtRaw = json['createdAt'];

    final updatedAtRaw = json['updatedAt'];

    if (id is! String ||
        ownerId is! String ||
        location is! String ||
        category is! String ||
        color is! String ||
        season is! String ||
        visibilityRaw is! String ||
        createdAtRaw is! String ||
        updatedAtRaw is! String) {
      throw const ClothingRepositoryException('服务器返回的衣物数据格式不正确');
    }

    final createdAt = DateTime.tryParse(createdAtRaw);

    final updatedAt = DateTime.tryParse(updatedAtRaw);

    if (createdAt == null || updatedAt == null) {
      throw const ClothingRepositoryException('服务器返回的衣物时间格式不正确');
    }

    final priceRaw = json['price'];

    double? price;

    if (priceRaw != null) {
      if (priceRaw is! num) {
        throw const ClothingRepositoryException('服务器返回的衣物价格格式不正确');
      }

      price = priceRaw.toDouble();
    }

    final brandRaw = json['brand'];

    String? brand;

    if (brandRaw != null) {
      if (brandRaw is! String) {
        throw const ClothingRepositoryException('服务器返回的品牌格式不正确');
      }

      brand = brandRaw;
    }

    final imageUrlRaw = json['imageUrl'];

    final imageUrl = imageUrlRaw is String ? imageUrlRaw : '';

    return Clothing(
      id: id,
      ownerId: ownerId,
      location: location,
      brand: brand,
      category: category,
      color: color,
      season: season,
      price: price,
      imagePath: imageUrl,

      // 后端返回的 imageUrl
      // 永远作为远程图片处理。
      imageType: ClothingImageType.remote,

      visibility: _parseVisibility(visibilityRaw),

      createdAt: createdAt,

      updatedAt: updatedAt,
    );
  }

  ClothingVisibility _parseVisibility(String value) {
    switch (value) {
      case 'public':
        return ClothingVisibility.public;

      case 'private':
        return ClothingVisibility.private;

      default:
        throw const ClothingRepositoryException('服务器返回的衣物可见性格式不正确');
    }
  }

  String _visibilityToApi(ClothingVisibility visibility) {
    switch (visibility) {
      case ClothingVisibility.public:
        return 'public';

      case ClothingVisibility.private:
        return 'private';
    }
  }

  // ============================================================
  // Error
  // ============================================================

  String _mapDeleteError(String message) {
    switch (message) {
      case 'Clothing not found':
        return '衣物不存在或已经被删除';

      case 'Unauthorized':
        return '登录状态已失效，请重新登录';

      default:
        return message;
    }
  }
}

/// Clothing Repository 异常。
class ClothingRepositoryException implements Exception {
  final String message;
  final int? statusCode;

  const ClothingRepositoryException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
