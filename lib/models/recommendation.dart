class Recommendation {
  final String id;

  final String senderId;
  final String receiverId;

  final List<String> clothingIds;

  final String message;

  final DateTime createdAt;

  bool isRead;

  Recommendation({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.clothingIds,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}