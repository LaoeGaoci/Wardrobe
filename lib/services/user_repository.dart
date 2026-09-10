import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

/// 用户账号数据
///
/// AppUser 负责公开的用户资料，
/// password 只保存在 Repository 内部。
class _UserAccount {
  AppUser user;
  final String password;

  _UserAccount({required this.user, required this.password});
}

/// 用户数据仓库
///
/// 负责：
/// - 保存所有注册用户
/// - 创建用户
/// - 登录验证
/// - 搜索用户
/// - 根据 ID / Email 获取用户
/// - 更新用户资料
///
/// 当前使用内存保存数据。
/// 后续接入 Firebase / Supabase / REST API 时，
/// FriendService 和 AuthService 不需要改变对外接口。
class UserRepository extends ChangeNotifier {
  UserRepository._();

  static final UserRepository instance = UserRepository._();

  final Map<String, _UserAccount> _accounts = {};

  /// 获取所有注册用户
  ///
  /// 注意：
  /// 这里返回的是 AppUser，不会暴露密码。
  List<AppUser> get allUsers {
    return _accounts.values
        .map((account) => account.user)
        .toList(growable: false);
  }

  /// 注册用户
  AppUser createUser({
    required String email,
    required String username,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw const UserRepositoryException('邮箱不能为空');
    }

    if (username.trim().isEmpty) {
      throw const UserRepositoryException('用户名不能为空');
    }

    if (password.isEmpty) {
      throw const UserRepositoryException('密码不能为空');
    }

    if (_accounts.values.any(
      (account) => account.user.email == normalizedEmail,
    )) {
      throw const UserRepositoryException('该邮箱已经注册');
    }

    final userId = 'user_${DateTime.now().microsecondsSinceEpoch}';

    final user = AppUser(
      id: userId,
      username: username.trim(),
      email: normalizedEmail,
    );

    _accounts[userId] = _UserAccount(user: user, password: password);

    notifyListeners();

    return user;
  }

  /// 根据邮箱获取用户
  AppUser? getUserByEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();

    for (final account in _accounts.values) {
      if (account.user.email == normalizedEmail) {
        return account.user;
      }
    }

    return null;
  }

  /// 根据 ID 获取用户
  AppUser? getUserById(String userId) {
    return _accounts[userId]?.user;
  }

  /// 登录验证
  AppUser authenticate({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();

    _UserAccount? matchedAccount;

    for (final account in _accounts.values) {
      if (account.user.email == normalizedEmail) {
        matchedAccount = account;
        break;
      }
    }

    if (matchedAccount == null) {
      throw const UserRepositoryException('该邮箱尚未注册');
    }

    if (matchedAccount.password != password) {
      throw const UserRepositoryException('密码错误');
    }

    return matchedAccount.user;
  }

  /// 搜索用户
  ///
  /// 支持：
  /// - 用户名
  /// - 邮箱
  ///
  /// 不区分大小写。
  List<AppUser> searchUsers(String keyword, {String? excludeUserId}) {
    final query = keyword.trim().toLowerCase();

    if (query.isEmpty) {
      return const [];
    }

    return _accounts.values
        .map((account) => account.user)
        .where((user) {
          if (excludeUserId != null && user.id == excludeUserId) {
            return false;
          }

          return user.username.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  /// 更新用户资料
  void updateUser(AppUser user) {
    final account = _accounts[user.id];

    if (account == null) {
      throw const UserRepositoryException('用户不存在');
    }

    account.user = user;

    notifyListeners();
  }

  /// 更新用户名
  AppUser updateUsername(String userId, String username) {
    final account = _accounts[userId];

    if (account == null) {
      throw const UserRepositoryException('用户不存在');
    }

    final newUsername = username.trim();

    if (newUsername.isEmpty) {
      throw const UserRepositoryException('用户名不能为空');
    }

    account.user = account.user.copyWith(username: newUsername);

    notifyListeners();

    return account.user;
  }

  /// 更新头像
  AppUser updateAvatar(String userId, String avatarUrl) {
    final account = _accounts[userId];

    if (account == null) {
      throw const UserRepositoryException('用户不存在');
    }

    account.user = account.user.copyWith(avatarUrl: avatarUrl);

    notifyListeners();

    return account.user;
  }
}

/// 用户数据异常
class UserRepositoryException implements Exception {
  final String message;

  const UserRepositoryException(this.message);

  @override
  String toString() => message;
}
