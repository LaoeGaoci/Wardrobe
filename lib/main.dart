import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'services/notification_background_worker.dart';
import 'services/notification_service.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[Bootstrap] Flutter binding ready');

  // ============================================================
  // SharedPreferences
  // ============================================================
  //
  // 通知开关属于用户本地设置。
  // 它必须在 runApp() 前恢复，这样 SettingsPage 第一次构建时
  // 就能拿到上一次保存的通知开关状态。
  //
  // 这里只读取 SharedPreferences，不初始化 WorkManager，
  // 也不初始化 flutter_local_notifications，因此不会因为原生插件
  // 初始化异常而阻塞 App 首屏。
  //

  final preferences = await SharedPreferences.getInstance();

  await NotificationService.instance.restoreLocalState(
    preferences: preferences,
  );

  debugPrint('[Bootstrap] SharedPreferences ready');

  // ============================================================
  // Camera
  // ============================================================

  try {
    cameras = await availableCameras();

    debugPrint('[Bootstrap] Camera ready: ${cameras.length}');
  } catch (error, stackTrace) {
    debugPrint('[Bootstrap] Camera init failed: $error');

    debugPrint('$stackTrace');

    // 摄像头初始化失败不能阻塞整个 App。
    cameras = <CameraDescription>[];
  }

  // ============================================================
  // Start app first
  // ============================================================

  runApp(WardrobeApp(preferences: preferences));

  debugPrint('[Bootstrap] runApp completed');

  // ============================================================
  // Background services
  // ============================================================
  //
  // WorkManager / flutter_local_notifications 都不是首屏硬依赖。
  // 等首帧出来后再初始化，避免通知模块导致白屏。
  //

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeBackgroundServices());
  });
}

// ============================================================
// Background service bootstrap
// ============================================================

Future<void> _initializeBackgroundServices() async {
  var workManagerReady = false;

  // ------------------------------------------------------------
  // WorkManager
  // ------------------------------------------------------------

  try {
    debugPrint('[Bootstrap] Initializing WorkManager...');

    await Workmanager()
        .initialize(notificationCallbackDispatcher)
        .timeout(const Duration(seconds: 10));

    workManagerReady = true;

    debugPrint('[Bootstrap] WorkManager ready');
  } catch (error, stackTrace) {
    debugPrint('[Bootstrap] WorkManager init failed: $error');

    debugPrint('$stackTrace');

    // 注意：这里不能 return。
    //
    // 即使 WorkManager 初始化失败，NotificationService 仍然要继续
    // 初始化系统通知插件。最重要的是，用户保存的通知开关状态已经在
    // runApp() 前恢复，不能因为 WorkManager 失败而被重置。
  }

  // ------------------------------------------------------------
  // Local notification service
  // ------------------------------------------------------------

  try {
    debugPrint('[Bootstrap] Initializing NotificationService...');

    await NotificationService.instance.initialize(
      workManagerReady: workManagerReady,
    );

    debugPrint('[Bootstrap] NotificationService ready');
  } catch (error, stackTrace) {
    debugPrint('[Bootstrap] NotificationService init failed: $error');

    debugPrint('$stackTrace');

    // 不影响 App 正常使用。
    // 用户本地通知开关仍然会保持上一次保存的状态。
  }
}
