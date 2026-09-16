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

  debugPrint(
    '[Bootstrap] Flutter binding ready',
  );

  // ============================================================
  // SharedPreferences
  // ============================================================

  final preferences =
  await SharedPreferences.getInstance();

  debugPrint(
    '[Bootstrap] SharedPreferences ready',
  );

  // ============================================================
  // Camera
  // ============================================================

  try {
    cameras =
    await availableCameras();

    debugPrint(
      '[Bootstrap] Camera ready: '
          '${cameras.length}',
    );
  } catch (
  error,
  stackTrace
  ) {
  debugPrint(
  '[Bootstrap] Camera init failed: '
  '$error',
  );

  debugPrint(
  '$stackTrace',
  );

  // 不让摄像头初始化失败阻塞整个 App。
  cameras =
  <CameraDescription>[];
  }

  // ============================================================
  // App
  // ============================================================
  //
  // 关键：
  //
  // 先启动 Wardrobe。
  //
  // 通知 / WorkManager 都不是首页显示的硬依赖，
  // 不能因为通知插件初始化失败导致整个 App 白屏。
  //

  runApp(
  WardrobeApp(
  preferences:
  preferences,
  ),
  );

  debugPrint(
  '[Bootstrap] runApp completed',
  );

  // ============================================================
  // Background services
  // ============================================================
  //
  // 首帧启动后，再异步初始化后台通知。
  //

  WidgetsBinding.instance
      .addPostFrameCallback(
  (_) {
  unawaited(
  _initializeBackgroundServices(),
  );
  },
  );
}

// ============================================================
// Background service bootstrap
// ============================================================

Future<void>
_initializeBackgroundServices() async {
  try {
    debugPrint(
      '[Bootstrap] Initializing WorkManager...',
    );

    await Workmanager()
        .initialize(
      notificationCallbackDispatcher,
    )
        .timeout(
      const Duration(
        seconds: 10,
      ),
    );

    debugPrint(
      '[Bootstrap] WorkManager ready',
    );
  } catch (
  error,
  stackTrace
  ) {
  debugPrint(
  '[Bootstrap] WorkManager init failed: '
  '$error',
  );

  debugPrint(
  '$stackTrace',
  );

  // WorkManager 失败后不要继续初始化
  // 依赖它的 NotificationService。
  return;
  }

  try {
  debugPrint(
  '[Bootstrap] Initializing NotificationService...',
  );

  await NotificationService
      .instance
      .initialize()
      .timeout(
  const Duration(
  seconds: 10,
  ),
  );

  debugPrint(
  '[Bootstrap] NotificationService ready',
  );
  } catch (
  error,
  stackTrace
  ) {
  debugPrint(
  '[Bootstrap] NotificationService init failed: '
  '$error',
  );

  debugPrint(
  '$stackTrace',
  );
  }
}