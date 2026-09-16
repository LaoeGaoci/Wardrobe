import '../../models/user/app_user.dart';
import '../../network/api_client.dart';
import 'session_storage.dart';

/// 登录 / 注册结果
class AuthResult {
  final AppUser user;
  final String token;

  const AuthResult({required this.user, required this.token});
}

/// 用户 Repository
///
/// 负责：
///
/// - 用户认证 API
/// - 用户资料 API
/// - Access Token 管理
/// - Access Token 本地安全持久化
///
/// 当前对应接口：
///
/// POST   /api/auth/code
/// POST   /api/auth/register
/// POST   /api/auth/login
/// POST   /api/auth/password-reset/code
/// POST   /api/auth/password-reset
///
/// GET    /api/users/me
/// PATCH  /api/users/me
/// PATCH  /api/users/me/password
/// DELETE /api/users/me
///
/// GET    /api/users/search?q=
/// GET    /api/users/:id
class UserRepository {
  UserRepository._();

  static final UserRepository instance = UserRepository._();

  final ApiClient _api = ApiClient.instance;

  final SessionStorage _sessionStorage = SessionStorage.instance;

  /// 临时用户缓存。
  ///
  /// 注意：
  ///
  /// 这里不是账号数据库。
  ///
  /// App 重启以后会清空，
  /// 当前用户会通过 /api/users/me
  /// 从服务器重新取得。
  final Map<String, AppUser> _userCache = {};

  AppUser? getUserById(String userId) {
    return _userCache[userId];
  }

  // ============================================================
  // Session
  // ============================================================

  /// 设置当前登录 Token。
  ///
  /// 同时完成：
  ///
  /// 1. 保存进系统安全存储
  /// 2. 设置到 ApiClient 内存
  ///
  /// 因此即使 App 被系统杀掉，
  /// Token 仍然可以在下次启动时恢复。
  Future<void> setAccessToken(String token) async {
    final value = token.trim();

    if (value.isEmpty) {
      throw const UserRepositoryException('服务器没有返回登录令牌');
    }

    await _sessionStorage.saveAccessToken(value);

    _api.setAccessToken(value);
  }

  /// App 启动时尝试恢复 Token。
  ///
  /// true：
  /// 本机存在保存过的登录 Token。
  ///
  /// false：
  /// 本机没有登录 Token。
  Future<bool> restoreAccessToken() async {
    final token = await _sessionStorage.readAccessToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    _api.setAccessToken(token);

    return true;
  }

  /// 清除当前会话。
  ///
  /// 同时清除：
  ///
  /// - ApiClient 内存 Token
  /// - 用户对象缓存
  /// - 系统安全存储中的 Token
  Future<void> clearSession() async {
    _api.clearAccessToken();

    _userCache.clear();

    await _sessionStorage.clearAccessToken();
  }

  // ============================================================
  // Auth
  // ============================================================

  /// 请求注册验证码。
  ///
  /// POST /api/auth/code
  Future<void> sendVerificationCode(String email) async {
    try {
      await _api.post(
        '/api/auth/code',
        body: {'email': email.trim().toLowerCase()},
      );
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  /// 注册。
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
          'email': email.trim().toLowerCase(),
          'verificationCode': verificationCode.trim(),
          'password': password,
        },
      );

      return _parseAuthResult(data);
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  /// 登录。
  ///
  /// POST /api/auth/login
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _api.post(
        '/api/auth/login',
        body: {'email': email.trim().toLowerCase(), 'password': password},
      );

