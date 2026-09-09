import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/clothing.dart';
import '../../widgets/info_row.dart';

class ClothingDetailPage extends StatelessWidget {
  final Clothing clothing;

  const ClothingDetailPage({
    super.key,
    required this.clothing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('衣物详情'),
      ),
      body: ListView(
        children: [
          _buildImage(),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  clothing.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                InfoRow(
                  title: '品牌',
                  value: clothing.brand ?? '未设置',
                ),

                InfoRow(
                  title: '类别',
                  value: clothing.category,
                ),

                InfoRow(
                  title: '颜色',
                  value: clothing.color,
                ),

                InfoRow(
                  title: '季节',
                  value: clothing.season,
                ),

                InfoRow(
                  title: '价格',
                  value: clothing.price == null
                      ? '未设置'
                      : '¥${clothing.price}',
                ),

                InfoRow(
                  title: '可见性',
                  value:
                  clothing.visibility ==
                      ClothingVisibility.public
                      ? 'Public'
                      : 'Private',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (clothing.imageType ==
        ClothingImageType.local) {
      return Image.file(
        File(clothing.imagePath),
        height: 420,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }

    return Image.network(
      clothing.imagePath,
      height: 420,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) {
        return _buildImageError();
      },
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 420,
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 56,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}