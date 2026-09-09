import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'app/app.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  cameras = await availableCameras();

  runApp(
    WardrobeApp(
      preferences: preferences,
    ),
  );
}