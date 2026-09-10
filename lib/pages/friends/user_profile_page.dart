import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/friend_service.dart';
import 'friend_requests_page.dart';

class UserProfilePage extends StatefulWidget {
  final AppUser user;

  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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

  FriendStatus get _status {
    return _friendService.getFriendStatus(widget.user.id);
  }

  /// 添加好友
  Future<void> _showAddFriendDialog() async {
    String message = '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('添加好友'),
          content: TextField(
            maxLines: 4,
            maxLength: 200,
            autofocus: true,
            onChanged: (value) {
              message = value;
            },
            decoration: const InputDecoration(
              hintText: '介绍一下自己吧',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, message.trim());
              },
              child: const Text('发送申请'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    try {
      await _friendService.sendFriendRequest(
        userId: widget.user.id,
        message: result,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('申请已发送'),
            content: const Text('好友申请已经发送，等待对方同意。'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        setState(() {});
      }
    } on FriendException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    }
  }

  /// 设置好友备注
  Future<void> _showRemarkDialog() async {
    String remark = _friendService.getRemark(widget.user.id);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('设置备注'),
              content: TextField(
                maxLength: 30,
                autofocus: true,
                onChanged: (value) {
                  remark = value;
                },
                decoration: const InputDecoration(
                  hintText: '请输入好友备注',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, remark.trim());
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      await _friendService.updateRemark(
        friendId: widget.user.id,
        remark: result,
      );

      if (mounted) {
        setState(() {});
      }
    } on FriendException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    }
  }

  /// 删除好友
  Future<void> _removeFriend() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('删除好友'),
          content: Text('确定要删除 ${widget.user.username} 吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _friendService.removeFriend(widget.user.id);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } on FriendException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    }
  }

  /// 取消好友申请
  Future<void> _cancelRequest() async {
    final request = _friendService.sentRequests
        .where((request) => request.toUser.id == widget.user.id)
        .firstOrNull;

    if (request == null) {
      return;
    }

    try {
      await _friendService.cancelFriendRequest(request.id);

      if (mounted) {
        setState(() {});
      }
    } on FriendException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    }
  }

  /// 显示错误
  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final remark = _friendService.getRemark(widget.user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('用户介绍')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),

          // 头像
          Center(child: _buildAvatar()),

          const SizedBox(height: 20),

          // 用户名
          Center(
            child: Text(
              widget.user.username,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          // 邮箱
          Center(
            child: Text(
              widget.user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 好友状态
          _buildStatusCard(),

          const SizedBox(height: 20),

          // 操作按钮
          _buildActionButtons(remark),
        ],
      ),
    );
  }

  /// 头像
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

  /// 好友状态卡片
  Widget _buildStatusCard() {
    String title;
    String subtitle;
    IconData icon;

    switch (_status) {
      case FriendStatus.friends:
        title = '好友';
        subtitle = '你们已经是好友';
        icon = Icons.people_alt_outlined;
        break;

      case FriendStatus.requestSent:
        title = '好友申请已发送';
        subtitle = '等待对方同意';
        icon = Icons.schedule;
        break;

      case FriendStatus.requestReceived:
        title = '收到好友申请';
        subtitle = '对方已经向你发送了好友申请';
        icon = Icons.person_add_alt_1;
        break;

      case FriendStatus.none:
        title = '还不是好友';
        subtitle = '可以发送好友申请';
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

  /// 根据好友状态显示操作
  Widget _buildActionButtons(String remark) {
    switch (_status) {
      case FriendStatus.none:
        return SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _showAddFriendDialog,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('添加好友'),
          ),
        );

      case FriendStatus.requestSent:
        return Column(
          children: [
            const Text('好友申请已发送', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _cancelRequest,
              child: const Text('取消申请'),
            ),
          ],
        );

      case FriendStatus.requestReceived:
        return SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendRequestsPage()),
              );
            },
            child: const Text('前往处理好友申请'),
          ),
        );

      case FriendStatus.friends:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _showRemarkDialog,
              icon: const Icon(Icons.edit_outlined),
              label: Text(remark.isEmpty ? '设置备注' : '备注：$remark'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _removeFriend,
              icon: const Icon(Icons.person_remove_outlined),
              label: const Text('删除好友'),
            ),
          ],
        );
    }
  }
}
