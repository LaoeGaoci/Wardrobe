import 'dart:io';

import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

import '../models/app_user.dart';
import '../models/clothing.dart';
import '../services/image_cache_service.dart';

/// Wardrobe 通用网络图片组件。
///
/// 使用：
/// - CachedNetworkImageProvider：磁盘缓存
/// - Flutter ImageCache：内存缓存
/// - OctoImage：加载动画 / 淡入 / 错误占位
class WardrobeNetworkImage extends StatelessWidget {
  final String imagePath;
  final String? version;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final WidgetBuilder? placeholderBuilder;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )? errorBuilder;

  const WardrobeNetworkImage({
    super.key,
    required this.imagePath,
    this.version,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.trim().isEmpty) {
      return _buildDefaultError(context);
    }

    try {
      final provider = ImageCacheService.instance.buildProvider(
        imagePath: imagePath,
        version: version,
      );

      return OctoImage(
        image: provider,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        fadeInDuration: const Duration(milliseconds: 220),
        fadeInCurve: Curves.easeOut,
        fadeOutDuration: const Duration(milliseconds: 120),
        fadeOutCurve: Curves.easeOut,
        placeholderBuilder: placeholderBuilder,
        progressIndicatorBuilder: placeholderBuilder == null
            ? (context, progress) {
                double? value;

                final total = progress?.expectedTotalBytes;

                if (progress != null && total != null && total > 0) {
                  value = progress.cumulativeBytesLoaded / total;
                }

                return Container(
                  width: width,
                  height: height,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 2.2,
                    ),
                  ),
                );
              }
            : null,
        errorBuilder: (context, error, stackTrace) {
          final customBuilder = errorBuilder;

          if (customBuilder != null) {
            return customBuilder(
              context,
              error,
              stackTrace,
            );
          }

          return _buildDefaultError(context);
        },
      );
    } catch (_) {
      return _buildDefaultError(context);
    }
  }

  Widget _buildDefaultError(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Theme.of(context)
            .colorScheme
            .onSurfaceVariant,
      ),
    );
  }
}

/// Wardrobe 衣物图片统一组件。
///
/// local -> Image.file
/// remote -> CachedNetworkImageProvider + OctoImage
class WardrobeClothingImage extends StatelessWidget {
  final Clothing clothing;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const WardrobeClothingImage({
    super.key,
    required this.clothing,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (clothing.imagePath.trim().isEmpty) {
      return _buildError(context);
    }

    if (clothing.imageType == ClothingImageType.local) {
      return Image.file(
        File(clothing.imagePath),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (context, error, stackTrace) {
          return _buildError(context);
        },
      );
    }

    return WardrobeNetworkImage(
      imagePath: clothing.imagePath,
      version: clothing.updatedAt.millisecondsSinceEpoch.toString(),
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
    );
  }

  Widget _buildError(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Theme.of(context)
            .colorScheme
            .onSurfaceVariant,
      ),
    );
  }
}

/// Wardrobe 用户头像统一组件。
class WardrobeAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;
  final IconData? fallbackIcon;

  const WardrobeAvatar({
    super.key,
    required this.user,
    this.radius = 20,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final fallback = _AvatarFallback(
      user: user,
      size: size,
      fallbackIcon: fallbackIcon,
    );

    if (user.avatarUrl.trim().isEmpty) {
      return fallback;
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: WardrobeNetworkImage(
          imagePath: user.avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          memCacheWidth: (size * 2).round(),
          memCacheHeight: (size * 2).round(),
          placeholderBuilder: (_) => fallback,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final AppUser user;
  final double size;
  final IconData? fallbackIcon;

  const _AvatarFallback({
    required this.user,
    required this.size,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final icon = fallbackIcon;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        alignment: Alignment.center,
        child: icon != null
            ? Icon(
                icon,
                size: size * 0.56,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              )
            : Text(
                user.username.isEmpty
                    ? '?'
                    : user.username.characters.first.toUpperCase(),
                style: TextStyle(
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}
