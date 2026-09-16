import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../pages/auth/auth_page.dart';
import '../pages/home/home_page.dart';
import '../services/users/auth_service.dart';
import 'theme.dart';
import '../services/notification/notification_router.dart';
import '../services/notification/notification_service.dart';

class WardrobeApp extends StatefulWidget {
  final SharedPreferences preferences;

  const WardrobeApp({super.key, required this.preferences});

  @override
  State<WardrobeApp> createState() {
    return _WardrobeAppState();
  }
}

class _WardrobeAppState extends State<WardrobeApp> {
  // ============================================================
  // Preference Keys
  // ============================================================

  static const String _themeModeKey = 'theme_mode';

  static const String _languageKey = 'app_language';

  // ============================================================
  // State
  // ============================================================

  late ThemeMode _themeMode;

  late Locale _locale;

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // Theme
    // ==========================================================
    //
    // 没有保存过主题设置时：
    //
    // 默认 ThemeMode.system
    //
    // 即：
    // 跟随 Android / iOS 系统主题。
    //
    final savedThemeMode = widget.preferences.getString(_themeModeKey);

    _themeMode = _themeModeFromCode(savedThemeMode);

    // ==========================================================
    // Locale
    // ==========================================================

    final savedLanguage = widget.preferences.getString(_languageKey);

    if (savedLanguage == null) {
      _locale = _localeFromSystem(
        WidgetsBinding.instance.platformDispatcher.locale,
      );
    } else {
      _locale = _localeFromCode(savedLanguage);
    }
  }

  // ============================================================
  // Theme
  // ============================================================

  /// 从 SharedPreferences 中保存的字符串恢复 ThemeMode。
  ///
  /// system -> ThemeMode.system
  /// light  -> ThemeMode.light
  /// dark   -> ThemeMode.dark
  ///
  /// null / 非法值：
  /// 默认 ThemeMode.system。
  ThemeMode _themeModeFromCode(String? code) {
    switch (code) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
        return ThemeMode.dark;

      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// ThemeMode 转换为可以持久化的字符串。
  String _themeModeCode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';

      case ThemeMode.light:
        return 'light';

      case ThemeMode.dark:
        return 'dark';
    }
  }

  /// 修改主题。
  ///
  /// ThemeMode.system：
  /// 跟随系统。
  ///
  /// ThemeMode.light：
  /// 强制浅色。
  ///
  /// ThemeMode.dark：
  /// 强制深色。
  Future<void> changeThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    setState(() {
      _themeMode = mode;
    });

    await widget.preferences.setString(_themeModeKey, _themeModeCode(mode));
  }

  // ============================================================
  // Locale
  // ============================================================

  Locale _localeFromSystem(Locale locale) {
    if (locale.languageCode == 'en') {
      return const Locale('en');
    }

    if (locale.languageCode == 'zh') {
      final countryCode = locale.countryCode;

      final traditional =
          locale.scriptCode == 'Hant' ||
          countryCode == 'TW' ||
          countryCode == 'HK' ||
          countryCode == 'MO';

      return Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: traditional ? 'Hant' : 'Hans',
      );
    }

    return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  }

  Locale _localeFromCode(String code) {
    switch (code) {
      case 'en':
        return const Locale('en');

      case 'zh_Hant':
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');

      case 'zh_Hans':
      default:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
    }
  }

  String _localeCode(Locale locale) {
    if (locale.languageCode == 'en') {
      return 'en';
    }

    if (locale.scriptCode == 'Hant') {
      return 'zh_Hant';
    }

    return 'zh_Hans';
  }

  // ============================================================
  // Locale Settings
  // ============================================================

  Future<void> changeLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });

    await widget.preferences.setString(_languageKey, _localeCode(locale));

    await NotificationService.instance.handleLocaleChanged(locale);
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationRouter.instance.navigatorKey,

      debugShowCheckedModeBanner: false,

      // ========================================================
      // Locale
      // ========================================================
      locale: _locale,

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      supportedLocales: AppLocalizations.supportedLocales,

      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,

      // ========================================================
      // Theme
      // ========================================================
      theme: AppTheme.light,

      darkTheme: AppTheme.dark,

      /// 这里直接把 ThemeMode 交给 MaterialApp。
      ///
      /// ThemeMode.system 时 Flutter 会自动监听
      /// Android / iOS 系统亮暗模式变化。
      themeMode: _themeMode,

      // ========================================================
      // Auth
      // ========================================================
      home: _AuthGate(
        themeMode: _themeMode,
        onThemeModeChanged: changeThemeMode,
        onLocaleChanged: changeLocale,
      ),
    );
  }
}

// ============================================================
// Auth Gate
// ============================================================

/// App 的认证入口。
///
/// 启动流程：
///
/// 1. 启动 App
/// 2. Secure Storage 读取 Token
/// 3. 请求 /api/users/me 验证
/// 4. 决定进入 HomePage 或 AuthPage
class _AuthGate extends StatefulWidget {
  final ThemeMode themeMode;

  final ValueChanged<ThemeMode> onThemeModeChanged;

  final ValueChanged<Locale> onLocaleChanged;

  const _AuthGate({
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<_AuthGate> createState() {
    return _AuthGateState();
  }
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();

    // 不 await。
    //
    // 初始化期间 AuthStatus.restoring，
    // UI 显示加载页面。
    AuthService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthService.instance,
      builder: (context, child) {
        final auth = AuthService.instance;

        switch (auth.status) {
          // ====================================================
          // 正在恢复会话
          // ====================================================

          case AuthStatus.restoring:
            return const _SessionLoadingPage();

          // ====================================================
          // 已登录
          // ====================================================

          case AuthStatus.authenticated:
            return HomePage(
              themeMode: widget.themeMode,
              onThemeModeChanged: widget.onThemeModeChanged,
              onLocaleChanged: widget.onLocaleChanged,
            );

          // ====================================================
          // 未登录
          // ====================================================

          case AuthStatus.unauthenticated:
            return const AuthPage();

          // ====================================================
          // 恢复失败
          // ====================================================

          case AuthStatus.restoreFailed:
            return _SessionRestoreErrorPage(
              message: auth.restoreError,
              onRetry: auth.retryRestoreSession,
              onLogin: () async {
                // 用户主动选择重新登录时，
                // 才真正删除本地 Token。
                await auth.logout();
              },
            );
        }
      },
    );
  }
}

// ============================================================
// Session Loading
// ============================================================

class _SessionLoadingPage extends StatelessWidget {
  const _SessionLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}

// ============================================================
// Session Restore Error
// ============================================================

class _SessionRestoreErrorPage extends StatelessWidget {
  final String? message;

  final Future<void> Function() onRetry;

  final Future<void> Function() onLogin;

  const _SessionRestoreErrorPage({
    required this.message,
    required this.onRetry,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    l10n.operationFailed,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (message != null && message!.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () {
                        onRetry();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.reload),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        onLogin();
                      },
                      child: Text(l10n.login),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
