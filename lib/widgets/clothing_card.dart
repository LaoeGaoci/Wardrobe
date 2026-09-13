import 'dart:io';

import 'package:flutter/material.dart';

import '../models/clothing.dart';
import '../network/api_client.dart';

class ClothingCard
    extends StatelessWidget {
  final Clothing clothing;

  const ClothingCard({
    super.key,
    required this.clothing,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      clipBehavior:
      Clip.antiAlias,
      margin:
      EdgeInsets.zero,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Expanded(
            child:
            _buildImage(),
          ),
          Padding(
            padding:
            const EdgeInsets
                .all(
              10,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  clothing.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  clothing.brand ==
                      null ||
                      clothing
                          .brand!
                          .isEmpty
                      ? clothing
                      .category
                      : '${clothing.brand}'
                      ' · '
                      '${clothing.category}',
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  TextStyle(
                    color:
                    Colors
                        .grey
                        .shade600,
                    fontSize:
                    13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (clothing
        .imagePath
        .isEmpty) {
      return _buildImageError();
    }

    if (clothing.imageType ==
        ClothingImageType
            .local) {
      return Image.file(
        File(
          clothing.imagePath,
        ),
        width:
        double.infinity,
        fit:
        BoxFit.cover,
        errorBuilder:
            (
            context,
            error,
            stackTrace,
            ) {
          return _buildImageError();
        },
      );
    }

    final imageUrl =
    _buildRemoteImageUrl();

    return Image.network(
      imageUrl,
      headers:
      ApiClient
          .instance
          .authorizationHeaders,
      width:
      double.infinity,
      fit:
      BoxFit.cover,
      errorBuilder:
          (
          context,
          error,
          stackTrace,
          ) {
        return _buildImageError();
      },
    );
  }

  /// updatedAt 加入 query，
  /// 避免替换图片以后 Flutter
  /// 继续命中旧的 NetworkImage 缓存。
  String _buildRemoteImageUrl() {
    final resolved =
    ApiClient.instance
        .resolveUrl(
      clothing.imagePath,
    );

    final uri =
    Uri.parse(
      resolved,
    );

    return uri
        .replace(
      queryParameters: {
        ...uri
            .queryParameters,
        'v': clothing
            .updatedAt
            .millisecondsSinceEpoch
            .toString(),
      },
    )
        .toString();
  }

  Widget _buildImageError() {
    return Container(
      color:
      Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons
              .image_not_supported_outlined,
          color:
          Colors.grey.shade400,
          size: 40,
        ),
      ),
    );
  }
}