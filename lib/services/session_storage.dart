import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 本地登录会话存储。
///
/// Access Token 属于敏感认证信息，
/// 不应该使用 SharedPreferences 明文保存。
class SessionStorage {
  SessionStorage._();

  static final SessionStorage instance =
  SessionStorage._();

  static const String _accessTokenKey =
      'wardrobe_access_token';

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  /// 保存 Access Token。
  Future<void> saveAccessToken(
      String token,
      ) async {
    final value = token.trim();

    if (value.isEmpty) {
      await clearAccessToken();
      return;
    }

    await _storage.write(
      key: _accessTokenKey,
      value: value,
    );
  }

  /// 读取 Access Token。
  Future<String?> readAccessToken() async {
    final token = await _storage.read(
      key: _accessTokenKey,
    );

    if (token == null) {
      return null;
    }

    final value = token.trim();

    if (value.isEmpty) {
      return null;
    }

    return value;
  }

  /// 删除 Access Token。
  Future<void> clearAccessToken() async {
    await _storage.delete(
      key: _accessTokenKey,
    );
  }
}