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

class _WardrobeAppState extends State<WardrobeApp> {
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
            .getBool(_darkModeKey) ??
            false;

    final savedLanguage =
    widget.preferences
        .getString(_languageKey);

    if (savedLanguage == null) {
      _locale = _localeFromSystem(
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

  Locale _localeFromSystem(
      Locale locale,
      ) {
    if (locale.languageCode == 'en') {
      return const Locale('en');
    }

    if (locale.languageCode == 'zh') {
      final countryCode =
          locale.countryCode;

      final traditional =
          locale.scriptCode ==
              'Hant' ||
              countryCode == 'TW' ||
              countryCode == 'HK' ||
              countryCode == 'MO';

      return Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode:
        traditional
            ? 'Hant'
            : 'Hans',
      );
    }

    return const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
    );
  }

  Locale _localeFromCode(
      String code,
      ) {
    switch (code) {
      case 'en':
        return const Locale('en');

      case 'zh_Hant':
        return const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
        );

      case 'zh_Hans':
      default:
        return const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hans',
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

  Future<void> changeTheme(
      bool value,
      ) async {
    setState(() {
      isDarkMode = value;
    });

    await widget.preferences.setBool(
      _darkModeKey,
      value,
    );
  }

  Future<void> changeLocale(
      Locale locale,
      ) async {
    setState(() {
      _locale = locale;
    });

    await widget.preferences.setString(
      _languageKey,
      _localeCode(locale),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
      false,

      locale: _locale,

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
      )!.appTitle,

      theme: AppTheme.light,

      darkTheme: AppTheme.dark,

      themeMode:
      isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      home: _AuthGate(
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

class _AuthGate
    extends StatelessWidget {
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
  Widget build(
      BuildContext context,
      ) {
    return AnimatedBuilder(
      animation:
      AuthService.instance,

      builder:
          (
          context,
          child,
          ) {
        if (AuthService
            .instance
            .isLoggedIn) {
          return HomePage(
            isDarkMode:
            isDarkMode,
            onThemeChanged:
            onThemeChanged,
            onLocaleChanged:
            onLocaleChanged,
          );
        }

        return const AuthPage();
      },
    );
  }
}