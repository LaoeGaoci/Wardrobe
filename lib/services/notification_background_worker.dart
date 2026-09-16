import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_repository.dart';
import 'notification_service.dart';
import 'session_storage.dart';

@pragma('vm:entry-point')
void notificationCallbackDispatcher() {
  Workmanager()
      .executeTask(
    (
      taskName,
      inputData,
    ) async {
      WidgetsFlutterBinding
          .ensureInitialized();

      DartPluginRegistrant
          .ensureInitialized();

      if (
        taskName !=
        NotificationService
            .backgroundTaskName
      ) {
        return true;
      }

      try {
        return await _pollNotifications();
      } on NotificationRepositoryException
          catch (e) {
        debugPrint(
          '[NotificationWorker] '
          '${e.message}',
        );

        // 401 will not become valid merely by immediately
        // retrying the same background task.
        if (
          e.statusCode ==
          401
        ) {
          return true;
        }

        return false;
      } catch (
        e,
        stackTrace
      ) {
        debugPrint(
          '[NotificationWorker] '
          '$e\n$stackTrace',
        );

        return false;
      }
    },
  );
}

Future<bool>
    _pollNotifications() async {
  final preferences =
      await SharedPreferences
          .getInstance();

  await preferences.reload();

  final enabled =
      preferences.getBool(
        NotificationService
            .enabledKey,
      ) ??
      false;

  if (!enabled) {
    return true;
  }

  final userId =
      preferences.getString(
    NotificationService
        .activeUserKey,
  );

  if (
    userId == null ||
    userId.trim().isEmpty
  ) {
    return true;
  }

  final token =
      await SessionStorage
          .instance
          .readAccessToken();

  if (
    token == null ||
    token.isEmpty
  ) {
    return true;
  }

  await NotificationService
      .initializeForBackground();

  // If Android permission was later disabled in system
  // settings, do not consume the server cursor.
  final allowed =
      await NotificationService
          .areSystemNotificationsEnabled();

  if (!allowed) {
    return true;
  }

  final cursorKey =
      NotificationService
          .cursorKey(
    userId,
  );

  int? cursor =
      preferences.getInt(
    cursorKey,
  );

  // First successful background run starts at the server's
  // current end position to avoid showing old history.
  if (cursor == null) {
    cursor =
        await NotificationRepository
            .fetchCurrentCursorWithToken(
      token:
          token,
    );

    await preferences.setInt(
      cursorKey,
      cursor,
    );

    return true;
  }

  final result =
      await NotificationRepository
          .pollWithToken(
    token:
        token,

    afterSeq:
        cursor,
  );

  final languageCode =
      preferences.getString(
        NotificationService
            .languageKey,
      ) ??
      _systemLanguageCode();

  var processedCursor =
      cursor;

  for (
    final notification
    in result.notifications
  ) {
    await NotificationService
        .showLocalNotification(
      notification,
      languageCode:
          languageCode,
    );

    processedCursor =
        notification.seq;

    // Persist after every successfully displayed notification.
    await preferences.setInt(
      cursorKey,
      processedCursor,
    );
  }

  // The backend may have scanned read rows that were filtered
  // from notifications. Advance over those rows too.
  if (
    result.nextCursor >
    processedCursor
  ) {
    await preferences.setInt(
      cursorKey,
      result.nextCursor,
    );
  }

  return true;
}

String _systemLanguageCode() {
  final locale =
      PlatformDispatcher
          .instance
          .locale;

  if (
    locale.languageCode ==
    'en'
  ) {
    return 'en';
  }

  if (
    locale.languageCode ==
    'zh'
  ) {
    final traditional =
        locale.scriptCode ==
                'Hant' ||
            locale.countryCode ==
                'TW' ||
            locale.countryCode ==
                'HK' ||
            locale.countryCode ==
                'MO';

    return traditional
        ? 'zh_Hant'
        : 'zh_Hans';
  }

  return 'zh_Hans';
}
