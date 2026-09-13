import 'package:flutter/material.dart';

import '../../models/clothing.dart';
import '../../models/clothing_recommendation.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/clothing_card.dart';

/// ============================================================
/// RecommendationHistoryPage
/// ============================================================
///
/// 推荐历史记录页面。
///
/// 数据不保存在这个页面中。
///
/// 真实数据来源：
///
/// Cloudflare Worker
///      ↓
/// D1 recommendations
///      ↓
/// RecommendationService
///
/// 页面分成：
///
/// 1. 收到的推荐
/// 2. 发出的推荐
class RecommendationHistoryPage
    extends StatefulWidget {
  const RecommendationHistoryPage({
    super.key,
  });

  @override
  State<RecommendationHistoryPage>
  createState() =>
      _RecommendationHistoryPageState();
}

class _RecommendationHistoryPageState
    extends State<RecommendationHistoryPage>
    with SingleTickerProviderStateMixin {
  final RecommendationService
  _recommendationService =
      RecommendationService.instance;

  late final TabController
  _tabController;

  bool _isLoadingReceived = true;

  bool _isLoadingSent = true;

  String? _receivedError;

  String? _sentError;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(
          length: 2,
          vsync: this,
        );

    _recommendationService.addListener(
      _onRecommendationChanged,
    );

    /// 页面进入后同时请求：
    ///
    /// GET /received
    /// GET /sent
    Future.microtask(
      _loadAll,
    );
  }

  @override
  void dispose() {
    _recommendationService.removeListener(
      _onRecommendationChanged,
    );

    _tabController.dispose();

    super.dispose();
  }

  void _onRecommendationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // Load
  // ============================================================

  Future<void> _loadAll() async {
    await Future.wait([
      _loadReceived(),
      _loadSent(),
    ]);
  }

  /// GET /api/recommendations/received
  Future<void> _loadReceived() async {
    if (mounted) {
      setState(() {
        _isLoadingReceived = true;
        _receivedError = null;
      });
    }

    try {
      await _recommendationService
          .refreshReceivedRecommendations();
    } on RecommendationException catch (e) {
      if (mounted) {
        setState(() {
          _receivedError =
              e.message;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReceived = false;
        });
      }
    }
  }

  /// GET /api/recommendations/sent
  Future<void> _loadSent() async {
    if (mounted) {
      setState(() {
        _isLoadingSent = true;
        _sentError = null;
      });
    }

    try {
      await _recommendationService
          .refreshSentRecommendations();
    } on RecommendationException catch (e) {
      if (mounted) {
        setState(() {
          _sentError =
              e.message;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSent = false;
        });
      }
    }
  }

  // ============================================================
  // Open recommendation
  // ============================================================

  /// 打开收到的推荐。
  ///
  /// 如果当前推荐还是未读：
  ///
  /// PATCH /api/recommendations/:id/read
  ///
  /// 然后再显示详情。
  Future<void> _openReceived(
      ClothingRecommendation recommendation,
      ) async {
    var current =
        recommendation;

    if (!recommendation.isRead) {
      try {
        current =
        await _recommendationService
            .markAsRead(
          recommendation.id,
        );
      } on RecommendationException catch (e) {
        if (!mounted) {
          return;
        }

        _showError(
          e.message,
        );

        return;
      }
    }

    if (!mounted) {
      return;
    }

    await _showRecommendationDetail(
      recommendation: current,
      isReceived: true,
    );
  }

  /// 打开自己发出去的推荐。
  ///
  /// sender 不能执行 markAsRead，
  /// 所以这里只负责查看。
  Future<void> _openSent(
      ClothingRecommendation recommendation,
      ) async {
    await _showRecommendationDetail(
      recommendation: recommendation,
      isReceived: false,
    );
  }

  // ============================================================
  // Detail dialog
  // ============================================================

  Future<void>
  _showRecommendationDetail({
    required ClothingRecommendation
    recommendation,
    required bool isReceived,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 32,
          ),
          child:
          _RecommendationHistoryDetail(
            recommendation:
            recommendation,
            isReceived:
            isReceived,
          ),
        );
      },
    );
  }

  // ============================================================
  // Error
  // ============================================================

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
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
        title:
        const Text(
          '推荐记录',
        ),
        bottom: TabBar(
          controller:
          _tabController,
          tabs:
          const [
            Tab(
              text:
              '收到的推荐',
            ),
            Tab(
              text:
              '发出的推荐',
            ),
          ],
        ),
      ),

      body: TabBarView(
        controller:
        _tabController,
        children: [
          _buildReceivedTab(),
          _buildSentTab(),
        ],
      ),
    );
  }

  // ============================================================
  // Received
  // ============================================================

  Widget _buildReceivedTab() {
    if (_isLoadingReceived) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_receivedError != null) {
      return _buildErrorState(
        _receivedError!,
        _loadReceived,
      );
    }

    final recommendations =
        _recommendationService
            .receivedRecommendations;

    if (recommendations.isEmpty) {
      return _buildEmptyState(
        icon:
        Icons
            .mark_email_unread_outlined,
        title:
        '还没有收到推荐',
        subtitle:
        '好友给你发送的衣物推荐会出现在这里',
        onRefresh:
        _loadReceived,
      );
    }

    return RefreshIndicator(
      onRefresh:
      _loadReceived,
      child:
      ListView.separated(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding:
        const EdgeInsets.all(
          16,
        ),

        itemCount:
        recommendations.length,

        separatorBuilder:
            (_, __) =>
        const SizedBox(
          height: 10,
        ),

        itemBuilder:
            (
            context,
            index,
            ) {
          final recommendation =
          recommendations[
          index
          ];

          return _buildReceivedCard(
            recommendation,
          );
        },
      ),
    );
  }

  Widget _buildReceivedCard(
      ClothingRecommendation recommendation,
      ) {
    final sender =
        recommendation.fromUser;

    return Card(
      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          12,
        ),

        onTap: () =>
            _openReceived(
              recommendation,
            ),

        child: Padding(
          padding:
          const EdgeInsets.all(
            16,
          ),

          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // --------------------------------------------------
              // Read status
              // --------------------------------------------------

              Padding(
                padding:
                const EdgeInsets.only(
                  top: 8,
                ),

                child: Container(
                  width: 9,
                  height: 9,
                  decoration:
                  BoxDecoration(
                    shape:
                    BoxShape.circle,

                    color:
                    recommendation.isRead
                        ? Colors.transparent
                        : Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary,
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              _buildAvatar(
                sender.username,
                sender.avatarUrl,
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sender.username,

                            maxLines:
                            1,

                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),

                        _buildReadStatus(
                          recommendation.isRead
                              ? '已读'
                              : '未读',

                          highlighted:
                          !recommendation
                              .isRead,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      recommendation.message,

                      maxLines:
                      2,

                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .checkroom_outlined,

                          size: 16,

                          color:
                          Theme.of(
                            context,
                          )
                              .colorScheme
                              .onSurfaceVariant,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          '${recommendation.clothes.length} 件衣物',

                          style:
                          Theme.of(
                            context,
                          )
                              .textTheme
                              .bodySmall,
                        ),

                        const Spacer(),

                        Text(
                          _formatTime(
                            recommendation
                                .createdAt,
                          ),

                          style:
                          Theme.of(
                            context,
                          )
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 4,
              ),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Sent
  // ============================================================

  Widget _buildSentTab() {
    if (_isLoadingSent) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_sentError != null) {
      return _buildErrorState(
        _sentError!,
        _loadSent,
      );
    }

    final recommendations =
        _recommendationService
            .sentRecommendations;

    if (recommendations.isEmpty) {
      return _buildEmptyState(
        icon:
        Icons
            .outgoing_mail,
        title:
        '还没有发出推荐',
        subtitle:
        '你给好友发送过的衣物推荐会出现在这里',
        onRefresh:
        _loadSent,
      );
    }

    return RefreshIndicator(
      onRefresh:
      _loadSent,
      child:
      ListView.separated(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding:
        const EdgeInsets.all(
          16,
        ),

        itemCount:
        recommendations.length,

        separatorBuilder:
            (_, __) =>
        const SizedBox(
          height: 10,
        ),

        itemBuilder:
            (
            context,
            index,
            ) {
          final recommendation =
          recommendations[
          index
          ];

          return _buildSentCard(
            recommendation,
          );
        },
      ),
    );
  }

  Widget _buildSentCard(
      ClothingRecommendation recommendation,
      ) {
    final receiver =
        recommendation.toUser;

    return Card(
      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          12,
        ),

        onTap: () =>
            _openSent(
              recommendation,
            ),

        child: Padding(
          padding:
          const EdgeInsets.all(
            16,
          ),

          child: Row(
            children: [
              _buildAvatar(
                receiver.username,
                receiver.avatarUrl,
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '发送给 ${receiver.username}',

                            maxLines:
                            1,

                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),

                        /// 这里 isRead 表示：
                        ///
                        /// 接收方有没有打开。
                        _buildReadStatus(
                          recommendation.isRead
                              ? '对方已读'
                              : '对方未读',

                          highlighted:
                          !recommendation
                              .isRead,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      recommendation.message,

                      maxLines:
                      2,

                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .checkroom_outlined,

                          size: 16,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          '${recommendation.clothes.length} 件衣物',

                          style:
                          Theme.of(
                            context,
                          )
                              .textTheme
                              .bodySmall,
                        ),

                        const Spacer(),

                        Text(
                          _formatTime(
                            recommendation
                                .createdAt,
                          ),

                          style:
                          Theme.of(
                            context,
                          )
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 4,
              ),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Common UI
  // ============================================================

  Widget _buildAvatar(
      String username,
      String avatarUrl,
      ) {
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage:
        NetworkImage(
          avatarUrl,
        ),
      );
    }

    return CircleAvatar(
      radius: 24,
      child: Text(
        username.isEmpty
            ? '?'
            : username
            .characters
            .first
            .toUpperCase(),
      ),
    );
  }

  Widget _buildReadStatus(
      String label, {
        required bool highlighted,
      }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),

      decoration:
      BoxDecoration(
        color: highlighted
            ? Theme.of(
          context,
        )
            .colorScheme
            .primaryContainer
            : Theme.of(
          context,
        )
            .colorScheme
            .surfaceContainerHighest,

        borderRadius:
        BorderRadius.circular(
          10,
        ),
      ),

      child: Text(
        label,

        style:
        Theme.of(
          context,
        )
            .textTheme
            .labelSmall,
      ),
    );
  }

  Widget _buildErrorState(
      String message,
      Future<void> Function() retry,
      ) {
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
              Icons.error_outline,
              size: 56,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              message,
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(
              height: 16,
            ),

            FilledButton(
              onPressed:
              retry,
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<void> Function()
    onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh:
      onRefresh,

      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height:
            MediaQuery.of(
              context,
            ).size.height *
                0.65,

            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  32,
                ),

                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,

                  children: [
                    Icon(
                      icon,
                      size: 58,
                      color:
                      Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      title,
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
                      subtitle,
                      textAlign:
                      TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Date
  // ============================================================

  String _formatTime(
      DateTime time,
      ) {
    final now =
    DateTime.now();

    final local =
    time.toLocal();

    final difference =
    now.difference(
      local,
    );

    if (!difference.isNegative) {
      if (difference.inMinutes <
          1) {
        return '刚刚';
      }

      if (difference.inHours <
          1) {
        return '${difference.inMinutes} 分钟前';
      }

      if (difference.inDays <
          1) {
        return '${difference.inHours} 小时前';
      }
    }

    final year =
    local.year
        .toString();

    final month =
    local.month
        .toString()
        .padLeft(
      2,
      '0',
    );

    final day =
    local.day
        .toString()
        .padLeft(
      2,
      '0',
    );

    final hour =
    local.hour
        .toString()
        .padLeft(
      2,
      '0',
    );

    final minute =
    local.minute
        .toString()
        .padLeft(
      2,
      '0',
    );

    return '$year-$month-$day $hour:$minute';
  }
}

/// ============================================================
/// Recommendation detail
/// ============================================================
///
/// 为了保持这次只增加一个文件，
/// 详情 Widget 直接放在历史页面文件内部。
class _RecommendationHistoryDetail
    extends StatelessWidget {
  final ClothingRecommendation
  recommendation;

  final bool isReceived;

  const _RecommendationHistoryDetail({
    required this.recommendation,
    required this.isReceived,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final otherUser =
    isReceived
        ? recommendation.fromUser
        : recommendation.toUser;

    return Padding(
      padding:
      const EdgeInsets.all(
        20,
      ),

      child: ConstrainedBox(
        constraints:
        const BoxConstraints(
          maxHeight: 650,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Icon(
                  isReceived
                      ? Icons
                      .mark_email_read_outlined
                      : Icons
                      .outgoing_mail,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    isReceived
                        ? '来自 ${otherUser.username} 的推荐'
                        : '发送给 ${otherUser.username} 的推荐',

                    style:
                    Theme.of(
                      context,
                    )
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),

                IconButton(
                  onPressed:
                      () =>
                      Navigator.pop(
                        context,
                      ),
                  icon:
                  const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.all(
                16,
              ),

              decoration:
              BoxDecoration(
                color:
                Theme.of(
                  context,
                )
                    .colorScheme
                    .surfaceContainerHighest,

                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),

              child: Text(
                recommendation.message,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Row(
              children: [
                Text(
                  '推荐衣物',

                  style:
                  Theme.of(
                    context,
                  )
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),

                const Spacer(),

                Text(
                  '${recommendation.clothes.length} 件',
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Expanded(
              child:
              recommendation
                  .clothes
                  .isEmpty
                  ? const Center(
                child: Text(
                  '推荐的衣物已经不存在了',
                ),
              )
                  : GridView.builder(
                itemCount:
                recommendation
                    .clothes
                    .length,

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                  2,
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
                  final clothing =
                  recommendation
                      .clothes[
                  index
                  ];

                  return ClothingCard(
                    clothing:
                    clothing,
                  );
                },
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            _buildStatusLine(
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLine(
      BuildContext context,
      ) {
    String status;

    if (isReceived) {
      status =
      recommendation.isRead
          ? '已读'
          : '未读';
    } else {
      status =
      recommendation.isRead
          ? '对方已读'
          : '对方未读';
    }

    return Row(
      children: [
        Icon(
          recommendation.isRead
              ? Icons
              .done_all
              : Icons
              .schedule,

          size: 18,

          color:
          Theme.of(
            context,
          )
              .colorScheme
              .onSurfaceVariant,
        ),

        const SizedBox(
          width: 6,
        ),

        Text(
          status,
        ),

        const Spacer(),

        Text(
          _formatDetailDate(
            recommendation.createdAt,
          ),
          style:
          Theme.of(
            context,
          )
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }

  String _formatDetailDate(
      DateTime time,
      ) {
    final local =
    time.toLocal();

    final year =
        local.year;

    final month =
    local.month
        .toString()
        .padLeft(
      2,
      '0',
    );

    final day =
    local.day
        .toString()
        .padLeft(
      2,
      '0',
    );

    final hour =
    local.hour
        .toString()
        .padLeft(
      2,
      '0',
    );

    final minute =
    local.minute
        .toString()
        .padLeft(
      2,
      '0',
    );

    return '$year-$month-$day $hour:$minute';
  }
}