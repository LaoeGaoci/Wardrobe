import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/notification/push_notification_payload.dart';
import '../../pages/friends/friend_requests_page.dart';
import '../../pages/home/recommendation_envelope_dialog.dart';
import '../../pages/notification/system_notification_page.dart';
import '../users/auth_service.dart';
import '../friends/recommendation_service.dart';

class NotificationRouter {
  NotificationRouter._() {
    AuthService.instance.addListener(_handleAuthChanged);
  }

  static final NotificationRouter instance = NotificationRouter._();

  /// 必须设置到 MaterialApp.navigatorKey。
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 使用队列而不是单一 pendingPayload。
  ///
  /// 这样在 App 启动 / Auth restore 期间如果连续收到多个点击事件，
  /// 不会让后一个覆盖前一个。
  final Queue<PushNotificationPayload> _pendingPayloads =
      Queue<PushNotificationPayload>();

  bool _routing = false;
  bool _flushScheduled = false;

  // ============================================================
  // Public
  // ============================================================

  void route(PushNotificationPayload payload) {
    _pendingPayloads.addLast(payload);

    _scheduleFlush();
  }

  // ============================================================
  // Auth
  // ============================================================

  void _handleAuthChanged() {
    if (AuthService.instance.status == AuthStatus.authenticated) {
      _scheduleFlush();
    }
  }

  // ============================================================
  // Flush
  // ============================================================

  void _scheduleFlush() {
    if (_flushScheduled) {
      return;
    }

    _flushScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;

      unawaited(_flush());
    });
  }

  Future<void> _flush() async {
    if (_routing) {
      return;
    }

    if (_pendingPayloads.isEmpty) {
      return;
    }

    if (AuthService.instance.status != AuthStatus.authenticated) {
      // 等待 AuthService 完成 session restore / login。
      return;
    }

    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      _scheduleFlush();
      return;
    }

    _routing = true;

    try {
      while (_pendingPayloads.isNotEmpty &&
          AuthService.instance.status == AuthStatus.authenticated) {
        final payload = _pendingPayloads.removeFirst();

        try {
          await _routeOne(navigator, payload);
        } catch (error, stackTrace) {
          debugPrint(
            '[NotificationRouter] '
            'route failed: $error',
          );
          debugPrint('$stackTrace');

          _showError(navigator);
        }
      }
    } finally {
      _routing = false;

      if (_pendingPayloads.isNotEmpty) {
        _scheduleFlush();
      }
    }
  }

  Future<void> _routeOne(
    NavigatorState navigator,
    PushNotificationPayload payload,
  ) async {
    switch (payload.type) {
      case PushNotificationType.friendRequest:
        await _openFriendRequests(navigator);
        break;

      case PushNotificationType.recommendation:
        await _openRecommendation(navigator, payload);
        break;

      case PushNotificationType.systemNotification:
        await _openSystemNotification(navigator, payload);
        break;
    }
  }

  // ============================================================
  // Friend request
  // ============================================================

  Future<void> _openFriendRequests(NavigatorState navigator) {
    return navigator.push(
      MaterialPageRoute<void>(builder: (_) => const FriendRequestsPage()),
    );
  }

  // ============================================================
  // Recommendation
  // ============================================================

  Future<void> _openRecommendation(
    NavigatorState navigator,
    PushNotificationPayload payload,
  ) async {
    final recommendationId = payload.resourceId;

    if (recommendationId == null || recommendationId.isEmpty) {
      throw const FormatException('Recommendation resourceId is missing');
    }

    final recommendation = await RecommendationService.instance
        .fetchRecommendation(recommendationId);

    if (!navigator.mounted) {
      return;
    }

    await showDialog<void>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (_) =>
          RecommendationEnvelopeDialog(recommendation: recommendation),
    );
  }

  // ============================================================
  // System notification
  // ============================================================

  Future<void> _openSystemNotification(
    NavigatorState navigator,
    PushNotificationPayload payload,
  ) {
    return navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => SystemNotificationPage(payload: payload),
      ),
    );
  }

  // ============================================================
  // Error
  // ============================================================

  void _showError(NavigatorState navigator) {
    if (!navigator.mounted) {
      return;
    }

    final context = navigator.context;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.notificationOpenFailed)),
      );
  }
}
