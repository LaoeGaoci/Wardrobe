import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/friend_service.dart';

import 'friend_requests_page.dart';
import 'friend_wardrobe_page.dart';

class UserProfilePage
    extends StatefulWidget {
  final AppUser user;

  const UserProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<UserProfilePage>
  createState() =>
      _UserProfilePageState();
}

class _UserProfilePageState
    extends State<UserProfilePage> {
  final FriendService _friendService =
      FriendService.instance;

  bool _isLoading = true;

  String? _loadError;

  bool _isOperating = false;

  @override
  void initState() {
    super.initState();

    _friendService.addListener(
      _onFriendChanged,
    );

    Future.microtask(
      _loadFriendContext,
    );
  }

  @override
  void dispose() {
    _friendService.removeListener(
      _onFriendChanged,
    );

    super.dispose();
  }

  void _onFriendChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  FriendStatus get _status =>
      _friendService.getFriendStatus(
        widget.user.id,
      );

  // ============================================================
  // Initial loading
  // ============================================================

  Future<void>
  _loadFriendContext() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      /// 好友列表用于获取 remark。
      await _friendService
          .refreshFriends();

      /// 申请列表用于：
      ///
      /// requestSent
      /// requestReceived
      /// 以及取消申请时找到 requestId。
      await _friendService
          .refreshRequests();

      /// 再向专用 status API 确认一次
      /// 当前用户与这个用户的最终状态。
      await _friendService
          .refreshFriendStatus(
        widget.user.id,
      );
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
  // Add friend
  // ============================================================

  Future<void>
  _showAddFriendDialog() async {
    String message = '';

    final result =
    await showDialog<String>(
      context: context,
      builder:
          (dialogContext) {
        return StatefulBuilder(
          builder:
              (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title:
              const Text(
                '添加好友',
              ),
              content:
              TextField(
                maxLines: 4,
                maxLength: 200,
                autofocus: true,
                onChanged:
                    (value) {
                  message =
                      value;

                  setDialogState(
                        () {},
                  );
                },
                decoration:
                const InputDecoration(
                  hintText:
                  '介绍一下自己吧',
                  border:
                  OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                  const Text(
                    '取消',
                  ),
                ),
                FilledButton(
                  onPressed:
                  message
                      .trim()
                      .isEmpty
                      ? null
                      : () {
                    Navigator.pop(
                      dialogContext,
                      message
                          .trim(),
                    );
                  },
                  child:
                  const Text(
                    '发送申请',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null ||
        result.isEmpty) {
      return;
    }

    setState(() {
      _isOperating = true;
    });

    try {
      await _friendService
          .sendFriendRequest(
        userId:
        widget.user.id,
        message:
        result,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder:
            (dialogContext) {
          return AlertDialog(
            title:
            const Text(
              '申请已发送',
            ),
            content:
            const Text(
              '好友申请已经发送，等待对方同意。',
            ),
            actions: [
              FilledButton(
                onPressed:
                    () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child:
                const Text(
                  '确定',
                ),
              ),
            ],
          );
        },
      );
    } on FriendException catch (e) {
      _showError(
        e.message,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOperating =
          false;
        });
      }
    }
  }

  // ============================================================
  // Remark
  // ============================================================

  Future<void> _showRemarkDialog() async {
    String remark =
    _friendService.getRemark(
      widget.user.id,
    );

    final result =
    await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            '设置备注',
          ),

          content: TextFormField(
            /// 直接设置初始内容，
            /// 不再使用 TextEditingController。
            initialValue: remark,

            maxLength: 50,

            autofocus: true,

            onChanged: (value) {
              remark = value;
            },

            decoration:
            const InputDecoration(
              hintText:
              '请输入好友备注',
              border:
              OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                '取消',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  remark.trim(),
                );
              },
              child: const Text(
                '保存',
              ),
            ),
          ],
        );
      },
    );

    /// 用户点击取消。
    if (result == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isOperating = true;
    });

    try {
      /// PATCH /api/friends/:friendId
      ///
      /// {
      ///   "remark": "..."
      /// }
      await _friendService.updateRemark(
        friendId:
        widget.user.id,
        remark:
        result,
      );
    } on FriendException catch (e) {
      _showError(
        e.message,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOperating = false;
        });
      }
    }
  }

  // ============================================================
  // Remove friend
  // ============================================================

  Future<void>
  _removeFriend() async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            '删除好友',
          ),
          content: Text(
            '确定要删除 '
                '${widget.user.username} '
                '吗？',
          ),
          actions: [
            TextButton(
              onPressed:
                  () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
              const Text(
                '取消',
              ),
            ),
            FilledButton(
              onPressed:
                  () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
              const Text(
                '删除',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isOperating = true;
    });

    try {
      await _friendService
          .removeFriend(
        widget.user.id,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
      );
    } on FriendException catch (e) {
      _showError(
        e.message,
      );

      if (mounted) {
        setState(() {
          _isOperating =
          false;
        });
      }
    }
  }

  // ============================================================
  // Cancel request
  // ============================================================

  Future<void>
  _cancelRequest() async {
    var request =
    _friendService
        .findSentRequestTo(
      widget.user.id,
    );

    /// 当前缓存里没有时，
    /// 主动重新从后端取一次。
    if (request == null) {
      try {
        await _friendService
            .refreshSentRequests();

        request =
            _friendService
                .findSentRequestTo(
              widget.user.id,
            );
      } on FriendException catch (e) {
        _showError(
          e.message,
        );

        return;
      }
    }

    if (request == null) {
      _showError(
        '未找到待取消的好友申请',
      );

      return;
    }

    setState(() {
      _isOperating = true;
    });

    try {
      await _friendService
          .cancelFriendRequest(
        request.id,
      );
    } on FriendException catch (e) {
      _showError(
        e.message,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOperating =
          false;
        });
      }
    }
  }

  // ============================================================
  // Requests page
  // ============================================================

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
      await _loadFriendContext();
    }
  }

  // ============================================================
  // Error
  // ============================================================

  void _showError(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),
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
    final remark =
    _friendService
        .getRemark(
      widget.user.id,
    );

    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          '用户介绍',
        ),
      ),
      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : _loadError != null
          ? _buildError()
          : ListView(
        padding:
        const EdgeInsets
            .all(
          24,
        ),
        children: [
          const SizedBox(
            height: 20,
          ),

          Center(
            child:
            _buildAvatar(),
          ),

          const SizedBox(
            height: 20,
          ),

          Center(
            child: Text(
              widget.user
                  .username,
              style:
              Theme.of(
                context,
              )
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight:
                FontWeight
                    .bold,
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Center(
            child: Text(
              widget.user
                  .email,
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
          ),

          const SizedBox(
            height: 32,
          ),

          _buildStatusCard(),

          const SizedBox(
            height: 20,
          ),

          AbsorbPointer(
            absorbing:
            _isOperating,
            child:
            Opacity(
              opacity:
              _isOperating
                  ? 0.6
                  : 1,
              child:
              _buildActionButtons(
                remark,
              ),
            ),
          ),

          if (_isOperating) ...[
            const SizedBox(
              height: 20,
            ),
            const Center(
              child:
              CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError() {
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
            Text(
              _loadError!,
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            FilledButton(
              onPressed:
              _loadFriendContext,
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

  // ============================================================
  // Avatar
  // ============================================================

  Widget _buildAvatar() {
    if (widget.user.avatarUrl
        .isNotEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundImage:
        NetworkImage(
          widget.user.avatarUrl,
        ),
      );
    }

    return CircleAvatar(
      radius: 48,
      child: Text(
        widget.user.username.isEmpty
            ? '?'
            : widget
            .user
            .username
            .characters
            .first
            .toUpperCase(),
        style:
        const TextStyle(
          fontSize: 32,
        ),
      ),
    );
  }

  // ============================================================
  // Status card
  // ============================================================

  Widget _buildStatusCard() {
    String title;
    String subtitle;
    IconData icon;

    switch (_status) {
      case FriendStatus.friends:
        title = '好友';
        subtitle =
        '你们已经是好友';
        icon =
            Icons
                .people_alt_outlined;
        break;

      case FriendStatus.requestSent:
        title =
        '好友申请已发送';
        subtitle =
        '等待对方同意';
        icon =
            Icons.schedule;
        break;

      case FriendStatus.requestReceived:
        title =
        '收到好友申请';
        subtitle =
        '对方已经向你发送了好友申请';
        icon =
            Icons
                .person_add_alt_1;
        break;

      case FriendStatus.none:
        title =
        '还不是好友';
        subtitle =
        '可以发送好友申请';
        icon =
            Icons.person_outline;
        break;
    }

    return Card(
      child: ListTile(
        leading:
        Icon(icon),
        title:
        Text(title),
        subtitle:
        Text(subtitle),
      ),
    );
  }

  // ============================================================
  // Action buttons
  // ============================================================

  Widget _buildActionButtons(
      String remark,
      ) {
    switch (_status) {
      case FriendStatus.none:
        return SizedBox(
          height: 48,
          child:
          FilledButton.icon(
            onPressed:
            _showAddFriendDialog,
            icon:
            const Icon(
              Icons
                  .person_add_alt_1,
            ),
            label:
            const Text(
              '添加好友',
            ),
          ),
        );

      case FriendStatus.requestSent:
        return Column(
          children: [
            const Text(
              '好友申请已发送',
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(
              height: 12,
            ),
            OutlinedButton(
              onPressed:
              _cancelRequest,
              child:
              const Text(
                '取消申请',
              ),
            ),
          ],
        );

      case FriendStatus.requestReceived:
        return SizedBox(
          height: 48,
          child:
          FilledButton(
            onPressed:
            _openFriendRequests,
            child:
            const Text(
              '前往处理好友申请',
            ),
          ),
        );

      case FriendStatus.friends:
        return Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,
          children: [
            FilledButton.icon(
              onPressed:
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                        FriendWardrobePage(
                          user:
                          widget.user,
                        ),
                  ),
                );
              },
              icon:
              const Icon(
                Icons
                    .checkroom_outlined,
              ),
              label:
              const Text(
                '查看衣柜',
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton.icon(
              onPressed:
              _showRemarkDialog,
              icon:
              const Icon(
                Icons.edit_outlined,
              ),
              label: Text(
                remark.isEmpty
                    ? '设置备注'
                    : '备注：$remark',
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton.icon(
              onPressed:
              _removeFriend,
              icon:
              const Icon(
                Icons
                    .person_remove_outlined,
              ),
              label:
              const Text(
                '删除好友',
              ),
            ),
          ],
        );
    }
  }
}