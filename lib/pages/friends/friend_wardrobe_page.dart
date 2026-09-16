import 'package:flutter/material.dart';

import '../../l10n/clothing_localizations.dart';
import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/user/app_user.dart';
import '../../models/clothing/clothing.dart';
import '../../services/friends/friend_service.dart';
import '../../services/clothing/image_cache_service.dart';
import '../../services/friends/recommendation_service.dart';
import '../../widgets/clothing_card.dart';

class FriendWardrobePage extends StatefulWidget {
  final AppUser user;

  const FriendWardrobePage({super.key, required this.user});

  @override
  State<FriendWardrobePage> createState() => _FriendWardrobePageState();
}

class _FriendWardrobePageState extends State<FriendWardrobePage> {
  static const String _allSubCategoriesValue = '__all_sub_categories__';

  final FriendService _friendService = FriendService.instance;
  final RecommendationService _recommendationService =
      RecommendationService.instance;
  final ImageCacheService _imageCacheService = ImageCacheService.instance;

  List<Clothing> _clothes = const [];

  bool _isLoading = true;
  String? _loadError;

  bool _selecting = false;
  final Set<String> _selectedClothingIds = {};

  String _searchKeyword = '';
  String _selectedMainCategory = 'all';
  String? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadClothes);
  }

  // ============================================================
  // Load
  // ============================================================

  Future<void> _loadClothes() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final clothes = await _friendService.fetchFriendClothing(widget.user.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _clothes = clothes;

        final validIds = clothes.map((item) => item.id).toSet();
        _selectedClothingIds.removeWhere((id) => !validIds.contains(id));

        // 刷新后如果当前二级分类已经不存在，自动清除二级筛选。
        if (_selectedSubCategory != null &&
            !clothes.any(
              (item) =>
                  item.category == _selectedSubCategory &&
                  mainCategoryIdFor(item.category) == _selectedMainCategory,
            )) {
          _selectedSubCategory = null;
        }
      });
    } on FriendException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // Filter
  // ============================================================

  List<Clothing> get _filteredClothes {
    Iterable<Clothing> result = _clothes;

    // 一级分类。
    if (_selectedMainCategory != 'all') {
      result = result.where(
        (item) => mainCategoryIdFor(item.category) == _selectedMainCategory,
      );
    }

    // 二级分类。
    if (_selectedSubCategory != null) {
      result = result.where((item) => item.category == _selectedSubCategory);
    }

    // 搜索。
    final keyword = _searchKeyword.trim().toLowerCase();

    if (keyword.isNotEmpty) {
      result = result.where((item) {
        final location = item.location.toLowerCase();
        final brand = (item.brand ?? '').toLowerCase();
        final color = item.color.toLowerCase();
        final rawCategory = item.category.toLowerCase();
        final rawSeason = item.season.toLowerCase();

        final subCategory = localizedCategory(
          context,
          item.category,
        ).toLowerCase();

        final categoryPath = localizedCategoryPath(
          context,
          item.category,
        ).toLowerCase();

        final season = localizedSeason(context, item.season).toLowerCase();

        final mainCategoryId = mainCategoryIdFor(item.category);
        final mainCategory = mainCategoryId == null
            ? ''
            : localizedMainCategory(context, mainCategoryId).toLowerCase();

        return location.contains(keyword) ||
            brand.contains(keyword) ||
            color.contains(keyword) ||
            rawCategory.contains(keyword) ||
            rawSeason.contains(keyword) ||
            subCategory.contains(keyword) ||
            categoryPath.contains(keyword) ||
            mainCategory.contains(keyword) ||
            season.contains(keyword);
      });
    }

    return result.toList(growable: false);
  }

  List<String> get _availableSubCategoryIds {
    if (_selectedMainCategory == 'all') {
      return const [];
    }

    final result = _clothes
        .where(
          (item) => mainCategoryIdFor(item.category) == _selectedMainCategory,
        )
        .map((item) => item.category)
        .toSet()
        .toList();

    result.sort(
      (a, b) => localizedCategory(
        context,
        a,
      ).compareTo(localizedCategory(context, b)),
    );

    return result;
  }

  void _selectMainCategory(String categoryId) {
    setState(() {
      _selectedMainCategory = categoryId;

      // 一级分类改变后，原来的二级分类筛选已经不再适用。
      _selectedSubCategory = null;
    });
  }

  Future<void> _showSubCategoryFilter() async {
    if (_selectedMainCategory == 'all') {
      return;
    }

    final subCategories = _availableSubCategoryIds;

    if (subCategories.isEmpty) {
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final selectedValue = _selectedSubCategory ?? _allSubCategoriesValue;

        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          localizedMainCategory(
                            sheetContext,
                            _selectedMainCategory,
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildSubCategoryTile(
                        sheetContext,
                        value: _allSubCategoriesValue,
                        selectedValue: selectedValue,
                        label: sheetContext.l10n.categoryAll,
                      ),
                      for (final categoryId in subCategories)
                        _buildSubCategoryTile(
                          sheetContext,
                          value: categoryId,
                          selectedValue: selectedValue,
                          label: localizedCategory(sheetContext, categoryId),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedSubCategory = selected == _allSubCategoriesValue
          ? null
          : selected;
    });
  }

  Widget _buildSubCategoryTile(
    BuildContext sheetContext, {
    required String value,
    required String selectedValue,
    required String label,
  }) {
    final selected = value == selectedValue;
    final colorScheme = Theme.of(sheetContext).colorScheme;

    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      selected: selected,
      onTap: () {
        Navigator.pop(sheetContext, value);
      },
    );
  }

  // ============================================================
  // Recommendation selection
  // ============================================================

  List<Clothing> get _selectedClothes {
    // 必须基于完整好友衣柜，而不是当前筛选结果。
    // 这样用户切换分类后，之前已经勾选的衣物不会丢失。
    return _clothes
        .where((item) => _selectedClothingIds.contains(item.id))
        .toList(growable: false);
  }

  void _toggleSelection(Clothing clothing) {
    setState(() {
      if (_selectedClothingIds.contains(clothing.id)) {
        _selectedClothingIds.remove(clothing.id);
      } else {
        _selectedClothingIds.add(clothing.id);
      }
    });
  }

  Future<void> _startRecommendation() async {
    try {
      final status = await _friendService.refreshFriendStatus(widget.user.id);

      if (!mounted) {
        return;
      }

      if (status != FriendStatus.friends) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.onlyFriendsCanRecommend)),
        );
        return;
      }

      setState(() {
        _selecting = true;
        _selectedClothingIds.clear();
      });
    } on FriendException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedErrorMessage(context, e.message))),
      );
    }
  }

  void _cancelSelection() {
    setState(() {
      _selecting = false;
      _selectedClothingIds.clear();
    });
  }

  Future<void> _showRecommendationDialog() async {
    if (_selectedClothes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.selectAtLeastOne)));
      return;
    }

    final message = await showDialog<String>(
      context: context,
      builder: (_) => _RecommendationMessageDialog(
        username: widget.user.username,
        clothingCount: _selectedClothes.length,
      ),
    );

    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    await _sendRecommendation(message);
  }

  Future<void> _sendRecommendation(String message) async {
    try {
      await _recommendationService.sendRecommendation(
        toUserId: widget.user.id,
        clothes: _selectedClothes,
        message: message,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selecting = false;
        _selectedClothingIds.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.recommendationSent)));
    } on RecommendationException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedErrorMessage(context, e.message))),
      );
    }
  }

  // ============================================================
  // Image cache
  // ============================================================

  void _scheduleImagePrefetch(List<Clothing> clothes, int index) {
    if (index != 0 && (index + 1) % 6 != 0) {
      return;
    }

    _imageCacheService.schedulePrecacheAhead(
      context,
      clothes,
      currentIndex: index,
      count: 6,
      maxWidth: 720,
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.friendWardrobe(widget.user.username)),
        actions: [
          if (!_selecting)
            TextButton.icon(
              onPressed: _isLoading ? null : _startRecommendation,
              icon: const Icon(Icons.card_giftcard_outlined),
              label: Text(l10n.recommend),
            )
          else
            TextButton(onPressed: _cancelSelection, child: Text(l10n.cancel)),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _selecting
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: _showRecommendationDialog,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(
                    _selectedClothes.isEmpty
                        ? l10n.selectClothing
                        : l10n.recommendItemCount(_selectedClothes.length),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 16),
              Text(
                localizedErrorMessage(context, _loadError!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadClothes,
                child: Text(context.l10n.reload),
              ),
            ],
          ),
        ),
      );
    }

    if (_clothes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadClothes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: _buildEmptyState(),
            ),
          ],
        ),
      );
    }

    return _buildWardrobeContent();
  }

  Widget _buildWardrobeContent() {
    final clothes = _filteredClothes;

    return RefreshIndicator(
      onRefresh: _loadClothes,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ====================================================
          // Search
          // ====================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchKeyword = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: context.l10n.searchClothing,
                  prefixIcon: const Icon(Icons.search),

                  // 只有选择一级分类后才显示二级筛选按钮。
                  suffixIcon: _selectedMainCategory == 'all'
                      ? null
                      : _buildSubCategoryFilterButton(),

                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
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
          ),

          // ====================================================
          // Main categories
          // ====================================================
          SliverToBoxAdapter(
            child: SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: clothingMainCategoryIds.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final categoryId = index == 0
                      ? 'all'
                      : clothingMainCategoryIds[index - 1];

                  final label = categoryId == 'all'
                      ? context.l10n.categoryAll
                      : localizedMainCategory(context, categoryId);

                  return ChoiceChip(
                    label: Text(label),
                    selected: _selectedMainCategory == categoryId,
                    onSelected: (_) {
                      _selectMainCategory(categoryId);
                    },
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ====================================================
          // Clothing grid
          // ====================================================
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: clothes.isEmpty
                ? SliverToBoxAdapter(child: _buildFilteredEmptyState())
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final clothing = clothes[index];

                      _scheduleImagePrefetch(clothes, index);

                      return _buildClothingItem(clothing);
                    }, childCount: clothes.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryFilterButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final active = _selectedSubCategory != null;

    return IconButton(
      tooltip: context.l10n.category,
      onPressed: _availableSubCategoryIds.isEmpty
          ? null
          : _showSubCategoryFilter,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            active ? Icons.filter_alt : Icons.filter_alt_outlined,
            color: active ? colorScheme.primary : null,
          ),
          if (active)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.filter_alt_off_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.noClothing,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClothingItem(Clothing clothing) {
    final selected = _selectedClothingIds.contains(clothing.id);

    return GestureDetector(
      onTap: () {
        if (_selecting) {
          _toggleSelection(clothing);
        }
      },
      child: Stack(
        children: [
          Positioned.fill(child: ClothingCard(clothing: clothing)),
          if (_selecting)
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checkroom_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.noPublicClothing,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onlyPublicVisible,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationMessageDialog extends StatefulWidget {
  final String username;
  final int clothingCount;

  const _RecommendationMessageDialog({
    required this.username,
    required this.clothingCount,
  });

  @override
  State<_RecommendationMessageDialog> createState() =>
      _RecommendationMessageDialogState();
}

class _RecommendationMessageDialogState
    extends State<_RecommendationMessageDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final message = _controller.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recommendationMessageRequired)),
      );
      return;
    }

    Navigator.of(context).pop(message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.recommendationFor(widget.username)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectedItems(widget.clothingCount)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 5,
            maxLength: 200,
            autofocus: true,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: l10n.recommendationMessageHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _send, child: Text(l10n.sendRecommendation)),
      ],
    );
  }
}
