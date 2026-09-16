import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService instance =
  FirebaseMessagingService._();

  FirebaseMessaging get _messaging =>
      FirebaseMessaging.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _messaging.setAutoInitEnabled(true);

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final settings =
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final status =
        settings.authorizationStatus;

    return status ==
        AuthorizationStatus.authorized ||
        status ==
            AuthorizationStatus.provisional;
  }

  Future<String?> getToken() async {
    final token =
    await _messaging.getToken();

    if (token == null) {
      return null;
    }

    final normalized =
    token.trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }

  Stream<String> get onTokenRefresh =>
      _messaging.onTokenRefresh;

  Stream<RemoteMessage> get onMessage =>
      FirebaseMessaging.onMessage;

  Stream<RemoteMessage>
  get onMessageOpenedApp =>
      FirebaseMessaging
          .onMessageOpenedApp;

  Future<RemoteMessage?>
  getInitialMessage() {
    return _messaging.getInitialMessage();
  }
}