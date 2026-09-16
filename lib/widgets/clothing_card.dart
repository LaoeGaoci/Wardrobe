import 'package:flutter/material.dart';

import '../l10n/clothing_localizations.dart';
import '../models/clothing/clothing.dart';
import 'wardrobe_image.dart';

class ClothingCard extends StatelessWidget {
  final Clothing clothing;

  const ClothingCard({super.key, required this.clothing});

  @override
  Widget build(BuildContext context) {
    final subCategory = localizedCategory(context, clothing.category);

    final season = localizedSeason(context, clothing.season);

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
              memCacheWidth: 720,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 类型
                Text(
                  subCategory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                // 季节 · 位置
                Text(
                  '$season · ${clothing.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
