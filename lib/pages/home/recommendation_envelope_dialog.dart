import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/clothing.dart';
import '../../models/clothing_recommendation.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/clothing_card.dart';

class RecommendationEnvelopeDialog extends StatefulWidget {
  final ClothingRecommendation recommendation;

  const RecommendationEnvelopeDialog({
    super.key,
    required this.recommendation,
  });

  @override
  State<RecommendationEnvelopeDialog> createState() =>
      _RecommendationEnvelopeDialogState();
}

class _RecommendationEnvelopeDialogState
    extends State<RecommendationEnvelopeDialog> {
  final RecommendationService _service = RecommendationService.instance;

  bool _opened = false;
  bool _savingRead = false;

  void _openEnvelope() {
    setState(() => _opened = true);
  }

  Future<void> _closeLetter() async {
    if (_savingRead) return;

    setState(() => _savingRead = true);

    try {
      await _service.markAsRead(widget.recommendation.id);

      if (!mounted) return;
      Navigator.pop(context, true);
    } on RecommendationException catch (e) {
      if (!mounted) return;

      setState(() => _savingRead = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(localizedErrorMessage(context, e.message)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final senderName = widget.recommendation.fromUser.username;
    final clothes = widget.recommendation.clothes;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: _opened
            ? _buildOpenedLetter(senderName, clothes)
            : _buildEnvelope(senderName),
      ),
    );
  }

  Widget _buildEnvelope(String senderName) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mail_outline, size: 96),
          const SizedBox(height: 20),
          Text(
            l10n.receivedClothingRecommendation,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.senderSentLetter(senderName),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _openEnvelope,
            icon: const Icon(Icons.markunread_outlined),
            label: Text(l10n.openLetter),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenedLetter(String senderName, List<Clothing> clothes) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.drafts_outlined, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.recommendationFrom(senderName),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Text(
                widget.recommendation.message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.recommendedClothing,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: clothes.isEmpty
                  ? Center(child: Text(l10n.recommendationClothingMissing))
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
                        return ClothingCard(clothing: clothes[index]);
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _savingRead ? null : _closeLetter,
                icon: _savingRead
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.inventory_2_outlined),
                label: Text(
                  _savingRead ? l10n.storingLetter : l10n.keepLetter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
