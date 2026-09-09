import '../models/app_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  AppUser currentUser = AppUser(
    id: 'user_001',
    username: 'Test User',
  );
}