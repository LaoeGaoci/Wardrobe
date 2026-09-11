import 'package:flutter/material.dart';

import '../../models/clothing.dart';
import '../../models/clothing_recommendation.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/clothing_card.dart';

class RecommendationEnvelopeDialog
    extends StatefulWidget {
  final ClothingRecommendation recommendation;

  const RecommendationEnvelopeDialog({
    super.key,
    required this.recommendation,
  });

  @override
  State<RecommendationEnvelopeDialog>
  createState() =>
      _RecommendationEnvelopeDialogState();
}

class _RecommendationEnvelopeDialogState
    extends State<RecommendationEnvelopeDialog> {
  bool _opened = false;

  final RecommendationService _service =
      RecommendationService.instance;

  @override
  Widget build(BuildContext context) {
    final sender =
    _service.getSender(widget.recommendation);

    final clothes =
    _service.getClothes(widget.recommendation);

    return Dialog(
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: _opened
            ? _buildOpenedLetter(
          sender?.username ?? '好友',
          clothes,
        )
            : _buildEnvelope(sender?.username ?? '好友'),
      ),
    );
  }

  Widget _buildEnvelope(String senderName) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.mail_outline,
            size: 96,
          ),

          const SizedBox(height: 20),

          Text(
            '你收到一封衣物推荐',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            '$senderName 给你寄来了一封信',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          FilledButton.icon(
            onPressed: () {
              setState(() {
                _opened = true;
              });

              _service.markAsRead(
                widget.recommendation.id,
              );
            },
            icon: const Icon(
              Icons.markunread_outlined,
            ),
            label: const Text('拆开信件'),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenedLetter(
      String senderName,
      List<Clothing> clothes,
      ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.mail_outline,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '来自 $senderName 的推荐',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(16),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: Text(
                widget.recommendation.message,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '推荐衣物',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: clothes.isEmpty
                  ? const Center(
                child: Text('推荐的衣物已经不存在了'),
              )
                  : GridView.builder(
                itemCount: clothes.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  return ClothingCard(
                    clothing: clothes[index],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('收好这封信'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}