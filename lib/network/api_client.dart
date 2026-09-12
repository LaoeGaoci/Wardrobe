import 'dart:convert';

import 'package:http/http.dart' as http;

/// API 配置
class ApiConfig {
  ApiConfig._();

  /// 默认用于 Windows / macOS / Linux Desktop 本地调试。
  ///
  /// 可以通过：
  ///
  /// flutter run \
  ///   --dart-define=API_BASE_URL=https://example.com
  ///
  /// 覆盖该地址。
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8787',
  );
}

/// 通用 API Client
///
/// 负责：
/// - GET / POST / PATCH / DELETE
/// - JSON 编解码
/// - Bearer Token
/// - API 错误统一处理
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();

  String? _accessToken;

  /// 设置登录 Token
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// 清除登录 Token
  void clearAccessToken() {
    _accessToken = null;
  }

  /// GET
  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>? queryParameters,
      }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
    );
  }

  /// POST
  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, dynamic>? body,
      }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
    );
  }

  /// PATCH
  Future<Map<String, dynamic>> patch(
      String path, {
        Map<String, dynamic>? body,
      }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
    );
  }

  /// DELETE
  Future<Map<String, dynamic>> delete(
      String path,
      ) {
    return _send(
      method: 'DELETE',
      path: path,
    );
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(
      path,
      queryParameters,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = _accessToken;

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      late final http.Response response;

      switch (method) {
        case 'GET':
          response = await _client.get(
            uri,
            headers: headers,
          );

          break;

        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: body == null
                ? null
                : jsonEncode(body),
          );

          break;

        case 'PATCH':
          response = await _client.patch(
            uri,
            headers: headers,
            body: body == null
                ? null
                : jsonEncode(body),
          );

          break;

        case 'DELETE':
          response = await _client.delete(
            uri,
            headers: headers,
          );

          break;

        default:
          throw StateError(
            'Unsupported HTTP method: $method',
          );
      }

      return _parseResponse(response);
    } on http.ClientException {
      throw const ApiException(
        '无法连接服务器，请检查后端是否已经启动',
      );
    }
  }

  Uri _buildUri(
      String path,
      Map<String, String>? queryParameters,
      ) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(
      0,
      ApiConfig.baseUrl.length - 1,
    )
        : ApiConfig.baseUrl;

    final normalizedPath = path.startsWith('/')
        ? path
        : '/$path';

    final uri = Uri.parse(
      '$base$normalizedPath',
    );

    if (queryParameters == null ||
        queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: queryParameters,
    );
  }

  Map<String, dynamic> _parseResponse(
      http.Response response,
      ) {
    Map<String, dynamic> data = const {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(
          response.body,
        );

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } on FormatException {
        throw ApiException(
          '服务器返回了无法解析的数据',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    final message = data['error'];

    throw ApiException(
      message is String && message.isNotEmpty
          ? message
          : '请求失败 (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}

/// API 异常
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(
      this.message, {
        this.statusCode,
      });

  @override
  String toString() => message;
}