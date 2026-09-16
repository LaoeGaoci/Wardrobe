import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/clothing/clothing.dart';
import '../../network/api_client.dart';
import '../users/auth_service.dart';

/// Wardrobe 图片缓存 / 预加载服务。
///
/// 负责：
/// - 统一生成 CachedNetworkImageProvider
/// - 给需要认证的图片自动加 Bearer Token
/// - 用用户 ID 隔离需要认证的磁盘缓存
/// - 使用 updatedAt 版本参数让换图后自动失效旧缓存
/// - 预加载下一屏图片到磁盘缓存 + Flutter ImageCache
class ImageCacheService {
  ImageCacheService._() {
    _sessionUserId = AuthService.instance.currentUser?.id;
    AuthService.instance.addListener(_handleAuthChanged);
  }

  static final ImageCacheService instance = ImageCacheService._();

  String? _sessionUserId;

  final Set<String> _preloadingKeys = <String>{};
  final Set<String> _preloadedKeys = <String>{};
  final Set<String> _scheduledKeys = <String>{};

  void _handleAuthChanged() {
    final nextUserId = AuthService.instance.currentUser?.id;

    if (nextUserId == _sessionUserId) {
      return;
    }

    _sessionUserId = nextUserId;
    resetRuntimeState();

    // CachedNetworkImageProvider 的 Flutter 内存层主要以 URL 为 key。
    // 切换账号时主动清空 ImageCache，避免同一 URL 的认证图片
    // 在不同账号会话之间继续留在内存中。
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }

  /// 构造统一的网络图片 Provider。
  ///
  /// [imagePath] 可以是后端返回的相对路径，也可以是完整 URL。
  /// [version] 通常传 clothing.updatedAt.millisecondsSinceEpoch。
  CachedNetworkImageProvider buildProvider({
    required String imagePath,
    String? version,
  }) {
    final request = _buildRequest(imagePath: imagePath, version: version);

    return CachedNetworkImageProvider(
      request.url,
      cacheKey: request.cacheKey,
      headers: request.headers,
    );
  }

  /// 预加载单件衣物图片。
  ///
  /// CachedNetworkImageProvider 会负责磁盘缓存；
  /// precacheImage 会同时把当前解码后的图片送进 Flutter ImageCache。
  Future<void> precacheClothing(
    BuildContext context,
    Clothing clothing, {
    int maxWidth = 720,
  }) async {
    if (!context.mounted ||
        clothing.imageType != ClothingImageType.remote ||
        clothing.imagePath.trim().isEmpty) {
      return;
    }

    final version = clothing.updatedAt.millisecondsSinceEpoch.toString();

    final request = _buildRequest(
      imagePath: clothing.imagePath,
      version: version,
    );

    final preloadKey = '${request.cacheKey}|w=$maxWidth';

    if (_preloadedKeys.contains(preloadKey) ||
        _preloadingKeys.contains(preloadKey)) {
      return;
    }

    _preloadingKeys.add(preloadKey);

    try {
      final networkProvider = CachedNetworkImageProvider(
        request.url,
        cacheKey: request.cacheKey,
        headers: request.headers,
      );

      // 磁盘缓存保留原图；这里只限制进入 Flutter ImageCache 的解码尺寸。
      // 这样列表预加载 720px 后，详情页仍然可以从同一份磁盘原图解码 1440px，
      // 不会因为第一次预加载缩略图而把磁盘缓存永久降成低分辨率。
      final memoryProvider = ResizeImage(networkProvider, width: maxWidth);

      await precacheImage(
        memoryProvider,
        context,
        onError: (_, __) {
          // 预加载失败不应该影响页面正常显示。
          // 真正进入屏幕时 WardrobeNetworkImage 会再次处理加载与错误状态。
        },
      );

      _preloadedKeys.add(preloadKey);
    } catch (_) {
      // 预加载属于优化行为，失败时静默降级到正常按需加载。
    } finally {
      _preloadingKeys.remove(preloadKey);
    }
  }

