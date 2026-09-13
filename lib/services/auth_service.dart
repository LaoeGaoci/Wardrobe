import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'clothing_repository.dart';
import 'user_repository.dart';

class AuthService
    extends ChangeNotifier {
  AuthService._();

  static final AuthService
  instance =
  AuthService._();

  final UserRepository
  _userRepository =
      UserRepository.instance;

  final ClothingRepository
  _clothingRepository =
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
      await _userRepository
          .login(
        email: email,
        password: password,
      );

      _userRepository
          .setAccessToken(
        result.token,
      );

      /// 防止显示上一个用户的衣柜缓存。
      _clothingRepository
          .clear();

      _currentUser =
          result.user;

      notifyListeners();

      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(
          e.message,
        ),
      );
    }
  }

  // ============================================================
  // Register
  // ============================================================

  Future<AppUser> register({
    required String email,
    required String
    verificationCode,
    required String password,
  }) async {
    try {
      final result =
      await _userRepository
          .register(
        email: email,
        verificationCode:
        verificationCode,
        password: password,
      );

      _userRepository
          .setAccessToken(
        result.token,
      );

      _clothingRepository
          .clear();

      _currentUser =
          result.user;

      notifyListeners();

      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(
          e.message,
        ),
      );
    }
  }

  // ============================================================
  // Verification
  // ============================================================

  Future<void>
  sendVerificationCode(
      String email,
      ) async {
    try {
      await _userRepository
          .sendVerificationCode(
        email,
      );
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(
          e.message,
        ),
      );
    }
  }

  // ============================================================
  // Current User
  // ============================================================

  Future<void>
  refreshCurrentUser()
  async {
    try {
      _currentUser =
      await _userRepository
          .getCurrentUser();

      notifyListeners();
    } on UserRepositoryException catch (e) {
      if (e.statusCode ==
          401) {
        logout();
      }

      throw AuthException(
        _friendlyMessage(
          e.message,
        ),
      );
    }
  }

  Future<AppUser>
  updateUsername(
      String username,
      ) async {
    if (_currentUser ==
        null) {
      throw const AuthException(
        '请先登录',
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
        _friendlyMessage(
          e.message,
        ),
      );
    }
  }

  Future<void> deleteAccount()
  async {
    if (_currentUser ==
        null) {
      throw const AuthException(
        '请先登录',
      );
    }

    try {
      await _userRepository
          .deleteCurrentUser();

      _clothingRepository
          .clear();

      _currentUser =
      null;

      notifyListeners();
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(
          e.message,
        ),
      );
    }
  }

  // ============================================================
  // Logout
  // ============================================================

  void logout() {
    _userRepository
        .clearSession();

    _clothingRepository
        .clear();

    _currentUser =
    null;

    notifyListeners();
  }

  // ============================================================
  // Error Mapping
  // ============================================================

  String _friendlyMessage(
      String message,
      ) {
    switch (message) {
      case 'Invalid email address':
        return '请输入有效的邮箱地址';

      case 'Invalid verification code':
        return '验证码错误';

      case 'Email already exists':
        return '该邮箱已经注册';

      case 'Email or username already exists':
        return '该邮箱或用户名已经被使用';

      case 'Invalid email or password':
        return '邮箱或密码错误';

      case 'Unauthorized':
        return '登录状态已失效，请重新登录';

      case 'Username already exists':
        return '该用户名已被使用';

      case 'Username cannot be empty':
      case 'Username is required':
        return '用户名不能为空';

      case 'Password must be at least 8 characters':
        return '密码至少需要 8 位';

      case 'Password must be at most 128 characters':
        return '密码不能超过 128 位';

      case 'User not found':
        return '用户不存在';

      default:
        return message;
    }
  }
}

class AuthException
    implements Exception {
  final String message;

  const AuthException(
      this.message,
      );

  @override
  String toString() =>
      message;
}