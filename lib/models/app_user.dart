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

  AppUser copyWith({
    String? username,
    String? email,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}