import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/user/app_user.dart';
import '../../services/friends/friend_service.dart';
import '../../widgets/wardrobe_image.dart';
import 'user_profile_page.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final FriendService _friendService = FriendService.instance;
  bool _isLoading = true;
  String? _loadError;
  final Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _friendService.addListener(_onFriendChanged);
    Future.microtask(_loadRequests);
  }

  @override
  void dispose() {
    _friendService.removeListener(_onFriendChanged);
    super.dispose();
  }

  void _onFriendChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadRequests() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      await _friendService.refreshRequests();
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

  Future<void> _accept(FriendRequest request) async {
    if (_processingIds.contains(request.id)) return;
    setState(() => _processingIds.add(request.id));

    try {
      await _friendService.acceptFriendRequest(request.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.becameFriends(request.fromUser.username),
            ),
          ),
        );
    } on FriendException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _processingIds.remove(request.id));
    }
  }

  Future<void> _reject(FriendRequest request) async {
    if (_processingIds.contains(request.id)) return;
    setState(() => _processingIds.add(request.id));

    try {
      await _friendService.rejectFriendRequest(request.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.requestRejected)));
    } on FriendException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _processingIds.remove(request.id));
    }
  }

  Future<void> _openUserProfile(AppUser user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfilePage(user: user)),
    );

    if (mounted) await _loadRequests();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(localizedErrorMessage(context, message))),
      );
  }

  @override
  Widget build(BuildContext context) {
    final requests = _friendService.receivedRequests;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.friendRequests)),
      body: _buildBody(requests),
    );
  }

  Widget _buildBody(List<FriendRequest> requests) {
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
              Text(
                localizedErrorMessage(context, _loadError!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadRequests,
                child: Text(context.l10n.reload),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: requests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: _buildEmptyState(),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildRequestCard(requests[index]),
            ),
    );
  }

  Widget _buildRequestCard(FriendRequest request) {
    final user = request.fromUser;
    final processing = _processingIds.contains(request.id);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: processing ? null : () => _openUserProfile(user),
              child: Row(
                children: [
                  WardrobeAvatar(user: user, radius: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(request.message),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: processing ? null : () => _reject(request),
                    child: Text(l10n.reject),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: processing ? null : () => _accept(request),
                    child: processing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_disabled_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noFriendRequests,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
