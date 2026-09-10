import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/clothing.dart';
import '../../services/clothing_repository.dart';
import '../../widgets/clothing_card.dart';

class FriendWardrobePage extends StatelessWidget {
  final AppUser user;

  const FriendWardrobePage({
    super.key,
    required this.user,
  });

  List<Clothing> _getPublicClothes() {
    return ClothingRepository.instance.clothes
        .where(
          (item) =>
      item.ownerId == user.id &&
          item.visibility == ClothingVisibility.public,
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final clothes = _getPublicClothes();

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.username}的衣柜'),
      ),
      body: clothes.isEmpty
          ? _buildEmptyState(context)
          : _buildWardrobe(clothes),
    );
  }

  Widget _buildWardrobe(List<Clothing> clothes) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: clothes.length,
      itemBuilder: (context, index) {
        return ClothingCard(
          clothing: clothes[index],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '这个衣柜暂时没有公开衣物',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '只有设置为 Public 的衣物才能被好友看到。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}