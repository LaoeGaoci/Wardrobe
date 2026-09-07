class AppUser {
  final String id;
  final String username;
  final String avatarUrl;

  AppUser({
    required this.id,
    required this.username,
    this.avatarUrl = '',
  });
}