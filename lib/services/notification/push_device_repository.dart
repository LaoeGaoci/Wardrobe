import '../../network/api_client.dart';

class PushDeviceRepository {
  PushDeviceRepository._();

  static final PushDeviceRepository instance = PushDeviceRepository._();

  final ApiClient _api = ApiClient.instance;

  // ============================================================
  // Register
  // ============================================================

  /// 注册当前 Android 设备。
  ///
  /// locale 使用 Wardrobe 自己的语言代码：
  ///
  /// - en
  /// - zh_Hans
  /// - zh_Hant
  ///
  /// Cloudflare 后端应该保存 locale，
  /// 以便 App 在后台 / terminated 时也能由 FCM 发送正确语言的标题和正文。
  Future<void> register({required String token, required String locale}) async {
    final normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      throw const PushDeviceRepositoryException('FCM token is empty');
    }

    final normalizedLocale = _normalizeLocale(locale);

    try {
      await _api.post(
        '/api/push/devices/register',
        body: {
          'token': normalizedToken,
          'platform': 'android',
          'locale': normalizedLocale,
        },
      );
    } on ApiException catch (e) {
      throw PushDeviceRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Unregister
  // ============================================================

  Future<void> unregister({required String token}) async {
    final normalized = token.trim();

    if (normalized.isEmpty) {
      return;
    }

    try {
      await _api.post(
        '/api/push/devices/unregister',
        body: {'token': normalized},
      );
    } on ApiException catch (e) {
      throw PushDeviceRepositoryException(e.message, statusCode: e.statusCode);
    }
  }

  // ============================================================
  // Locale
  // ============================================================

  String _normalizeLocale(String locale) {
    switch (locale) {
      case 'en':
      case 'zh_Hans':
      case 'zh_Hant':
        return locale;

      default:
        return 'zh_Hans';
    }
  }
}

class PushDeviceRepositoryException implements Exception {
  final String message;
  final int? statusCode;

  const PushDeviceRepositoryException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
