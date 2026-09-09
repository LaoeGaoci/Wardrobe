import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/auth/auth_page.dart';
import '../pages/home/home_page.dart';
import '../services/auth_service.dart';
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
  static const String _darkModeKey =
      'dark_mode_enabled';

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

    await widget.preferences.setBool(
      _darkModeKey,
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Wardrobe',

      // Light Theme
      theme: AppTheme.light,

      // Dark Theme
      darkTheme: AppTheme.dark,

      // 当前主题
      themeMode:
      isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 根据登录状态决定显示页面
      home: _AuthGate(
        isDarkMode: isDarkMode,
        onThemeChanged: changeTheme,
      ),
    );
  }
}

/// 根据认证状态决定显示 AuthPage 或 HomePage
class _AuthGate extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const _AuthGate({
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthService.instance,
      builder: (context, child) {
        if (AuthService.instance.isLoggedIn) {
          return HomePage(
            isDarkMode: isDarkMode,
            onThemeChanged: onThemeChanged,
          );
        }

        return const AuthPage();
      },
    );
  }
}