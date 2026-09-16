import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../models/app_notification.dart';
import 'auth_service.dart';
import 'notification_repository.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._() {
    _authService.addListener(_handleAuthChanged);
  }

  static final NotificationService instance = NotificationService._();

  // ==========================================================
  // SharedPreferences keys
  // ==========================================================

  static const String enabledKey = 'notifications_enabled';

  static const String activeUserKey = 'notification_active_user_id';

  static const String languageKey = 'app_language';

  static String cursorKey(String userId) => 'notification_cursor:$userId';

  // ==========================================================
  // WorkManager
  // ==========================================================

  static const String backgroundTaskUniqueName = 'wardrobe_notification_poll';

  static const String backgroundTaskName = 'wardrobe_notification_poll';

  // ==========================================================
  // Android notification channel
  // ==========================================================

  static const String channelId = 'wardrobe_notifications';

  static const String channelName = 'Wardrobe Notifications';

  static const String channelDescription =
      'Friend requests, clothing recommendations and system notifications';

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final NotificationRepository _repository = NotificationRepository.instance;

  final AuthService _authService = AuthService.instance;

  // ==========================================================
  // Runtime state
  // ==========================================================

  /// SharedPreferences 是否已经恢复完成。
  bool _localStateRestored = false;

  /// flutter_local_notifications 是否已经初始化成功。
  bool _pluginInitialized = false;

  /// 完整 NotificationService 初始化是否完成。
  bool _initialized = false;

  /// WorkManager 当前是否已经成功初始化。
  ///
  /// 这只是“后台轮询能力”的状态，不能影响用户保存的通知开关。
  bool _workManagerReady = false;

  /// 用户自己在 Wardrobe 设置中选择的通知开关。
  ///
  /// 这个值必须持久化，不能因为系统权限查询失败或 WorkManager
  /// 初始化失败而被自动改成 false。
  bool _enabled = false;

  String? _activeUserId;

  Future<void>? _pluginInitializationFuture;

  // ==========================================================
  // Getters
  // ==========================================================

  bool get enabled => _enabled;

  String? get activeUserId => _activeUserId;

  bool get isInitialized => _initialized;

  bool get isWorkManagerReady => _workManagerReady;

  // ==========================================================
  // Restore local state
  // ==========================================================
  //
  // 这个方法故意与 flutter_local_notifications / WorkManager 解耦。
  //
  // App 启动时应该在 runApp() 前调用它，从 SharedPreferences 恢复：
  //
  // - notifications_enabled
  // - notification_active_user_id
  //
  // 因此即使原生通知插件初始化失败，设置页面仍然能够正确显示用户
  // 上一次保存的通知开关。
  //

  Future<void> restoreLocalState({SharedPreferences? preferences}) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();

    await prefs.reload();

    _enabled = prefs.getBool(enabledKey) ?? false;

    _activeUserId = prefs.getString(activeUserKey);

    _localStateRestored = true;

    debugPrint(
      '[NotificationService] '
      'restored local state: '
      'enabled=$_enabled, '
      'activeUserId=$_activeUserId',
    );

    notifyListeners();
  }

  // ==========================================================
  // Initialize
  // ==========================================================

  Future<void> initialize({required bool workManagerReady}) async {
    _workManagerReady = workManagerReady;

    // 本地状态正常情况下已经由 main.dart 在 runApp() 前恢复。
    // 这里保留兜底，防止未来其他入口直接调用 initialize()。
    if (!_localStateRestored) {
      await restoreLocalState();
    }

    // 如果之前已经完整初始化过，只需要根据最新 WorkManager 状态
    // 重新同步后台任务即可。
    if (_initialized) {
      if (_enabled && _activeUserId != null) {
        final allowed = await areSystemNotificationsEnabled();

        if (allowed) {
          await _ensureBackgroundTask();
        } else {
          await _cancelBackgroundTask();
        }
      }

      return;
    }

    try {
      await _ensureLocalNotificationsInitialized();

      // AuthService 可能仍处于 restoring。
      // _syncActiveUserFromAuth() 对 restoring 状态会保持本地保存的用户。
      await _syncActiveUserFromAuth();

      if (_enabled) {
        final allowed = await areSystemNotificationsEnabled();

        if (allowed && _activeUserId != null) {
          await _ensureBackgroundTask();
        } else if (!allowed) {
          // 系统通知权限关闭时，只暂停后台任务。
          //
          // 绝对不要把 notifications_enabled 写成 false，
          // 因为这是用户自己的 App 设置，而不是 Android 权限状态。
          await _cancelBackgroundTask();
        }
      }

      // 只有全部初始化过程走到这里之后才认为初始化完成。
      _initialized = true;

      debugPrint(
        '[NotificationService] initialized: '
        'enabled=$_enabled, '
        'workManagerReady=$_workManagerReady, '
        'activeUserId=$_activeUserId',
      );

      notifyListeners();
    } catch (error, stackTrace) {
      // 初始化失败必须允许未来再次重试。
      _initialized = false;

      debugPrint('[NotificationService] initialize failed: $error');

      debugPrint('$stackTrace');

      rethrow;
    }
  }

  // ==========================================================
  // Local notifications plugin initialization
  // ==========================================================

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_pluginInitialized) {
      return;
    }

    final existing = _pluginInitializationFuture;

    if (existing != null) {
      await existing;
      return;
    }

    final future = _initializeLocalNotificationsPlugin();

    _pluginInitializationFuture = future;

    try {
      await future;
    } finally {
      _pluginInitializationFuture = null;
    }
  }

  Future<void> _initializeLocalNotificationsPlugin() async {
    const android = AndroidInitializationSettings('ic_launcher');

    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(settings: settings);

    _pluginInitialized = true;

    debugPrint(
      '[NotificationService] '
      'flutter_local_notifications ready',
    );
  }

  // ==========================================================
  // Auth synchronization
  // ==========================================================

  void _handleAuthChanged() {
    unawaited(_syncActiveUserFromAuth());
  }

  Future<void> _syncActiveUserFromAuth() async {
    final status = _authService.status;

    // App 启动恢复登录期间，以及临时网络恢复失败期间，保留本地保存的
    // activeUserId，避免后台任务因为一次启动时序问题被错误清空。
    if (status == AuthStatus.restoring || status == AuthStatus.restoreFailed) {
      return;
    }

    final userId = status == AuthStatus.authenticated
        ? _authService.currentUser?.id
        : null;

    if (_activeUserId == userId) {
      if (userId != null && _enabled) {
        await _ensureBackgroundTask();
      }

      return;
    }

    _activeUserId = userId;

    final preferences = await SharedPreferences.getInstance();

    if (userId == null) {
      await preferences.remove(activeUserKey);

      await _cancelBackgroundTask();

      notifyListeners();

      return;
    }

    await preferences.setString(activeUserKey, userId);

    if (_enabled) {
      await _ensureCursor(userId);

      await _ensureBackgroundTask();
    }

    notifyListeners();
  }

  // ==========================================================
  // Settings switch
  // ==========================================================

  Future<bool> setEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();

    // ----------------------------------------------------------
    // Disable
    // ----------------------------------------------------------

    if (!value) {
      _enabled = false;

      await preferences.setBool(enabledKey, false);

      await _cancelBackgroundTask();

      debugPrint('[NotificationService] disabled by user');

      notifyListeners();

      return true;
    }

    // ----------------------------------------------------------
    // Enable
    // ----------------------------------------------------------
    //
    // 用户主动打开通知时才请求 Android 系统通知权限。
    //

    try {
      await _ensureLocalNotificationsInitialized();

      final granted = await _requestSystemPermission();

      if (!granted) {
        // 用户这一次没有授予系统权限，因此本次“打开通知”操作失败。
        // 保持 App 设置为 false，并让 SettingsPage 显示权限提示。
        _enabled = false;

        await preferences.setBool(enabledKey, false);

        await _cancelBackgroundTask();

        notifyListeners();

        return false;
      }

      _enabled = true;

      // 先持久化用户选择。
      // 后面的网络 / WorkManager 操作即使失败，也不能把这个值抹掉。
      await preferences.setBool(enabledKey, true);

      // 如果 AuthService 此时已经完成登录恢复，这一步可以及时同步用户。
      await _syncActiveUserFromAuth();

      final userId = _activeUserId;

      if (userId != null && userId.isNotEmpty) {
        // 第一次启用时从“现在”开始，避免历史记录突然全部成为
        // Android 系统通知。
        await _ensureCursor(userId);

        await _ensureBackgroundTask();
      }

      debugPrint('[NotificationService] enabled by user');

      notifyListeners();

      return true;
    } catch (error, stackTrace) {
      debugPrint('[NotificationService] enable failed: $error');

      debugPrint('$stackTrace');

      // 如果还没成功持久化 true，保持当前状态。
      // 如果 true 已经成功写入，_enabled 也已经是 true；后台调度失败
      // 不应该抹掉用户选择。
      notifyListeners();

      return _enabled;
    }
  }

  // ==========================================================
  // Android permission
  // ==========================================================

  Future<bool> _requestSystemPermission() async {
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) {
      return true;
    }

    final granted = await android.requestNotificationsPermission();

    if (granted == true) {
      return true;
    }

    return await android.areNotificationsEnabled() ?? false;
  }

  static Future<bool> areSystemNotificationsEnabled() async {
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) {
      return true;
    }

    return await android.areNotificationsEnabled() ?? false;
  }

  Future<void> openSystemNotificationSettings() async {
    await _ensureLocalNotificationsInitialized();

    await _localNotifications.openAppNotificationSettings();
  }

  // ==========================================================
  // Cursor
  // ==========================================================

  Future<void> _ensureCursor(String userId) async {
    final preferences = await SharedPreferences.getInstance();

    final key = cursorKey(userId);

    if (preferences.containsKey(key)) {
      return;
    }

    try {
      final cursor = await _repository.fetchCurrentCursor();

      await preferences.setInt(key, cursor);

      debugPrint(
        '[NotificationService] '
        'initialized cursor for $userId: $cursor',
      );
    } catch (error) {
      debugPrint(
        '[NotificationService] '
        'cursor initialization deferred: $error',
      );

      // 后台 Worker 第一次成功联网时会初始化 cursor。
    }
  }

  // ==========================================================
  // WorkManager
  // ==========================================================

  Future<void> _ensureBackgroundTask() async {
    if (!_enabled || _activeUserId == null || !_workManagerReady) {
      return;
    }

    try {
      await Workmanager().registerPeriodicTask(
        backgroundTaskUniqueName,
        backgroundTaskName,

        frequency: const Duration(minutes: 15),

        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,

        constraints: Constraints(networkType: NetworkType.connected),
      );

      debugPrint(
        '[NotificationService] '
        'background polling task registered',
      );
    } catch (error, stackTrace) {
      // 后台调度失败只能影响后台通知能力，不能改变用户开关。
      debugPrint(
        '[NotificationService] '
        'register background task failed: $error',
      );

      debugPrint('$stackTrace');
    }
  }

  Future<void> _cancelBackgroundTask() async {
    if (!_workManagerReady) {
      return;
    }

    try {
      await Workmanager().cancelByUniqueName(backgroundTaskUniqueName);
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] '
        'cancel background task failed: $error',
      );

      debugPrint('$stackTrace');
    }
  }

  // ==========================================================
  // Background plugin initialization
  // ==========================================================

  static Future<void> initializeForBackground() async {
    const android = AndroidInitializationSettings('ic_launcher');

    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(settings: settings);
  }

  // ==========================================================
  // Show notification
  // ==========================================================

  static Future<void> showLocalNotification(
    AppNotification notification, {
    required String languageCode,
  }) async {
    final text = _notificationText(notification, languageCode);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,

      channelDescription: channelDescription,

      importance: Importance.high,

      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final notificationId = notification.seq & 0x7fffffff;

    await _localNotifications.show(
      id: notificationId,

      title: text.$1,

      body: text.$2,

      notificationDetails: details,

      payload: notification.resourceId,
    );
  }

  // ==========================================================
  // Localized notification text
  // ==========================================================

  static (String, String) _notificationText(
    AppNotification notification,
    String languageCode,
  ) {
    final sender = notification.sender?.username.trim().isNotEmpty == true
        ? notification.sender!.username
        : 'Wardrobe';

    final english = languageCode == 'en';

    final traditional = languageCode == 'zh_Hant';

    switch (notification.type) {
      case AppNotificationType.friendRequest:
        if (english) {
          return ('New friend request', '$sender sent you a friend request');
        }

        if (traditional) {
          return ('新的好友請求', '$sender 向你傳送了好友請求');
        }

        return ('新的好友请求', '$sender 向你发送了好友请求');

      case AppNotificationType.recommendation:
        if (english) {
          return (
            'New clothing recommendation',
            '$sender sent you a clothing recommendation',
          );
        }

        if (traditional) {
          return ('新的衣物推薦', '$sender 給你傳送了一份衣物推薦');
        }

        return ('新的衣物推荐', '$sender 给你发送了一份衣物推荐');

      case AppNotificationType.systemNotification:
        return (notification.title ?? 'Wardrobe', notification.message ?? '');
    }
  }
}
