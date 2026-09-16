import 'dart:async';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'services/notification/firebase_messaging_service.dart';
import 'services/notification/notification_service.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint(
    '[Bootstrap] Flutter binding ready',
  );

  final preferences =
  await SharedPreferences.getInstance();

  debugPrint(
    '[Bootstrap] SharedPreferences ready',
  );

  var firebaseReady = false;

  try {
    await Firebase.initializeApp();

    await FirebaseMessagingService
        .instance
        .initialize();

    firebaseReady = true;

    debugPrint(
      '[Bootstrap] Firebase ready',
    );
  } catch (error, stackTrace) {
    debugPrint(
      '[Bootstrap] Firebase init failed: $error',
    );

    debugPrint(
      '$stackTrace',
    );
  }

  // restoreLocalState 本身不应该依赖 Firebase，
  // 但放在 Firebase 初始化之后可以避免初始化链问题。
  await NotificationService
      .instance
      .restoreLocalState(
    preferences: preferences,
  );

  try {
    cameras =
    await availableCameras();

    debugPrint(
      '[Bootstrap] Camera ready: ${cameras.length}',
    );
  } catch (error, stackTrace) {
    debugPrint(
      '[Bootstrap] Camera init failed: $error',
    );

    debugPrint(
      '$stackTrace',
    );

    cameras =
    <CameraDescription>[];
  }

  runApp(
    WardrobeApp(
      preferences: preferences,
    ),
  );

  debugPrint(
    '[Bootstrap] runApp completed',
  );

  if (firebaseReady) {
    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        unawaited(
          _initializeNotificationService(),
        );
      },
    );
  } else {
    debugPrint(
      '[Bootstrap] NotificationService skipped because Firebase is unavailable',
    );
  }
}

Future<void>
_initializeNotificationService() async {
  try {
    await NotificationService
        .instance
        .initialize();

    debugPrint(
      '[Bootstrap] NotificationService ready',
    );
  } catch (error, stackTrace) {
    debugPrint(
      '[Bootstrap] NotificationService init failed: $error',
    );

    debugPrint(
      '$stackTrace',
    );
  }
}