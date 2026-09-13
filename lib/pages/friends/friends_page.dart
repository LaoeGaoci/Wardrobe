import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/friend_service.dart';

import 'friend_requests_page.dart';
import 'user_profile_page.dart';

import 'recommendation_history_page.dart';

class FriendsPage
    extends StatefulWidget {
  const FriendsPage({
    super.key,
  });

  @override
  State<FriendsPage> createState() =>
      _FriendsPageState();
}

class _FriendsPageState
    extends State<FriendsPage> {
  final FriendService _friendService =
      FriendService.instance;

  final TextEditingController
  _searchController =
  TextEditingController();

  /// 搜索防抖。
  Timer? _searchDebounce;

  /// 防止旧搜索请求晚于新请求返回。
  int _searchGeneration = 0;

  bool _isSearching = false;

  bool _isLoading = true;

  bool _isSearchLoading = false;

  String? _loadError;

  String? _searchError;

  List<AppUser> _searchResults =
  const [];

  @override
  void initState() {
    super.initState();

    _friendService.addListener(
      _onFriendChanged,
    );

    /// 页面第一次进入，
    /// 从服务器同步好友和好友申请。
    Future.microtask(
      _loadInitialData,
    );
  }

  @override
  void dispose() {
    _friendService.removeListener(
      _onFriendChanged,
    );

    _searchDebounce?.cancel();

    _searchController.dispose();

    super.dispose();
  }

  void _onFriendChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // Initial data
  // ============================================================

  Future<void> _loadInitialData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      await _friendService
          .refreshAll();
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
  // Search
  // ============================================================

  void _onSearchChanged(
      String value,
      ) {
    _searchDebounce?.cancel();

    final keyword =
    value.trim();

    _searchGeneration++;

    if (keyword.isEmpty) {
      setState(() {
        _isSearching =
        false;

        _isSearchLoading =
        false;

        _searchResults =
        const [];

        _searchError =
        null;
      });

      return;
    }

    setState(() {
      _isSearching =
      true;

      _isSearchLoading =
      true;

      _searchError =
      null;
    });

    final generation =
        _searchGeneration;

    /// 用户停止输入 350ms 后再请求后端。
    _searchDebounce = Timer(
      const Duration(
        milliseconds: 350,
      ),
          () {
        _performSearch(
          keyword,
          generation,
        );
      },
    );
  }

  Future<void> _performSearch(
      String keyword,
      int generation,
      ) async {
    try {
      final results =
      await _friendService
          .searchUsers(
        keyword,
      );

      /// 如果搜索期间用户已经输入了新关键词，
      /// 丢弃当前旧结果。
      if (!mounted ||
          generation !=
              _searchGeneration) {
        return;
      }

      setState(() {
        _searchResults =
            results;

        _isSearchLoading =
        false;
      });
    } on FriendException catch (e) {
      if (!mounted ||
          generation !=
              _searchGeneration) {
        return;
      }

      setState(() {
        _searchResults =
        const [];

        _searchError =
            e.message;

        _isSearchLoading =
        false;
      });
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();

    _searchGeneration++;

    _searchController.clear();

    setState(() {
      _isSearching =
      false;

      _isSearchLoading =
      false;

      _searchResults =
      const [];

      _searchError =
      null;
    });
  }

  // ============================================================
  // Navigation
  // ============================================================

  /// 打开推荐历史记录。
  ///
  /// 页面内部会分别请求：
  ///
  /// GET /api/recommendations/received
  /// GET /api/recommendations/sent
  Future<void>
  _openRecommendationHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const RecommendationHistoryPage(),
      ),
    );
  }

  Future<void> _openUserProfile(
      AppUser user,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            UserProfilePage(
              user: user,
            ),
      ),
    );

    if (!mounted) {
      return;
    }

    /// 用户详情中可能执行：
    ///
    /// 添加好友
    /// 删除好友
    /// 修改备注
    ///
    /// 回来以后主动同步一次。
    await _loadInitialData();
  }

  Future<void>
  _openFriendRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const FriendRequestsPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadInitialData();
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final friends =
        _friendService.friends;

    final requestCount =
        _friendService
            .receivedRequestCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '好友',
        ),
        actions: [
          /// ==========================================================
          /// 推荐历史
          /// ==========================================================
          IconButton(
            tooltip:
            '推荐记录',

            icon:
            const Icon(
              Icons
                  .card_giftcard_outlined,
            ),

            onPressed:
            _openRecommendationHistory,
          ),

          /// ==========================================================
          /// 好友申请
          /// ==========================================================
          Stack(
            children: [
              IconButton(
                tooltip:
                '好友申请',
                icon: const Icon(
                  Icons
                      .person_add_alt_1_outlined,
                ),
                onPressed:
                _openFriendRequests,
              ),

              if (requestCount >
                  0)
                Positioned(
                  right: 7,
                  top: 7,
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      Theme.of(
                        context,
                      )
                          .colorScheme
                          .error,
                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),
                    ),
                    child: Text(
                      requestCount >
                          99
                          ? '99+'
                          : '$requestCount',
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 10,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),

          Expanded(
            child:
            _buildBody(
              friends,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      List<AppUser> friends,
      ) {
    if (_isSearching) {
      return _buildSearchResults();
    }

    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_loadError != null) {
      return _buildErrorState(
        _loadError!,
        _loadInitialData,
      );
    }

    return RefreshIndicator(
      onRefresh:
      _loadInitialData,
      child:
      _buildFriendList(
        friends,
      ),
    );
  }

  // ============================================================
  // Search UI
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding:
      const EdgeInsets
          .fromLTRB(
        16,
        12,
        16,
        8,
      ),
      child: TextField(
        controller:
        _searchController,
        onChanged:
        _onSearchChanged,
        decoration:
        InputDecoration(
          hintText:
          '搜索用户名或邮箱',
          prefixIcon:
          const Icon(
            Icons.search,
          ),
          suffixIcon:
          _isSearching
              ? IconButton(
            icon:
            const Icon(
              Icons.clear,
            ),
            onPressed:
            _clearSearch,
          )
              : null,
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius
                .circular(
              14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearchLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_searchError != null) {
      return _buildErrorState(
        _searchError!,
            () async {
          await _performSearch(
            _searchController
                .text
                .trim(),
            _searchGeneration,
          );
        },
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon:
        Icons.search_off,
        title:
        '没有找到用户',
        subtitle:
        '可以尝试搜索用户名或邮箱',
      );
    }

    return ListView.separated(
      padding:
      const EdgeInsets.all(
        16,
      ),
      itemCount:
      _searchResults.length,
      separatorBuilder:
          (_, __) =>
      const SizedBox(
        height: 8,
      ),
      itemBuilder:
          (context, index) {
        final user =
        _searchResults[
        index
        ];

        return _buildUserTile(
          user,
          showRemark:
          false,
        );
      },
    );
  }

  // ============================================================
  // Friend list UI
  // ============================================================

  Widget _buildFriendList(
      List<AppUser> friends,
      ) {
    if (friends.isEmpty) {
      /// RefreshIndicator 需要可滚动 child。
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(
              context,
            ).size.height *
                0.55,
            child:
            _buildEmptyState(
              icon:
              Icons
                  .people_outline,
              title:
              '还没有好友',
              subtitle:
              '搜索用户并添加好友吧',
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.all(
        16,
      ),
      itemCount:
      friends.length,
      separatorBuilder:
          (_, __) =>
      const SizedBox(
        height: 8,
      ),
      itemBuilder:
          (context, index) {
        final friend =
        friends[index];

        return _buildUserTile(
          friend,
          showRemark:
          true,
        );
      },
    );
  }

  Widget _buildUserTile(
      AppUser user, {
        required bool showRemark,
      }) {
    final status =
    _friendService
        .getFriendStatus(
      user.id,
    );

    final remark =
    _friendService
        .getRemark(
      user.id,
    );

    final displayName =
    showRemark &&
        remark.isNotEmpty
        ? remark
        : user.username;

    return Card(
      child: ListTile(
        leading:
        _buildAvatar(
          user,
        ),
        title: Text(
          displayName,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w600,
          ),
        ),
        subtitle:
        showRemark &&
            remark.isNotEmpty
            ? Text(
          user.username,
        )
            : Text(
          user.email,
        ),
        trailing: showRemark
            ? const Icon(
          Icons
              .chevron_right,
        )
            : _buildStatusWidget(
          status,
        ),
        onTap: () =>
            _openUserProfile(
              user,
            ),
      ),
    );
  }

  Widget _buildStatusWidget(
      FriendStatus status,
      ) {
    switch (status) {
      case FriendStatus.friends:
        return const Text(
          '好友',
        );

      case FriendStatus.requestSent:
        return const Text(
          '已申请',
        );

      case FriendStatus.requestReceived:
        return const Text(
          '待处理',
        );

      case FriendStatus.none:
        return const Icon(
          Icons.chevron_right,
        );
    }
  }

  Widget _buildAvatar(
      AppUser user,
      ) {
    if (user.avatarUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage:
        NetworkImage(
          user.avatarUrl,
        ),
      );
    }

    return CircleAvatar(
      child: Text(
        user.username.isEmpty
            ? '?'
            : user
            .username
            .characters
            .first
            .toUpperCase(),
      ),
    );
  }

  // ============================================================
  // State widgets
  // ============================================================

  Widget _buildErrorState(
      String message,
      Future<void> Function()
      retry,
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
              Icons
                  .error_outline,
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
              onPressed: retry,
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
  }) {
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
            Icon(
              icon,
              size: 56,
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
    );
  }
}