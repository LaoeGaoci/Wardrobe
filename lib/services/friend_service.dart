import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'auth_service.dart';
import 'user_repository.dart';

/// 好友状态
enum FriendStatus {
  /// 没有好友关系，也没有申请
  none,

  /// 已经是好友
  friends,

  /// 当前用户已经发送申请
  requestSent,

  /// 当前用户收到对方申请
  requestReceived,
}

/// 好友申请
class FriendRequest {
  final String id;
  final AppUser fromUser;
  final AppUser toUser;

  /// 申请文本
  final String message;

  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.message,
    required this.createdAt,
  });
}

/// 好友关系
class FriendRelation {
  final String userId;
  final String friendId;

  String remark;

  FriendRelation({
    required this.userId,
    required this.friendId,
    this.remark = '',
  });
}

/// 好友服务
///
/// 注意：
///
/// 当前只有“搜索用户”已经连接后端。
///
/// 好友关系、好友申请、备注等功能
/// 仍然暂时使用前端内存。
class FriendService
    extends ChangeNotifier {
  FriendService._();

  static final FriendService instance =
  FriendService._();

  final AuthService _authService =
      AuthService.instance;

  final UserRepository _userRepository =
      UserRepository.instance;

  /// 所有好友关系
  ///
  /// key:
  /// userId:friendId
  final Map<String, FriendRelation>
  _relations = {};

  /// 所有好友申请
  final Map<String, FriendRequest>
  _requests = {};

  /// 当前用户
  AppUser? get currentUser =>
      _authService.currentUser;

  /// 当前用户好友
  List<AppUser> get friends {
    final user = currentUser;

    if (user == null) {
      return const [];
    }

    final friendIds =
    _relations.values
        .where(
          (relation) =>
      relation.userId ==
          user.id,
    )
        .map(
          (relation) =>
      relation.friendId,
    )
        .toSet();

    return friendIds
        .map(
      _userRepository
          .getUserById,
    )
        .whereType<AppUser>()
        .toList(
      growable: false,
    );
  }

  /// 收到的好友申请
  List<FriendRequest>
  get receivedRequests {
    final user = currentUser;

    if (user == null) {
      return const [];
    }

    return _requests.values
        .where(
          (request) =>
      request.toUser.id ==
          user.id,
    )
        .toList(
      growable: false,
    );
  }

  /// 已发送的好友申请
  List<FriendRequest>
  get sentRequests {
    final user = currentUser;

    if (user == null) {
      return const [];
    }

    return _requests.values
        .where(
          (request) =>
      request.fromUser.id ==
          user.id,
    )
        .toList(
      growable: false,
    );
  }

  /// 收到的好友申请数量
  int get receivedRequestCount =>
      receivedRequests.length;

  // ============================================================
  // 用户搜索
  // ============================================================

  /// 搜索用户
  ///
  /// GET /api/users/search?q=keyword
  ///
  /// 当前用户由 Bearer Token 决定，
  /// 后端已经会自动排除自己。
  Future<List<AppUser>> searchUsers(
      String keyword,
      ) async {
    if (currentUser == null) {
      return const [];
    }

    try {
      return await _userRepository
          .searchUsers(
        keyword,
      );
    } on UserRepositoryException catch (e) {
      throw FriendException(
        e.message,
      );
    }
  }

  // ============================================================
  // 好友状态
  // ============================================================

  FriendStatus getFriendStatus(
      String userId,
      ) {
    final user = currentUser;

    if (user == null) {
      return FriendStatus.none;
    }

    if (user.id == userId) {
      return FriendStatus.none;
    }

    if (_hasRelation(
      userId: user.id,
      friendId: userId,
    )) {
      return FriendStatus.friends;
    }

    if (_hasRequest(
      fromUserId: user.id,
      toUserId: userId,
    )) {
      return FriendStatus.requestSent;
    }

    if (_hasRequest(
      fromUserId: userId,
      toUserId: user.id,
    )) {
      return FriendStatus
          .requestReceived;
    }

    return FriendStatus.none;
  }

  // ============================================================
  // 发送好友申请
  // ============================================================

  Future<FriendRequest>
  sendFriendRequest({
    required String userId,
    required String message,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw const FriendException(
        '请先登录',
      );
    }

    if (user.id == userId) {
      throw const FriendException(
        '不能添加自己为好友',
      );
    }

    final targetUser =
    _userRepository
        .getUserById(
      userId,
    );

    if (targetUser == null) {
      throw const FriendException(
        '用户不存在',
      );
    }

    final status =
    getFriendStatus(
      userId,
    );

    if (status ==
        FriendStatus.friends) {
      throw const FriendException(
        '对方已经是你的好友',
      );
    }

    if (status ==
        FriendStatus.requestSent) {
      throw const FriendException(
        '好友申请已经发送',
      );
    }

    if (status ==
        FriendStatus
            .requestReceived) {
      throw const FriendException(
        '对方已经向你发送了好友申请，请处理该申请',
      );
    }

    final requestMessage =
    message.trim();

    if (requestMessage.isEmpty) {
      throw const FriendException(
        '请输入好友申请信息',
      );
    }

    await Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
    );

    final requestId =
        'request_${DateTime.now().microsecondsSinceEpoch}';

    final request =
    FriendRequest(
      id: requestId,
      fromUser: user,
      toUser: targetUser,
      message:
      requestMessage,
      createdAt:
      DateTime.now(),
    );

    _requests[requestId] =
        request;

    notifyListeners();

    return request;
  }

  // ============================================================
  // 接受好友申请
  // ============================================================

  Future<void>
  acceptFriendRequest(
      String requestId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw const FriendException(
        '请先登录',
      );
    }

    final request =
    _requests[requestId];

    if (request == null) {
      throw const FriendException(
        '好友申请不存在',
      );
    }

    if (request.toUser.id !=
        user.id) {
      throw const FriendException(
        '无权处理该好友申请',
      );
    }

    await Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
    );

    final fromUserId =
        request.fromUser.id;

    final currentUserId =
        user.id;

    _createRelation(
      userId: currentUserId,
      friendId: fromUserId,
    );

    _createRelation(
      userId: fromUserId,
      friendId: currentUserId,
    );

    _requests.remove(
      requestId,
    );

    notifyListeners();
  }

  // ============================================================
  // 拒绝好友申请
  // ============================================================

  Future<void>
  rejectFriendRequest(
      String requestId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw const FriendException(
        '请先登录',
      );
    }

    final request =
    _requests[requestId];

    if (request == null) {
      throw const FriendException(
        '好友申请不存在',
      );
    }

    if (request.toUser.id !=
        user.id) {
      throw const FriendException(
        '无权处理该好友申请',
      );
    }

    await Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
    );

    _requests.remove(
      requestId,
    );

    notifyListeners();
  }

  // ============================================================
  // 取消好友申请
  // ============================================================

  Future<void>
  cancelFriendRequest(
      String requestId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw const FriendException(
        '请先登录',
      );
    }

    final request =
    _requests[requestId];

    if (request == null) {
      throw const FriendException(
        '好友申请不存在',
      );
    }

    if (request.fromUser.id !=
        user.id) {
      throw const FriendException(
        '无权取消该好友申请',
      );
    }

    await Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
    );

    _requests.remove(
      requestId,
    );

    notifyListeners();
  }

  // ============================================================
  // 删除好友
  // ============================================================

  Future<void> removeFriend(
      String friendId,
      ) async {
    final user = currentUser;

    if (user == null) {
      throw const FriendException(
        '请先登录',
      );
    }

    if (!_hasRelation(
      userId: user.id,
      friendId: friendId,
    )) {
      throw const FriendException(
        '对方不是你的好友',
      );
    }

    await Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
    );

    _relations.remove(
      _relationKey(
        user.id,
        friendId,
      ),
    );

    _relations.remove(
      _relationKey(
        friendId,
        user.id,
      ),
    );

    notifyListeners();
  }

  // ============================================================
  // 好友备注
  // ============================================================

  String getRemark(
      String friendId,
      ) {
    final user = currentUser;

    if (user == null) {
      return '';
    }

    final relation =
    _relations[
    _relationKey(
      user.id,
      friendId,
    )
    ];

    return relation?.remark ??
        '';
  }

  Future<void> updateRemark({
    required String friendId,
    required String remark,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw const FriendException(
        '请先登录',
      );
    }

    if (!_hasRelation(
      userId: user.id,
      friendId: friendId,
    )) {
      throw const FriendException(
        '对方不是你的好友',
      );
    }

    final relation =
    _relations[
    _relationKey(
      user.id,
      friendId,
    )
    ];

    if (relation == null) {
      throw const FriendException(
        '好友关系不存在',
      );
    }

    relation.remark =
        remark.trim();

    notifyListeners();
  }

  String getFriendDisplayName(
      AppUser friend,
      ) {
    final remark =
    getRemark(
      friend.id,
    );

    if (remark.isNotEmpty) {
      return remark;
    }

    return friend.username;
  }

  // ============================================================
  // Internal
  // ============================================================

  String _relationKey(
      String userId,
      String friendId,
      ) {
    return '$userId:$friendId';
  }

  bool _hasRelation({
    required String userId,
    required String friendId,
  }) {
    return _relations.containsKey(
      _relationKey(
        userId,
        friendId,
      ),
    );
  }

  void _createRelation({
    required String userId,
    required String friendId,
  }) {
    final key =
    _relationKey(
      userId,
      friendId,
    );

    _relations.putIfAbsent(
      key,
          () => FriendRelation(
        userId: userId,
        friendId: friendId,
      ),
    );
  }

  bool _hasRequest({
    required String fromUserId,
    required String toUserId,
  }) {
    return _requests.values.any(
          (request) =>
      request.fromUser.id ==
          fromUserId &&
          request.toUser.id ==
              toUserId,
    );
  }
}

/// 好友异常
class FriendException
    implements Exception {
  final String message;

  const FriendException(
      this.message,
      );

  @override
  String toString() => message;
}