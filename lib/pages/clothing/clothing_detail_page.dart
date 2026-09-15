import 'package:flutter/material.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/clothing.dart';
import '../../services/clothing_repository.dart';
import '../../widgets/info_row.dart';
import '../../widgets/wardrobe_image.dart';
import 'edit_clothing_page.dart';

class ClothingDetailPage extends StatefulWidget {
  final Clothing clothing;

  const ClothingDetailPage({
    super.key,
    required this.clothing,
  });

  @override
  State<ClothingDetailPage> createState() =>
      _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  late Clothing _clothing;

  final ClothingRepository _repository = ClothingRepository.instance;

  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _clothing = widget.clothing;
  }

  Future<void> _editCard() async {
    final updated = await Navigator.push<Clothing>(
      context,
      MaterialPageRoute(
        builder: (_) => EditClothingPage(
          clothing: _clothing,
        ),
      ),
    );

    if (updated == null || !mounted) {
      return;
    }

    setState(() {
      _clothing = updated;
    });
  }

  Future<void> _deleteClothing() async {
    if (_deleting) {
      return;
    }

    final l10n = context.l10n;
    final subCategory = localizedCategory(
      context,
      _clothing.category,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          icon: Icon(
            Icons.delete_outline,
            color: colorScheme.error,
          ),
          title: Text(l10n.deleteClothing),
          content: Text(
            l10n.deleteClothingConfirm(
              subCategory,
              _clothing.location,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deleting = true;
    });

    try {
      await _repository.deleteClothing(_clothing.id);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } on ClothingRepositoryException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _deleting = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _deleting = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.deleteClothingFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subCategory = localizedCategory(
      context,
      _clothing.category,
    );
    final categoryPath = localizedCategoryPath(
      context,
      _clothing.category,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clothingDetails),
      ),
      body: ListView(
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subCategory,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                InfoRow(
                  title: l10n.storageLocation,
                  value: _clothing.location,
                ),
                InfoRow(
                  title: l10n.brand,
                  value: _clothing.brand ?? l10n.notSet,
                ),
                InfoRow(
                  title: l10n.category,
                  value: categoryPath,
                ),
                InfoRow(
                  title: l10n.color,
                  value: _clothing.color,
                ),
                InfoRow(
                  title: l10n.season,
                  value: localizedSeason(
                    context,
                    _clothing.season,
                  ),
                ),
                InfoRow(
                  title: l10n.price,
                  value: _clothing.price == null
                      ? l10n.notSet
                      : '¥${_clothing.price}',
                ),
                InfoRow(
                  title: l10n.visibility,
                  value: localizedVisibility(
                    context,
                    _clothing.visibility,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _deleting ? null : _editCard,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.editCard),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _deleting ? null : _deleteClothing,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    icon: _deleting
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                        : const Icon(Icons.delete_outline),
                    label: Text(
                      _deleting
                          ? l10n.deletingClothing
                          : l10n.deleteClothing,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return WardrobeClothingImage(
      clothing: _clothing,
      height: 420,
      width: double.infinity,
      fit: BoxFit.cover,
      memCacheWidth: 1440,
    );
  }
}
