import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ============================================================
// API Config
// ============================================================

class ApiConfig {
  ApiConfig._();

  /// 正式环境默认地址。
  ///
  /// 正常执行：
  ///
  /// flutter run
  ///
  /// 将直接连接：
  ///
  /// https://api.laoegaoci.win
  ///
  /// 如果需要临时切回本地：
  ///
  /// Android Emulator：
  ///
  /// flutter run \
  ///   --dart-define=API_BASE_URL=http://10.0.2.2:8787
  ///
  /// Windows Desktop：
  ///
  /// flutter run \
  ///   --dart-define=API_BASE_URL=http://127.0.0.1:8787
  static const String baseUrl =
  String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
    'https://api.laoegaoci.win',
  );

  /// 普通 JSON API 超时时间。
  static const Duration requestTimeout =
  Duration(
    seconds: 30,
  );

  /// 图片上传允许更长时间。
  static const Duration uploadTimeout =
  Duration(
    seconds: 60,
  );
}

// ============================================================
// API Client
// ============================================================

/// Wardrobe 通用 API Client。
///
/// 当前生产环境：
///
/// Flutter
///   ↓
/// https://api.laoegaoci.win
///   ↓
/// Cloudflare Worker
///   ↓
/// D1 / R2 / Email Service
///
/// 负责：
///
/// - GET
/// - POST
/// - PATCH
/// - DELETE
/// - multipart PUT
/// - JSON 编解码
/// - Bearer Token
/// - URL 拼接
/// - 网络异常
/// - 超时
/// - API 错误解析
/// - Debug 请求日志
class ApiClient {
  ApiClient._();

  static final ApiClient instance =
  ApiClient._();

  final http.Client _client =
  http.Client();

  String? _accessToken;

  // ============================================================
  // Session
  // ============================================================

  void setAccessToken(
      String token,
      ) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  /// 给 Image.network 等需要认证的请求使用。
  ///
  /// 注意：
  ///
  /// Debug 日志绝对不要打印这里的 Token。
  Map<String, String>
  get authorizationHeaders {
    final token =
        _accessToken;

    if (token == null ||
        token.isEmpty) {
      return const {};
    }

    return {
      'Authorization':
      'Bearer $token',
    };
  }

  // ============================================================
  // URL
  // ============================================================

  /// 把后端返回的相对 URL：
  ///
  /// /api/clothing/xxx/image
  ///
  /// 自动转换成：
  ///
  /// https://api.laoegaoci.win/api/clothing/xxx/image
  ///
  /// 如果传入的本身已经是：
  ///
  /// https://example.com/...
  ///
  /// 则原样返回。
  String resolveUrl(
      String path,
      ) {
    final normalized =
    path.trim();

    if (normalized.isEmpty) {
      return '';
    }

    final parsed =
    Uri.tryParse(
      normalized,
    );

    if (parsed != null &&
        parsed.hasScheme) {
      return normalized;
    }

    return _buildUri(
      normalized,
      null,
    ).toString();
  }

