import 'package:flutter/foundation.dart';

import '../../models/user/app_user.dart';
import '../../models/clothing/clothing.dart';
import '../../models/friends/friendship.dart';
import '../../network/api_client.dart';

import '../users/auth_service.dart';
import '../users/user_repository.dart';

/// 继续把好友模型导出。
///
/// 这样原来只写：
///
/// import '../../services/friend_service.dart';
///
/// 的页面依然可以直接使用：
///
/// FriendStatus
/// FriendRequest
/// FriendRelation
///
/// 不需要所有页面同时增加 friendship.dart import。
export '../../models/friends/friendship.dart';

/// ============================================================
/// FriendService
/// ============================================================
///
/// 数据源已经从：
///
/// Flutter 本地内存
///
/// 改成：
///
/// Flutter
///   ↓
/// ApiClient
///   ↓
/// Cloudflare Worker
///   ↓
/// D1 / R2
///
/// Service 内的 List / Map 现在只是“页面缓存”，
/// 不再是好友数据的真实数据库。
class FriendService extends ChangeNotifier {
  FriendService._() {
    /// 记录当前登录账号。
    _sessionUserId = _authService.currentUser?.id;

    /// 登录 / 登出 / 切换账号时，
    /// 自动清空好友缓存。
    _authService.addListener(_handleAuthChanged);
  }

  static final FriendService instance = FriendService._();

  final ApiClient _api = ApiClient.instance;

  final AuthService _authService = AuthService.instance;

  final UserRepository _userRepository = UserRepository.instance;

  // ============================================================
  // Session
  // ============================================================

  String? _sessionUserId;

  AppUser? get currentUser => _authService.currentUser;

  // ============================================================
  // Cache
  // ============================================================

  /// 当前账号的好友关系缓存。
  final List<FriendRelation> _friendRelations = [];

  /// 当前账号收到的 pending 申请。
  final List<FriendRequest> _receivedRequests = [];

  /// 当前账号发出的 pending 申请。
  final List<FriendRequest> _sentRequests = [];

  /// 用户 ID -> 好友状态。
  ///
  /// 页面可以同步调用：
  ///
  /// getFriendStatus(userId)
  ///
  /// 不需要在 build() 里面直接 await。
  final Map<String, FriendStatus> _statusCache = {};

  /// friendId -> 好友公开衣物。
  ///
  /// 这里也是页面缓存，
  /// 数据源仍然是后端。
  final Map<String, List<Clothing>> _friendClothingCache = {};

  // ============================================================
  // Public cache getters
  // ============================================================

  /// 当前用户好友。
  List<AppUser> get friends =>
      List.unmodifiable(_friendRelations.map((relation) => relation.user));

  /// 完整好友关系。
  ///
  /// 包含：
  ///
  /// user
  /// remark
  /// createdAt
  List<FriendRelation> get friendRelations =>
      List.unmodifiable(_friendRelations);

  List<FriendRequest> get receivedRequests =>
      List.unmodifiable(_receivedRequests);

  List<FriendRequest> get sentRequests => List.unmodifiable(_sentRequests);

  int get receivedRequestCount => _receivedRequests.length;

  // ============================================================
  // Initial refresh
  // ============================================================

  /// 好友页面第一次进入时调用。
  ///
  /// 会依次同步：
  ///
  /// GET /api/friends
  /// GET /api/friends/requests/received
  /// GET /api/friends/requests/sent
  Future<void> refreshAll() async {
    _requireLogin();

    await refreshFriends();

    await refreshReceivedRequests();

    await refreshSentRequests();
  }

  // ============================================================
  // Friends
  // ============================================================

