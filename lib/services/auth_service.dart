import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'user_repository.dart';

/// 用户认证服务
///
/// 负责：
/// - 当前登录用户
/// - 登录
/// - 注册
/// - 获取验证码
/// - 修改用户名
/// - 删除账户
/// - 退出登录
class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance =
  AuthService._();

  final UserRepository _userRepository =
      UserRepository.instance;

  AppUser? _currentUser;

  /// 当前登录用户
  AppUser? get currentUser =>
      _currentUser;

  /// 是否已经登录
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

      // 后续请求自动携带 Bearer Token。
      _userRepository.setAccessToken(
        result.token,
      );

      _currentUser = result.user;

      notifyListeners();

      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(e.message),
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

      _userRepository.setAccessToken(
        result.token,
      );

      _currentUser = result.user;

      notifyListeners();

      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(e.message),
      );
    }
  }

  // ============================================================
  // Verification Code
  // ============================================================

  Future<void> sendVerificationCode(
      String email,
      ) async {
    try {
      await _userRepository
          .sendVerificationCode(email);
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(e.message),
      );
    }
  }

  // ============================================================
  // Current User
  // ============================================================

  /// 根据当前 Token 从后端重新取得用户资料。
  ///
  /// 当前阶段 Token 只存在内存中，
  /// 所以主要用于登录后的主动刷新。
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
        _friendlyMessage(e.message),
      );
    }
  }

  /// 修改用户名
  Future<AppUser> updateUsername(
      String username,
      ) async {
    if (_currentUser == null) {
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

      _currentUser = updatedUser;

      notifyListeners();

      return updatedUser;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(e.message),
      );
    }
  }

  /// 删除当前账户
  Future<void> deleteAccount() async {
    if (_currentUser == null) {
      throw const AuthException(
        '请先登录',
      );
    }

    try {
      await _userRepository
          .deleteCurrentUser();

      _currentUser = null;

      notifyListeners();
    } on UserRepositoryException catch (e) {
      throw AuthException(
        _friendlyMessage(e.message),
      );
    }
  }

  // ============================================================
  // Logout
  // ============================================================

  void logout() {
    _userRepository.clearSession();

    _currentUser = null;

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

/// 认证异常
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}