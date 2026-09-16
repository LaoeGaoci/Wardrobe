import 'package:flutter/material.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/l10n.dart';

class ClothingCategoryPickerPage extends StatefulWidget {
  final String currentCategory;

  const ClothingCategoryPickerPage({super.key, required this.currentCategory});

  @override
  State<ClothingCategoryPickerPage> createState() =>
      _ClothingCategoryPickerPageState();
}

class _ClothingCategoryPickerPageState
    extends State<ClothingCategoryPickerPage> {
  final TextEditingController _searchController = TextEditingController();

  late String _selectedMainCategory;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedMainCategory =
        mainCategoryIdFor(widget.currentCategory) ??
        clothingMainCategoryIds.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectCategoryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchCategoryHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (!searching)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: clothingMainCategoryIds.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final mainCategoryId = clothingMainCategoryIds[index];

                  return ChoiceChip(
                    label: Text(localizedMainCategory(context, mainCategoryId)),
                    selected: mainCategoryId == _selectedMainCategory,
                    onSelected: (_) {
                      setState(() {
                        _selectedMainCategory = mainCategoryId;
                      });
                    },
                  );
                },
              ),
            ),
          if (!searching) const Divider(height: 16),
          Expanded(
            child: searching
                ? _buildSearchResults()
                : _buildCategoryList(_selectedMainCategory),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String mainCategoryId) {
    final categories =
        clothingCategoryHierarchy[mainCategoryId] ?? const <String>[];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) {
        return _buildCategoryTile(categories[index], showMainCategory: false);
      },
    );
  }

  Widget _buildSearchResults() {
    final query = _query.trim().toLowerCase();
    final results = <String>[];

    for (final entry in clothingCategoryHierarchy.entries) {
      final mainCategoryLabel = localizedMainCategory(
        context,
        entry.key,
      ).toLowerCase();

      for (final categoryId in entry.value) {
        final subCategoryLabel = localizedCategory(
          context,
          categoryId,
        ).toLowerCase();
        final categoryPath = localizedCategoryPath(
          context,
          categoryId,
        ).toLowerCase();

        if (mainCategoryLabel.contains(query) ||
            subCategoryLabel.contains(query) ||
            categoryPath.contains(query) ||
            categoryId.toLowerCase().contains(query)) {
          results.add(categoryId);
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            context.l10n.noCategoryResults,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) {
        return _buildCategoryTile(results[index], showMainCategory: true);
      },
    );
  }

  Widget _buildCategoryTile(
    String categoryId, {
    required bool showMainCategory,
  }) {
    final mainCategoryId = mainCategoryIdFor(categoryId);
    final selected = categoryId == widget.currentCategory;

    return ListTile(
      leading: Icon(_iconForMainCategory(mainCategoryId)),
      title: Text(localizedCategory(context, categoryId)),
      subtitle: showMainCategory && mainCategoryId != null
          ? Text(localizedMainCategory(context, mainCategoryId))
          : null,
      trailing: selected
          ? Icon(
              Icons.check_rounded,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.pop(context, categoryId);
      },
    );
  }

  IconData _iconForMainCategory(String? mainCategoryId) {
    switch (mainCategoryId) {
      case 'tops':
        return Icons.checkroom_outlined;
      case 'bottoms':
        return Icons.view_agenda_outlined;
      case 'one_piece':
        return Icons.woman_2_outlined;
      case 'sets':
        return Icons.layers_outlined;
      case 'underwear':
        return Icons.dry_cleaning_outlined;
      case 'footwear':
        return Icons.directions_walk_outlined;
      case 'accessories':
        return Icons.style_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
