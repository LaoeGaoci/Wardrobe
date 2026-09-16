enum AppNotificationType {
  friendRequest,
  recommendation,
  systemNotification,
}

AppNotificationType
parseAppNotificationType(
  String value,
) {
  switch (value) {
    case 'friend_request':
      return AppNotificationType
          .friendRequest;

    case 'recommendation':
      return AppNotificationType
          .recommendation;

    case 'system_notification':
      return AppNotificationType
          .systemNotification;

    default:
      throw FormatException(
        'Unknown notification type: $value',
      );
  }
}

class AppNotificationSender {
  final String id;
  final String username;
  final String avatarUrl;

  const AppNotificationSender({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  factory AppNotificationSender
      .fromJson(
    Map<String, dynamic> json,
  ) {
    return AppNotificationSender(
      id:
          json['id'] as String,

      username:
          json['username']
              as String? ??
          '',

      avatarUrl:
          json['avatarUrl']
              as String? ??
          '',
    );
  }
}

class AppNotification {
  final int seq;
  final String id;
  final AppNotificationType type;
  final String? resourceId;
  final String? title;
  final String? message;
  final AppNotificationSender? sender;
  final DateTime createdAt;

  const AppNotification({
    required this.seq,
    required this.id,
    required this.type,
    required this.resourceId,
    required this.title,
    required this.message,
    required this.sender,
    required this.createdAt,
  });

  factory AppNotification.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawSeq =
        json['seq'];

    if (rawSeq is! num) {
      throw const FormatException(
        'Invalid notification seq',
      );
    }

    final rawSender =
        json['sender'];

    return AppNotification(
      seq:
          rawSeq.toInt(),

      id:
          json['id'] as String,

      type:
          parseAppNotificationType(
        json['type']
            as String,
      ),

      resourceId:
          json['resourceId']
              as String?,

      title:
          json['title']
              as String?,

      message:
          json['message']
              as String?,

      sender:
          rawSender is Map
              ? AppNotificationSender
                  .fromJson(
                  Map<String, dynamic>
                      .from(
                    rawSender,
                  ),
                )
              : null,

      createdAt:
          DateTime.parse(
        json['createdAt']
            as String,
      ),
    );
  }
}

class NotificationPollResult {
  final List<AppNotification>
      notifications;

  final int nextCursor;

  const NotificationPollResult({
    required this.notifications,
    required this.nextCursor,
  });
}
