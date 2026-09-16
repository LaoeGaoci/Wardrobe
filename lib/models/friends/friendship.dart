import '../user/app_user.dart';

/// ============================================================
/// 好友状态
/// ============================================================
///
/// 与后端：
///
/// GET /api/friends/status/:userId
///
/// 返回的字符串保持一致。
enum FriendStatus {
  /// 没有好友关系，也没有待处理申请
  none,

  /// 已经是好友
  friends,

  /// 当前用户已经向对方发送申请
  requestSent,

  /// 对方向当前用户发送了申请
  requestReceived,
}

/// 把后端字符串转换为 Flutter enum。
FriendStatus friendStatusFromJson(dynamic value) {
  switch (value) {
    case 'friends':
      return FriendStatus.friends;

    case 'requestSent':
      return FriendStatus.requestSent;

    case 'requestReceived':
      return FriendStatus.requestReceived;

    case 'none':
    default:
      return FriendStatus.none;
  }
}

/// ============================================================
/// 好友关系
/// ============================================================
///
/// 后端：
///
/// GET /api/friends
///
/// 返回：
///
/// {
///   "user": {...},
///   "remark": "妈妈",
///   "createdAt": "..."
/// }
///
/// 注意：
///
/// 数据库字段叫 nickname，
/// 但是 API 对 Flutter 统一叫 remark。
class FriendRelation {
  final AppUser user;

  /// 当前用户给好友设置的备注
  final String remark;

  final DateTime createdAt;

  const FriendRelation({
    required this.user,
    required this.remark,
    required this.createdAt,
  });

  /// 好友 ID。
  String get friendId => user.id;

  factory FriendRelation.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];

    if (rawUser is! Map) {
      throw const FormatException('Invalid friend user');
    }

    return FriendRelation(
      user: AppUser.fromJson(Map<String, dynamic>.from(rawUser)),

      remark: json['remark'] as String? ?? '',

      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  FriendRelation copyWith({
    AppUser? user,
    String? remark,
    DateTime? createdAt,
  }) {
    return FriendRelation(
      user: user ?? this.user,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// ============================================================
/// 好友申请
/// ============================================================
///
/// 后端：
///
/// GET /api/friends/requests/received
/// GET /api/friends/requests/sent
///
/// 返回：
///
/// {
///   "id": "...",
///   "fromUser": {...},
///   "toUser": {...},
///   "message": "...",
///   "createdAt": "..."
/// }
class FriendRequest {
  final String id;

  final AppUser fromUser;

  final AppUser toUser;

  final String message;

  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.message,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    final rawFromUser = json['fromUser'];

    final rawToUser = json['toUser'];

    if (rawFromUser is! Map || rawToUser is! Map) {
      throw const FormatException('Invalid friend request users');
    }

    return FriendRequest(
      id: json['id'] as String,

      fromUser: AppUser.fromJson(Map<String, dynamic>.from(rawFromUser)),

      toUser: AppUser.fromJson(Map<String, dynamic>.from(rawToUser)),

      message: json['message'] as String? ?? '',

      createdAt: _parseDateTime(json['createdAt']),
    );
  }
}

/// ============================================================
/// 日期解析
/// ============================================================
///
/// D1 CURRENT_TIMESTAMP 有时返回：
///
/// 2026-09-13 12:30:00
///
/// Dart 更标准的形式是：
///
/// 2026-09-13T12:30:00
///
/// 所以这里兼容两种格式。
DateTime _parseDateTime(dynamic value) {
  if (value is! String || value.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  final normalized = value.contains('T') ? value : value.replaceFirst(' ', 'T');

  return DateTime.tryParse(normalized) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
