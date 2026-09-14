import 'package:flutter/material.dart';

import '../../models/clothing_recommendation.dart';
import '../../services/recommendation_service.dart';

import '../friends/friends_page.dart';
import '../profile/profile.dart';

import 'recommendation_envelope_dialog.dart';
import 'wardrobe_page.dart';

import '../../services/friend_service.dart';

class HomePage
    extends StatefulWidget {
  final ValueChanged<bool>
  onThemeChanged;

  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {
  int selectedIndex = 0;

  final RecommendationService
  _recommendationService =
      RecommendationService.instance;

  final FriendService _friendService =
      FriendService.instance;

  /// 防止连续点击最上面的信封，
  /// 同时打开多个 Dialog。
  bool _openingRecommendation =
  false;

  /// 第一次同步未读推荐。
  bool _loadingRecommendations =
  false;

  @override
  void initState() {
    super.initState();

    _recommendationService.addListener(
      _onRecommendationChanged,
    );

    _friendService.addListener(
      _onFriendChanged,
    );

    /// HomePage 建立完成以后
    /// 再访问服务器。
    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        _refreshUnreadRecommendations();
        _refreshFriendRequests();
      },
    );
  }

  void _onFriendChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _recommendationService
        .removeListener(
      _onRecommendationChanged,
    );
    _friendService.removeListener(
      _onFriendChanged,
    );
    super.dispose();
  }

  // ============================================================
  // Recommendation listener
  // ============================================================

  void _onRecommendationChanged() {
    if (!mounted) {
      return;
    }

    /// Service 的未读队列变化以后，
    /// 首页重新 build。
    ///
    /// 当最上面一封信被标记已读：
    ///
    /// 第一封移除
    /// ↓
    /// 第二封成为 first
    /// ↓
    /// AnimatedSwitcher 自动播放上浮动画
    setState(() {});
  }

  // ============================================================
  // Load unread queue
  // ============================================================

  Future<void>
  _refreshUnreadRecommendations() async {
    if (_loadingRecommendations) {
      return;
    }

    setState(() {
      _loadingRecommendations =
      true;
    });

    try {
      await _recommendationService
          .refreshUnreadRecommendations();
    } on RecommendationException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      )
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '推荐加载失败：${e.message}',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _loadingRecommendations =
          false;
        });
      }
    }
  }

  Future<void> _refreshFriendRequests() async {
    try {
      await _friendService
          .refreshReceivedRequests();
    } on FriendException {
      // 好友申请数量同步失败
      // 不应该阻塞主页使用。
    }
  }
  // ============================================================
  // Open current top envelope
  // ============================================================

  Future<void>
  _openTopRecommendation() async {
    if (_openingRecommendation) {
      return;
    }

    final recommendation =
        _recommendationService
            .latestUnreadRecommendation;

    if (recommendation == null) {
      return;
    }

    setState(() {
      _openingRecommendation =
      true;
    });

    /// barrierDismissible = false：
    ///
    /// 防止用户点 Dialog 外部导致
    /// “已经看过内容但没有走 markAsRead”。
    ///
    /// 信件必须通过：
    ///
    /// “收好这封信”
    ///
    /// 完成这一轮阅读。
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,

      builder: (_) {
        return RecommendationEnvelopeDialog(
          recommendation:
          recommendation,
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _openingRecommendation =
      false;
    });

    /// 如果还有下一封，
    /// RecommendationService 已经在
    /// markAsRead() 后把上一封从队列删除。
    ///
    /// 因此这里不需要手动：
    ///
    /// removeAt(0)
    ///
    /// 下一封自然成为 first。
  }

  // ============================================================
  // Navigation
  // ============================================================

  void _selectDestination(
      int index,
      ) {
    setState(() {
      selectedIndex =
          index;
    });

    /// 回到“衣柜首页”时，
    /// 顺便重新检查一次未读推荐。
    ///
    /// 这样用户在好友页停留期间
    /// 收到了新推荐，
    /// 回来以后也可以看到。
    if (index == 0) {
      _refreshUnreadRecommendations();
    }
  }

  Widget _buildFriendNavigationIcon({
    required bool selected,
  }) {
    final requestCount =
        _friendService.receivedRequestCount;

    return Badge(
      isLabelVisible: requestCount > 0,
      label: Text(
        requestCount > 99
            ? '99+'
            : '$requestCount',
      ),
      child: Icon(
        selected
            ? Icons.people
            : Icons.people_outline,
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
    final pages = [
      const WardrobePage(),

      const FriendsPage(),

      ProfilePage(
        isDarkMode:
        widget.isDarkMode,

        onThemeChanged:
        widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // ------------------------------------------------------
          // Original pages
          // ------------------------------------------------------

          Positioned.fill(
            child: IndexedStack(
              index:
              selectedIndex,

              children:
              pages,
            ),
          ),

          // ------------------------------------------------------
          // Recommendation envelope stack
          // ------------------------------------------------------

          /// 只在首页 / 衣柜 Tab 显示推荐信。
          if (selectedIndex == 0)
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,

              child: SafeArea(
                top: false,

                child:
                _buildRecommendationOverlay(),
              ),
            ),
        ],
      ),

      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        selectedIndex,

        onDestinationSelected:
        _selectDestination,

          destinations: [
            const NavigationDestination(
              icon: Icon(
                Icons.checkroom_outlined,
              ),
              selectedIcon: Icon(
                Icons.checkroom,
              ),
              label: '衣柜',
            ),

            NavigationDestination(
              icon: _buildFriendNavigationIcon(
                selected: false,
              ),
              selectedIcon:
              _buildFriendNavigationIcon(
                selected: true,
              ),
              label: '好友',
            ),

            const NavigationDestination(
              icon: Icon(
                Icons.person_outline,
              ),
              selectedIcon: Icon(
                Icons.person,
              ),
              label: '我的',
            ),
          ],
      ),
    );
  }

  // ============================================================
  // Recommendation overlay
  // ============================================================

  Widget _buildRecommendationOverlay() {
    final unread =
        _recommendationService
            .unreadRecommendations;

    if (unread.isEmpty) {
      /// 没有推荐时不占任何首页空间。
      return const SizedBox.shrink();
    }

    final top =
        unread.first;

    /// AnimatedSwitcher 的 key
    /// 使用“当前最上层 recommendation id”。
    ///
    /// 第一封被阅读后：
    ///
    /// R3 -> R2
    ///
    /// key 改变，
    /// Flutter 自动播放切换动画。
    return AnimatedSwitcher(
      duration:
      const Duration(
        milliseconds: 420,
      ),

      switchInCurve:
      Curves.easeOutBack,

      switchOutCurve:
      Curves.easeIn,

      layoutBuilder:
          (
          currentChild,
          previousChildren,
          ) {
        return Stack(
          alignment:
          Alignment.bottomCenter,

          children: [
            ...previousChildren,

            if (currentChild != null)
              currentChild,
          ],
        );
      },

      transitionBuilder:
          (
          child,
          animation,
          ) {
        final curved =
        CurvedAnimation(
          parent:
          animation,

          curve:
          Curves.easeOutCubic,

          reverseCurve:
          Curves.easeInCubic,
        );

        /// 当前信移开 / 下一封上浮时，
        /// 使用：
        ///
        /// Fade
        /// +
        /// Slide
        /// +
        /// Scale
        ///
        /// 做出类似把最上层信件拿走的感觉。
        return FadeTransition(
          opacity:
          animation,

          child:
          SlideTransition(
            position:
            Tween<Offset>(
              begin:
              const Offset(
                0.10,
                0.08,
              ),

              end:
              Offset.zero,
            ).animate(
              curved,
            ),

            child:
            ScaleTransition(
              scale:
              Tween<double>(
                begin:
                0.96,

                end:
                1.0,
              ).animate(
                curved,
              ),

              child:
              child,
            ),
          ),
        );
      },

      child:
      _RecommendationEnvelopeStack(
        key:
        ValueKey(
          top.id,
        ),

        recommendations:
        unread,

        totalCount:
        _recommendationService
            .unreadCount,

        onTap:
        _openingRecommendation
            ? null
            : _openTopRecommendation,
      ),
    );
  }
}

