import '../models/clothing.dart';
import '../network/api_client.dart';

class ClothingRepository {
  ClothingRepository._();

  static final ClothingRepository
  instance =
  ClothingRepository._();

  final ApiClient _api =
      ApiClient.instance;

  /// 前端缓存。
  ///
  /// 数据源已经变成后端 D1，
  /// 这里只用于页面和现有 Service
  /// 的同步读取。
  final List<Clothing>
  _clothes = [];

  List<Clothing> get clothes =>
      List.unmodifiable(
        _clothes,
      );

  // ============================================================
  // List
  // ============================================================

  /// GET /api/clothing
  Future<List<Clothing>>
  fetchMyClothes({
    String? category,
    String? query,
    ClothingVisibility?
    visibility,
  }) async {
    final queryParameters =
    <String, String>{};

    if (category != null &&
        category
            .trim()
            .isNotEmpty) {
      queryParameters[
      'category'] =
          category.trim();
    }

    if (query != null &&
        query.trim().isNotEmpty) {
      queryParameters['q'] =
          query.trim();
    }

    if (visibility != null) {
      queryParameters[
      'visibility'] =
          visibility.name;
    }

    try {
      final data =
      await _api.get(
        '/api/clothing',
        queryParameters:
        queryParameters.isEmpty
            ? null
            : queryParameters,
      );

      final rawClothes =
      data['clothes'];

      if (rawClothes is! List) {
        throw const ClothingRepositoryException(
          '服务器返回的衣物列表格式不正确',
        );
      }

      final clothes =
      rawClothes
          .map(
        _parseClothing,
      )
          .toList(
        growable:
        false,
      );

      _clothes
        ..clear()
        ..addAll(
          clothes,
        );

      return List.unmodifiable(
        _clothes,
      );
    } on ApiException catch (e) {
      throw ClothingRepositoryException(
        e.message,
        statusCode:
        e.statusCode,
      );
    }
  }

  // ============================================================
  // Detail
  // ============================================================

  /// GET /api/clothing/:id
  Future<Clothing> fetchById(
      String id,
      ) async {
    try {
      final data =
      await _api.get(
        '/api/clothing/$id',
      );

      final clothing =
      _parseClothing(
        data['clothing'],
      );

      _upsertCache(
        clothing,
      );

      return clothing;
    } on ApiException catch (e) {
      throw ClothingRepositoryException(
        e.message,
        statusCode:
        e.statusCode,
      );
    }
  }

  // ============================================================
  // Create
  // ============================================================

  /// POST /api/clothing
  Future<Clothing> addClothing(
      Clothing clothing,
      ) async {
    try {
      final data =
      await _api.post(
        '/api/clothing',
        body:
        clothing
            .toRequestJson(),
      );

      final created =
      _parseClothing(
        data['clothing'],
      );

      _clothes.insert(
        0,
        created,
      );

      return created;
    } on ApiException catch (e) {
      throw ClothingRepositoryException(
        e.message,
        statusCode:
        e.statusCode,
      );
    }
  }

  // ============================================================
  // Update
  // ============================================================

  /// PATCH /api/clothing/:id
  Future<Clothing> updateClothing(
      Clothing clothing,
      ) async {
    try {
      final data =
      await _api.patch(
        '/api/clothing/${clothing.id}',
        body:
        clothing
            .toRequestJson(),
      );

      final updated =
      _parseClothing(
        data['clothing'],
      );

      _upsertCache(
        updated,
      );

      return updated;
    } on ApiException catch (e) {
      throw ClothingRepositoryException(
        e.message,
        statusCode:
        e.statusCode,
      );
    }
  }

  // ============================================================
  // Delete
  // ============================================================

  /// DELETE /api/clothing/:id
  Future<void> deleteClothing(
      String id,
      ) async {
    try {
      await _api.delete(
        '/api/clothing/$id',
      );

      _clothes.removeWhere(
            (item) =>
        item.id == id,
      );
    } on ApiException catch (e) {
      throw ClothingRepositoryException(
        e.message,
        statusCode:
        e.statusCode,
      );
    }
  }

  // ============================================================
  // Image
  // ============================================================

  /// PUT /api/clothing/:id/image
  Future<Clothing>
  uploadClothingImage({
    required String clothingId,
    required String imagePath,
  }) async {
    try {
      final data =
      await _api
          .putMultipartFile(
        '/api/clothing/'
            '$clothingId/image',
        fieldName: 'image',
        filePath: imagePath,
      );

      final clothing =
      _parseClothing(
        data['clothing'],
      );

      _upsertCache(
        clothing,
      );

      return clothing;
    } on ApiException catch (e) {
      throw ClothingRepositoryException(
        e.message,
        statusCode:
        e.statusCode,
      );
    }
  }

  /// DELETE /api/clothing/:id/image
  Future<Clothing>
  deleteClothingImage(
      String clothingId,
      ) async {
    try {
      final data =
      await _api.delete(
        '/api/clothing/'
            '$clothingId/image',
      );

      final clothing =
      _parseClothing(
        data['clothing'],
      );

      _upsertCache(
        clothing,
      );

      return clothing;
    } on ApiException catch (e) {
      throw ClothingRepositoryException(
        e.message,
        statusCode:
        e.statusCode,
      );
    }
  }

  // ============================================================
  // Cache
  // ============================================================

  Clothing? getById(
      String id,
      ) {
    for (final clothing
    in _clothes) {
      if (clothing.id == id) {
        return clothing;
      }
    }

    return null;
  }

  void clear() {
    _clothes.clear();
  }

  void _upsertCache(
      Clothing clothing,
      ) {
    final index =
    _clothes.indexWhere(
          (item) =>
      item.id ==
          clothing.id,
    );

    if (index == -1) {
      _clothes.insert(
        0,
        clothing,
      );

      return;
    }

    _clothes[index] =
        clothing;
  }

  // ============================================================
  // Parse
  // ============================================================

  Clothing _parseClothing(
      dynamic value,
      ) {
    if (value is! Map) {
      throw const ClothingRepositoryException(
        '服务器返回的衣物数据格式不正确',
      );
    }

    try {
      return Clothing.fromJson(
        Map<String, dynamic>.from(
          value,
        ),
      );
    } catch (_) {
      throw const ClothingRepositoryException(
        '服务器返回的衣物数据格式不正确',
      );
    }
  }
}

class ClothingRepositoryException
    implements Exception {
  final String message;
  final int? statusCode;

  const ClothingRepositoryException(
      this.message, {
        this.statusCode,
      });

  @override
  String toString() =>
      message;
}