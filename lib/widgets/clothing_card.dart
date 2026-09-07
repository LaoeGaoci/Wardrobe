import 'package:flutter/material.dart';

import '../models/clothing.dart';

class ClothingCard extends StatelessWidget {
  final Clothing clothing;

  const ClothingCard({
    super.key,
    required this.clothing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              clothing.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Icon(
                      Icons
                          .image_not_supported_outlined,
                      color: Colors.grey.shade400,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  clothing.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${clothing.brand} · ${clothing.category}',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
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