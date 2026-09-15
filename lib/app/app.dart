import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
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
  State<WardrobeApp> createState() {
    return _WardrobeAppState();
  }
}

class _WardrobeAppState
    extends State<WardrobeApp> {
  static const String _darkModeKey =
      'dark_mode_enabled';

  static const String _languageKey =
      'app_language';

  late bool isDarkMode;

  late Locale _locale;

  @override
  void initState() {
    super.initState();

    isDarkMode =
        widget.preferences
            .getBool(
          _darkModeKey,
        ) ??
            false;

    final savedLanguage =
    widget.preferences
        .getString(
      _languageKey,
    );

    if (savedLanguage ==
        null) {
      _locale =
          _localeFromSystem(
            WidgetsBinding
                .instance
                .platformDispatcher
                .locale,
          );
    } else {
      _locale =
          _localeFromCode(
            savedLanguage,
          );
    }
  }

  // ============================================================
  // Locale
  // ============================================================

  Locale _localeFromSystem(
      Locale locale,
      ) {
    if (locale.languageCode ==
        'en') {
      return const Locale(
        'en',
      );
    }

    if (locale.languageCode ==
        'zh') {
      final countryCode =
          locale.countryCode;

      final traditional =
          locale.scriptCode ==
              'Hant' ||
              countryCode ==
                  'TW' ||
              countryCode ==
                  'HK' ||
              countryCode ==
                  'MO';

      return Locale.fromSubtags(
        languageCode:
        'zh',
        scriptCode:
        traditional
            ? 'Hant'
            : 'Hans',
      );
    }

    return const Locale.fromSubtags(
      languageCode:
      'zh',
      scriptCode:
      'Hans',
    );
  }

  Locale _localeFromCode(
      String code,
      ) {
    switch (code) {
      case 'en':
        return const Locale(
          'en',
        );

      case 'zh_Hant':
        return const Locale.fromSubtags(
          languageCode:
          'zh',
          scriptCode:
          'Hant',
        );

      case 'zh_Hans':
      default:
        return const Locale.fromSubtags(
          languageCode:
          'zh',
          scriptCode:
          'Hans',
        );
    }
  }

  String _localeCode(
      Locale locale,
      ) {
    if (locale.languageCode ==
        'en') {
      return 'en';
    }

    if (locale.scriptCode ==
        'Hant') {
      return 'zh_Hant';
    }

    return 'zh_Hans';
  }

  // ============================================================
  // Settings
  // ============================================================

  Future<void> changeTheme(
      bool value,
      ) async {
    setState(() {
      isDarkMode =
          value;
    });

    await widget.preferences
        .setBool(
      _darkModeKey,
      value,
    );
  }

  Future<void> changeLocale(
      Locale locale,
      ) async {
    setState(() {
      _locale =
          locale;
    });

    await widget.preferences
        .setString(
      _languageKey,
      _localeCode(
        locale,
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
      false,

      locale:
      _locale,

      localizationsDelegates:
      AppLocalizations
          .localizationsDelegates,

      supportedLocales:
      AppLocalizations
          .supportedLocales,

      onGenerateTitle:
          (context) =>
      AppLocalizations.of(
        context,
      )!
          .appTitle,

      theme:
      AppTheme.light,

      darkTheme:
      AppTheme.dark,

      themeMode:
      isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      home:
      _AuthGate(
        isDarkMode:
        isDarkMode,
        onThemeChanged:
        changeTheme,
        onLocaleChanged:
        changeLocale,
      ),
    );
  }
}

// ============================================================
// Auth Gate
// ============================================================

/// App 的认证入口。
///
/// 与以前不同：
///
/// 以前：
///
/// currentUser == null
/// → 直接显示登录页
///
/// 现在：
///
/// 1. 启动
/// 2. Secure Storage 读取 Token
/// 3. /api/users/me 验证
/// 4. 决定进入主页还是登录页
class _AuthGate
    extends StatefulWidget {
  final bool isDarkMode;

  final ValueChanged<bool>
  onThemeChanged;

  final ValueChanged<Locale>
  onLocaleChanged;

  const _AuthGate({
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<_AuthGate> createState() {
    return _AuthGateState();
  }
}

class _AuthGateState
    extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();

    // 不 await。
    //
    // 初始化期间 AuthStatus.restoring，
    // UI 会显示加载页面。
    AuthService.instance
        .initialize();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedBuilder(
      animation:
      AuthService.instance,
      builder: (
          context,
          child,
          ) {
        final auth =
            AuthService.instance;

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
              isDarkMode:
              widget.isDarkMode,
              onThemeChanged:
              widget.onThemeChanged,
              onLocaleChanged:
              widget.onLocaleChanged,
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
              message:
              auth.restoreError,
              onRetry:
              auth.retryRestoreSession,
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

class _SessionLoadingPage
    extends StatelessWidget {
  const _SessionLoadingPage();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// ============================================================
// Session Restore Error
// ============================================================

class _SessionRestoreErrorPage
    extends StatelessWidget {
  final String? message;

  final Future<void> Function()
  onRetry;

  final Future<void> Function()
  onLogin;

  const _SessionRestoreErrorPage({
    required this.message,
    required this.onRetry,
    required this.onLogin,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final l10n =
    AppLocalizations.of(
      context,
    )!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(
              32,
            ),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth:
                420,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size:
                    64,
                    color:
                    Theme.of(
                      context,
                    )
                        .colorScheme
                        .onSurfaceVariant,
                  ),

                  const SizedBox(
                    height:
                    20,
                  ),

                  Text(
                    l10n.operationFailed,
                    textAlign:
                    TextAlign.center,
                    style:
                    Theme.of(
                      context,
                    )
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  if (message !=
                      null &&
                      message!
                          .isNotEmpty) ...[
                    const SizedBox(
                      height:
                      10,
                    ),

                    Text(
                      message!,
                      textAlign:
                      TextAlign.center,
                      style:
                      Theme.of(
                        context,
                      )
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color:
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height:
                    28,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height:
                    50,
                    child:
                    FilledButton.icon(
                      onPressed: () {
                        onRetry();
                      },
                      icon:
                      const Icon(
                        Icons.refresh,
                      ),
                      label:
                      Text(
                        l10n.reload,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                    8,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    child:
                    TextButton(
                      onPressed: () {
                        onLogin();
                      },
                      child:
                      Text(
                        l10n.login,
                      ),
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