  /// 预加载某个列表中 [start] 开始的 [count] 张远程衣物图片。
  Future<void> precacheRange(
    BuildContext context,
    List<Clothing> clothes, {
    required int start,
    int count = 6,
    int maxWidth = 720,
  }) async {
    if (!context.mounted || clothes.isEmpty || count <= 0) {
      return;
    }

    final safeStart = start.clamp(0, clothes.length).toInt();
    final end = (safeStart + count).clamp(0, clothes.length).toInt();

    if (safeStart >= end) {
      return;
    }

    // 不一次性发起大量请求；一次只预取一小段。
    final futures = <Future<void>>[];

    for (var index = safeStart; index < end; index++) {
      futures.add(
        precacheClothing(context, clothes[index], maxWidth: maxWidth),
      );
    }

    await Future.wait(futures);
  }

  /// 在 Grid item build 完成后，预加载“下一屏”。
  ///
  /// 页面可以在 index == 0 或每 6 个 item 时调用。
  /// 此方法本身会去重，避免同一批图片反复安排预加载。
  void schedulePrecacheAhead(
    BuildContext context,
    List<Clothing> clothes, {
    required int currentIndex,
    int count = 6,
    int maxWidth = 720,
  }) {
    if (!context.mounted || clothes.isEmpty || count <= 0) {
      return;
    }

    final start = currentIndex + 1;

    if (start >= clothes.length) {
      return;
    }

    final end = (start + count).clamp(0, clothes.length).toInt();
    final batchKey = clothes
        .sublist(start, end)
        .map((item) => '${item.id}:${item.updatedAt.millisecondsSinceEpoch}')
        .join('|');

    final scheduleKey = '$batchKey|w=$maxWidth';

    if (!_scheduledKeys.add(scheduleKey)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        _scheduledKeys.remove(scheduleKey);
        return;
      }

      unawaited(
        precacheRange(
          context,
          clothes,
          start: start,
          count: count,
          maxWidth: maxWidth,
        ).whenComplete(() {
          // 本批调度结束后允许未来再次调度。
          // 已成功预加载的单图会被 _preloadedKeys 去重；
          // 失败的图片则有机会在网络恢复后重新预取。
          _scheduledKeys.remove(scheduleKey);
        }),
      );
    });
  }

  /// 清理“本次运行期间已经预加载”的记录。
  ///
  /// 注意：这里不会删除磁盘缓存，只清理服务内部的去重状态。
  void resetRuntimeState() {
    _preloadingKeys.clear();
    _preloadedKeys.clear();
    _scheduledKeys.clear();
  }

  _ImageRequest _buildRequest({required String imagePath, String? version}) {
    final rawPath = imagePath.trim();

    if (rawPath.isEmpty) {
      throw ArgumentError.value(
        imagePath,
        'imagePath',
        'Image path cannot be empty',
      );
    }

    final resolvedUrl = ApiClient.instance.resolveUrl(rawPath);
    final versionedUrl = _appendVersion(resolvedUrl, version);
    final needsAuthorization = _isWardrobeApiImage(rawPath, versionedUrl);

    final userId = AuthService.instance.currentUser?.id ?? 'anonymous';

    final cacheKey = needsAuthorization
        ? 'wardrobe-user:$userId:$versionedUrl'
        : 'wardrobe-public:$versionedUrl';

    return _ImageRequest(
      url: versionedUrl,
      cacheKey: cacheKey,
      headers: needsAuthorization
          ? ApiClient.instance.authorizationHeaders
          : const <String, String>{},
    );
  }

  String _appendVersion(String url, String? version) {
    if (version == null || version.isEmpty) {
      return url;
    }

    final uri = Uri.parse(url);

    return uri
        .replace(queryParameters: {...uri.queryParameters, 'v': version})
        .toString();
  }

  bool _isWardrobeApiImage(String originalPath, String resolvedUrl) {
    final originalUri = Uri.tryParse(originalPath);

    // 后端返回的相对 URL 一定属于 Wardrobe API。
    if (originalUri == null || !originalUri.hasScheme) {
      return true;
    }

    final apiUri = Uri.tryParse(ApiConfig.baseUrl);
    final imageUri = Uri.tryParse(resolvedUrl);

    if (apiUri == null ||
        imageUri == null ||
        !apiUri.hasAuthority ||
        !imageUri.hasAuthority) {
      return false;
    }

    return apiUri.scheme == imageUri.scheme &&
        apiUri.host == imageUri.host &&
        apiUri.port == imageUri.port;
  }
}

class _ImageRequest {
  final String url;
  final String cacheKey;
  final Map<String, String> headers;

  const _ImageRequest({
    required this.url,
    required this.cacheKey,
    required this.headers,
  });
}
