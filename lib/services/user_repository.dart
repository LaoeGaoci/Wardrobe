import '../models/app_user.dart';
import '../network/api_client.dart';

/// 登录 / 注册结果
class AuthResult {
  final AppUser user;
  final String token;

  const AuthResult({
    required this.user,
    required this.token,
  });
}

/// 用户 Repository
///
/// 负责与后端用户 API 通信。
///
/// 当前对应接口：
///
/// POST   /api/auth/code
/// POST   /api/auth/register
/// POST   /api/auth/login
///
/// GET    /api/users/me
/// PATCH  /api/users/me
/// DELETE /api/users/me
///
/// GET    /api/users/search?q=
/// GET    /api/users/:id
class UserRepository {
  UserRepository._();

  static final UserRepository instance =
  UserRepository._();

  final ApiClient _api =
      ApiClient.instance;

  /// 临时用户缓存。
  ///
  /// 注意：
  /// 这里已经不是账号数据库。
  ///
  /// 目前好友系统还没有迁移到后端，
  /// FriendService / RecommendationService
  /// 仍然有同步读取用户对象的逻辑，
  /// 所以暂时缓存从服务器取得过的用户。
  final Map<String, AppUser> _userCache = {};

  /// 从缓存读取用户
  AppUser? getUserById(String userId) {
    return _userCache[userId];
  }

  /// 设置当前登录 Token
  void setAccessToken(String token) {
    _api.setAccessToken(token);
  }

  /// 清除当前会话
  void clearSession() {
    _api.clearAccessToken();
    _userCache.clear();
  }

  // ============================================================
  // Auth
  // ============================================================

  /// 请求验证码
  ///
  /// POST /api/auth/code
  Future<void> sendVerificationCode(
      String email,
      ) async {
    try {
      await _api.post(
        '/api/auth/code',
        body: {
          'email':
          email.trim().toLowerCase(),
        },
      );
    } on ApiException catch (e) {
      throw UserRepositoryException(
        e.message,
        statusCode: e.statusCode,
      );
    }
  }

  /// 注册
  ///
  /// POST /api/auth/register
  Future<AuthResult> register({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    try {
      final data = await _api.post(
        '/api/auth/register',
        body: {
          'email':
          email.trim().toLowerCase(),
          'verificationCode':
          verificationCode.trim(),
          'password': password,
        },
      );

      return _parseAuthResult(data);
    } on ApiException catch (e) {
      throw UserRepositoryException(
        e.message,
        statusCode: e.statusCode,
      );
    }
  }

  /// 登录
  ///
  /// POST /api/auth/login
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _api.post(
        '/api/auth/login',
        body: {
          'email':
          email.trim().toLowerCase(),
          'password': password,
        },
      );

      return _parseAuthResult(data);
    } on ApiException catch (e) {
      throw UserRepositoryException(
        e.message,
        statusCode: e.statusCode,
      );
    }
  }

  // ============================================================
  // Current User
  // ============================================================

  /// 获取当前登录用户
  ///
  /// GET /api/users/me
  Future<AppUser> getCurrentUser() async {
    try {
      final data = await _api.get(
        '/api/users/me',
      );

      final user =
      _parseUser(data['user']);

      _cacheUser(user);

      return user;
    } on ApiException catch (e) {
      throw UserRepositoryException(
        e.message,
        statusCode: e.statusCode,
      );
    }
  }

  /// 修改当前用户名
  ///
  /// PATCH /api/users/me
  Future<AppUser> updateUsername(
      String username,
      ) async {
    try {
      final data = await _api.patch(
        '/api/users/me',
        body: {
          'username': username.trim(),
        },
      );

      final user =
      _parseUser(data['user']);

      _cacheUser(user);

      return user;
    } on ApiException catch (e) {
      throw UserRepositoryException(
        e.message,
        statusCode: e.statusCode,
      );
    }
  }

  /// 删除当前账户
  ///
  /// DELETE /api/users/me
  Future<void> deleteCurrentUser() async {
    try {
      await _api.delete(
        '/api/users/me',
      );

      clearSession();
    } on ApiException catch (e) {
      throw UserRepositoryException(
        e.message,
        statusCode: e.statusCode,
      );
    }
  }

  // ============================================================
  // Users
  // ============================================================

  /// 搜索其他用户
  ///
  /// GET /api/users/search?q=keyword
  Future<List<AppUser>> searchUsers(
      String keyword,
      ) async {
    final query = keyword.trim();

    if (query.isEmpty) {
      return const [];
    }

    try {
      final data = await _api.get(
        '/api/users/search',
        queryParameters: {
          'q': query,
        },
      );

      final rawUsers = data['users'];

      if (rawUsers is! List) {
        throw const UserRepositoryException(
          '服务器返回的用户列表格式不正确',
        );
      }

      final users = rawUsers
          .map(_parseUser)
          .toList(growable: false);

      for (final user in users) {
        _cacheUser(user);
      }

      return users;
    } on ApiException catch (e) {
      throw UserRepositoryException(
        e.message,
        statusCode: e.statusCode,
      );
    }
  }

  /// 根据 ID 查询用户
  ///
  /// GET /api/users/:id
  Future<AppUser?> fetchUserById(
      String userId,
      ) async {
    try {
      final data = await _api.get(
        '/api/users/$userId',
      );

      final user =
      _parseUser(data['user']);

      _cacheUser(user);

      return user;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }

      throw UserRepositoryException(
        e.message,
        statusCode: e.statusCode,
      );
    }
  }

  // ============================================================
  // Parse
  // ============================================================

  AuthResult _parseAuthResult(
      Map<String, dynamic> data,
      ) {
    final user =
    _parseUser(data['user']);

    final token = data['token'];

    if (token is! String ||
        token.isEmpty) {
      throw const UserRepositoryException(
        '服务器没有返回登录令牌',
      );
    }

    _cacheUser(user);

    return AuthResult(
      user: user,
      token: token,
    );
  }

  AppUser _parseUser(dynamic value) {
    if (value is! Map) {
      throw const UserRepositoryException(
        '服务器返回的用户数据格式不正确',
      );
    }

    try {
      return AppUser.fromJson(
        Map<String, dynamic>.from(
          value,
        ),
      );
    } catch (_) {
      throw const UserRepositoryException(
        '服务器返回的用户数据格式不正确',
      );
    }
  }

  void _cacheUser(AppUser user) {
    _userCache[user.id] = user;
  }
}

/// 用户 Repository 异常
class UserRepositoryException
    implements Exception {
  final String message;
  final int? statusCode;

  const UserRepositoryException(
      this.message, {
        this.statusCode,
      });

  @override
  String toString() => message;
}