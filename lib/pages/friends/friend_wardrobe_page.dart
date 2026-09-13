import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/clothing.dart';
import '../../services/friend_service.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/clothing_card.dart';

class FriendWardrobePage
    extends StatefulWidget {
  final AppUser user;

  const FriendWardrobePage({
    super.key,
    required this.user,
  });

  @override
  State<FriendWardrobePage>
  createState() =>
      _FriendWardrobePageState();
}

class _FriendWardrobePageState
    extends State<FriendWardrobePage> {
  final FriendService _friendService =
      FriendService.instance;

  final RecommendationService
  _recommendationService =
      RecommendationService.instance;

  /// 当前真正从好友衣柜 API
  /// 读取到的公开衣物。
  List<Clothing> _clothes =
  const [];

  bool _isLoading = true;

  String? _loadError;

  bool _selecting = false;

  final Set<String>
  _selectedClothingIds = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(
      _loadClothes,
    );
  }

  // ============================================================
  // Load friend wardrobe
  // ============================================================

  Future<void> _loadClothes() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final clothes =
      await _friendService
          .fetchFriendClothing(
        widget.user.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _clothes =
            clothes;

        /// 刷新后可能某件衣物已经
        /// 不再公开，所以清掉无效选择。
        final validIds =
        clothes
            .map(
              (item) =>
          item.id,
        )
            .toSet();

        _selectedClothingIds
            .removeWhere(
              (id) =>
          !validIds
              .contains(
            id,
          ),
        );
      });
    } on FriendException catch (e) {
      if (mounted) {
        setState(() {
          _loadError =
              e.message;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading =
          false;
        });
      }
    }
  }

  // ============================================================
  // Selection
  // ============================================================

  List<Clothing>
  get _selectedClothes {
    return _clothes
        .where(
          (item) =>
          _selectedClothingIds
              .contains(
            item.id,
          ),
    )
        .toList(
      growable: false,
    );
  }

  void _toggleSelection(
      Clothing clothing,
      ) {
    setState(() {
      if (_selectedClothingIds
          .contains(
        clothing.id,
      )) {
        _selectedClothingIds.remove(
          clothing.id,
        );
      } else {
        _selectedClothingIds.add(
          clothing.id,
        );
      }
    });
  }

  // ============================================================
  // Recommendation
  // ============================================================

  Future<void>
  _startRecommendation() async {
    try {
      /// 推荐之前再确认双方仍是好友。
      final status =
      await _friendService
          .refreshFriendStatus(
        widget.user.id,
      );

      if (!mounted) {
        return;
      }

      if (status !=
          FriendStatus.friends) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              '只有好友之间才能进行衣物推荐',
            ),
          ),
        );

        return;
      }

      setState(() {
        _selecting =
        true;

        _selectedClothingIds
            .clear();
      });
    } on FriendException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(e.message),
        ),
      );
    }
  }

  void _cancelSelection() {
    setState(() {
      _selecting =
      false;

      _selectedClothingIds
          .clear();
    });
  }

  Future<void>
  _showRecommendationDialog() async {
    if (_selectedClothes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            '请至少选择一件衣物',
          ),
        ),
      );

      return;
    }

    final message =
    await showDialog<String>(
      context: context,
      builder:
          (dialogContext) {
        return _RecommendationMessageDialog(
          username:
          widget.user.username,
          clothingCount:
          _selectedClothes.length,
        );
      },
    );

    if (!mounted ||
        message == null ||
        message.isEmpty) {
      return;
    }

    await _sendRecommendation(
      message,
    );
  }

  Future<void> _sendRecommendation(
      String message,
      ) async {
    try {
      await _recommendationService
          .sendRecommendation(
        toUserId:
        widget.user.id,
        clothes:
        _selectedClothes,
        message:
        message,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selecting =
        false;

        _selectedClothingIds
            .clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            '衣物推荐已发送',
          ),
        ),
      );
    } on RecommendationException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(e.message),
        ),
      );
    }
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.user.username}的衣柜',
        ),
        actions: [
          if (!_selecting)
            TextButton.icon(
              onPressed:
              _isLoading
                  ? null
                  : _startRecommendation,
              icon:
              const Icon(
                Icons
                    .card_giftcard_outlined,
              ),
              label:
              const Text(
                '推荐',
              ),
            )
          else
            TextButton(
              onPressed:
              _cancelSelection,
              child:
              const Text(
                '取消',
              ),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar:
      _selecting
          ? SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.all(
            12,
          ),
          child:
          FilledButton.icon(
            onPressed:
            _showRecommendationDialog,
            icon:
            const Icon(
              Icons
                  .send_outlined,
            ),
            label: Text(
              _selectedClothes
                  .isEmpty
                  ? '请选择衣物'
                  : '推荐 '
                  '${_selectedClothes.length} '
                  '件衣物',
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(
            32,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .error_outline,
                size: 56,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                _loadError!,
                textAlign:
                TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton(
                onPressed:
                _loadClothes,
                child:
                const Text(
                  '重新加载',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
      _loadClothes,
      child: _clothes.isEmpty
          ? ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(
              context,
            ).size.height *
                0.65,
            child:
            _buildEmptyState(),
          ),
        ],
      )
          : GridView.builder(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.all(
          12,
        ),
        itemCount:
        _clothes.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing:
          10,
          mainAxisSpacing:
          10,
          childAspectRatio:
          0.72,
        ),
        itemBuilder:
            (
            context,
            index,
            ) {
          return _buildClothingItem(
            _clothes[
            index
            ],
          );
        },
      ),
    );
  }

  Widget _buildClothingItem(
      Clothing clothing,
      ) {
    final selected =
    _selectedClothingIds
        .contains(
      clothing.id,
    );

    return GestureDetector(
      onTap: () {
        if (_selecting) {
          _toggleSelection(
            clothing,
          );
        }

        /// 当前好友衣柜暂时只负责展示和推荐。
        ///
        /// 后续如果要做好友衣物详情页，
        /// 可以在非 selecting 状态下
        /// Navigator.push 到专用只读详情页。
      },
      child: Stack(
        children: [
          Positioned.fill(
            child:
            ClothingCard(
              clothing:
              clothing,
            ),
          ),

          if (_selecting)
            Positioned(
              top: 8,
              right: 8,
              child:
              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds:
                  150,
                ),
                width: 30,
                height: 30,
                decoration:
                BoxDecoration(
                  color: selected
                      ? Theme.of(
                    context,
                  )
                      .colorScheme
                      .primary
                      : Colors.white,
                  shape:
                  BoxShape.circle,
                  border:
                  Border.all(
                    color: selected
                        ? Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary
                        : Colors
                        .grey
                        .shade400,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                  Icons.check,
                  size: 20,
                  color:
                  Colors.white,
                )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .checkroom_outlined,
              size: 64,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              '这个衣柜暂时没有公开衣物',
              style:
              Theme.of(
                context,
              )
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '只有设置为 Public 的衣物才能被好友看到。',
              textAlign:
              TextAlign.center,
              style:
              Theme.of(
                context,
              )
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// 推荐留言弹窗
/// ============================================================
///
/// 推荐系统目前仍然是你的原有模块，
/// 本次只把好友关系和好友衣柜迁移到后端。
class _RecommendationMessageDialog
    extends StatefulWidget {
  final String username;

  final int clothingCount;

  const _RecommendationMessageDialog({
    required this.username,
    required this.clothingCount,
  });

  @override
  State<_RecommendationMessageDialog>
  createState() =>
      _RecommendationMessageDialogState();
}

class _RecommendationMessageDialogState
    extends State<_RecommendationMessageDialog> {
  late final TextEditingController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _send() {
    final message =
    _controller.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            '请输入推荐留言',
          ),
        ),
      );

      return;
    }

    Navigator.of(
      context,
    ).pop(
      message,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return AlertDialog(
      title: Text(
        '给 ${widget.username} 的推荐',
      ),
      content: Column(
        mainAxisSize:
        MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Text(
            '已选择 '
                '${widget.clothingCount} '
                '件衣物',
          ),

          const SizedBox(
            height: 16,
          ),

          TextField(
            controller:
            _controller,
            maxLines: 5,
            maxLength: 200,
            autofocus: true,
            textInputAction:
            TextInputAction
                .newline,
            decoration:
            const InputDecoration(
              hintText:
              '捎一句话吧，例如：这星期天气转凉了，记得穿这些衣服。',
              border:
              OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop();
          },
          child:
          const Text(
            '取消',
          ),
        ),

        FilledButton(
          onPressed:
          _send,
          child:
          const Text(
            '发送推荐',
          ),
        ),
      ],
    );
  }
}