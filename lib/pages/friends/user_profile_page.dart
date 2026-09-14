import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/app_user.dart';
import '../../services/friend_service.dart';
import 'friend_requests_page.dart';
import 'friend_wardrobe_page.dart';

class UserProfilePage extends StatefulWidget {
  final AppUser user;

  const UserProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FriendService _friendService = FriendService.instance;

  bool _isLoading = true;
  String? _loadError;
  bool _isOperating = false;

  @override
  void initState() {
    super.initState();
    _friendService.addListener(_onFriendChanged);
    Future.microtask(_loadFriendContext);
  }

  @override
  void dispose() {
    _friendService.removeListener(_onFriendChanged);
    super.dispose();
  }

  void _onFriendChanged() {
    if (mounted) setState(() {});
  }

  FriendStatus get _status => _friendService.getFriendStatus(widget.user.id);

  Future<void> _loadFriendContext() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      await _friendService.refreshFriends();
      await _friendService.refreshRequests();
      await _friendService.refreshFriendStatus(widget.user.id);
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

  Future<void> _showAddFriendDialog() async {
    String message = '';
    final l10n = context.l10n;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.addFriend),
              content: TextField(
                maxLines: 4,
                maxLength: 200,
                autofocus: true,
                onChanged: (value) {
                  message = value;
                  setDialogState(() {});
                },
                decoration: InputDecoration(
                  hintText: l10n.introduceYourself,
                  border: const OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: message.trim().isEmpty
                      ? null
                      : () => Navigator.pop(dialogContext, message.trim()),
                  child: Text(l10n.sendRequest),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.isEmpty) return;

    setState(() => _isOperating = true);

    try {
      await _friendService.sendFriendRequest(
        userId: widget.user.id,
        message: result,
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(context.l10n.requestSentTitle),
            content: Text(context.l10n.requestSentBody),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.confirm),
              ),
            ],
          );
        },
      );
    } on FriendException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isOperating = false);
    }
  }

  Future<void> _showRemarkDialog() async {
    String remark = _friendService.getRemark(widget.user.id);
    final l10n = context.l10n;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.setRemark),
          content: TextFormField(
            initialValue: remark,
            maxLength: 50,
            autofocus: true,
            onChanged: (value) => remark = value,
            decoration: InputDecoration(
              hintText: l10n.remarkHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, remark.trim()),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (result == null || !mounted) return;

    setState(() => _isOperating = true);

    try {
      await _friendService.updateRemark(
        friendId: widget.user.id,
        remark: result,
      );
    } on FriendException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isOperating = false);
    }
  }

  Future<void> _removeFriend() async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteFriend),
          content: Text(l10n.deleteFriendConfirm(widget.user.username)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isOperating = true);

    try {
      await _friendService.removeFriend(widget.user.id);
      if (!mounted) return;
      Navigator.pop(context);
    } on FriendException catch (e) {
      _showError(e.message);
      if (mounted) setState(() => _isOperating = false);
    }
  }

  Future<void> _cancelRequest() async {
    var request = _friendService.findSentRequestTo(widget.user.id);

    if (request == null) {
      try {
        await _friendService.refreshSentRequests();
        request = _friendService.findSentRequestTo(widget.user.id);
      } on FriendException catch (e) {
        _showError(e.message);
        return;
      }
    }

    if (request == null) {
      _showError(context.l10n.pendingCancelNotFound);
      return;
    }

    setState(() => _isOperating = true);

    try {
      await _friendService.cancelFriendRequest(request.id);
    } on FriendException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isOperating = false);
    }
  }

  Future<void> _openFriendRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FriendRequestsPage()),
    );

    if (mounted) await _loadFriendContext();
  }

  void _showError(String message) {
    if (!mounted) return;
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
    final remark = _friendService.getRemark(widget.user.id);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.userProfile)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildError()
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 20),
                    Center(child: _buildAvatar()),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        widget.user.username,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        widget.user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    AbsorbPointer(
                      absorbing: _isOperating,
                      child: Opacity(
                        opacity: _isOperating ? 0.6 : 1,
                        child: _buildActionButtons(remark),
                      ),
                    ),
                    if (_isOperating) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
    );
  }

  Widget _buildError() {
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
              onPressed: _loadFriendContext,
              child: Text(context.l10n.reload),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.user.avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(widget.user.avatarUrl),
      );
    }

    return CircleAvatar(
      radius: 48,
      child: Text(
        widget.user.username.isEmpty
            ? '?'
            : widget.user.username.characters.first.toUpperCase(),
        style: const TextStyle(fontSize: 32),
      ),
    );
  }

  Widget _buildStatusCard() {
    final l10n = context.l10n;
    late String title;
    late String subtitle;
    late IconData icon;

    switch (_status) {
      case FriendStatus.friends:
        title = l10n.statusFriend;
        subtitle = l10n.alreadyFriends;
        icon = Icons.people_alt_outlined;
        break;
      case FriendStatus.requestSent:
        title = l10n.friendRequestSent;
        subtitle = l10n.waitingApproval;
        icon = Icons.schedule;
        break;
      case FriendStatus.requestReceived:
        title = l10n.receivedFriendRequest;
        subtitle = l10n.friendRequestReceivedSubtitle;
        icon = Icons.person_add_alt_1;
        break;
      case FriendStatus.none:
        title = l10n.notFriendsYet;
        subtitle = l10n.canSendFriendRequest;
        icon = Icons.person_outline;
        break;
    }

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildActionButtons(String remark) {
    final l10n = context.l10n;

    switch (_status) {
      case FriendStatus.none:
        return SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _showAddFriendDialog,
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(l10n.addFriend),
          ),
        );
      case FriendStatus.requestSent:
        return Column(
          children: [
            Text(l10n.friendRequestSent, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _cancelRequest,
              child: Text(l10n.cancelRequest),
            ),
          ],
        );
      case FriendStatus.requestReceived:
        return SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: _openFriendRequests,
            child: Text(l10n.processFriendRequests),
          ),
        );
      case FriendStatus.friends:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FriendWardrobePage(user: widget.user),
                  ),
                );
              },
              icon: const Icon(Icons.checkroom_outlined),
              label: Text(l10n.viewWardrobe),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showRemarkDialog,
              icon: const Icon(Icons.edit_outlined),
              label: Text(
                remark.isEmpty ? l10n.setRemark : l10n.remarkValue(remark),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _removeFriend,
              icon: const Icon(Icons.person_remove_outlined),
              label: Text(l10n.removeFriend),
            ),
          ],
        );
    }
  }
}
