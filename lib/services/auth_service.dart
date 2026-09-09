import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();

  AppUser? _currentUser;

  final Map<String, _LocalAccount> _accounts = {};

  AppUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// 登录
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final normalizedEmail = email.trim().toLowerCase();

    final account = _accounts[normalizedEmail];

    if (account == null) {
      throw const AuthException('该邮箱尚未注册');
    }

    if (account.password != password) {
      throw const AuthException('密码错误');
    }

    _currentUser = AppUser(
      id: account.id,
      username: account.username,
    );

    notifyListeners();

    return _currentUser!;
  }

  /// 注册
  Future<AppUser> register({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final normalizedEmail = email.trim().toLowerCase();

    if (_accounts.containsKey(normalizedEmail)) {
      throw const AuthException('该邮箱已经注册');
    }

    // 开发阶段暂时使用固定验证码
    if (verificationCode != '123456') {
      throw const AuthException('验证码错误');
    }

    final userId =
        'user_${DateTime.now().millisecondsSinceEpoch}';

    final username =
        normalizedEmail.split('@').first;

    final account = _LocalAccount(
      id: userId,
      username: username,
      password: password,
    );

    _accounts[normalizedEmail] = account;

    _currentUser = AppUser(
      id: account.id,
      username: account.username,
    );

    notifyListeners();

    return _currentUser!;
  }

  /// 发送验证码
  Future<void> sendVerificationCode(
      String email,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw const AuthException('请输入邮箱');
    }

    if (!normalizedEmail.contains('@')) {
      throw const AuthException('请输入有效的邮箱地址');
    }

    // TODO:
    // 接入真实邮箱验证码服务
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

/// 本地账号
class _LocalAccount {
  final String id;
  final String username;
  final String password;

  const _LocalAccount({
    required this.id,
    required this.username,
    required this.password,
  });
}

/// 认证异常
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}