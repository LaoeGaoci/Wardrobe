class AppUser {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl = '',
  });

  /// 从后端 JSON 创建用户对象
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  AppUser copyWith({String? username, String? email, String? avatarUrl}) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
