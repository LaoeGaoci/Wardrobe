import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../models/app_notification.dart';
import 'auth_service.dart';
import 'notification_repository.dart';

class NotificationService
    extends ChangeNotifier {
  NotificationService._() {
    _authService.addListener(
      _handleAuthChanged,
    );
  }

  static final NotificationService
      instance =
      NotificationService._();

  // ==========================================================
  // SharedPreference keys
  // ==========================================================

  static const String enabledKey =
      'notifications_enabled';

  static const String activeUserKey =
      'notification_active_user_id';

  static const String languageKey =
      'app_language';

  static String cursorKey(
    String userId,
  ) =>
      'notification_cursor:$userId';

  // ==========================================================
  // WorkManager
  // ==========================================================

  static const String
      backgroundTaskUniqueName =
      'wardrobe_notification_poll';

  static const String
      backgroundTaskName =
      'wardrobe_notification_poll';

  // ==========================================================
  // Android notification channel
  // ==========================================================

  static const String channelId =
      'wardrobe_notifications';

  static const String channelName =
      'Wardrobe Notifications';

  static const String
      channelDescription =
      'Friend requests, clothing recommendations and system notifications';

  static final
      FlutterLocalNotificationsPlugin
      _localNotifications =
      FlutterLocalNotificationsPlugin();

  final NotificationRepository
      _repository =
      NotificationRepository.instance;

  final AuthService _authService =
      AuthService.instance;

  bool _initialized =
      false;

  bool _enabled =
      false;

  String? _activeUserId;

  bool get enabled =>
      _enabled;

  String? get activeUserId =>
      _activeUserId;

  // ==========================================================
  // Initialize
  // ==========================================================

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized =
        true;

    const android =
        AndroidInitializationSettings(
      'ic_launcher',
    );

    const settings =
        InitializationSettings(
      android:
          android,
    );

    await _localNotifications
        .initialize(
      settings:
          settings,
    );

    final preferences =
        await SharedPreferences
            .getInstance();

    await preferences.reload();

    _enabled =
        preferences.getBool(
          enabledKey,
        ) ??
        false;

    _activeUserId =
        preferences.getString(
      activeUserKey,
    );

    // Do not clear a saved user while AuthService is still
    // restoring its secure-storage session.
    await _syncActiveUserFromAuth();

    if (_enabled) {
      final allowed =
          await areSystemNotificationsEnabled();

      if (!allowed) {
        _enabled =
            false;

        await preferences
            .setBool(
          enabledKey,
          false,
        );

        await _cancelBackgroundTask();
      } else if (
        _activeUserId != null
      ) {
        await _ensureBackgroundTask();
      }
    }

    notifyListeners();
  }

  // ==========================================================
  // Auth synchronization
  // ==========================================================

  void _handleAuthChanged() {
    unawaited(
      _syncActiveUserFromAuth(),
    );
  }

  Future<void>
      _syncActiveUserFromAuth() async {
    final status =
        _authService.status;

    // During restore/temporary restore failure, keep the last
    // persisted user so Android background work remains stable.
    if (
      status ==
          AuthStatus.restoring ||
      status ==
          AuthStatus.restoreFailed
    ) {
      return;
    }

    final userId =
        status ==
                AuthStatus
                    .authenticated
            ? _authService
                .currentUser
                ?.id
            : null;

    if (
      _activeUserId ==
      userId
    ) {
      if (
        userId != null &&
        _enabled
      ) {
        await _ensureBackgroundTask();
      }

      return;
    }

    _activeUserId =
        userId;

    final preferences =
        await SharedPreferences
            .getInstance();

    if (userId == null) {
      await preferences.remove(
        activeUserKey,
      );

      await _cancelBackgroundTask();

      notifyListeners();

      return;
    }

    await preferences.setString(
      activeUserKey,
      userId,
    );

    if (_enabled) {
      await _ensureCursor(
        userId,
      );

      await _ensureBackgroundTask();
    }

    notifyListeners();
  }

  // ==========================================================
  // Settings switch
  // ==========================================================

  Future<bool> setEnabled(
    bool value,
  ) async {
    final preferences =
        await SharedPreferences
            .getInstance();

    if (!value) {
      _enabled =
          false;

      await preferences.setBool(
        enabledKey,
        false,
      );

      await _cancelBackgroundTask();

      notifyListeners();

      return true;
    }

    final granted =
        await _requestSystemPermission();

    if (!granted) {
      _enabled =
          false;

      await preferences.setBool(
        enabledKey,
        false,
      );

      await _cancelBackgroundTask();

      notifyListeners();

      return false;
    }

    _enabled =
        true;

    await preferences.setBool(
      enabledKey,
      true,
    );

    final userId =
        _activeUserId;

    if (
      userId != null &&
      userId.isNotEmpty
    ) {
      // Start from "now" on the first enable so historical
      // records do not suddenly become Android notifications.
      await _ensureCursor(
        userId,
      );

      await _ensureBackgroundTask();
    }

    notifyListeners();

    return true;
  }

  // ==========================================================
  // Android permission
  // ==========================================================

  Future<bool>
      _requestSystemPermission() async {
    final android =
        _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) {
      return true;
    }

    final granted =
        await android
            .requestNotificationsPermission();

    if (granted == true) {
      return true;
    }

    return await android
            .areNotificationsEnabled() ??
        false;
  }

  static Future<bool>
      areSystemNotificationsEnabled() async {
    final android =
        _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) {
      return true;
    }

    return await android
            .areNotificationsEnabled() ??
        false;
  }

  Future<void>
      openSystemNotificationSettings() async {
    await _localNotifications
        .openAppNotificationSettings();
  }

  // ==========================================================
  // Cursor
  // ==========================================================

  Future<void> _ensureCursor(
    String userId,
  ) async {
    final preferences =
        await SharedPreferences
            .getInstance();

    final key =
        cursorKey(
      userId,
    );

    if (
      preferences.containsKey(
        key,
      )
    ) {
      return;
    }

    try {
      final cursor =
          await _repository
              .fetchCurrentCursor();

      await preferences.setInt(
        key,
        cursor,
      );
    } catch (_) {
      // The background worker will initialize this cursor on
      // its first successful network run.
    }
  }

  // ==========================================================
  // WorkManager
  // ==========================================================

  Future<void>
      _ensureBackgroundTask() async {
    if (
      !_enabled ||
      _activeUserId == null
    ) {
      return;
    }

    await Workmanager()
        .registerPeriodicTask(
      backgroundTaskUniqueName,
      backgroundTaskName,

      frequency:
          const Duration(
        minutes: 15,
      ),

      existingWorkPolicy:
          ExistingPeriodicWorkPolicy
              .update,

      constraints:
          Constraints(
        networkType:
            NetworkType.connected,
      ),
    );
  }

  Future<void>
      _cancelBackgroundTask() async {
    await Workmanager()
        .cancelByUniqueName(
      backgroundTaskUniqueName,
    );
  }

  // ==========================================================
  // Background plugin initialization
  // ==========================================================

  static Future<void>
      initializeForBackground() async {
    const android =
        AndroidInitializationSettings(
      'ic_launcher',
    );

    const settings =
        InitializationSettings(
      android:
          android,
    );

    await _localNotifications
        .initialize(
      settings:
          settings,
    );
  }

  // ==========================================================
  // Show
  // ==========================================================

  static Future<void>
      showLocalNotification(
    AppNotification notification, {
    required String languageCode,
  }) async {
    final text =
        _notificationText(
      notification,
      languageCode,
    );

    const androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,

      channelDescription:
          channelDescription,

      importance:
          Importance.high,

      priority:
          Priority.high,
    );

    const details =
        NotificationDetails(
      android:
          androidDetails,
    );

    final notificationId =
        notification.seq &
            0x7fffffff;

    await _localNotifications
        .show(
      id:
          notificationId,

      title:
          text.$1,

      body:
          text.$2,

      notificationDetails:
          details,

      payload:
          notification
              .resourceId,
    );
  }

  static (String, String)
      _notificationText(
    AppNotification notification,
    String languageCode,
  ) {
    final sender =
        notification.sender
                ?.username
                .trim()
                .isNotEmpty ==
            true
        ? notification
            .sender!
            .username
        : 'Wardrobe';

    final english =
        languageCode ==
            'en';

    final traditional =
        languageCode ==
            'zh_Hant';

    switch (notification.type) {
      case AppNotificationType
            .friendRequest:
        if (english) {
          return (
            'New friend request',
            '$sender sent you a friend request',
          );
        }

        if (traditional) {
          return (
            '新的好友請求',
            '$sender 向你傳送了好友請求',
          );
        }

        return (
          '新的好友请求',
          '$sender 向你发送了好友请求',
        );

      case AppNotificationType
            .recommendation:
        if (english) {
          return (
            'New clothing recommendation',
            '$sender sent you a clothing recommendation',
          );
        }

        if (traditional) {
          return (
            '新的衣物推薦',
            '$sender 給你傳送了一份衣物推薦',
          );
        }

        return (
          '新的衣物推荐',
          '$sender 给你发送了一份衣物推荐',
        );

      case AppNotificationType
            .systemNotification:
        return (
          notification.title ??
              'Wardrobe',

          notification.message ??
              '',
        );
    }
  }
}
