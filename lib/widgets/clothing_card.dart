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
    final subCategory = localizedCategory(
      context,
      clothing.category,
    );

    final season = localizedSeason(
      context,
      clothing.season,
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
              memCacheWidth: 720,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '$season · $subCategory · ${clothing.location}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
