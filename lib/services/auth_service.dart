import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'user_repository.dart';

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();

  final UserRepository _userRepository = UserRepository.instance;

  AppUser? _currentUser;

  /// 当前登录用户
  AppUser? get currentUser => _currentUser;

  /// 是否已经登录
  bool get isLoggedIn => _currentUser != null;

  /// 登录
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = _userRepository.authenticate(
        email: email,
        password: password,
      );

      _currentUser = user;

      notifyListeners();

      return user;
    } on UserRepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// 注册
  Future<AppUser> register({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw const AuthException('请输入邮箱');
    }

    if (!normalizedEmail.contains('@')) {
      throw const AuthException('请输入有效的邮箱地址');
    }

    // 开发阶段暂时使用固定验证码。
    if (verificationCode != '123456') {
      throw const AuthException('验证码错误');
    }

    final username = normalizedEmail.split('@').first;

    try {
      final user = _userRepository.createUser(
        email: normalizedEmail,
        username: username,
        password: password,
      );

      _currentUser = user;

      notifyListeners();

      return user;
    } on UserRepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// 修改用户名
  void updateUsername(String username) {
    final user = _currentUser;

    if (user == null) {
      throw const AuthException('请先登录');
    }

    try {
      final updatedUser = _userRepository.updateUsername(user.id, username);

      _currentUser = updatedUser;

      notifyListeners();
    } on UserRepositoryException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// 发送验证码
  Future<void> sendVerificationCode(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw const AuthException('请输入邮箱');
    }

    if (!normalizedEmail.contains('@')) {
      throw const AuthException('请输入有效的邮箱地址');
    }

    // TODO:
    // 接入真实邮箱验证码服务。
    //
    // 当前开发阶段验证码固定为：
    // 123456
  }

  /// 退出登录
  void logout() {
    _currentUser = null;

    notifyListeners();
  }
}

/// 认证异常
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
