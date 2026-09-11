class ClothingRecommendation {
  final String id;

  /// 推荐人
  final String fromUserId;

  /// 接收推荐的人
  final String toUserId;

  /// 被推荐的衣物 ID
  final List<String> clothingIds;

  /// 推荐留言
  final String message;

  /// 创建时间
  final DateTime createdAt;

  /// 是否已经打开
  bool isRead;

  ClothingRecommendation({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.clothingIds,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}