  // ============================================================
  // JSON API
  // ============================================================

  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>?
        queryParameters,
      }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters:
      queryParameters,
    );
  }

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

  Future<Map<String, dynamic>> delete(
      String path,
      ) {
    return _send(
      method: 'DELETE',
      path: path,
    );
  }

  // ============================================================
  // Multipart Upload
  // ============================================================

  /// 上传图片。
  ///
  /// 例如：
  ///
  /// PUT /api/clothing/:id/image
  ///
  /// multipart/form-data
  ///
  /// field:
  ///
  /// image
  Future<Map<String, dynamic>>
  putMultipartFile(
      String path, {
        required String fieldName,
        required String filePath,
      }) async {
    final file =
    File(filePath);

    if (!await file.exists()) {
      throw const ApiException(
        '待上传的图片不存在',
      );
    }

    final length =
    await file.length();

    const maxImageSize =
        10 * 1024 * 1024;

    if (length <= 0) {
      throw const ApiException(
        '图片文件为空',
      );
    }

    if (length >
        maxImageSize) {
      throw const ApiException(
        '图片不能超过 10MB',
      );
    }

    final uploadInfo =
    _detectImageType(
      filePath,
    );

    final uri =
    _buildUri(
      path,
      null,
    );

    _debugRequest(
      'PUT',
      uri,
    );

    final boundary =
        '----wardrobe-${DateTime.now().microsecondsSinceEpoch}';

    final imageBytes =
    await file.readAsBytes();

    final body =
    BytesBuilder();

    body.add(
      utf8.encode(
        '--$boundary\r\n',
      ),
    );

    body.add(
      utf8.encode(
        'Content-Disposition: form-data; '
            'name="$fieldName"; '
            'filename="${uploadInfo.fileName}"\r\n',
      ),
    );

    body.add(
      utf8.encode(
        'Content-Type: '
            '${uploadInfo.contentType}\r\n',
      ),
    );

    body.add(
      utf8.encode(
        '\r\n',
      ),
    );

    body.add(
      imageBytes,
    );

    body.add(
      utf8.encode(
        '\r\n--$boundary--\r\n',
      ),
    );

    final headers =
    <String, String>{
      'Accept':
      'application/json',

      'Content-Type':
      'multipart/form-data; '
          'boundary=$boundary',

      ...authorizationHeaders,
    };

    try {
      final request =
      http.Request(
        'PUT',
        uri,
      );

      request.headers.addAll(
        headers,
      );

      request.bodyBytes =
          body.takeBytes();

      final streamed =
      await _client
          .send(
        request,
      )
          .timeout(
        ApiConfig
            .uploadTimeout,
      );

      final response =
      await http.Response
          .fromStream(
        streamed,
      );

      _debugResponse(
        response,
      );

      return _parseResponse(
        response,
      );
    } on TimeoutException {
      throw const ApiException(
        '请求超时，请稍后重试',
      );
    } on SocketException {
      throw const ApiException(
        '无法连接服务器，请检查网络连接后重试',
      );
    } on http.ClientException {
      throw const ApiException(
        '网络请求失败，请检查网络连接后重试',
      );
    }
  }

  // ============================================================
  // Internal Request
  // ============================================================

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, String>?
    queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri =
    _buildUri(
      path,
      queryParameters,
    );

    _debugRequest(
      method,
      uri,
    );

    final headers =
    <String, String>{
      'Accept':
      'application/json',

      'Content-Type':
      'application/json',

      ...authorizationHeaders,
    };

    try {
      late final http.Response
      response;

      switch (method) {
        case 'GET':
          response =
          await _client
              .get(
            uri,
            headers:
            headers,
          )
              .timeout(
            ApiConfig
                .requestTimeout,
          );

          break;

        case 'POST':
          response =
          await _client
              .post(
            uri,
            headers:
            headers,
            body: body ==
                null
                ? null
                : jsonEncode(
              body,
            ),
          )
              .timeout(
            ApiConfig
                .requestTimeout,
          );

          break;

        case 'PATCH':
          response =
          await _client
              .patch(
            uri,
            headers:
            headers,
            body: body ==
                null
                ? null
                : jsonEncode(
              body,
            ),
          )
              .timeout(
            ApiConfig
                .requestTimeout,
          );

          break;

        case 'DELETE':
          response =
          await _client
              .delete(
            uri,
            headers:
            headers,
          )
              .timeout(
            ApiConfig
                .requestTimeout,
          );

          break;

        default:
          throw StateError(
            'Unsupported HTTP method: '
                '$method',
          );
      }

      _debugResponse(
        response,
      );

      return _parseResponse(
        response,
      );
    } on TimeoutException {
      throw const ApiException(
        '请求超时，请稍后重试',
      );
    } on SocketException {
      throw const ApiException(
        '无法连接服务器，请检查网络连接后重试',
      );
    } on http.ClientException {
      throw const ApiException(
        '网络请求失败，请检查网络连接后重试',
      );
    }
  }

  // ============================================================
  // URI
  // ============================================================

  Uri _buildUri(
      String path,
      Map<String, String>?
      queryParameters,
      ) {
    final configuredBase =
    ApiConfig.baseUrl.trim();

    if (configuredBase.isEmpty) {
      throw StateError(
        'API_BASE_URL 不能为空',
      );
    }

    final base =
    configuredBase.endsWith('/')
        ? configuredBase
        .substring(
      0,
      configuredBase
          .length -
          1,
    )
        : configuredBase;

    final normalizedPath =
    path.startsWith('/')
        ? path
        : '/$path';

    final uri =
    Uri.parse(
      '$base$normalizedPath',
    );

    if (queryParameters ==
        null ||
        queryParameters
            .isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters:
      queryParameters,
    );
  }

  // ============================================================
  // Response
  // ============================================================

  Map<String, dynamic>
  _parseResponse(
      http.Response response,
      ) {
    Map<String, dynamic>
    data =
    const {};

    if (response.body
        .isNotEmpty) {
      try {
        final decoded =
        jsonDecode(
          response.body,
        );

        if (decoded
        is Map<
            String,
            dynamic>) {
          data =
              decoded;
        } else {
          throw ApiException(
            '服务器返回的数据格式不正确',
            statusCode:
            response
                .statusCode,
          );
        }
      } on FormatException {
        throw ApiException(
          '服务器返回了无法解析的数据',
          statusCode:
          response
              .statusCode,
        );
      }
    }

    if (response.statusCode >=
        200 &&
        response.statusCode <
            300) {
      return data;
    }

    final rawError =
    data['error'];

    final message =
    rawError is String &&
        rawError
            .isNotEmpty
        ? rawError
        : _defaultErrorMessage(
      response
          .statusCode,
    );

    throw ApiException(
      message,
      statusCode:
      response.statusCode,
    );
  }

  // ============================================================
  // Debug
  // ============================================================

  /// 只打印：
  ///
  /// method + URL
  ///
  /// 不打印：
  ///
  /// password
  /// verificationCode
  /// Authorization
  /// JWT
  /// request body
  void _debugRequest(
      String method,
      Uri uri,
      ) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(
      '[API] -> $method $uri',
    );
  }

  /// 成功响应只打印状态码。
  ///
  /// 失败时额外打印 response body，
  /// 方便定位 Cloudflare Worker 返回的错误。
  ///
  /// Release 构建不会输出这些内容。
  void _debugResponse(
      http.Response response,
      ) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(
      '[API] <- '
          '${response.statusCode} '
          '${response.request?.method ?? ''} '
          '${response.request?.url ?? ''}',
    );

    if (response.statusCode >=
        400) {
      final body =
          response.body;

      if (body.isNotEmpty) {
        const maxLength =
        1000;

        final safeBody =
        body.length >
            maxLength
            ? '${body.substring(0, maxLength)}...'
            : body;

        debugPrint(
          '[API] error body: '
              '$safeBody',
        );
      }
    }
  }

  // ============================================================
  // Default Errors
  // ============================================================

  String _defaultErrorMessage(
      int statusCode,
      ) {
    switch (statusCode) {
      case 400:
        return '请求参数不正确';

      case 401:
        return '登录状态已失效，请重新登录';

      case 403:
        return '没有权限执行此操作';

      case 404:
        return '请求的资源不存在';

      case 409:
        return '当前操作发生冲突';

      case 413:
        return '上传内容过大';

      case 429:
        return '请求过于频繁，请稍后再试';

      case 500:
      case 502:
      case 503:
      case 504:
        return '服务器暂时无法处理请求，请稍后重试';

      default:
        return '请求失败 ($statusCode)';
    }
  }

  // ============================================================
  // Image
  // ============================================================

  _ImageUploadInfo
  _detectImageType(
      String filePath,
      ) {
    final normalized =
    filePath
        .toLowerCase();

    if (normalized.endsWith(
      '.png',
    )) {
      return const _ImageUploadInfo(
        contentType:
        'image/png',
        fileName:
        'clothing.png',
      );
    }

    if (normalized.endsWith(
      '.webp',
    )) {
      return const _ImageUploadInfo(
        contentType:
        'image/webp',
        fileName:
        'clothing.webp',
      );
    }

    if (normalized.endsWith(
      '.jpg',
    ) ||
        normalized.endsWith(
          '.jpeg',
        )) {
      return const _ImageUploadInfo(
        contentType:
        'image/jpeg',
        fileName:
        'clothing.jpg',
      );
    }

    throw const ApiException(
      '仅支持 JPG、PNG 或 WebP 图片',
    );
  }

  // ============================================================
  // Dispose
  // ============================================================

  void close() {
    _client.close();
  }
}

// ============================================================
// Image Upload Info
// ============================================================

class _ImageUploadInfo {
  final String contentType;
  final String fileName;

  const _ImageUploadInfo({
    required this.contentType,
    required this.fileName,
  });
}

// ============================================================
// API Exception
// ============================================================

class ApiException
    implements Exception {
  final String message;

  final int? statusCode;

  const ApiException(
      this.message, {
        this.statusCode,
      });

  bool get isUnauthorized =>
      statusCode == 401;

  bool get isForbidden =>
      statusCode == 403;

  bool get isNotFound =>
      statusCode == 404;

  bool get isConflict =>
      statusCode == 409;

  bool get isRateLimited =>
      statusCode == 429;

  bool get isServerError =>
      statusCode != null &&
          statusCode! >= 500;

  @override
  String toString() =>
      message;
}