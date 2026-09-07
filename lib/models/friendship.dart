class Friendship {
  final String id;

  final String ownerId;
  final String friendId;

  /// 我给这个好友设置的备注
  final String nickname;

  final String status;

  Friendship({
    required this.id,
    required this.ownerId,
    required this.friendId,
    this.nickname = '',
    this.status = 'accepted',
  });
}