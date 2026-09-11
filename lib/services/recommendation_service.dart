import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/clothing.dart';
import '../models/clothing_recommendation.dart';
import 'auth_service.dart';
import 'clothing_repository.dart';
import 'friend_service.dart';
import 'user_repository.dart';

class RecommendationService extends ChangeNotifier {
  RecommendationService._();

  static final RecommendationService instance =
  RecommendationService._();

  final AuthService _authService = AuthService.instance;
  final ClothingRepository _clothingRepository =
      ClothingRepository.instance;
  final FriendService _friendService = FriendService.instance;
  final UserRepository _userRepository = UserRepository.instance;

  final List<ClothingRecommendation> _recommendations = [];

  /// 所有推荐
  List<ClothingRecommendation> get recommendations =>
      List.unmodifiable(_recommendations);

  /// 当前用户收到的推荐
  List<ClothingRecommendation> get receivedRecommendations {
    final user = _authService.currentUser;

    if (user == null) {
      return const [];
    }

    return _recommendations
        .where((item) => item.toUserId == user.id)
        .toList(growable: false);
  }

  /// 当前用户收到的未读推荐
  List<ClothingRecommendation> get unreadRecommendations {
    return receivedRecommendations
        .where((item) => !item.isRead)
        .toList(growable: false);
  }

  /// 未读推荐数量
  int get unreadCount => unreadRecommendations.length;

  /// 当前用户收到的最新一封未读推荐
  ClothingRecommendation? get latestUnreadRecommendation {
    final unread = unreadRecommendations;

    if (unread.isEmpty) {
      return null;
    }

    return unread.last;
  }

  /// 发送推荐
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

    final targetUser = _userRepository.getUserById(toUserId);

    if (targetUser == null) {
      throw const RecommendationException('接收推荐的用户不存在');
    }

    if (_friendService.getFriendStatus(toUserId) !=
        FriendStatus.friends) {
      throw const RecommendationException('只能给好友发送衣物推荐');
    }

    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      throw const RecommendationException('请输入推荐留言');
    }

    // 推荐的衣物必须属于接收方。
    for (final clothing in clothes) {
      if (clothing.ownerId != toUserId) {
        throw const RecommendationException(
          '只能推荐好友衣柜中的衣物',
        );
      }

      // 推荐只能使用好友公开的衣物。
      if (clothing.visibility != ClothingVisibility.public) {
        throw const RecommendationException(
          '只能推荐好友公开的衣物',
        );
      }
    }

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    final recommendation = ClothingRecommendation(
      id: 'recommendation_${DateTime.now().microsecondsSinceEpoch}',
      fromUserId: currentUser.id,
      toUserId: toUserId,
      clothingIds: clothes.map((item) => item.id).toList(),
      message: trimmedMessage,
      createdAt: DateTime.now(),
    );

    _recommendations.add(recommendation);

    notifyListeners();

    return recommendation;
  }

  /// 获取推荐人
  AppUser? getSender(
      ClothingRecommendation recommendation,
      ) {
    return _userRepository.getUserById(
      recommendation.fromUserId,
    );
  }

  /// 获取推荐中的衣物
  List<Clothing> getClothes(
      ClothingRecommendation recommendation,
      ) {
    return recommendation.clothingIds
        .map(_clothingRepository.getById)
        .whereType<Clothing>()
        .toList(growable: false);
  }

  /// 标记为已读
  void markAsRead(String recommendationId) {
    final recommendation = _recommendations
        .where((item) => item.id == recommendationId)
        .firstOrNull;

    if (recommendation == null) {
      return;
    }

    if (recommendation.isRead) {
      return;
    }

    recommendation.isRead = true;

    notifyListeners();
  }
}

class RecommendationException implements Exception {
  final String message;

  const RecommendationException(this.message);

  @override
  String toString() => message;
}