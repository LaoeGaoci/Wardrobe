import 'package:flutter/material.dart';

import '../../services/friend_service.dart';
import '../friends/friend_requests_page.dart';

/// 通知类型
enum AppNotificationType {
  system,
  friendRequest,
  recommendation,
}

/// 通知
class AppNotification {
  final String id;
  final AppNotificationType type;
  final String title;
  final String content;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}

/// 通知页面
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FriendService _friendService = FriendService.instance;

  /// 系统通知
  final List<AppNotification> _systemNotifications = [
    AppNotification(
      id: 'system_001',
      type: AppNotificationType.system,
      title: '系统更新',
      content: '衣柜应用已完成一次更新，欢迎体验新的功能。',
      createdAt: DateTime(2026, 9, 1),
    ),
  ];

  /// 推荐通知
  final List<AppNotification> _recommendations = [
    AppNotification(
      id: 'recommendation_001',
      type: AppNotificationType.recommendation,
      title: '好友推荐',
      content: '发现了一些你可能认识的用户。',
      createdAt: DateTime(2026, 9, 2),
    ),
  ];

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

  /// 好友申请转换为通知
  List<AppNotification> get _friendRequestNotifications {
    return _friendService.receivedRequests.map((request) {
      return AppNotification(
        id: request.id,
        type: AppNotificationType.friendRequest,
        title: '好友申请',
        content: '${request.fromUser.username} 向你发送了好友申请',
        createdAt: request.createdAt,
      );
    }).toList();
  }

  /// 所有通知
  List<AppNotification> get _notifications {
    final notifications = [
      ..._systemNotifications,
      ..._friendRequestNotifications,
      ..._recommendations,
    ];

    notifications.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return notifications;
  }

  /// 未读通知数量
  ///
  /// 当前阶段：
  /// - 好友申请 = 未读
  /// - 系统/推荐通知暂时不参与未读计算
  int get unreadCount {
    return _friendService.receivedRequestCount;
  }

  void _openNotification(AppNotification notification) {
    switch (notification.type) {
      case AppNotificationType.friendRequest:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FriendRequestsPage(),
          ),
        );
        break;

      case AppNotificationType.system:
      case AppNotificationType.recommendation:
        _showNotificationDetail(notification);
        break;
    }
  }

  void _showNotificationDetail(AppNotification notification) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification.title),
          content: Text(notification.content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  IconData _getIcon(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.system:
        return Icons.system_update_outlined;

      case AppNotificationType.friendRequest:
        return Icons.person_add_alt_1_outlined;

      case AppNotificationType.recommendation:
        return Icons.auto_awesome_outlined;
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} 分钟前';
    }

    if (difference.inDays < 1) {
      return '${difference.inHours} 小时前';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    }

    return '${dateTime.year}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '通知',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          return _buildNotificationTile(
            notifications[index],
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(
      AppNotification notification,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(
            _getIcon(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            notification.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Text(
          _formatDate(notification.createdAt),
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () {
          _openNotification(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 56,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无通知',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
        ],
      ),
    );
  }
}