  /// GET /api/friends
  Future<List<FriendRelation>> refreshFriends() async {
    _requireLogin();

    try {
      final data = await _api.get('/api/friends');

      final rawFriends = data['friends'];

      if (rawFriends is! List) {
        throw const FriendException('服务器返回的好友列表格式不正确');
      }

      final relations = rawFriends
          .map(_parseFriendRelation)
          .toList(growable: false);

      _friendRelations
        ..clear()
        ..addAll(relations);

      _rebuildStatusCache();

      notifyListeners();

      return List.unmodifiable(_friendRelations);
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // User search
  // ============================================================

  /// 搜索用户仍然复用 UserRepository。
  ///
  /// UserRepository 已经对应：
  ///
  /// GET /api/users/search?q=keyword
  Future<List<AppUser>> searchUsers(String keyword) async {
    _requireLogin();

    final query = keyword.trim();

    if (query.isEmpty) {
      return const [];
    }

    try {
      return await _userRepository.searchUsers(query);
    } on UserRepositoryException catch (e) {
      if (e.statusCode == 401) {
        _authService.logout();
      }

      throw FriendException(_friendlyMessage(e.message));
    }
  }

  // ============================================================
  // Friend status
  // ============================================================

  /// 页面同步读取缓存中的状态。
  ///
  /// build() 中应该使用这个方法，
  /// 不要直接发 HTTP。
  FriendStatus getFriendStatus(String userId) {
    final user = currentUser;

    if (user == null || user.id == userId) {
      return FriendStatus.none;
    }

    return _statusCache[userId] ?? FriendStatus.none;
  }

  /// 主动从后端刷新某个用户状态。
  ///
  /// GET
  /// /api/friends/status/:userId
  Future<FriendStatus> refreshFriendStatus(String userId) async {
    _requireLogin();

    try {
      final data = await _api.get(
        '/api/friends/status/'
        '${Uri.encodeComponent(userId)}',
      );

      final status = friendStatusFromJson(data['status']);

      _statusCache[userId] = status;

      notifyListeners();

      return status;
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Received requests
  // ============================================================

  /// GET
  /// /api/friends/requests/received
  Future<List<FriendRequest>> refreshReceivedRequests() async {
    _requireLogin();

    try {
      final data = await _api.get('/api/friends/requests/received');

      final rawRequests = data['requests'];

      if (rawRequests is! List) {
        throw const FriendException('服务器返回的好友申请格式不正确');
      }

      final requests = rawRequests
          .map(_parseFriendRequest)
          .toList(growable: false);

      _receivedRequests
        ..clear()
        ..addAll(requests);

      _rebuildStatusCache();

      notifyListeners();

      return List.unmodifiable(_receivedRequests);
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Sent requests
  // ============================================================

  /// GET
  /// /api/friends/requests/sent
  Future<List<FriendRequest>> refreshSentRequests() async {
    _requireLogin();

    try {
      final data = await _api.get('/api/friends/requests/sent');

      final rawRequests = data['requests'];

      if (rawRequests is! List) {
        throw const FriendException('服务器返回的好友申请格式不正确');
      }

      final requests = rawRequests
          .map(_parseFriendRequest)
          .toList(growable: false);

      _sentRequests
        ..clear()
        ..addAll(requests);

      _rebuildStatusCache();

      notifyListeners();

      return List.unmodifiable(_sentRequests);
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  /// 同时刷新收到和发出的申请。
  Future<void> refreshRequests() async {
    await refreshReceivedRequests();

    await refreshSentRequests();
  }

  // ============================================================
  // Send request
  // ============================================================

  /// POST /api/friends/requests
  ///
  /// Body:
  ///
  /// {
  ///   "userId": "...",
  ///   "message": "你好..."
  /// }
  Future<FriendRequest> sendFriendRequest({
    required String userId,
    required String message,
  }) async {
    _requireLogin();

    final requestMessage = message.trim();

    if (requestMessage.isEmpty) {
      throw const FriendException('请输入好友申请信息');
    }

    try {
      final data = await _api.post(
        '/api/friends/requests',
        body: {'userId': userId, 'message': requestMessage},
      );

      final request = _parseFriendRequest(data['request']);

      /// 防止重复插入缓存。
      _sentRequests.removeWhere((item) => item.id == request.id);

      _sentRequests.insert(0, request);

      _rebuildStatusCache();

      notifyListeners();

      return request;
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Accept request
  // ============================================================

  /// POST
  /// /api/friends/requests/:requestId/accept
  Future<void> acceptFriendRequest(String requestId) async {
    _requireLogin();

    try {
      final data = await _api.post(
        '/api/friends/requests/'
        '${Uri.encodeComponent(requestId)}'
        '/accept',
      );

      final relation = _parseFriendRelation(data['friend']);

      /// 申请已经处理，
      /// 从 received pending 缓存移除。
      _receivedRequests.removeWhere((request) => request.id == requestId);

      /// 如果之前缓存中已经存在，
      /// 先删除再插入最新版本。
      _friendRelations.removeWhere(
        (item) => item.friendId == relation.friendId,
      );

      _friendRelations.add(relation);

      _rebuildStatusCache();

      notifyListeners();
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Reject request
  // ============================================================

  /// POST
  /// /api/friends/requests/:requestId/reject
  Future<void> rejectFriendRequest(String requestId) async {
    _requireLogin();

    try {
      await _api.post(
        '/api/friends/requests/'
        '${Uri.encodeComponent(requestId)}'
        '/reject',
      );

      _receivedRequests.removeWhere((request) => request.id == requestId);

      _rebuildStatusCache();

      notifyListeners();
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Cancel sent request
  // ============================================================

  /// DELETE
  /// /api/friends/requests/:requestId
  Future<void> cancelFriendRequest(String requestId) async {
    _requireLogin();

    try {
      await _api.delete(
        '/api/friends/requests/'
        '${Uri.encodeComponent(requestId)}',
      );

      _sentRequests.removeWhere((request) => request.id == requestId);

      _rebuildStatusCache();

      notifyListeners();
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  /// 根据目标用户找“我发送给他的申请”。
  ///
  /// UserProfilePage 取消申请时使用。
  FriendRequest? findSentRequestTo(String userId) {
    for (final request in _sentRequests) {
      if (request.toUser.id == userId) {
        return request;
      }
    }

    return null;
  }

  /// 找“这个用户发给我的申请”。
  FriendRequest? findReceivedRequestFrom(String userId) {
    for (final request in _receivedRequests) {
      if (request.fromUser.id == userId) {
        return request;
      }
    }

    return null;
  }

  // ============================================================
  // Remark
  // ============================================================

  /// PATCH /api/friends/:friendId
  ///
  /// {
  ///   "remark": "妈妈"
  /// }
  Future<void> updateRemark({
    required String friendId,
    required String remark,
  }) async {
    _requireLogin();

    try {
      final data = await _api.patch(
        '/api/friends/'
        '${Uri.encodeComponent(friendId)}',
        body: {'remark': remark.trim()},
      );

      final relation = _parseFriendRelation(data['friend']);

      final index = _friendRelations.indexWhere(
        (item) => item.friendId == friendId,
      );

      if (index == -1) {
        _friendRelations.add(relation);
      } else {
        _friendRelations[index] = relation;
      }

      notifyListeners();
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  /// 从好友关系缓存读取备注。
  String getRemark(String friendId) {
    for (final relation in _friendRelations) {
      if (relation.friendId == friendId) {
        return relation.remark;
      }
    }

    return '';
  }

  /// 页面显示名称：
  ///
  /// 有备注 -> 备注
  /// 无备注 -> username
  String getFriendDisplayName(AppUser friend) {
    final remark = getRemark(friend.id);

    if (remark.isNotEmpty) {
      return remark;
    }

    return friend.username;
  }

  // ============================================================
  // Delete friend
  // ============================================================

  /// DELETE /api/friends/:friendId
  Future<void> removeFriend(String friendId) async {
    _requireLogin();

    try {
      await _api.delete(
        '/api/friends/'
        '${Uri.encodeComponent(friendId)}',
      );

      _friendRelations.removeWhere((relation) => relation.friendId == friendId);

      /// 好友关系删除以后，
      /// 也删除其好友衣柜缓存。
      _friendClothingCache.remove(friendId);

      _rebuildStatusCache();

      notifyListeners();
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Friend wardrobe
  // ============================================================

  /// GET
  /// /api/friends/:friendId/clothing
  ///
  /// 后端会强制：
  ///
  /// visibility = public
  ///
  /// 所以前端不需要自己再过滤 private。
  Future<List<Clothing>> fetchFriendClothing(
    String friendId, {
    String? category,
    String? query,
  }) async {
    _requireLogin();

    final queryParameters = <String, String>{};

    if (category != null && category.trim().isNotEmpty && category != '全部') {
      queryParameters['category'] = category.trim();
    }

    if (query != null && query.trim().isNotEmpty) {
      queryParameters['q'] = query.trim();
    }

    try {
      final data = await _api.get(
        '/api/friends/'
        '${Uri.encodeComponent(friendId)}'
        '/clothing',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final rawClothes = data['clothes'];

      if (rawClothes is! List) {
        throw const FriendException('服务器返回的好友衣柜格式不正确');
      }

      final clothes = rawClothes.map(_parseClothing).toList(growable: false);

      _friendClothingCache[friendId] = clothes;

      notifyListeners();

      return List.unmodifiable(clothes);
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  /// 同步读取好友衣柜缓存。
  List<Clothing> getCachedFriendClothing(String friendId) {
    return List.unmodifiable(
      _friendClothingCache[friendId] ?? const <Clothing>[],
    );
  }

  // ============================================================
  // Clear cache
  // ============================================================

  /// 清空好友模块缓存。
  ///
  /// 登录账号变化时自动调用。
  void clear() {
    _clearCache();

    notifyListeners();
  }

  void _clearCache() {
    _friendRelations.clear();

    _receivedRequests.clear();

    _sentRequests.clear();

    _statusCache.clear();

    _friendClothingCache.clear();
  }

  // ============================================================
  // Auth listener
  // ============================================================

  /// 监听 AuthService。
  ///
  /// A 用户退出，
  /// B 用户登录以后，
  /// 不能继续显示 A 的好友缓存。
  void _handleAuthChanged() {
    final newUserId = _authService.currentUser?.id;

    if (newUserId == _sessionUserId) {
      return;
    }

    _sessionUserId = newUserId;

    _clearCache();

    notifyListeners();
  }

  // ============================================================
  // Rebuild status cache
  // ============================================================

  /// 根据完整缓存重新计算好友状态。
  ///
  /// 优先级：
  ///
  /// friends
  /// > requestSent
  /// > requestReceived
  /// > none
  void _rebuildStatusCache() {
    _statusCache.clear();

    for (final relation in _friendRelations) {
      _statusCache[relation.friendId] = FriendStatus.friends;
    }

    for (final request in _sentRequests) {
      if (_statusCache[request.toUser.id] == FriendStatus.friends) {
        continue;
      }

      _statusCache[request.toUser.id] = FriendStatus.requestSent;
    }

    for (final request in _receivedRequests) {
      if (_statusCache[request.fromUser.id] == FriendStatus.friends) {
        continue;
      }

      _statusCache[request.fromUser.id] = FriendStatus.requestReceived;
    }
  }

  // ============================================================
  // Parse
  // ============================================================

  FriendRelation _parseFriendRelation(dynamic value) {
    if (value is! Map) {
      throw const FriendException('服务器返回的好友数据格式不正确');
    }

    try {
      return FriendRelation.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      throw const FriendException('服务器返回的好友数据格式不正确');
    }
  }

  FriendRequest _parseFriendRequest(dynamic value) {
    if (value is! Map) {
      throw const FriendException('服务器返回的好友申请格式不正确');
    }

    try {
      return FriendRequest.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      throw const FriendException('服务器返回的好友申请格式不正确');
    }
  }

  Clothing _parseClothing(dynamic value) {
    if (value is! Map) {
      throw const FriendException('服务器返回的衣物数据格式不正确');
    }

    try {
      return Clothing.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      throw const FriendException('服务器返回的衣物数据格式不正确');
    }
  }

  // ============================================================
  // Login guard
  // ============================================================

  void _requireLogin() {
    if (_authService.currentUser == null) {
      throw const FriendException('请先登录');
    }
  }

  // ============================================================
  // API error
  // ============================================================

  Never _throwApiException(ApiException error) {
    if (error.statusCode == 401) {
      _authService.logout();
    }

    throw FriendException(_friendlyMessage(error.message));
  }

  /// 把后端英文业务错误转换成用户可读中文。
  String _friendlyMessage(String message) {
    switch (message) {
      case 'Unauthorized':
        return '登录状态已失效，请重新登录';

      case 'User not found':
        return '用户不存在';

      case 'Cannot add yourself as a friend':
        return '不能添加自己为好友';

      case 'User is already your friend':
        return '对方已经是你的好友';

      case 'Friend request already sent':
        return '好友申请已经发送';

      case 'This user has already sent you a friend request':
        return '对方已经向你发送好友申请，请先处理';

      case 'Friend request not found':
        return '好友申请不存在或已经处理';

      case 'Friend not found':
        return '好友关系不存在';

      case 'User is not your friend':
        return '对方不是你的好友';

      case 'Friend request message is required':
        return '请输入好友申请信息';

      case 'Cannot access yourself through friend API':
        return '不能通过好友接口访问自己的衣柜';

      case 'Clothing not found':
        return '好友衣物不存在或不可见';

      case 'Clothing image not found':
        return '衣物图片不存在';

      default:
        return message;
    }
  }
}

/// ============================================================
/// FriendException
/// ============================================================
class FriendException implements Exception {
  final String message;

  const FriendException(this.message);

  @override
  String toString() => message;
}
