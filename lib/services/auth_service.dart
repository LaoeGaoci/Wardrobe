import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'clothing_repository.dart';
import 'user_repository.dart';

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance =
  AuthService._();

  final UserRepository _userRepository =
      UserRepository.instance;

  final ClothingRepository _clothingRepository =
      ClothingRepository.instance;

  AppUser? _currentUser;

  AppUser? get currentUser =>
      _currentUser;

  bool get isLoggedIn =>
      _currentUser != null;

  // ============================================================
  // Login
  // ============================================================

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final result =
      await _userRepository.login(
        email: email,
        password: password,
      );

      _userRepository
          .setAccessToken(
        result.token,
      );

      _clothingRepository.clear();

      _currentUser =
          result.user;

      notifyListeners();

      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  // ============================================================
  // Register
  // ============================================================

  Future<AppUser> register({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    try {
      final result =
      await _userRepository.register(
        email: email,
        verificationCode:
        verificationCode,
        password: password,
      );

      _userRepository
          .setAccessToken(
        result.token,
      );

      _clothingRepository.clear();

      _currentUser =
          result.user;

      notifyListeners();

      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  /// 发送注册邮箱验证码。
  Future<void> sendVerificationCode(
      String email,
      ) async {
    try {
      await _userRepository
          .sendVerificationCode(
        email,
      );
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  // ============================================================
  // Forgot password
  // ============================================================

  /// 请求密码重置验证码。
  ///
  /// 后端为了避免账户枚举，
  /// 邮箱不存在时也可能返回 success。
  Future<void> sendPasswordResetCode(
      String email,
      ) async {
    try {
      await _userRepository
          .sendPasswordResetCode(
        email,
      );
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  /// 使用邮箱验证码重置密码。
  ///
  /// 重置成功后：
  ///
  /// - 不自动登录
  /// - 用户应返回登录页面
  /// - 所有旧 JWT 已由后端失效
  Future<void> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      await _userRepository.resetPassword(
        email: email,
        verificationCode:
        verificationCode,
        newPassword:
        newPassword,
      );
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  // ============================================================
  // Current user
  // ============================================================

  Future<void> refreshCurrentUser() async {
    try {
      _currentUser =
      await _userRepository
          .getCurrentUser();

      notifyListeners();
    } on UserRepositoryException catch (e) {
      if (e.statusCode == 401) {
        logout();
      }

      throw AuthException(
        e.message,
      );
    }
  }

  Future<AppUser> updateUsername(
      String username,
      ) async {
    if (_currentUser == null) {
      throw const AuthException(
        'Unauthorized',
      );
    }

    try {
      final updatedUser =
      await _userRepository
          .updateUsername(
        username,
      );

      _currentUser =
          updatedUser;

      notifyListeners();

      return updatedUser;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  /// 修改已登录用户密码。
  ///
  /// 后端会返回新 Token，
  /// Repository 内部会自动替换。
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      throw const AuthException(
        'Unauthorized',
      );
    }

    try {
      await _userRepository
          .changePassword(
        currentPassword:
        currentPassword,
        newPassword:
        newPassword,
      );
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) {
      throw const AuthException(
        'Unauthorized',
      );
    }

    try {
      await _userRepository
          .deleteCurrentUser();

      _clothingRepository.clear();

      _currentUser = null;

      notifyListeners();
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  // ============================================================
  // Logout
  // ============================================================

  void logout() {
    _userRepository
        .clearSession();

    _clothingRepository.clear();

    _currentUser = null;

    notifyListeners();
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(
      this.message,
      );

  @override
  String toString() =>
      message;
}