import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'clothing_repository.dart';
import 'user_repository.dart';

/// 当前认证状态。
enum AuthStatus {
  /// App 正在启动，
  /// 正在检查本地是否存在登录 Token。
  restoring,

  /// 已经登录。
  authenticated,

  /// 没有登录。
  unauthenticated,

  /// 本机存在 Token，
  /// 但由于网络等原因暂时无法确认登录状态。
  restoreFailed,
}

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance =
  AuthService._();

  final UserRepository _userRepository =
      UserRepository.instance;

  final ClothingRepository _clothingRepository =
      ClothingRepository.instance;

  AppUser? _currentUser;

  AuthStatus _status =
      AuthStatus.restoring;

  String? _restoreError;

  bool _initialized =
  false;

  // ============================================================
  // Getters
  // ============================================================

  AppUser? get currentUser =>
      _currentUser;

  AuthStatus get status =>
      _status;

  String? get restoreError =>
      _restoreError;

  bool get isLoggedIn =>
      _status ==
          AuthStatus.authenticated &&
          _currentUser != null;

  // ============================================================
  // Initialize / Restore Session
  // ============================================================

  /// App 启动时初始化登录状态。
  ///
  /// 一个 App 生命周期内只自动执行一次。
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    await _restoreSession();
  }

  /// 用户手动重试恢复登录。
  ///
  /// 主要用于：
  ///
  /// - App 启动时没有网络
  /// - Cloudflare 暂时不可用
  /// - 请求超时
  Future<void> retryRestoreSession() async {
    await _restoreSession();
  }

  /// 从 Secure Storage 恢复 Token，
  /// 然后调用 /api/users/me 验证。
  Future<void> _restoreSession() async {
    _status =
        AuthStatus.restoring;

    _restoreError =
    null;

    notifyListeners();

    try {
      final hasToken =
      await _userRepository
          .restoreAccessToken();

      // 从未登录过，
      // 或者之前已经主动退出登录。
      if (!hasToken) {
        _currentUser =
        null;

        _clothingRepository
            .clear();

        _status =
            AuthStatus
                .unauthenticated;

        return;
      }

      try {
        // 本地存在 Token。
        //
        // 不直接相信本地状态，
        // 而是调用服务器验证 Token。
        final user =
        await _userRepository
            .getCurrentUser();

        _currentUser =
            user;

        _status =
            AuthStatus
                .authenticated;
      } on UserRepositoryException catch (e) {
        if (e.statusCode ==
            401) {
          // 只有服务器明确返回 401
          // 才认为登录真正失效。
          //
          // 可能原因：
          //
          // - Token 超过 30 天
          // - Token 签名无效
          // - 用户修改了密码
          // - 用户重置了密码
          // - token_version 已改变
          await _userRepository
              .clearSession();

          _clothingRepository
              .clear();

          _currentUser =
          null;

          _status =
              AuthStatus
                  .unauthenticated;

          return;
        }

        // 网络错误、服务器错误等，
        // 不能擅自删除用户 Token。
        //
        // 否则用户只是暂时断网，
        // 却会被永久退出登录。
        _currentUser =
        null;

        _restoreError =
            e.message;

        _status =
            AuthStatus
                .restoreFailed;
      }
    } catch (e) {
      // Secure Storage 本身出现异常，
      // 或发生其它初始化异常。
      _currentUser =
      null;

      _restoreError =
          e.toString();

      _status =
          AuthStatus
              .restoreFailed;
    } finally {
      notifyListeners();
    }
  }

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
        email:
        email,
        password:
        password,
      );

      // 同时：
      //
      // - 写入 Secure Storage
      // - 写入 ApiClient
      await _userRepository
          .setAccessToken(
        result.token,
      );

      _clothingRepository
          .clear();

      _currentUser =
          result.user;

      _restoreError =
      null;

      _status =
          AuthStatus
              .authenticated;

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
        email:
        email,
        verificationCode:
        verificationCode,
        password:
        password,
      );

      await _userRepository
          .setAccessToken(
        result.token,
      );

      _clothingRepository
          .clear();

      _currentUser =
          result.user;

      _restoreError =
      null;

      _status =
          AuthStatus
              .authenticated;

      notifyListeners();

      return result.user;
    } on UserRepositoryException catch (e) {
      throw AuthException(
        e.message,
      );
    }
  }

  // ============================================================
  // Verification Code
  // ============================================================

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
  // Forgot Password
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
      await _userRepository
          .resetPassword(
        email:
        email,
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
  // Current User
  // ============================================================

  /// 使用当前 Token 重新从服务器取得用户资料。
  Future<void> refreshCurrentUser() async {
    try {
      _currentUser =
      await _userRepository
          .getCurrentUser();

      _status =
          AuthStatus
              .authenticated;

      notifyListeners();
    } on UserRepositoryException catch (e) {
      if (e.statusCode ==
          401) {
        await logout();
      }

      throw AuthException(
        e.message,
      );
    }
  }

  /// 修改用户名。
  Future<AppUser> updateUsername(
      String username,
      ) async {
    if (_currentUser ==
        null) {
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
  /// 后端会返回新 Token。
  ///
  /// UserRepository 会同时：
  ///
  /// - 更新 ApiClient Token
  /// - 更新 Secure Storage Token
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser ==
        null) {
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

  /// 删除当前账户。
  Future<void> deleteAccount() async {
    if (_currentUser ==
        null) {
      throw const AuthException(
        'Unauthorized',
      );
    }

    try {
      await _userRepository
          .deleteCurrentUser();

      _clothingRepository
          .clear();

      _currentUser =
      null;

      _restoreError =
      null;

      _status =
          AuthStatus
              .unauthenticated;

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

  /// 主动退出登录。
  ///
  /// 注意：
  ///
  /// 现在这是异步方法，
  /// 因为需要删除系统安全存储中的 Token。
  Future<void> logout() async {
    await _userRepository
        .clearSession();

    _clothingRepository
        .clear();

    _currentUser =
    null;

    _restoreError =
    null;

    _status =
        AuthStatus
            .unauthenticated;

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