import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../models/app_notification.dart';
import '../network/api_client.dart';

class NotificationRepository {
  NotificationRepository._();

  static final NotificationRepository
      instance =
      NotificationRepository._();

  final ApiClient _api =
      ApiClient.instance;

  // ==========================================================
  // Foreground requests
  // ==========================================================

  Future<int>
      fetchCurrentCursor() async {
    try {
      final data =
          await _api.get(
        '/api/notifications/cursor',
      );

      return _parseCursor(
        data['cursor'],
      );
    } on ApiException catch (e) {
      throw NotificationRepositoryException(
        e.message,
        statusCode:
            e.statusCode,
      );
    }
  }

  Future<NotificationPollResult>
      poll({
    required int afterSeq,
  }) async {
    try {
      final data =
          await _api.get(
        '/api/notifications/poll',
        queryParameters: {
          'afterSeq':
              '$afterSeq',
        },
      );

      return _parsePollResult(
        data,
      );
    } on ApiException catch (e) {
      throw NotificationRepositoryException(
        e.message,
        statusCode:
            e.statusCode,
      );
    }
  }

  Future<void> markAsRead(
    String notificationId,
  ) async {
    try {
      await _api.patch(
        '/api/notifications/'
        '${Uri.encodeComponent(notificationId)}'
        '/read',
      );
    } on ApiException catch (e) {
      throw NotificationRepositoryException(
        e.message,
        statusCode:
            e.statusCode,
      );
    }
  }

  // ==========================================================
  // Background-isolate requests
  // ==========================================================

  static Future<int>
      fetchCurrentCursorWithToken({
    required String token,
  }) async {
    final data =
        await _backgroundGet(
      path:
          '/api/notifications/cursor',

      token:
          token,
    );

    return _parseCursor(
      data['cursor'],
    );
  }

  static Future<NotificationPollResult>
      pollWithToken({
    required String token,
    required int afterSeq,
  }) async {
    final data =
        await _backgroundGet(
      path:
          '/api/notifications/poll',

      token:
          token,

      queryParameters: {
        'afterSeq':
            '$afterSeq',
      },
    );

    return _parsePollResult(
      data,
    );
  }

  static Future<Map<String, dynamic>>
      _backgroundGet({
    required String path,
    required String token,
    Map<String, String>?
        queryParameters,
  }) async {
    final base =
        Uri.parse(
      ApiConfig.baseUrl,
    );

    final uri =
        base
            .resolve(path)
            .replace(
      queryParameters:
          queryParameters,
    );

    http.Response response;

    try {
      response =
          await http
              .get(
                uri,
                headers: {
                  'Accept':
                      'application/json',

                  'Authorization':
                      'Bearer $token',
                },
              )
              .timeout(
                ApiConfig
                    .requestTimeout,
              );
    } catch (_) {
      throw const NotificationRepositoryException(
        'Network request failed',
      );
    }

    dynamic decoded;

    try {
      decoded =
          jsonDecode(
        response.body,
      );
    } catch (_) {
      throw NotificationRepositoryException(
        'Invalid server response',
        statusCode:
            response.statusCode,
      );
    }

    if (
      response.statusCode < 200 ||
      response.statusCode >= 300
    ) {
      var message =
          'Request failed';

      if (
        decoded is Map &&
        decoded['error']
            is String
      ) {
        message =
            decoded['error']
                as String;
      }

      throw NotificationRepositoryException(
        message,
        statusCode:
            response.statusCode,
      );
    }

    if (decoded is! Map) {
      throw const NotificationRepositoryException(
        'Invalid server response',
      );
    }

    return Map<String, dynamic>
        .from(
      decoded,
    );
  }

  // ==========================================================
  // Parse
  // ==========================================================

  static int _parseCursor(
    dynamic value,
  ) {
    if (value is! num) {
      throw const NotificationRepositoryException(
        'Invalid notification cursor',
      );
    }

    return value.toInt();
  }

  static NotificationPollResult
      _parsePollResult(
    Map<String, dynamic> data,
  ) {
    final rawNotifications =
        data['notifications'];

    if (
      rawNotifications is! List
    ) {
      throw const NotificationRepositoryException(
        'Invalid notifications response',
      );
    }

    final notifications =
        rawNotifications
            .map(
              (item) {
                if (item is! Map) {
                  throw const NotificationRepositoryException(
                    'Invalid notification data',
                  );
                }

                return AppNotification
                    .fromJson(
                  Map<String, dynamic>
                      .from(
                    item,
                  ),
                );
              },
            )
            .toList(
              growable: false,
            );

    return NotificationPollResult(
      notifications:
          notifications,

      nextCursor:
          _parseCursor(
        data['nextCursor'],
      ),
    );
  }
}

class NotificationRepositoryException
    implements Exception {
  final String message;
  final int? statusCode;

  const NotificationRepositoryException(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() =>
      message;
}
