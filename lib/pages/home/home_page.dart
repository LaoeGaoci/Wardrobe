import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/friends/clothing_recommendation.dart';
import '../../services/friends/friend_service.dart';
import '../../services/friends/recommendation_service.dart';
import '../friends/friends_page.dart';
import '../profile/profile.dart';
import 'recommendation_envelope_dialog.dart';
import 'wardrobe_page.dart';

class HomePage extends StatefulWidget {
  /// 当前主题模式：
  ///
  /// ThemeMode.system -> 跟随系统
  /// ThemeMode.light  -> 浅色
  /// ThemeMode.dark   -> 深色
  final ThemeMode themeMode;

  /// 修改主题模式
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// 修改语言
  final ValueChanged<Locale> onLocaleChanged;

  const HomePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final RecommendationService _recommendationService =
      RecommendationService.instance;

  final FriendService _friendService = FriendService.instance;

  bool _openingRecommendation = false;

  bool _loadingRecommendations = false;

  @override
  void initState() {
    super.initState();

    _recommendationService.addListener(_onRecommendationChanged);

    _friendService.addListener(_onFriendChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUnreadRecommendations();
      _refreshFriendRequests();
    });
  }

  @override
  void dispose() {
    _recommendationService.removeListener(_onRecommendationChanged);

    _friendService.removeListener(_onFriendChanged);

    super.dispose();
  }

  void _onRecommendationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFriendChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // Recommendation
  // ============================================================

  Future<void> _refreshUnreadRecommendations() async {
    if (_loadingRecommendations) {
      return;
    }

    setState(() {
      _loadingRecommendations = true;
    });

    try {
      await _recommendationService.refreshUnreadRecommendations();
    } on RecommendationException catch (e) {
      if (!mounted) {
        return;
      }

      final error = localizedErrorMessage(context, e.message);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.recommendationLoadFailed(error))),
        );
    } finally {
      if (mounted) {
        setState(() {
          _loadingRecommendations = false;
        });
      }
    }
  }

  Future<void> _refreshFriendRequests() async {
    try {
      await _friendService.refreshReceivedRequests();
    } on FriendException {
      // 好友申请角标同步失败
      // 不应该阻塞主页。
    }
  }

  Future<void> _openTopRecommendation() async {
    if (_openingRecommendation) {
      return;
    }

    final recommendation = _recommendationService.latestUnreadRecommendation;

    if (recommendation == null) {
      return;
    }

    setState(() {
      _openingRecommendation = true;
    });

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          RecommendationEnvelopeDialog(recommendation: recommendation),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _openingRecommendation = false;
    });
  }

  // ============================================================
  // Navigation
  // ============================================================

  void _selectDestination(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 0) {
      _refreshUnreadRecommendations();
    }
  }

  Widget _buildFriendNavigationIcon({required bool selected}) {
    final requestCount = _friendService.receivedRequestCount;

    return Badge(
      isLabelVisible: requestCount > 0,
      label: Text(requestCount > 99 ? '99+' : '$requestCount'),
      child: Icon(selected ? Icons.people : Icons.people_outline),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final pages = [
      const WardrobePage(),

      const FriendsPage(),

      ProfilePage(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        onLocaleChanged: widget.onLocaleChanged,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: selectedIndex, children: pages),
          ),

          if (selectedIndex == 0)
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: SafeArea(top: false, child: _buildRecommendationOverlay()),
            ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.checkroom_outlined),
            selectedIcon: const Icon(Icons.checkroom),
            label: l10n.wardrobe,
          ),

          NavigationDestination(
            icon: _buildFriendNavigationIcon(selected: false),
            selectedIcon: _buildFriendNavigationIcon(selected: true),
            label: l10n.friends,
          ),

          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Recommendation Overlay
  // ============================================================

  Widget _buildRecommendationOverlay() {
    final unread = _recommendationService.unreadRecommendations;

    if (unread.isEmpty) {
      return const SizedBox.shrink();
    }

    final top = unread.first;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.10, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
      child: _RecommendationEnvelopeStack(
        key: ValueKey(top.id),
        recommendations: unread,
        totalCount: _recommendationService.unreadCount,
        onTap: _openingRecommendation ? null : _openTopRecommendation,
      ),
    );
  }
}

// ============================================================
// Recommendation Envelope Stack
// ============================================================

class _RecommendationEnvelopeStack extends StatelessWidget {
  final List<ClothingRecommendation> recommendations;

  final int totalCount;

  final VoidCallback? onTap;

  const _RecommendationEnvelopeStack({
    super.key,
    required this.recommendations,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visible = recommendations.take(3).toList(growable: false);

    return SizedBox(
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          for (int depth = visible.length - 1; depth >= 0; depth--)
            _buildEnvelopeLayer(context, visible[depth], depth),
        ],
      ),
    );
  }

  Widget _buildEnvelopeLayer(
    BuildContext context,
    ClothingRecommendation recommendation,
    int depth,
  ) {
    final isTop = depth == 0;

    final verticalOffset = -12.0 * depth;

    final scale = 1.0 - (depth * 0.035);

    return Transform.translate(
      offset: Offset(0, verticalOffset),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: depth * 10.0),
          child: SizedBox(
            width: double.infinity,
            height: 138,
            child: isTop
                ? _buildTopEnvelope(context, recommendation)
                : _buildBackEnvelope(context, depth),
          ),
        ),
      ),
    );
  }

  Widget _buildBackEnvelope(BuildContext context, int depth) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      color: depth == 1
          ? Theme.of(context).colorScheme.surfaceContainerHigh
          : Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(
              Icons.mail_outline,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopEnvelope(
    BuildContext context,
    ClothingRecommendation recommendation,
  ) {
    final senderName = recommendation.fromUser.username;

    final l10n = context.l10n;

    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.mail_outline,
                  size: 30,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recommendationLetterFrom(senderName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      recommendation.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      totalCount == 1
                          ? l10n.tapOpenLetter
                          : l10n.unreadRecommendations(totalCount),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$totalCount',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
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
