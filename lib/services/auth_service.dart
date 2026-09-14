import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'clothing_repository.dart';
import 'user_repository.dart';

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();

  final UserRepository _userRepository = UserRepository.instance;
  final ClothingRepository _clothingRepository =
      ClothingRepository.instance;

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _userRepository.login(
        email: email,
        password: password,
      );

      _userRepository.setAccessToken(result.token);
      _clothingRepository.clear();
      _currentUser = result.user;

      notifyListeners();
      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<AppUser> register({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    try {
      final result = await _userRepository.register(
        email: email,
        verificationCode: verificationCode,
        password: password,
      );

      _userRepository.setAccessToken(result.token);
      _clothingRepository.clear();
      _currentUser = result.user;

      notifyListeners();
      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> sendVerificationCode(String email) async {
    try {
      await _userRepository.sendVerificationCode(email);
    } on UserRepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> refreshCurrentUser() async {
    try {
      _currentUser = await _userRepository.getCurrentUser();
      notifyListeners();
    } on UserRepositoryException catch (e) {
      if (e.statusCode == 401) {
        logout();
      }

      throw AuthException(e.message);
    }
  }

  Future<AppUser> updateUsername(String username) async {
    if (_currentUser == null) {
      throw const AuthException('Unauthorized');
    }

    try {
      final updatedUser = await _userRepository.updateUsername(username);
      _currentUser = updatedUser;

      notifyListeners();
      return updatedUser;
    } on UserRepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) {
      throw const AuthException('Unauthorized');
    }

    try {
      await _userRepository.deleteCurrentUser();
      _clothingRepository.clear();
      _currentUser = null;

      notifyListeners();
    } on UserRepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  void logout() {
    _userRepository.clearSession();
    _clothingRepository.clear();
    _currentUser = null;

    notifyListeners();
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
