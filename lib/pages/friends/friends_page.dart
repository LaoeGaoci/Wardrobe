import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/friend_service.dart';
import 'friend_requests_page.dart';
import 'user_profile_page.dart';

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

  final List<AppUser>
  _searchResults = [];

  Timer? _searchDebounce;

  bool _isSearching = false;
  bool _isLoadingSearch = false;

  String? _searchError;

  /// 防止旧请求覆盖新请求结果。
  int _searchVersion = 0;

  @override
  void initState() {
    super.initState();

    _friendService.addListener(
      _onFriendChanged,
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

    if (mounted) {
      setState(() {});
    }
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

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // Search
  // ============================================================

  void _onSearchChanged(
      String value,
      ) {
    final keyword =
    value.trim();

    _searchDebounce?.cancel();

    if (keyword.isEmpty) {
      _searchVersion++;

      setState(() {
        _isSearching = false;
        _isLoadingSearch =
        false;

        _searchError = null;

        _searchResults.clear();
      });

      return;
    }

    setState(() {
      _isSearching = true;
      _isLoadingSearch = true;
      _searchError = null;
    });

    _searchDebounce =
        Timer(
          const Duration(
            milliseconds: 300,
          ),
              () => _searchUsers(
            keyword,
          ),
        );
  }

  Future<void> _searchUsers(
      String keyword,
      ) async {
    final version =
    ++_searchVersion;

    try {
      final users =
      await _friendService
          .searchUsers(
        keyword,
      );

      if (!mounted ||
          version !=
              _searchVersion) {
        return;
      }

      setState(() {
        _searchResults
          ..clear()
          ..addAll(users);

        _isLoadingSearch =
        false;

        _searchError = null;
      });
    } on FriendException catch (e) {
      if (!mounted ||
          version !=
              _searchVersion) {
        return;
      }

      setState(() {
        _searchResults.clear();

        _isLoadingSearch =
        false;

        _searchError =
            e.message;
      });
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();

    _searchVersion++;

    _searchController.clear();

    setState(() {
      _isSearching = false;
      _isLoadingSearch = false;
      _searchError = null;

      _searchResults.clear();
    });
  }

  // ============================================================
  // UI
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
        title:
        const Text(
          '好友',
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip:
                '好友申请',
                icon:
                const Icon(
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
                  child:
                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal:
                      5,
                      vertical: 2,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Theme.of(
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
            child: _isSearching
                ? _buildSearchResults()
                : _buildFriendList(
              friends,
            ),
          ),
        ],
      ),
    );
  }

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
          hintText: '搜索用户',
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

  Widget _buildFriendList(
      List<AppUser> friends,
      ) {
    if (friends.isEmpty) {
      return _buildEmptyState(
        icon:
        Icons.people_outline,
        title: '还没有好友',
        subtitle:
        '搜索用户并添加好友吧',
      );
    }

    return ListView.separated(
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
          showRemark: true,
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_isLoadingSearch) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    final error =
        _searchError;

    if (error != null) {
      return _buildEmptyState(
        icon:
        Icons.error_outline,
        title: '搜索失败',
        subtitle: error,
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon:
        Icons.search_off,
        title: '没有找到用户',
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
        _searchResults[index];

        return _buildUserTile(
          user,
          showRemark: false,
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

    final displayName =
    showRemark
        ? _friendService
        .getFriendDisplayName(
      user,
    )
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
        subtitle: showRemark &&
            _friendService
                .getRemark(
              user.id,
            )
                .isNotEmpty
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

      case FriendStatus
          .requestSent:
        return const Text(
          '已申请',
        );

      case FriendStatus
          .requestReceived:
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
    if (user.avatarUrl
        .isNotEmpty) {
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
            : user.username
            .characters
            .first
            .toUpperCase(),
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
          ],
        ),
      ),
    );
  }
}