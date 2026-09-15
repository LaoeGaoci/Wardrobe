import 'package:flutter/material.dart';

import '../l10n/clothing_localizations.dart';
import '../models/clothing.dart';
import 'wardrobe_image.dart';

class ClothingCard extends StatelessWidget {
  final Clothing clothing;

  const ClothingCard({
    super.key,
    required this.clothing,
  });

  @override
  Widget build(BuildContext context) {
    final category = localizedCategory(
      context,
      clothing.category,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: WardrobeClothingImage(
              clothing: clothing,
              width: double.infinity,
              fit: BoxFit.cover,

              // Grid 缩略图无需按原始高分辨率解码进内存。
              // 720px 对双列衣柜已经足够，同时能降低滚动时的内存压力。
              memCacheWidth: 720,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clothing.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  clothing.brand == null || clothing.brand!.isEmpty
                      ? category
                      : '${clothing.brand} · $category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