/// ============================================================
/// Recommendation envelope stack
/// ============================================================
///
/// 首页最多真正绘制三层。
///
/// 即使有：
///
/// 10 封未读
///
/// 也只画：
///
/// 第三层
/// 第二层
/// 第一层
///
/// 然后在最上层显示：
///
/// “10 封未读推荐”
///
/// 避免大量 Widget 重叠。
class _RecommendationEnvelopeStack
    extends StatelessWidget {
  final List<ClothingRecommendation>
  recommendations;

  final int totalCount;

  final VoidCallback? onTap;

  const _RecommendationEnvelopeStack({
    super.key,
    required this.recommendations,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    /// 最多绘制前三封。
    final visible =
    recommendations
        .take(
      3,
    )
        .toList(
      growable: false,
    );

    return SizedBox(
      height: 180,

      child: Stack(
        clipBehavior:
        Clip.none,

        alignment:
        Alignment.bottomCenter,

        children: [
          /// 倒序绘制：
          ///
          /// depth 2 先画
          /// depth 1 再画
          /// depth 0 最后画
          ///
          /// 因此最新推荐始终在最上面。
          for (
          int depth =
              visible.length - 1;
          depth >= 0;
          depth--
          )
            _buildEnvelopeLayer(
              context,
              visible[depth],
              depth,
            ),
        ],
      ),
    );
  }

  Widget _buildEnvelopeLayer(
      BuildContext context,
      ClothingRecommendation
      recommendation,
      int depth,
      ) {
    final isTop =
        depth == 0;

    /// 后面的信稍微向上错开。
    final verticalOffset =
        -12.0 * depth;

    /// 后面的信稍微缩小，
    /// 强化透视和堆叠感。
    final scale =
        1.0 -
            (depth * 0.035);

    return Transform.translate(
      offset: Offset(
        0,
        verticalOffset,
      ),

      child: Transform.scale(
        scale:
        scale,

        alignment:
        Alignment.bottomCenter,

        child: Padding(
          padding:
          EdgeInsets.symmetric(
            horizontal:
            depth * 10.0,
          ),

          child: SizedBox(
            width:
            double.infinity,

            height:
            138,

            child: isTop
                ? _buildTopEnvelope(
              context,
              recommendation,
            )
                : _buildBackEnvelope(
              context,
              depth,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Back envelope
  // ============================================================

  /// 第二、第三层不显示具体内容。
  ///
  /// 它们只是告诉用户：
  ///
  /// “后面还有信”。
  Widget _buildBackEnvelope(
      BuildContext context,
      int depth,
      ) {
    return Material(
      elevation:
      2,

      borderRadius:
      BorderRadius.circular(
        20,
      ),

      color:
      depth == 1
          ? Theme.of(
        context,
      )
          .colorScheme
          .surfaceContainerHigh
          : Theme.of(
        context,
      )
          .colorScheme
          .surfaceContainer,

      child: Container(
        decoration:
        BoxDecoration(
          borderRadius:
          BorderRadius.circular(
            20,
          ),

          border:
          Border.all(
            color:
            Theme.of(
              context,
            )
                .colorScheme
                .outlineVariant,
          ),
        ),

        child: Align(
          alignment:
          Alignment.topCenter,

          child: Padding(
            padding:
            const EdgeInsets.only(
              top: 10,
            ),

            child: Icon(
              Icons
                  .mail_outline,

              size:
              20,

              color:
              Theme.of(
                context,
              )
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(
                alpha:
                0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Top envelope
  // ============================================================

  Widget _buildTopEnvelope(
      BuildContext context,
      ClothingRecommendation
      recommendation,
      ) {
    final senderName =
        recommendation
            .fromUser
            .username;

    return Material(
      elevation:
      10,

      borderRadius:
      BorderRadius.circular(
        20,
      ),

      color:
      Theme.of(
        context,
      )
          .colorScheme
          .surfaceContainerHighest,

      clipBehavior:
      Clip.antiAlias,

      child: InkWell(
        onTap:
        onTap,

        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          child: Row(
            children: [
              // --------------------------------------------------
              // Envelope icon
              // --------------------------------------------------

              Container(
                width: 54,
                height: 54,

                decoration:
                BoxDecoration(
                  color:
                  Theme.of(
                    context,
                  )
                      .colorScheme
                      .primaryContainer,

                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),

                child: Icon(
                  Icons
                      .mail_outline,

                  size:
                  30,

                  color:
                  Theme.of(
                    context,
                  )
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // --------------------------------------------------
              // Text
              // --------------------------------------------------

              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      '来自 $senderName 的推荐信',

                      maxLines:
                      1,

                      overflow:
                      TextOverflow
                          .ellipsis,

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

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      recommendation
                          .message,

                      maxLines:
                      1,

                      overflow:
                      TextOverflow
                          .ellipsis,

                      style:
                      Theme.of(
                        context,
                      )
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color:
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      totalCount == 1
                          ? '点击拆开这封推荐信'
                          : '还有 $totalCount 封未读推荐',

                      style:
                      Theme.of(
                        context,
                      )
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                        color:
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              // --------------------------------------------------
              // Count badge
              // --------------------------------------------------

              Container(
                constraints:
                const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                ),

                decoration:
                BoxDecoration(
                  color:
                  Theme.of(
                    context,
                  )
                      .colorScheme
                      .primary,

                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),

                alignment:
                Alignment.center,

                child: Text(
                  '$totalCount',

                  style:
                  TextStyle(
                    color:
                    Theme.of(
                      context,
                    )
                        .colorScheme
                        .onPrimary,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}