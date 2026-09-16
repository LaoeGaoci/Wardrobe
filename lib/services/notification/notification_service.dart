import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../models/notification/push_notification_payload.dart';
import '../users/auth_service.dart';
import 'firebase_messaging_service.dart';
import 'notification_router.dart';
import 'push_device_repository.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._() {
    _authService.addListener(_handleAuthChanged);
  }

  static final NotificationService instance =
  NotificationService._();

  // ============================================================
  // SharedPreferences
  // ============================================================

  static const String enabledKey =
      'notifications_enabled';

  static const String activeUserKey =
      'notification_active_user_id';

  static const String registeredTokenKey =
      'notification_registered_fcm_token';

  static const String languageKey =
      'app_language';

  // ============================================================
  // Android notification
  // ============================================================

  static const String channelId =
      'wardrobe_notifications';

  /// Android 状态栏通知专用图标。
  ///
  /// 对应：
  ///
  /// android/app/src/main/res/drawable/ic_notification.xml
  ///
  /// 注意：
  /// 这里只写资源名称，不写扩展名。
  static const String notificationIcon =
      'ic_notification';

  // ============================================================
  // Dependencies
  // ============================================================

  static final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  final FirebaseMessagingService
  _firebaseMessaging =
      FirebaseMessagingService.instance;

  final PushDeviceRepository
  _pushDeviceRepository =
      PushDeviceRepository.instance;

  final AuthService _authService =
      AuthService.instance;

  final NotificationRouter _router =
      NotificationRouter.instance;

  // ============================================================
  // State
  // ============================================================

  bool _localStateRestored = false;
  bool _pluginInitialized = false;
  bool _initialized = false;
  bool _enabled = false;

  String? _activeUserId;
  String? _languageCode;

  Future<void>? _pluginInitializationFuture;

  StreamSubscription<RemoteMessage>?
  _foregroundMessageSubscription;

  StreamSubscription<RemoteMessage>?
  _openedMessageSubscription;

  StreamSubscription<String>?
  _tokenRefreshSubscription;

  // ============================================================
  // Getters
  // ============================================================

  bool get enabled => _enabled;

  bool get isInitialized => _initialized;

  String? get activeUserId => _activeUserId;

  // ============================================================
  // Restore local state
  // ============================================================

  Future<void> restoreLocalState({
    SharedPreferences? preferences,
  }) async {
    final prefs =
        preferences ??
            await SharedPreferences.getInstance();

    await prefs.reload();

    _enabled =
        prefs.getBool(enabledKey) ?? false;

    _activeUserId =
        prefs.getString(activeUserKey);

    _languageCode =
        prefs.getString(languageKey);

    _localStateRestored = true;

    debugPrint(
      '[NotificationService] '
          'restored: enabled=$_enabled, '
          'activeUserId=$_activeUserId',
    );

    notifyListeners();
  }

  // ============================================================
  // Initialize
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) {
      await _syncActiveUserFromAuthSafely();
      return;
    }

    if (!_localStateRestored) {
      await restoreLocalState();
    }

    /// 初始化 Firebase Messaging。
    ///
    /// 原来的代码虽然有
    /// FirebaseMessagingService.initialize()
    /// 但 NotificationService 没有真正调用。
    await _firebaseMessaging.initialize();

    /// 初始化 flutter_local_notifications。
    await _ensureLocalNotificationsInitialized();

    /// 注册 Firebase 消息监听器。
    _bindFirebaseStreams();

    // ----------------------------------------------------------
    // Local notification cold start
    // ----------------------------------------------------------

    /// 处理：
    ///
    /// App 在前台收到 FCM
    /// ↓
    /// 我们使用 flutter_local_notifications 显示
    /// ↓
    /// 用户后来点击通知启动 App
    await _consumeLocalNotificationLaunchDetails();

    // ----------------------------------------------------------
    // FCM cold start
    // ----------------------------------------------------------

    /// 处理：
    ///
    /// App terminated
    /// ↓
    /// FCM 系统通知
    /// ↓
    /// 用户点击通知启动 App
    try {
      final initialMessage =
      await _firebaseMessaging
          .getInitialMessage();

      if (initialMessage != null) {
        _routeRemoteMessage(
          initialMessage,
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'getInitialMessage failed: $error',
      );
      debugPrint('$stackTrace');
    }

    await _syncActiveUserFromAuthSafely();

    /// 如果用户已经关闭通知，
    /// 清理可能残留的旧设备 FCM Token。
    if (!_enabled) {
      await _cleanupDisabledPushState();
    }

    _initialized = true;

    debugPrint(
      '[NotificationService] initialized',
    );

    notifyListeners();
  }

  // ============================================================
  // Local notification plugin
  // ============================================================

  Future<void>
  _ensureLocalNotificationsInitialized() async {
    if (_pluginInitialized) {
      return;
    }

    final existing =
        _pluginInitializationFuture;

    if (existing != null) {
      await existing;
      return;
    }

    final future =
    _initializeLocalNotificationsPlugin();

    _pluginInitializationFuture =
        future;

    try {
      await future;
    } finally {
      _pluginInitializationFuture =
      null;
    }
  }

  Future<void>
  _initializeLocalNotificationsPlugin() async {
    /// 这里不能使用 ic_launcher。
    ///
    /// flutter_local_notifications
    /// 需要 Android drawable 中存在通知图标。
    const android =
    AndroidInitializationSettings(
      notificationIcon,
    );

    const settings =
    InitializationSettings(
      android: android,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse:
      _handleLocalNotificationTapped,
    );

    _pluginInitialized = true;

    await _createOrUpdateNotificationChannel();

    debugPrint(
      '[NotificationService] '
          'flutter_local_notifications ready',
    );
  }

  Future<void>
  _consumeLocalNotificationLaunchDetails() async {
    try {
      final details =
      await _localNotifications
          .getNotificationAppLaunchDetails();

      if (details == null ||
          !details.didNotificationLaunchApp) {
        return;
      }

      final response =
          details.notificationResponse;

      if (response == null) {
        return;
      }

      _handleLocalNotificationTapped(
        response,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'local launch details failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // Locale / localization
  // ============================================================

  Future<void> handleLocaleChanged(
      Locale locale,
      ) async {
    _languageCode =
        _localeCode(locale);

    if (_pluginInitialized) {
      await _createOrUpdateNotificationChannel();
    }

    if (_enabled &&
        _authService.status ==
            AuthStatus.authenticated) {
      await _trySyncCurrentDevice();
    }
  }

  Future<void>
  _createOrUpdateNotificationChannel() async {
    if (!_pluginInitialized) {
      return;
    }

    final androidPlugin =
    _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return;
    }

    final l10n =
    _currentLocalizations();

    final channel =
    AndroidNotificationChannel(
      channelId,
      l10n.notifications,
      description:
      l10n.notificationsSubtitle,
      importance:
      Importance.high,
    );

    await androidPlugin
        .createNotificationChannel(
      channel,
    );
  }

  AppLocalizations
  _currentLocalizations() {
    return lookupAppLocalizations(
      _currentLocale(),
    );
  }

  Locale _currentLocale() {
    final code =
        _languageCode;

    if (code != null) {
      switch (code) {
        case 'en':
          return const Locale('en');

        case 'zh_Hant':
          return const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
          );

        case 'zh_Hans':
          return const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
          );
      }
    }

    return _normalizeLocale(
      PlatformDispatcher.instance.locale,
    );
  }

  String _currentLocaleCode() {
    return _localeCode(
      _currentLocale(),
    );
  }

  Locale _normalizeLocale(
      Locale locale,
      ) {
    if (locale.languageCode == 'en') {
      return const Locale('en');
    }

    if (locale.languageCode == 'zh') {
      final traditional =
          locale.scriptCode == 'Hant' ||
              locale.countryCode == 'TW' ||
              locale.countryCode == 'HK' ||
              locale.countryCode == 'MO';

      return Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode:
        traditional
            ? 'Hant'
            : 'Hans',
      );
    }

    return const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
    );
  }

  String _localeCode(
      Locale locale,
      ) {
    final normalized =
    _normalizeLocale(locale);

    if (normalized.languageCode ==
        'en') {
      return 'en';
    }

    if (normalized.scriptCode ==
        'Hant') {
      return 'zh_Hant';
    }

    return 'zh_Hans';
  }

  // ============================================================
  // Firebase listeners
  // ============================================================

  void _bindFirebaseStreams() {
    _foregroundMessageSubscription ??=
        _firebaseMessaging
            .onMessage
            .listen(
          _handleForegroundMessage,
          onError: (
              Object error,
              ) {
            debugPrint(
              '[NotificationService] '
                  'onMessage error: $error',
            );
          },
        );

    _openedMessageSubscription ??=
        _firebaseMessaging
            .onMessageOpenedApp
            .listen(
          _routeRemoteMessage,
          onError: (
              Object error,
              ) {
            debugPrint(
              '[NotificationService] '
                  'onMessageOpenedApp error: $error',
            );
          },
        );

    _tokenRefreshSubscription ??=
        _firebaseMessaging
            .onTokenRefresh
            .listen(
          _handleTokenRefresh,
          onError: (
              Object error,
              ) {
            debugPrint(
              '[NotificationService] '
                  'onTokenRefresh error: $error',
            );
          },
        );
  }

  // ============================================================
  // Auth synchronization
  // ============================================================

  void _handleAuthChanged() {
    unawaited(
      _syncActiveUserFromAuthSafely(),
    );
  }

  Future<void>
  _syncActiveUserFromAuthSafely() async {
    try {
      await _syncActiveUserFromAuth();
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'auth synchronization failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  Future<void>
  _syncActiveUserFromAuth() async {
    final status =
        _authService.status;

    /// session restore 或临时恢复失败时，
    /// 不清除保存的 activeUserId。
    if (status ==
        AuthStatus.restoring ||
        status ==
            AuthStatus.restoreFailed) {
      return;
    }

    final newUserId =
    status ==
        AuthStatus.authenticated
        ? _authService
        .currentUser
        ?.id
        : null;

    final previousUserId =
        _activeUserId;

    _activeUserId =
        newUserId;

    final preferences =
    await SharedPreferences
        .getInstance();

    if (newUserId == null) {
      await preferences.remove(
        activeUserKey,
      );

      /// 退出登录时 Bearer Token
      /// 可能已经被 AuthService 清除，
      /// 所以这里只保证本机 FCM Token
      /// 被删除。
      if (previousUserId != null &&
          _enabled) {
        await _deleteLocalFirebaseToken();
      }

      notifyListeners();
      return;
    }

    await preferences.setString(
      activeUserKey,
      newUserId,
    );

    if (_enabled) {
      await _trySyncCurrentDevice();
    }

    notifyListeners();
  }

  // ============================================================
  // Settings switch
  // ============================================================

  Future<bool> setEnabled(
      bool value,
      ) async {
    final preferences =
    await SharedPreferences
        .getInstance();

    // ----------------------------------------------------------
    // Disable
    // ----------------------------------------------------------

    if (!value) {
      _enabled = false;

      await preferences.setBool(
        enabledKey,
        false,
      );

      /// 先解绑服务器设备，
      /// 再删除 Firebase Token。
      await _unregisterCurrentDeviceSafely();

      await _deleteLocalFirebaseToken();

      debugPrint(
        '[NotificationService] '
            'disabled by user',
      );

      notifyListeners();

      return true;
    }

    // ----------------------------------------------------------
    // Enable
    // ----------------------------------------------------------

    try {
      /// 确保 Firebase Messaging
      /// 已经初始化。
      await _firebaseMessaging.initialize();

      /// 确保 Android Local Notification
      /// 已经初始化。
      await _ensureLocalNotificationsInitialized();

      final granted =
      await _requestSystemPermission();

      if (!granted) {
        _enabled = false;

        await preferences.setBool(
          enabledKey,
          false,
        );

        notifyListeners();

        return false;
      }

      _enabled = true;

      await preferences.setBool(
        enabledKey,
        true,
      );

      /// Token 注册网络失败时，
      /// 不关闭用户已经开启的通知设置。
      if (_authService.status ==
          AuthStatus.authenticated) {
        await _trySyncCurrentDevice();
      }

      debugPrint(
        '[NotificationService] '
            'enabled by user',
      );

      notifyListeners();

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'enable failed: $error',
      );
      debugPrint('$stackTrace');

      _enabled = false;

      await preferences.setBool(
        enabledKey,
        false,
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // Android notification permission
  // ============================================================

  Future<bool>
  _requestSystemPermission() async {
    await _firebaseMessaging.initialize();

    final firebaseGranted =
    await _firebaseMessaging
        .requestPermission();

    if (!firebaseGranted) {
      return false;
    }

    return areSystemNotificationsEnabled();
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

  /// SettingsPage 进入时调用。
  ///
  /// 如果用户已经从 Android 系统设置中
  /// 手动关闭 Wardrobe 通知，
  /// App 内设置也同步关闭。
  Future<bool>
  refreshSystemPermission() async {
    try {
      await _ensureLocalNotificationsInitialized();

      final allowed =
      await areSystemNotificationsEnabled();

      if (_enabled &&
          !allowed) {
        _enabled = false;

        final preferences =
        await SharedPreferences
            .getInstance();

        await preferences.setBool(
          enabledKey,
          false,
        );

        await _unregisterCurrentDeviceSafely();

        await _deleteLocalFirebaseToken();

        notifyListeners();
      }

      return allowed;
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'refresh permission failed: $error',
      );
      debugPrint('$stackTrace');

      return false;
    }
  }

  /// 打开 Android 当前 App 的通知设置页。
  Future<bool>
  openSystemNotificationSettings() async {
    try {
      await _ensureLocalNotificationsInitialized();

      await _localNotifications
          .openAppNotificationSettings();

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'open notification settings failed: $error',
      );
      debugPrint('$stackTrace');

      return false;
    }
  }

  // ============================================================
  // Device registration
  // ============================================================

  Future<void>
  _trySyncCurrentDevice() async {
    try {
      await syncCurrentDevice();
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'push device sync failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  Future<void>
  syncCurrentDevice() async {
    if (!_enabled) {
      return;
    }

    if (_authService.status !=
        AuthStatus.authenticated) {
      return;
    }

    if (_authService.currentUser ==
        null) {
      return;
    }

    await _firebaseMessaging.initialize();

    final token =
    await _firebaseMessaging
        .getToken();

    if (token == null) {
      debugPrint(
        '[NotificationService] '
            'FCM token is null',
      );
      return;
    }

    final normalized =
    token.trim();

    if (normalized.isEmpty) {
      return;
    }

    final preferences =
    await SharedPreferences
        .getInstance();

    final previousToken =
    preferences.getString(
      registeredTokenKey,
    );

    /// 后端 register 应按 FCM token
    /// 进行 UPSERT。
    await _pushDeviceRepository.register(
      token: normalized,
      locale: _currentLocaleCode(),
    );

    await preferences.setString(
      registeredTokenKey,
      normalized,
    );

    /// Token 发生刷新以后，
    /// 尽量清理服务器中的旧 Token。
    if (previousToken != null &&
        previousToken.isNotEmpty &&
        previousToken !=
            normalized) {
      try {
        await _pushDeviceRepository
            .unregister(
          token: previousToken,
        );
      } catch (error) {
        debugPrint(
          '[NotificationService] '
              'old token cleanup failed: $error',
        );
      }
    }

    debugPrint(
      '[NotificationService] '
          'push device synchronized',
    );
  }

  // ============================================================
  // Token refresh
  // ============================================================

  Future<void> _handleTokenRefresh(
      String token,
      ) async {
    if (!_enabled) {
      return;
    }

    if (_authService.status !=
        AuthStatus.authenticated) {
      return;
    }

    final normalized =
    token.trim();

    if (normalized.isEmpty) {
      return;
    }

    final preferences =
    await SharedPreferences
        .getInstance();

    final previousToken =
    preferences.getString(
      registeredTokenKey,
    );

    try {
      await _pushDeviceRepository.register(
        token: normalized,
        locale:
        _currentLocaleCode(),
      );

      await preferences.setString(
        registeredTokenKey,
        normalized,
      );

      if (previousToken != null &&
          previousToken.isNotEmpty &&
          previousToken !=
              normalized) {
        try {
          await _pushDeviceRepository
              .unregister(
            token: previousToken,
          );
        } catch (error) {
          debugPrint(
            '[NotificationService] '
                'old token cleanup failed: $error',
          );
        }
      }

      debugPrint(
        '[NotificationService] '
            'FCM token refresh synchronized',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'FCM token refresh sync failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // Disable / cleanup
  // ============================================================

  Future<void>
  _cleanupDisabledPushState() async {
    await _unregisterCurrentDeviceSafely();

    await _deleteLocalFirebaseToken();
  }

  Future<void>
  _unregisterCurrentDeviceSafely() async {
    try {
      await _unregisterCurrentDevice();
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'unregister failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  Future<void>
  _unregisterCurrentDevice() async {
    if (_authService.status !=
        AuthStatus.authenticated) {
      return;
    }

    final preferences =
    await SharedPreferences
        .getInstance();

    final token =
    preferences.getString(
      registeredTokenKey,
    );

    if (token == null ||
        token.isEmpty) {
      return;
    }

    await _pushDeviceRepository
        .unregister(
      token: token,
    );
  }

  Future<void>
  _deleteLocalFirebaseToken() async {
    var deleted = false;

    try {
      await _firebaseMessaging
          .deleteToken();

      deleted = true;
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'delete FCM token failed: $error',
      );
      debugPrint('$stackTrace');
    }

    /// Firebase deleteToken 真正成功之后，
    /// 才删除本地保存的 registration token。
    if (deleted) {
      final preferences =
      await SharedPreferences
          .getInstance();

      await preferences.remove(
        registeredTokenKey,
      );
    }
  }

  // ============================================================
  // Foreground FCM
  // ============================================================

  Future<void>
  _handleForegroundMessage(
      RemoteMessage message,
      ) async {
    if (!_enabled) {
      return;
    }

    try {
      final payload =
      PushNotificationPayload
          .fromRemoteMessage(
        message,
      );

      await _showForegroundNotification(
        payload,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'foreground message failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  Future<void>
  _showForegroundNotification(
      PushNotificationPayload payload,
      ) async {
    await _ensureLocalNotificationsInitialized();

    final l10n =
    _currentLocalizations();

    final text =
    _notificationText(
      payload,
      l10n,
    );

    /// 显式指定 ic_notification。
    ///
    /// 避免插件回退到不存在或不适合作为
    /// Android small notification icon
    /// 的 launcher icon。
    final androidDetails =
    AndroidNotificationDetails(
      channelId,
      l10n.notifications,
      channelDescription:
      l10n.notificationsSubtitle,
      importance:
      Importance.high,
      priority:
      Priority.high,
      icon:
      notificationIcon,
    );

    final details =
    NotificationDetails(
      android: androidDetails,
    );

    final id =
    DateTime.now()
        .millisecondsSinceEpoch &
    0x7fffffff;

    await _localNotifications.show(
      id: id,
      title: text.$1,
      body: text.$2,
      notificationDetails:
      details,
      payload:
      payload.encode(),
    );
  }

  // ============================================================
  // FCM notification click
  // ============================================================

  void _routeRemoteMessage(
      RemoteMessage message,
      ) {
    try {
      final payload =
      PushNotificationPayload
          .fromRemoteMessage(
        message,
      );

      _router.route(
        payload,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'remote routing failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // Local notification click
  // ============================================================

  void _handleLocalNotificationTapped(
      NotificationResponse response,
      ) {
    final rawPayload =
        response.payload;

    if (rawPayload == null ||
        rawPayload.isEmpty) {
      return;
    }

    try {
      final payload =
      PushNotificationPayload.decode(
        rawPayload,
      );

      _router.route(
        payload,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
            'local notification payload failed: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // Fallback notification text
  // ============================================================

  (String, String) _notificationText(
      PushNotificationPayload payload,
      AppLocalizations l10n,
      ) {
    switch (payload.type) {
      case PushNotificationType.friendRequest:
        return (
        payload.title ??
            l10n
                .notificationFriendRequestTitle,
        payload.body ??
            l10n
                .notificationFriendRequestBody,
        );

      case PushNotificationType.recommendation:
        return (
        payload.title ??
            l10n
                .notificationRecommendationTitle,
        payload.body ??
            l10n
                .notificationRecommendationBody,
        );

      case PushNotificationType.systemNotification:
        return (
        payload.title ??
            l10n
                .notificationSystemTitle,
        payload.body ??
            l10n
                .notificationSystemBody,
        );
    }
  }
}