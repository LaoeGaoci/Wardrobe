import '../user/app_user.dart';
import '../clothing/clothing.dart';

/// ============================================================
/// ClothingRecommendation
/// ============================================================
///
/// 后端推荐 DTO：
///
/// {
///   "id": "...",
///   "fromUser": {...},
///   "toUser": {...},
///   "clothes": [...],
///   "message": "...",
///   "createdAt": "...",
///   "readAt": null,
///   "isRead": false
/// }
///
/// 推荐现在是一个完整对象，
/// Flutter 不需要再根据 userId / clothingId
/// 去本地 Repository 拼数据。
class ClothingRecommendation {
  final String id;

  /// 推荐发送者。
  final AppUser fromUser;

  /// 推荐接收者。
  final AppUser toUser;

  /// 推荐包含的衣物。
  ///
  /// 后端直接返回完整 Clothing DTO。
  final List<Clothing> clothes;

  /// 好友留下的推荐留言。
  final String message;

  /// 推荐创建时间。
  final DateTime createdAt;

  /// 第一次打开推荐的时间。
  ///
  /// null：
  ///   未读
  ///
  /// 非 null：
  ///   已读
  final DateTime? readAt;

  const ClothingRecommendation({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.clothes,
    required this.message,
    required this.createdAt,
    required this.readAt,
  });

  // ============================================================
  // Compatibility getters
  // ============================================================

  /// 保留这些 getter，
  /// 让旧代码如果仍然使用：
  ///
  /// recommendation.fromUserId
  ///
  /// 不会立刻报错。
  String get fromUserId => fromUser.id;

  String get toUserId => toUser.id;

  List<String> get clothingIds =>
      clothes.map((item) => item.id).toList(growable: false);

  /// 是否已经阅读。
  bool get isRead => readAt != null;

  // ============================================================
  // Backend JSON
  // ============================================================

  factory ClothingRecommendation.fromJson(Map<String, dynamic> json) {
    final rawFromUser = json['fromUser'];

    final rawToUser = json['toUser'];

    final rawClothes = json['clothes'];

    if (rawFromUser is! Map || rawToUser is! Map || rawClothes is! List) {
      throw const FormatException('Invalid recommendation data');
    }

    return ClothingRecommendation(
      id: json['id'] as String,

      fromUser: AppUser.fromJson(Map<String, dynamic>.from(rawFromUser)),

      toUser: AppUser.fromJson(Map<String, dynamic>.from(rawToUser)),

      clothes: rawClothes
          .map((value) {
            if (value is! Map) {
              throw const FormatException('Invalid recommendation clothing');
            }

            return Clothing.fromJson(Map<String, dynamic>.from(value));
          })
          .toList(growable: false),

      message: json['message'] as String? ?? '',

      createdAt: _parseRequiredDateTime(json['createdAt']),

      readAt: _parseOptionalDateTime(json['readAt']),
    );
  }

  // ============================================================
  // Copy
  // ============================================================

  ClothingRecommendation copyWith({
    AppUser? fromUser,
    AppUser? toUser,
    List<Clothing>? clothes,
    String? message,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return ClothingRecommendation(
      id: id,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      clothes: clothes ?? this.clothes,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

/// ============================================================
/// Date helpers
/// ============================================================

/// D1 CURRENT_TIMESTAMP 可能返回：
///
/// 2026-09-13 22:30:00
///
/// Dart 更标准的 ISO 格式是：
///
/// 2026-09-13T22:30:00
///
/// 所以这里统一兼容。
DateTime _parseRequiredDateTime(dynamic value) {
  if (value is! String || value.isEmpty) {
    throw const FormatException('Invalid recommendation date');
  }

  final parsed = DateTime.tryParse(value.replaceFirst(' ', 'T'));

  if (parsed == null) {
    throw const FormatException('Invalid recommendation date');
  }

  return parsed;
}

DateTime? _parseOptionalDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is! String || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value.replaceFirst(' ', 'T'));
}
