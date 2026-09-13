import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API 配置
class ApiConfig {
  ApiConfig._();

  /// 可以通过：
  ///
  /// flutter run \
  ///   --dart-define=API_BASE_URL=http://192.168.1.100:8787
  ///
  /// 覆盖默认地址。
  static const String _definedBaseUrl =
  String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) {
      return _definedBaseUrl;
    }

    /// Android Emulator 访问宿主 Windows：
    ///
    /// 不能使用 127.0.0.1，
    /// 必须使用 10.0.2.2。
    if (defaultTargetPlatform ==
        TargetPlatform.android) {
      return 'http://10.0.2.2:8787';
    }

    /// Windows / macOS / Linux Desktop。
    return 'http://127.0.0.1:8787';
  }
}

/// 通用 API Client
///
/// 负责：
/// - GET
/// - POST
/// - PATCH
/// - DELETE
/// - multipart PUT
/// - JSON 编解码
/// - Bearer Token
/// - API 错误统一处理
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

  /// 给 Image.network 等非 JSON 请求使用。
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

  /// 把后端返回的相对 URL：
  ///
  /// /api/clothing/xxx/image
  ///
  /// 转换成：
  ///
  /// http://10.0.2.2:8787/api/clothing/xxx/image
  String resolveUrl(
      String path,
      ) {
    if (path.isEmpty) {
      return '';
    }

    final parsed =
    Uri.tryParse(path);

    if (parsed != null &&
        parsed.hasScheme) {
      return path;
    }

    return _buildUri(
      path,
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
  // Multipart
  // ============================================================

  /// 上传衣物图片。
  ///
  /// PUT /api/clothing/:id/image
  ///
  /// multipart/form-data
  ///
  /// field:
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

    if (length > maxImageSize) {
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
      await _client.send(
        request,
      );

      final response =
      await http.Response
          .fromStream(
        streamed,
      );

      return _parseResponse(
        response,
      );
    } on http.ClientException {
      throw const ApiException(
        '无法连接服务器，请检查后端是否已经启动',
      );
    } on SocketException {
      throw const ApiException(
        '无法连接服务器，请检查后端是否已经启动',
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
          await _client.get(
            uri,
            headers: headers,
          );

          break;

        case 'POST':
          response =
          await _client.post(
            uri,
            headers: headers,
            body: body == null
                ? null
                : jsonEncode(
              body,
            ),
          );

          break;

        case 'PATCH':
          response =
          await _client.patch(
            uri,
            headers: headers,
            body: body == null
                ? null
                : jsonEncode(
              body,
            ),
          );

          break;

        case 'DELETE':
          response =
          await _client.delete(
            uri,
            headers: headers,
          );

          break;

        default:
          throw StateError(
            'Unsupported HTTP method: '
                '$method',
          );
      }

      return _parseResponse(
        response,
      );
    } on http.ClientException {
      throw const ApiException(
        '无法连接服务器，请检查后端是否已经启动',
      );
    } on SocketException {
      throw const ApiException(
        '无法连接服务器，请检查后端是否已经启动',
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
        ApiConfig.baseUrl;

    final base =
    configuredBase.endsWith('/')
        ? configuredBase.substring(
      0,
      configuredBase.length -
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

    if (queryParameters == null ||
        queryParameters.isEmpty) {
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
    Map<String, dynamic> data =
    const {};

    if (response.body.isNotEmpty) {
      try {
        final decoded =
        jsonDecode(
          response.body,
        );

        if (decoded
        is Map<String, dynamic>) {
          data = decoded;
        }
      } on FormatException {
        throw ApiException(
          '服务器返回了无法解析的数据',
          statusCode:
          response.statusCode,
        );
      }
    }

    if (response.statusCode >=
        200 &&
        response.statusCode <
            300) {
      return data;
    }

    final message =
    data['error'];

    throw ApiException(
      message is String &&
          message.isNotEmpty
          ? message
          : '请求失败 '
          '(${response.statusCode})',
      statusCode:
      response.statusCode,
    );
  }

  // ============================================================
  // Image
  // ============================================================

  _ImageUploadInfo _detectImageType(
      String filePath,
      ) {
    final normalized =
    filePath.toLowerCase();

    if (normalized.endsWith(
      '.png',
    )) {
      return const _ImageUploadInfo(
        contentType: 'image/png',
        fileName: 'clothing.png',
      );
    }

    if (normalized.endsWith(
      '.webp',
    )) {
      return const _ImageUploadInfo(
        contentType: 'image/webp',
        fileName: 'clothing.webp',
      );
    }

    if (normalized.endsWith(
      '.jpg',
    ) ||
        normalized.endsWith(
          '.jpeg',
        )) {
      return const _ImageUploadInfo(
        contentType: 'image/jpeg',
        fileName: 'clothing.jpg',
      );
    }

    throw const ApiException(
      '仅支持 JPG、PNG 或 WebP 图片',
    );
  }
}

class _ImageUploadInfo {
  final String contentType;
  final String fileName;

  const _ImageUploadInfo({
    required this.contentType,
    required this.fileName,
  });
}

/// API 异常
class ApiException
    implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(
      this.message, {
        this.statusCode,
      });

  @override
  String toString() =>
      message;
}