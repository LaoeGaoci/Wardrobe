import 'package:flutter/foundation.dart';

import '../../models/user/app_user.dart';
import '../../models/clothing/clothing.dart';
import '../../models/friends/clothing_recommendation.dart';
import '../../network/api_client.dart';

import '../users/auth_service.dart';

/// ============================================================
/// RecommendationService
/// ============================================================
///
/// 推荐数据真实来源已经改为：
///
/// Cloudflare Worker
///        ↓
/// D1
///
/// Service 内部的 List 只是 Flutter 页面缓存，
/// 不再是真实数据库。
class RecommendationService extends ChangeNotifier {
  RecommendationService._() {
    /// 记录当前登录账号。
    _sessionUserId = _authService.currentUser?.id;

    /// 监听登录 / 登出 / 切换账号。
    ///
    /// 防止 B 登录以后仍然看到 A 的推荐缓存。
    _authService.addListener(_handleAuthChanged);
  }

  static final RecommendationService instance = RecommendationService._();

  final ApiClient _api = ApiClient.instance;

  final AuthService _authService = AuthService.instance;

  String? _sessionUserId;

  // ============================================================
  // Cache
  // ============================================================

  /// 首页使用的“未读推荐信队列”。
  ///
  /// 顺序：
  ///
  /// index 0 = 最新一封
  /// index 1 = 第二新
  /// index 2 = 第三新
  final List<ClothingRecommendation> _unreadRecommendations = [];

  /// “收到的推荐”历史。
  final List<ClothingRecommendation> _receivedRecommendations = [];

  /// “发出的推荐”历史。
  final List<ClothingRecommendation> _sentRecommendations = [];

  /// 后端未读数量。
  int _unreadCount = 0;

  // ============================================================
  // Getters
  // ============================================================

  List<ClothingRecommendation> get unreadRecommendations =>
      List.unmodifiable(_unreadRecommendations);

  List<ClothingRecommendation> get receivedRecommendations =>
      List.unmodifiable(_receivedRecommendations);

  List<ClothingRecommendation> get sentRecommendations =>
      List.unmodifiable(_sentRecommendations);

  /// 兼容旧代码。
  ///
  /// 合并收到和发出的推荐，
  /// 并根据创建时间倒序。
  List<ClothingRecommendation> get recommendations {
    final map = <String, ClothingRecommendation>{};

    for (final item in _receivedRecommendations) {
      map[item.id] = item;
    }

    for (final item in _sentRecommendations) {
      map[item.id] = item;
    }

    final result = map.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return List.unmodifiable(result);
  }

  int get unreadCount => _unreadCount;

  /// 首页最上面那一封信。
  ///
  /// 后端 /unread 已经按照：
  ///
  /// created_at DESC
  ///
  /// 排序，所以 first 就是最新。
  ClothingRecommendation? get latestUnreadRecommendation {
    if (_unreadRecommendations.isEmpty) {
      return null;
    }

    return _unreadRecommendations.first;
  }

  // ============================================================
  // Home unread queue
  // ============================================================

