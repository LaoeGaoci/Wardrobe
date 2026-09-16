import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  final bool notificationsEnabled;

  /// 当前主题模式。
  ///
  /// ThemeMode.system -> 跟随系统
  /// ThemeMode.light  -> 浅色
  /// ThemeMode.dark   -> 深色
  final ThemeMode themeMode;

  final ValueChanged<bool>
  onNotificationsChanged;

  final ValueChanged<ThemeMode>
  onThemeModeChanged;

  final ValueChanged<Locale>
  onLocaleChanged;

  const SettingsPage({
    super.key,
    required this.notificationsEnabled,
    required this.themeMode,
    required this.onNotificationsChanged,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  late bool
  notificationsEnabled;

  late ThemeMode
  themeMode;

  bool _isDeletingAccount =
  false;

  @override
  void initState() {
    super.initState();

    notificationsEnabled =
        widget.notificationsEnabled;

    themeMode =
        widget.themeMode;
  }

  // ============================================================
  // Locale
  // ============================================================

  Locale _normalizedLocale(
      Locale locale,
      ) {
    if (locale.languageCode ==
        'en') {
      return const Locale(
        'en',
      );
    }

    final countryCode =
        locale.countryCode;

    if (locale.scriptCode ==
        'Hant' ||
        countryCode ==
            'TW' ||
        countryCode ==
            'HK' ||
        countryCode ==
            'MO') {
      return const Locale
          .fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      );
    }

    return const Locale
        .fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
    );
  }

  String _languageName(
      Locale locale,
      ) {
    final normalized =
    _normalizedLocale(
      locale,
    );

    if (normalized.languageCode ==
        'en') {
      return 'English';
    }

    if (normalized.scriptCode ==
        'Hant') {
      return '繁體中文';
    }

    return '简体中文';
  }

  Future<void>
  _showLanguagePicker() async {
    final currentLocale =
    _normalizedLocale(
      Localizations.localeOf(
        context,
      ),
    );

    final selected =
    await showModalBottomSheet<
        Locale>(
      context: context,
      builder: (
          bottomSheetContext,
          ) {
        return SafeArea(
          child:
          RadioGroup<Locale>(
            groupValue:
            currentLocale,
            onChanged: (
                value,
                ) {
              if (value !=
                  null) {
                Navigator.pop(
                  bottomSheetContext,
                  value,
                );
              }
            },
            child:
            const Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                RadioListTile<
                    Locale>(
                  value:
                  Locale
                      .fromSubtags(
                    languageCode:
                    'zh',
                    scriptCode:
                    'Hans',
                  ),
                  title:
                  Text(
                    '简体中文',
                  ),
                ),
                RadioListTile<
                    Locale>(
                  value:
                  Locale
                      .fromSubtags(
                    languageCode:
                    'zh',
                    scriptCode:
                    'Hant',
                  ),
                  title:
                  Text(
                    '繁體中文',
                  ),
                ),
                RadioListTile<
                    Locale>(
                  value:
                  Locale(
                    'en',
                  ),
                  title:
                  Text(
                    'English',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    widget.onLocaleChanged(
      selected,
    );
  }

  // ============================================================
  // Theme
  // ============================================================

  /// 当前语言使用的主题标题。
  ///
  /// 暂时放在这里，这样不修改 ARB
  /// 也可以直接编译运行。
  String _themeTitle(
      Locale locale,
      ) {
    final normalized =
    _normalizedLocale(
      locale,
    );

    if (normalized.languageCode ==
        'en') {
      return 'Theme';
    }

    if (normalized.scriptCode ==
        'Hant') {
      return '主題';
    }

    return '主题';
  }

  String _themeSubtitle(
      Locale locale,
      ) {
    final normalized =
    _normalizedLocale(
      locale,
    );

    if (normalized.languageCode ==
        'en') {
      return 'Choose app appearance';
    }

    if (normalized.scriptCode ==
        'Hant') {
      return '選擇應用程式外觀';
    }

    return '选择应用外观';
  }

  String _themeModeName(
      Locale locale,
      ThemeMode mode,
      ) {
    final normalized =
    _normalizedLocale(
      locale,
    );

    final isEnglish =
        normalized.languageCode ==
            'en';

    final isTraditional =
        normalized.scriptCode ==
            'Hant';

    switch (mode) {
      case ThemeMode.system:
        if (isEnglish) {
          return 'Follow system';
        }

        if (isTraditional) {
          return '跟隨系統';
        }

        return '跟随系统';

      case ThemeMode.light:
        if (isEnglish) {
          return 'Light';
        }

        if (isTraditional) {
          return '淺色';
        }

        return '浅色';

      case ThemeMode.dark:
        if (isEnglish) {
          return 'Dark';
        }

        if (isTraditional) {
          return '深色';
        }

        return '深色';
    }
  }

  IconData _themeModeIcon(
      ThemeMode mode,
      ) {
    switch (mode) {
      case ThemeMode.system:
        return Icons
            .brightness_auto_outlined;

      case ThemeMode.light:
        return Icons
            .light_mode_outlined;

      case ThemeMode.dark:
        return Icons
            .dark_mode_outlined;
    }
  }

  Future<void>
  _showThemePicker() async {
    final locale =
    Localizations.localeOf(
      context,
    );

    final selected =
    await showModalBottomSheet<
        ThemeMode>(
      context: context,
      builder: (
          bottomSheetContext,
          ) {
        return SafeArea(
          child:
          RadioGroup<ThemeMode>(
            groupValue:
            themeMode,
            onChanged: (
                value,
                ) {
              if (value !=
                  null) {
                Navigator.pop(
                  bottomSheetContext,
                  value,
                );
              }
            },
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                RadioListTile<
                    ThemeMode>(
                  value:
                  ThemeMode
                      .system,
                  secondary:
                  const Icon(
                    Icons
                        .brightness_auto_outlined,
                  ),
                  title: Text(
                    _themeModeName(
                      locale,
                      ThemeMode
                          .system,
                    ),
                  ),
                ),
                RadioListTile<
                    ThemeMode>(
                  value:
                  ThemeMode
                      .light,
                  secondary:
                  const Icon(
                    Icons
                        .light_mode_outlined,
                  ),
                  title: Text(
                    _themeModeName(
                      locale,
                      ThemeMode
                          .light,
                    ),
                  ),
                ),
                RadioListTile<
                    ThemeMode>(
                  value:
                  ThemeMode
                      .dark,
                  secondary:
                  const Icon(
                    Icons
                        .dark_mode_outlined,
                  ),
                  title: Text(
                    _themeModeName(
                      locale,
                      ThemeMode
                          .dark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    if (selected ==
        themeMode) {
      return;
    }

    setState(() {
      themeMode =
          selected;
    });

    widget.onThemeModeChanged(
      selected,
    );
  }

  // ============================================================
  // Delete account
  // ============================================================

  Future<void>
  _showDeleteAccountDialog() async {
    final user =
        AuthService
            .instance
            .currentUser;

    if (user == null) {
      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      barrierDismissible:
      false,
      builder: (_) {
        return _DeleteAccountDialog(
          email: user.email,
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    await _deleteAccount();
  }

  Future<void>
  _deleteAccount() async {
    if (_isDeletingAccount) {
      return;
    }

    setState(() {
      _isDeletingAccount =
      true;
    });

    try {
      await AuthService
          .instance
          .deleteAccount();

      if (!mounted) {
        return;
      }

      // 删除账号后 AuthService 会：
      //
      // currentUser = null
      // notifyListeners()
      //
      // AuthGate 会自动切换回登录页面。
      Navigator.of(context)
          .pop();
    } on AuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDeletingAccount =
        false;
      });

      ScaffoldMessenger.of(
        context,
      )
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              localizedErrorMessage(
                context,
                e.message,
              ),
            ),
            behavior:
            SnackBarBehavior
                .floating,
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDeletingAccount =
        false;
      });

      ScaffoldMessenger.of(
        context,
      )
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context
                  .l10n
                  .operationFailed,
            ),
            behavior:
            SnackBarBehavior
                .floating,
          ),
        );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final l10n =
        context.l10n;

    final locale =
    Localizations.localeOf(
      context,
    );

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding:
        const EdgeInsets.all(
          20,
        ),
        children: [
          // ====================================================
          // Preferences
          // ====================================================

          Text(
            l10n.preferences,
            style:
            const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color:
              Colors.grey,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ====================================================
          // Notifications
          // ====================================================

          Card(
            elevation: 0,
            child:
            SwitchListTile(
              contentPadding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
              ),
              secondary:
              const Icon(
                Icons
                    .notifications_outlined,
              ),
              title: Text(
                l10n.notifications,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight
                      .w500,
                ),
              ),
              subtitle: Text(
                l10n
                    .notificationsSubtitle,
              ),
              value:
              notificationsEnabled,
              onChanged: (
                  value,
                  ) {
                setState(() {
                  notificationsEnabled =
                      value;
                });

                widget
                    .onNotificationsChanged(
                  value,
                );
              },
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ====================================================
          // Theme
          // ====================================================

          Card(
            elevation: 0,
            child: ListTile(
              contentPadding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
              ),
              leading: Icon(
                _themeModeIcon(
                  themeMode,
                ),
              ),
              title: Text(
                _themeTitle(
                  locale,
                ),
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight
                      .w500,
                ),
              ),
              subtitle: Text(
                _themeSubtitle(
                  locale,
                ),
              ),
              trailing: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    _themeModeName(
                      locale,
                      themeMode,
                    ),
                    style: TextStyle(
                      color:
                      colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons
                        .chevron_right,
                    color:
                    colorScheme
                        .onSurfaceVariant,
                  ),
                ],
              ),
              onTap:
              _showThemePicker,
            ),
          ),

          const SizedBox(
            height: 32,
          ),

          // ====================================================
          // App
          // ====================================================

          Text(
            l10n.appSection,
            style:
            const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color:
              Colors.grey,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ====================================================
          // Language
          // ====================================================

          Card(
            elevation: 0,
            child: ListTile(
              leading:
              const Icon(
                Icons
                    .language_outlined,
              ),
              title: Text(
                l10n.language,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight
                      .w500,
                ),
              ),
              trailing: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    _languageName(
                      locale,
                    ),
                    style: TextStyle(
                      color:
                      colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons
                        .chevron_right,
                    color:
                    colorScheme
                        .onSurfaceVariant,
                  ),
                ],
              ),
              onTap:
              _showLanguagePicker,
            ),
          ),

          const SizedBox(
            height: 32,
          ),

          // ====================================================
          // Account
          // ====================================================

          Text(
            l10n.accountSection,
            style:
            const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color:
              Colors.grey,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Card(
            elevation: 0,
            child: ListTile(
              leading:
              _isDeletingAccount
                  ? SizedBox(
                width: 24,
                height: 24,
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2.2,
                  color:
                  colorScheme
                      .error,
                ),
              )
                  : Icon(
                Icons
                    .delete_forever_outlined,
                color:
                colorScheme
                    .error,
              ),
              title: Text(
                l10n
                    .deleteAccount,
                style: TextStyle(
                  color:
                  colorScheme
                      .error,
                  fontWeight:
                  FontWeight
                      .w600,
                ),
              ),
              subtitle: Text(
                l10n
                    .deleteAccountSubtitle,
              ),
              trailing: Icon(
                Icons
                    .chevron_right,
                color:
                colorScheme
                    .error,
              ),
              onTap:
              _isDeletingAccount
                  ? null
                  : _showDeleteAccountDialog,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Delete Account Dialog
// ============================================================

class _DeleteAccountDialog
    extends StatefulWidget {
  final String email;

  const _DeleteAccountDialog({
    required this.email,
  });

  @override
  State<_DeleteAccountDialog>
  createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState
    extends State<
        _DeleteAccountDialog> {
  late final TextEditingController
  _controller;

  bool _emailMatches =
  false;

  @override
  void initState() {
    super.initState();

    _controller =
        TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _onEmailChanged(
      String value,
      ) {
    final matches =
        value
            .trim()
            .toLowerCase() ==
            widget.email
                .trim()
                .toLowerCase();

    if (matches ==
        _emailMatches) {
      return;
    }

    setState(() {
      _emailMatches =
          matches;
    });
  }

  void _confirm() {
    if (!_emailMatches) {
      return;
    }

    FocusScope.of(context)
        .unfocus();

    Navigator.of(context)
        .pop(true);
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final l10n =
        context.l10n;

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Icon(
            Icons
                .warning_amber_rounded,
            color:
            colorScheme.error,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              l10n
                  .deleteAccount,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize:
        MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            l10n
                .deleteAccountDescription,
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            l10n
                .deleteAccountEmailPrompt(
              widget.email,
            ),
            style:
            const TextStyle(
              fontWeight:
              FontWeight.w500,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextField(
            controller:
            _controller,
            autofocus: false,
            keyboardType:
            TextInputType
                .emailAddress,
            autocorrect: false,
            enableSuggestions:
            false,
            textInputAction:
            TextInputAction.done,
            onChanged:
            _onEmailChanged,
            onSubmitted: (_) {
              if (_emailMatches) {
                _confirm();
              }
            },
            decoration:
            InputDecoration(
              hintText:
              l10n
                  .deleteAccountEmailHint,
              prefixIcon:
              const Icon(
                Icons
                    .email_outlined,
              ),
              border:
              const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(
              context,
            ).unfocus();

            Navigator.of(
              context,
            ).pop(false);
          },
          child:
          Text(
            l10n.cancel,
          ),
        ),
        FilledButton(
          onPressed:
          _emailMatches
              ? _confirm
              : null,
          style:
          FilledButton
              .styleFrom(
            backgroundColor:
            colorScheme.error,
            foregroundColor:
            colorScheme.onError,
          ),
          child:
          Text(
            l10n.deleteAccount,
          ),
        ),
      ],
    );
  }
}