import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/friend_service.dart';
import 'user_profile_page.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final FriendService _friendService = FriendService.instance;

  @override
  void initState() {
    super.initState();

    _friendService.addListener(_onFriendChanged);
  }

  @override
  void dispose() {
    _friendService.removeListener(_onFriendChanged);

    super.dispose();
  }

  void _onFriendChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _accept(FriendRequest request) async {
    try {
      await _friendService.acceptFriendRequest(request.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${request.fromUser.username} 已成为你的好友')),
        );
    } on FriendException catch (e) {
      _showError(e.message);
    }
  }

  Future<void> _reject(FriendRequest request) async {
    try {
      await _friendService.rejectFriendRequest(request.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('已拒绝好友申请')));
    } on FriendException catch (e) {
      _showError(e.message);
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openUserProfile(AppUser user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfilePage(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = _friendService.receivedRequests;

    return Scaffold(
      appBar: AppBar(title: const Text('好友申请')),
      body: requests.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];

                return _buildRequestCard(request);
              },
            ),
    );
  }

  Widget _buildRequestCard(FriendRequest request) {
    final user = request.fromUser;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openUserProfile(user),
              child: Row(
                children: [
                  _buildAvatar(user),
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
                    onPressed: () => _reject(request),
                    child: const Text('拒绝'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _accept(request),
                    child: const Text('同意'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(AppUser user) {
    if (user.avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(user.avatarUrl),
      );
    }

    return CircleAvatar(
      radius: 28,
      child: Text(
        user.username.isEmpty
            ? '?'
            : user.username.characters.first.toUpperCase(),
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
            Text('暂无好友申请', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