      return _parseAuthResult(data);
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  /// 请求忘记密码验证码。
  ///
  /// POST /api/auth/password-reset/code
  ///
  /// 后端为了避免账户枚举：
  ///
  /// 无论邮箱是否注册，
  /// 都统一返回 success。
  Future<void> sendPasswordResetCode(String email) async {
    try {
      await _api.post(
        '/api/auth/password-reset/code',
        body: {'email': email.trim().toLowerCase()},
      );
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  /// 忘记密码后重置密码。
  ///
  /// POST /api/auth/password-reset
  ///
  /// 成功以后不会自动登录。
  Future<void> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      await _api.post(
        '/api/auth/password-reset',
        body: {
          'email': email.trim().toLowerCase(),
          'verificationCode': verificationCode.trim(),
          'newPassword': newPassword,
        },
      );
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Current User
  // ============================================================

  /// 根据当前 Token 获取登录用户。
  ///
  /// GET /api/users/me
  ///
  /// App 启动恢复登录时也使用这个接口
  /// 验证本地保存的 Token 是否仍然有效。
  Future<AppUser> getCurrentUser() async {
    try {
      final data = await _api.get('/api/users/me');

      final user = _parseUser(data['user']);

      _cacheUser(user);

      return user;
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  /// 修改当前用户名。
  ///
  /// PATCH /api/users/me
  Future<AppUser> updateUsername(String username) async {
    try {
      final data = await _api.patch(
        '/api/users/me',
        body: {'username': username.trim()},
      );

      final user = _parseUser(data['user']);

      _cacheUser(user);

      return user;
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  /// 修改当前密码。
  ///
  /// PATCH /api/users/me/password
  ///
  /// 后端会：
  ///
  /// - token_version + 1
  /// - 使所有旧 Token 失效
  /// - 返回当前设备的新 Token
  ///
  /// 因此这里必须同时更新
  /// Secure Storage 中保存的 Token。
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final data = await _api.patch(
        '/api/users/me/password',
        body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      final token = data['token'];

      if (token is! String || token.isEmpty) {
        throw const UserRepositoryException('服务器没有返回登录令牌');
      }

      // 不能只更新 ApiClient 内存。
      //
      // 否则 App 重启后会重新读到
      // 修改密码之前的旧 Token。
      await setAccessToken(token);

      return token;
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  /// 删除当前账户。
  ///
  /// DELETE /api/users/me
  Future<void> deleteCurrentUser() async {
    try {
      await _api.delete('/api/users/me');

      await clearSession();
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Users
  // ============================================================

  /// 搜索其他用户。
  ///
  /// GET /api/users/search?q=keyword
  Future<List<AppUser>> searchUsers(String keyword) async {
    final query = keyword.trim();

    if (query.isEmpty) {
      return const [];
    }

    try {
      final data = await _api.get(
        '/api/users/search',
        queryParameters: {'q': query},
      );

      final rawUsers = data['users'];

      if (rawUsers is! List) {
        throw const UserRepositoryException('服务器返回的用户列表格式不正确');
      }

      final users = rawUsers.map(_parseUser).toList(growable: false);

      for (final user in users) {
        _cacheUser(user);
      }

      return users;
    } on ApiException catch (e) {
      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  /// 根据 ID 查询用户。
  ///
  /// GET /api/users/:id
  Future<AppUser?> fetchUserById(String userId) async {
    try {
      final data = await _api.get('/api/users/$userId');

      final user = _parseUser(data['user']);

      _cacheUser(user);

      return user;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }

      throw UserRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Parse
  // ============================================================

  AuthResult _parseAuthResult(Map<String, dynamic> data) {
    final user = _parseUser(data['user']);

    final token = data['token'];

    if (token is! String || token.isEmpty) {
      throw const UserRepositoryException('服务器没有返回登录令牌');
    }

    _cacheUser(user);

    return AuthResult(user: user, token: token);
  }

  AppUser _parseUser(dynamic value) {
    if (value is! Map) {
      throw const UserRepositoryException('服务器返回的用户数据格式不正确');
    }

    try {
      return AppUser.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      throw const UserRepositoryException('服务器返回的用户数据格式不正确');
    }
  }

  void _cacheUser(AppUser user) {
    _userCache[user.id] = user;
  }
}

/// 用户 Repository 异常
class UserRepositoryException implements Exception {
  final String message;
  final int? statusCode;

  const UserRepositoryException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
