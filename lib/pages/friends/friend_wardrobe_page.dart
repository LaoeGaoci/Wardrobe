import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/app_user.dart';
import '../../models/clothing.dart';
import '../../services/friend_service.dart';
import '../../services/image_cache_service.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/clothing_card.dart';

class FriendWardrobePage extends StatefulWidget {
  final AppUser user;

  const FriendWardrobePage({
    super.key,
    required this.user,
  });

  @override
  State<FriendWardrobePage> createState() => _FriendWardrobePageState();
}

class _FriendWardrobePageState extends State<FriendWardrobePage> {
  final FriendService _friendService = FriendService.instance;
  final RecommendationService _recommendationService =
      RecommendationService.instance;
  final ImageCacheService _imageCacheService =
      ImageCacheService.instance;

  List<Clothing> _clothes = const [];
  bool _isLoading = true;
  String? _loadError;
  bool _selecting = false;
  final Set<String> _selectedClothingIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadClothes);
  }

  Future<void> _loadClothes() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final clothes = await _friendService.fetchFriendClothing(widget.user.id);
      if (!mounted) return;

      setState(() {
        _clothes = clothes;
        final validIds = clothes.map((item) => item.id).toSet();
        _selectedClothingIds.removeWhere((id) => !validIds.contains(id));
      });
    } on FriendException catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.message;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Clothing> get _selectedClothes {
    return _clothes
        .where((item) => _selectedClothingIds.contains(item.id))
        .toList(growable: false);
  }

  void _scheduleImagePrefetch(int index) {
    if (index != 0 && (index + 1) % 6 != 0) {
      return;
    }

    _imageCacheService.schedulePrecacheAhead(
      context,
      _clothes,
      currentIndex: index,
      count: 6,
      maxWidth: 720,
    );
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
      if (!mounted) return;

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
      if (!mounted) return;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectAtLeastOne)),
      );
      return;
    }

    final message = await showDialog<String>(
      context: context,
      builder: (_) => _RecommendationMessageDialog(
        username: widget.user.username,
        clothingCount: _selectedClothes.length,
      ),
    );

    if (!mounted || message == null || message.isEmpty) return;
    await _sendRecommendation(message);
  }

  Future<void> _sendRecommendation(String message) async {
    try {
      await _recommendationService.sendRecommendation(
        toUserId: widget.user.id,
        clothes: _selectedClothes,
        message: message,
      );

      if (!mounted) return;
      setState(() {
        _selecting = false;
        _selectedClothingIds.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recommendationSent)),
      );
    } on RecommendationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedErrorMessage(context, e.message))),
      );
    }
  }

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
            TextButton(
              onPressed: _cancelSelection,
              child: Text(l10n.cancel),
            ),
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

    return RefreshIndicator(
      onRefresh: _loadClothes,
      child: _clothes.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: _buildEmptyState(),
                ),
              ],
            )
          : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: _clothes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                _scheduleImagePrefetch(index);

                return _buildClothingItem(
                  _clothes[index],
                );
              },
            ),
    );
  }

  Widget _buildClothingItem(Clothing clothing) {
    final selected = _selectedClothingIds.contains(clothing.id);

    return GestureDetector(
      onTap: () {
        if (_selecting) _toggleSelection(clothing);
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
        FilledButton(
          onPressed: _send,
          child: Text(l10n.sendRecommendation),
        ),
      ],
    );
  }
}
