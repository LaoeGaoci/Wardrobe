import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  runApp(
    WardrobeApp(
      preferences: preferences,
    ),
  );
}