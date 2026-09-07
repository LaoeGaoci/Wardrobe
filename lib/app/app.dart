import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/home/home_page.dart';
import 'theme.dart';

class WardrobeApp extends StatefulWidget {
  final SharedPreferences preferences;

  const WardrobeApp({
    super.key,
    required this.preferences,
  });

  @override
  State<WardrobeApp> createState() => _WardrobeAppState();
}

class _WardrobeAppState extends State<WardrobeApp> {
  static const String _darkModeKey = 'dark_mode_enabled';

  late bool isDarkMode;

  @override
  void initState() {
    super.initState();

    // 从本地读取 Dark Mode
    isDarkMode =
        widget.preferences.getBool(_darkModeKey) ?? false;
  }

  /// 修改 Dark Mode
  Future<void> changeTheme(bool value) async {
    setState(() {
      isDarkMode = value;
    });

    // 保存到本地
    await widget.preferences.setBool(
      _darkModeKey,
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Wadrobe',

      // Light Theme
      theme: AppTheme.light,

      // Dark Theme
      darkTheme: AppTheme.dark,

      // 当前主题
      themeMode:
      isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: HomePage(
        isDarkMode: isDarkMode,
        onThemeChanged: changeTheme,
      ),
    );
  }
}