  /// GET /api/recommendations/unread
  ///
  /// 首页进入时调用。
  ///
  /// 这个接口返回所有未读推荐，
  /// 最新推荐位于 index 0。
  Future<List<ClothingRecommendation>> refreshUnreadRecommendations() async {
    _requireLogin();

    try {
      final data = await _api.get('/api/recommendations/unread');

      final recommendations = _parseRecommendationList(data['recommendations']);

      _unreadRecommendations
        ..clear()
        ..addAll(recommendations);

      /// /unread 本身已经返回全部未读，
      /// 所以可以直接同步数量。
      _unreadCount = recommendations.length;

      notifyListeners();

      return List.unmodifiable(_unreadRecommendations);
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  /// GET /api/recommendations/unread-count
  ///
  /// 如果某个页面只想显示数字，
  /// 可以调用这个轻量接口，
  /// 不需要下载全部推荐内容。
  Future<int> refreshUnreadCount() async {
    _requireLogin();

    try {
      final data = await _api.get('/api/recommendations/unread-count');

      final rawCount = data['count'];

      if (rawCount is! num) {
        throw const RecommendationException('服务器返回的未读推荐数量格式不正确');
      }

      _unreadCount = rawCount.toInt();

      notifyListeners();

      return _unreadCount;
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Received history
  // ============================================================

  /// GET /api/recommendations/received
  ///
  /// 获取：
  ///
  /// 未读 + 已读
  ///
  /// 的完整收到推荐历史。
  Future<List<ClothingRecommendation>> refreshReceivedRecommendations() async {
    _requireLogin();

    try {
      final data = await _api.get('/api/recommendations/received');

      final recommendations = _parseRecommendationList(data['recommendations']);

      _receivedRecommendations
        ..clear()
        ..addAll(recommendations);

      notifyListeners();

      return List.unmodifiable(_receivedRecommendations);
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Sent history
  // ============================================================

  /// GET /api/recommendations/sent
  Future<List<ClothingRecommendation>> refreshSentRecommendations() async {
    _requireLogin();

    try {
      final data = await _api.get('/api/recommendations/sent');

      final recommendations = _parseRecommendationList(data['recommendations']);

      _sentRecommendations
        ..clear()
        ..addAll(recommendations);

      notifyListeners();

      return List.unmodifiable(_sentRecommendations);
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Detail
  // ============================================================

  /// GET /api/recommendations/:id
  Future<ClothingRecommendation> fetchRecommendation(
    String recommendationId,
  ) async {
    _requireLogin();

    try {
      final data = await _api.get(
        '/api/recommendations/'
        '${Uri.encodeComponent(recommendationId)}',
      );

      final recommendation = _parseRecommendation(data['recommendation']);

      _updateCache(recommendation);

      notifyListeners();

      return recommendation;
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Send
  // ============================================================

  /// POST /api/recommendations
  ///
  /// 这个方法的参数保持和你原来的
  /// FriendWardrobePage 一致，
  /// 所以发送推荐页面不需要重新改调用方式。
  Future<ClothingRecommendation> sendRecommendation({
    required String toUserId,
    required List<Clothing> clothes,
    required String message,
  }) async {
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      throw const RecommendationException('请先登录');
    }

    if (currentUser.id == toUserId) {
      throw const RecommendationException('不能给自己发送推荐');
    }

    if (clothes.isEmpty) {
      throw const RecommendationException('请至少选择一件衣物');
    }

    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      throw const RecommendationException('请输入推荐留言');
    }

    if (trimmedMessage.length > 200) {
      throw const RecommendationException('推荐留言不能超过 200 个字符');
    }

    /// 前端先做一层快速检查，
    /// 后端仍然会再次做真正的权限校验。
    for (final clothing in clothes) {
      if (clothing.ownerId != toUserId) {
        throw const RecommendationException('只能推荐好友衣柜中的衣物');
      }

      if (clothing.visibility != ClothingVisibility.public) {
        throw const RecommendationException('只能推荐好友公开的衣物');
      }
    }

    try {
      final data = await _api.post(
        '/api/recommendations',
        body: {
          'toUserId': toUserId,

          'clothingIds': clothes.map((item) => item.id).toList(growable: false),

          'message': trimmedMessage,
        },
      );

      final recommendation = _parseRecommendation(data['recommendation']);

      /// 如果“发出的推荐历史”已经加载过，
      /// 可以马上在缓存顶部看到刚发出的推荐。
      _sentRecommendations.removeWhere((item) => item.id == recommendation.id);

      _sentRecommendations.insert(0, recommendation);

      notifyListeners();

      return recommendation;
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Read
  // ============================================================

  /// PATCH
  /// /api/recommendations/:id/read
  ///
  /// “收好这封信”时调用。
  ///
  /// 请求成功后：
  ///
  /// 1. 更新收到历史缓存
  /// 2. 从未读信封队列删除
  /// 3. unreadCount - 1
  /// 4. notifyListeners()
  ///
  /// HomePage 就会自动让下一封信上浮。
  Future<ClothingRecommendation> markAsRead(String recommendationId) async {
    _requireLogin();

    try {
      final data = await _api.patch(
        '/api/recommendations/'
        '${Uri.encodeComponent(recommendationId)}'
        '/read',
      );

      final updated = _parseRecommendation(data['recommendation']);

      /// 先判断它之前是否真的存在于
      /// 未读队列。
      final wasUnread = _unreadRecommendations.any(
        (item) => item.id == recommendationId,
      );

      /// 当前信从首页堆叠队列移除。
      _unreadRecommendations.removeWhere((item) => item.id == recommendationId);

      if (wasUnread && _unreadCount > 0) {
        _unreadCount--;
      }

      /// 更新历史缓存中的同一条推荐。
      _replaceIfPresent(_receivedRecommendations, updated);

      notifyListeners();

      return updated;
    } on ApiException catch (e) {
      _throwApiException(e);
    }
  }

  // ============================================================
  // Compatibility helpers
  // ============================================================

  /// 新推荐对象已经直接包含发送者。
  AppUser? getSender(ClothingRecommendation recommendation) {
    return recommendation.fromUser;
  }

  /// 新推荐对象已经直接包含衣物。
  List<Clothing> getClothes(ClothingRecommendation recommendation) {
    return List.unmodifiable(recommendation.clothes);
  }

  // ============================================================
  // Cache
  // ============================================================

  void clear() {
    _clearCache();

    notifyListeners();
  }

  void _clearCache() {
    _unreadRecommendations.clear();

    _receivedRecommendations.clear();

    _sentRecommendations.clear();

    _unreadCount = 0;
  }

  /// 登录账号发生变化时，
  /// 清空上一账号的推荐。
  void _handleAuthChanged() {
    final newUserId = _authService.currentUser?.id;

    if (newUserId == _sessionUserId) {
      return;
    }

    _sessionUserId = newUserId;

    _clearCache();

    notifyListeners();
  }

  void _updateCache(ClothingRecommendation recommendation) {
    _replaceIfPresent(_unreadRecommendations, recommendation);

    _replaceIfPresent(_receivedRecommendations, recommendation);

    _replaceIfPresent(_sentRecommendations, recommendation);
  }

  void _replaceIfPresent(
    List<ClothingRecommendation> list,
    ClothingRecommendation recommendation,
  ) {
    final index = list.indexWhere((item) => item.id == recommendation.id);

    if (index == -1) {
      return;
    }

    list[index] = recommendation;
  }

  // ============================================================
  // Parse
  // ============================================================

  List<ClothingRecommendation> _parseRecommendationList(dynamic value) {
    if (value is! List) {
      throw const RecommendationException('服务器返回的推荐列表格式不正确');
    }

    return value.map(_parseRecommendation).toList(growable: false);
  }

  ClothingRecommendation _parseRecommendation(dynamic value) {
    if (value is! Map) {
      throw const RecommendationException('服务器返回的推荐数据格式不正确');
    }

    try {
      return ClothingRecommendation.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      throw const RecommendationException('服务器返回的推荐数据格式不正确');
    }
  }

  // ============================================================
  // Auth
  // ============================================================

  void _requireLogin() {
    if (_authService.currentUser == null) {
      throw const RecommendationException('请先登录');
    }
  }

  // ============================================================
  // API error
  // ============================================================

  Never _throwApiException(ApiException error) {
    if (error.statusCode == 401) {
      _authService.logout();
    }

    throw RecommendationException(_friendlyMessage(error.message));
  }

  String _friendlyMessage(String message) {
    switch (message) {
      case 'Unauthorized':
        return '登录状态已失效，请重新登录';

      case 'User not found':
        return '接收推荐的用户不存在';

      case 'Cannot recommend clothing to yourself':
        return '不能给自己发送推荐';

      case 'You can only recommend clothing to friends':
        return '只能给好友发送衣物推荐';

      case 'One or more clothing items are unavailable':
        return '部分衣物已经不存在、已设为私密或不属于该好友';

      case 'At least one clothing item is required':
        return '请至少选择一件衣物';

      case 'Recommendation message is required':
        return '请输入推荐留言';

      case 'Recommendation not found':
        return '推荐不存在或你没有查看权限';

      case 'Recommendation clothing not found':
        return '推荐中的衣物已经不存在';

      case 'Recommendation clothing image not found':
        return '推荐中的衣物图片已经不存在';

      default:
        return message;
    }
  }
}

/// ============================================================
/// RecommendationException
/// ============================================================

class RecommendationException implements Exception {
  final String message;

  const RecommendationException(this.message);

  @override
  String toString() => message;
}
