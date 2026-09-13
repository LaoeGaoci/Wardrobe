import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/clothing.dart';
import '../../network/api_client.dart';
import '../../widgets/info_row.dart';

import 'edit_clothing_page.dart';

class ClothingDetailPage
    extends StatefulWidget {
  final Clothing clothing;

  const ClothingDetailPage({
    super.key,
    required this.clothing,
  });

  @override
  State<ClothingDetailPage>
  createState() =>
      _ClothingDetailPageState();
}

class _ClothingDetailPageState
    extends State<ClothingDetailPage> {
  late Clothing _clothing;

  @override
  void initState() {
    super.initState();

    _clothing =
        widget.clothing;
  }

  // ============================================================
  // Edit
  // ============================================================

  Future<void> _editCard() async {
    final updated =
    await Navigator.push<Clothing>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditClothingPage(
              clothing:
              _clothing,
            ),
      ),
    );

    if (updated == null ||
        !mounted) {
      return;
    }

    setState(() {
      _clothing =
          updated;
    });
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '衣物详情',
        ),
      ),

      body: ListView(
        children: [
          _buildImage(),

          Padding(
            padding:
            const EdgeInsets.all(
              20,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  _clothing.name,
                  style:
                  const TextStyle(
                    fontSize: 26,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                InfoRow(
                  title: '品牌',
                  value:
                  _clothing.brand ??
                      '未设置',
                ),

                InfoRow(
                  title: '类别',
                  value:
                  _clothing.category,
                ),

                InfoRow(
                  title: '颜色',
                  value:
                  _clothing.color,
                ),

                InfoRow(
                  title: '季节',
                  value:
                  _clothing.season,
                ),

                InfoRow(
                  title: '价格',
                  value:
                  _clothing.price ==
                      null
                      ? '未设置'
                      : '¥${_clothing.price}',
                ),

                InfoRow(
                  title: '可见性',
                  value:
                  _clothing.visibility ==
                      ClothingVisibility
                          .public
                      ? 'Public'
                      : 'Private',
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton.icon(
                    onPressed:
                    _editCard,
                    icon:
                    const Icon(
                      Icons
                          .edit_outlined,
                    ),

                    /// 按你的要求：
                    /// 按钮文字固定为
                    /// “编辑卡片”
                    label:
                    const Text(
                      '编辑卡片',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Image
  // ============================================================

  Widget _buildImage() {
    if (_clothing
        .imagePath
        .isEmpty) {
      return _buildImageError();
    }

    if (_clothing.imageType ==
        ClothingImageType.local) {
      return Image.file(
        File(
          _clothing.imagePath,
        ),
        height: 420,
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

    return Image.network(
      _remoteImageUrl(),
      headers:
      ApiClient
          .instance
          .authorizationHeaders,
      height: 420,
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

  String _remoteImageUrl() {
    final resolved =
    ApiClient.instance
        .resolveUrl(
      _clothing.imagePath,
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
        'v': _clothing
            .updatedAt
            .millisecondsSinceEpoch
            .toString(),
      },
    )
        .toString();
  }

  Widget _buildImageError() {
    return Container(
      height: 420,
      color:
      Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons
              .image_not_supported_outlined,
          size: 56,
          color:
          Colors.grey.shade400,
        ),
      ),
    );
  }
}