import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/clothing_recommendation.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/clothing_card.dart';
import '../../widgets/wardrobe_image.dart';

class RecommendationHistoryPage extends StatefulWidget {
  const RecommendationHistoryPage({super.key});

  @override
  State<RecommendationHistoryPage> createState() =>
      _RecommendationHistoryPageState();
}

class _RecommendationHistoryPageState extends State<RecommendationHistoryPage>
    with SingleTickerProviderStateMixin {
  final RecommendationService _recommendationService =
      RecommendationService.instance;

  late final TabController _tabController;
  bool _isLoadingReceived = true;
  bool _isLoadingSent = true;
  String? _receivedError;
  String? _sentError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recommendationService.addListener(_onRecommendationChanged);
    Future.microtask(_loadAll);
  }

  @override
  void dispose() {
    _recommendationService.removeListener(_onRecommendationChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onRecommendationChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadReceived(), _loadSent()]);
  }

  Future<void> _loadReceived() async {
    if (mounted) {
      setState(() {
        _isLoadingReceived = true;
        _receivedError = null;
      });
    }

    try {
      await _recommendationService.refreshReceivedRecommendations();
    } on RecommendationException catch (e) {
      if (mounted) {
        setState(() {
          _receivedError = e.message;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingReceived = false);
    }
  }

  Future<void> _loadSent() async {
    if (mounted) {
      setState(() {
        _isLoadingSent = true;
        _sentError = null;
      });
    }

    try {
      await _recommendationService.refreshSentRecommendations();
    } on RecommendationException catch (e) {
      if (mounted) {
        setState(() {
          _sentError = e.message;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingSent = false);
    }
  }

  Future<void> _openReceived(ClothingRecommendation recommendation) async {
    var current = recommendation;

    if (!recommendation.isRead) {
      try {
        current = await _recommendationService.markAsRead(recommendation.id);
      } on RecommendationException catch (e) {
        if (!mounted) return;
        _showError(e.message);
        return;
      }
    }

    if (!mounted) return;
    await _showRecommendationDetail(
      recommendation: current,
      isReceived: true,
    );
  }

  Future<void> _openSent(ClothingRecommendation recommendation) async {
    await _showRecommendationDetail(
      recommendation: recommendation,
      isReceived: false,
    );
  }

  Future<void> _showRecommendationDetail({
    required ClothingRecommendation recommendation,
    required bool isReceived,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: _RecommendationHistoryDetail(
          recommendation: recommendation,
          isReceived: isReceived,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(localizedErrorMessage(context, message)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recommendationHistory),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.receivedRecommendations),
            Tab(text: l10n.sentRecommendations),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedTab(),
          _buildSentTab(),
        ],
      ),
    );
  }

  Widget _buildReceivedTab() {
    if (_isLoadingReceived) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_receivedError != null) {
      return _buildErrorState(_receivedError!, _loadReceived);
    }

    final recommendations = _recommendationService.receivedRecommendations;

    if (recommendations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mark_email_unread_outlined,
        title: context.l10n.noReceivedRecommendations,
        subtitle: context.l10n.receivedRecommendationsHint,
        onRefresh: _loadReceived,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReceived,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _buildReceivedCard(recommendations[index]);
        },
      ),
    );
  }

  Widget _buildReceivedCard(ClothingRecommendation recommendation) {
    final sender = recommendation.fromUser;
    final l10n = context.l10n;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openReceived(recommendation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: recommendation.isRead
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              WardrobeAvatar(
                user: sender,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sender.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildReadStatus(
                          recommendation.isRead ? l10n.read : l10n.unread,
                          highlighted: !recommendation.isRead,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.checkroom_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.clothingCount(recommendation.clothes.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(recommendation.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentTab() {
    if (_isLoadingSent) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sentError != null) {
      return _buildErrorState(_sentError!, _loadSent);
    }

    final recommendations = _recommendationService.sentRecommendations;

    if (recommendations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.outgoing_mail,
        title: context.l10n.noSentRecommendations,
        subtitle: context.l10n.sentRecommendationsHint,
        onRefresh: _loadSent,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSent,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _buildSentCard(recommendations[index]);
        },
      ),
    );
  }

  Widget _buildSentCard(ClothingRecommendation recommendation) {
    final receiver = recommendation.toUser;
    final l10n = context.l10n;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openSent(recommendation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              WardrobeAvatar(
                user: receiver,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.sentTo(receiver.username),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildReadStatus(
                          recommendation.isRead
                              ? l10n.recipientRead
                              : l10n.recipientUnread,
                          highlighted: !recommendation.isRead,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.checkroom_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.clothingCount(recommendation.clothes.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(recommendation.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadStatus(String label, {required bool highlighted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
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
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 58,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(subtitle, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final local = time.toLocal();
    final difference = now.difference(local);
    final l10n = context.l10n;

    if (!difference.isNegative) {
      if (difference.inMinutes < 1) return l10n.justNow;
      if (difference.inHours < 1) {
        return l10n.minutesAgo(difference.inMinutes);
      }
      if (difference.inDays < 1) {
        return l10n.hoursAgo(difference.inHours);
      }
    }

    return _localizedDate(local);
  }

  String _localizedDate(DateTime time) {
    final year = time.year.toString();
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }
}

class _RecommendationHistoryDetail extends StatelessWidget {
  final ClothingRecommendation recommendation;
  final bool isReceived;

  const _RecommendationHistoryDetail({
    required this.recommendation,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser =
        isReceived ? recommendation.fromUser : recommendation.toUser;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isReceived
                      ? Icons.mark_email_read_outlined
                      : Icons.outgoing_mail,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isReceived
                        ? l10n.recommendationFrom(otherUser.username)
                        : l10n.recommendationTo(otherUser.username),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: l10n.close,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(recommendation.message),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  l10n.recommendedClothing,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(l10n.itemCount(recommendation.clothes.length)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: recommendation.clothes.isEmpty
                  ? Center(child: Text(l10n.recommendationClothingMissing))
                  : GridView.builder(
                      itemCount: recommendation.clothes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        return ClothingCard(
                          clothing: recommendation.clothes[index],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            _buildStatusLine(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLine(BuildContext context) {
    final l10n = context.l10n;
    final status = isReceived
        ? (recommendation.isRead ? l10n.read : l10n.unread)
        : (recommendation.isRead ? l10n.recipientRead : l10n.recipientUnread);

    return Row(
      children: [
        Icon(
          recommendation.isRead ? Icons.done_all : Icons.schedule,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(status),
        const Spacer(),
        Text(
          _formatDetailDate(recommendation.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDetailDate(DateTime time) {
    final local = time.toLocal();
    final year = local.year.toString();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }
}
