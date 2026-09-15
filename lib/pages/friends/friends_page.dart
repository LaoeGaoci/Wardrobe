import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/app_user.dart';
import '../../services/friend_service.dart';
import '../../widgets/wardrobe_image.dart';
import 'friend_requests_page.dart';
import 'recommendation_history_page.dart';
import 'user_profile_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final FriendService _friendService = FriendService.instance;
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  int _searchGeneration = 0;
  bool _isSearching = false;
  bool _isLoading = true;
  bool _isSearchLoading = false;
  String? _loadError;
  String? _searchError;
  List<AppUser> _searchResults = const [];

  @override
  void initState() {
    super.initState();
    _friendService.addListener(_onFriendChanged);
    Future.microtask(_loadInitialData);
  }

  @override
  void dispose() {
    _friendService.removeListener(_onFriendChanged);
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onFriendChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInitialData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      await _friendService.refreshAll();
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

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final keyword = value.trim();
    _searchGeneration++;

    if (keyword.isEmpty) {
      setState(() {
        _isSearching = false;
        _isSearchLoading = false;
        _searchResults = const [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
      _searchError = null;
    });

    final generation = _searchGeneration;
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _performSearch(keyword, generation),
    );
  }

  Future<void> _performSearch(String keyword, int generation) async {
    try {
      final results = await _friendService.searchUsers(keyword);
      if (!mounted || generation != _searchGeneration) return;

      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } on FriendException catch (e) {
      if (!mounted || generation != _searchGeneration) return;

      setState(() {
        _searchResults = const [];
        _searchError = e.message;
        _isSearchLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchGeneration++;
    _searchController.clear();

    setState(() {
      _isSearching = false;
      _isSearchLoading = false;
      _searchResults = const [];
      _searchError = null;
    });
  }

  Future<void> _openRecommendationHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecommendationHistoryPage()),
    );
  }

  Future<void> _openUserProfile(AppUser user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfilePage(user: user)),
    );

    if (mounted) await _loadInitialData();
  }

  Future<void> _openFriendRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FriendRequestsPage()),
    );

    if (mounted) await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final friends = _friendService.friends;
    final requestCount = _friendService.receivedRequestCount;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.friends),
        actions: [
          IconButton(
            tooltip: l10n.recommendationHistory,
            icon: const Icon(Icons.card_giftcard_outlined),
            onPressed: _openRecommendationHistory,
          ),
          Stack(
            children: [
              IconButton(
                tooltip: l10n.friendRequests,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                onPressed: _openFriendRequests,
              ),
              if (requestCount > 0)
                Positioned(
                  right: 7,
                  top: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      requestCount > 99 ? '99+' : '$requestCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
          Expanded(child: _buildBody(friends)),
        ],
      ),
    );
  }

  Widget _buildBody(List<AppUser> friends) {
    if (_isSearching) return _buildSearchResults();
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_loadError != null) {
      return _buildErrorState(_loadError!, _loadInitialData);
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: _buildFriendList(friends),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: context.l10n.searchUserOrEmail,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchError != null) {
      return _buildErrorState(
        _searchError!,
        () => _performSearch(
          _searchController.text.trim(),
          _searchGeneration,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: context.l10n.noUserFound,
        subtitle: context.l10n.trySearchUserOrEmail,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildUserTile(_searchResults[index], showRemark: false);
      },
    );
  }

  Widget _buildFriendList(List<AppUser> friends) {
    if (friends.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: _buildEmptyState(
              icon: Icons.people_outline,
              title: context.l10n.noFriends,
              subtitle: context.l10n.searchAndAddFriends,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildUserTile(friends[index], showRemark: true);
      },
    );
  }

  Widget _buildUserTile(AppUser user, {required bool showRemark}) {
    final status = _friendService.getFriendStatus(user.id);
    final remark = _friendService.getRemark(user.id);
    final displayName = showRemark && remark.isNotEmpty ? remark : user.username;

    return Card(
      child: ListTile(
        leading: WardrobeAvatar(user: user),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: showRemark && remark.isNotEmpty
            ? Text(user.username)
            : Text(user.email),
        trailing: showRemark
            ? const Icon(Icons.chevron_right)
            : _buildStatusWidget(status),
        onTap: () => _openUserProfile(user),
      ),
    );
  }

  Widget _buildStatusWidget(FriendStatus status) {
    final l10n = context.l10n;

    switch (status) {
      case FriendStatus.friends:
        return Text(l10n.statusFriend);
      case FriendStatus.requestSent:
        return Text(l10n.statusRequested);
      case FriendStatus.requestReceived:
        return Text(l10n.statusPending);
      case FriendStatus.none:
        return const Icon(Icons.chevron_right);
    }
  }

  Widget _buildErrorState(
    String message,
    Future<void> Function() retry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              localizedErrorMessage(context, message),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: retry,
              child: Text(context.l10n.reload),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
