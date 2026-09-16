import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

enum PushNotificationType { friendRequest, recommendation, systemNotification }

class PushNotificationPayload {
  final PushNotificationType type;
  final String? notificationId;
  final String? resourceId;
  final String? title;
  final String? body;

  const PushNotificationPayload({
    required this.type,
    this.notificationId,
    this.resourceId,
    this.title,
    this.body,
  });

  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);

    return PushNotificationPayload.fromMap({
      ...data,
      'title': message.notification?.title ?? data['title'],
      'body': message.notification?.body ?? data['body'],
    });
  }

  factory PushNotificationPayload.fromMap(Map<String, dynamic> data) {
    final rawType = data['type']?.toString().trim();

    final type = switch (rawType) {
      'friend_request' => PushNotificationType.friendRequest,
      'recommendation' => PushNotificationType.recommendation,
      'system_notification' => PushNotificationType.systemNotification,
      _ => throw FormatException('Unknown push notification type: $rawType'),
    };

    return PushNotificationPayload(
      type: type,
      notificationId: _nullableText(data['notificationId']),
      resourceId: _nullableText(data['resourceId']),
      title: _nullableText(data['title']),
      body: _nullableText(data['body']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': switch (type) {
        PushNotificationType.friendRequest => 'friend_request',
        PushNotificationType.recommendation => 'recommendation',
        PushNotificationType.systemNotification => 'system_notification',
      },
      if (notificationId != null) 'notificationId': notificationId,
      if (resourceId != null) 'resourceId': resourceId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
    };
  }

  String encode() {
    return jsonEncode(toMap());
  }

  factory PushNotificationPayload.decode(String value) {
    final decoded = jsonDecode(value);

    if (decoded is! Map) {
      throw const FormatException('Invalid notification payload');
    }

    return PushNotificationPayload.fromMap(Map<String, dynamic>.from(decoded));
  }

  static String? _nullableText(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }
}
