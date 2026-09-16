import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  // Kept for compatibility with the existing ProfilePage.
  // NotificationService is the real source of truth.
  final bool notificationsEnabled;

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
  final NotificationService
      _notificationService =
      NotificationService.instance;

  late bool
      notificationsEnabled;

  late ThemeMode
      themeMode;

  bool _changingNotification =
      false;

  bool _isDeletingAccount =
      false;

  @override
  void initState() {
    super.initState();

    notificationsEnabled =
        _notificationService
            .enabled;

    themeMode =
        widget.themeMode;

    _notificationService
        .addListener(
      _onNotificationChanged,
    );
  }

  @override
  void dispose() {
    _notificationService
        .removeListener(
      _onNotificationChanged,
    );

    super.dispose();
  }

  void _onNotificationChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      notificationsEnabled =
          _notificationService
              .enabled;
    });
  }

  // ==========================================================
  // Notification
  // ==========================================================

  Future<void>
      _changeNotificationSetting(
    bool value,
  ) async {
    if (_changingNotification) {
      return;
    }

    setState(() {
      _changingNotification =
          true;
    });

    final success =
        await _notificationService
            .setEnabled(
      value,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _changingNotification =
          false;

      notificationsEnabled =
          _notificationService
              .enabled;
    });

    // Keep the old callback alive for compatibility.
    widget
        .onNotificationsChanged(
      notificationsEnabled,
    );

    if (
      value &&
      !success
    ) {
      await _showPermissionDialog();
    }
  }

  Future<void>
      _showPermissionDialog() async {
    final locale =
        _normalizedLocale(
      Localizations.localeOf(
        context,
      ),
    );

    final isEnglish =
        locale.languageCode ==
            'en';

    final isTraditional =
        locale.scriptCode ==
            'Hant';

    final message =
        isEnglish
            ? 'Notification permission is required to receive friend requests, clothing recommendations and system notifications.'
            : isTraditional
                ? '需要允許系統通知權限，才能接收好友請求、衣物推薦和系統通知。'
                : '需要允许系统通知权限，才能接收好友请求、衣物推荐和系统通知。';

    final settingsText =
        isEnglish
            ? 'Open system settings'
            : isTraditional
                ? '前往系統設定'
                : '前往系统设置';

    final open =
        await showDialog<bool>(
      context:
          context,

      builder:
          (dialogContext) {
        return AlertDialog(
          title:
              Text(
            context
                .l10n
                .notifications,
          ),

          content:
              Text(
            message,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  Text(
                context
                    .l10n
                    .cancel,
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  Text(
                settingsText,
              ),
            ),
          ],
        );
      },
    );

    if (
      open == true
    ) {
      await _notificationService
          .openSystemNotificationSettings();
    }
  }

  // ==========================================================
  // Locale
  // ==========================================================

  Locale _normalizedLocale(
    Locale locale,
  ) {
    if (
      locale.languageCode ==
      'en'
    ) {
      return const Locale(
        'en',
      );
    }

    final countryCode =
        locale.countryCode;

    if (
      locale.scriptCode ==
          'Hant' ||
      countryCode ==
          'TW' ||
      countryCode ==
          'HK' ||
      countryCode ==
          'MO'
    ) {
      return const Locale
          .fromSubtags(
        languageCode:
            'zh',
        scriptCode:
            'Hant',
      );
    }

    return const Locale
        .fromSubtags(
      languageCode:
          'zh',
      scriptCode:
          'Hans',
    );
  }

  String _languageName(
    Locale locale,
  ) {
    final normalized =
        _normalizedLocale(
      locale,
    );

    if (
      normalized.languageCode ==
      'en'
    ) {
      return 'English';
    }

    if (
      normalized.scriptCode ==
      'Hant'
    ) {
      return '繁體中文';
    }

    return '简体中文';
  }

  String _notificationSubtitle(
    Locale locale,
  ) {
    final normalized =
        _normalizedLocale(
      locale,
    );

    if (
      normalized.languageCode ==
      'en'
    ) {
      return 'Receive friend requests, clothing recommendations and system notifications';
    }

    if (
      normalized.scriptCode ==
      'Hant'
    ) {
      return '接收好友請求、衣物推薦和系統通知';
    }

    return '接收好友请求、衣物推荐和系统通知';
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
      context:
          context,

      builder:
          (
        bottomSheetContext,
      ) {
        return SafeArea(
          child:
              RadioGroup<Locale>(
            groupValue:
                currentLocale,

            onChanged:
                (
              value,
            ) {
              if (
                value != null
              ) {
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
                      Locale.fromSubtags(
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
                      Locale.fromSubtags(
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

    if (
      selected == null ||
      !mounted
    ) {
      return;
    }

    widget.onLocaleChanged(
      selected,
    );
  }

  // ==========================================================
  // Theme
  // ==========================================================

  String _themeTitle(
    Locale locale,
  ) {
    final normalized =
        _normalizedLocale(
      locale,
    );

    if (
      normalized.languageCode ==
      'en'
    ) {
      return 'Theme';
    }

    if (
      normalized.scriptCode ==
      'Hant'
    ) {
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

    if (
      normalized.languageCode ==
      'en'
    ) {
      return 'Choose app appearance';
    }

    if (
      normalized.scriptCode ==
      'Hant'
    ) {
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

    final english =
        normalized.languageCode ==
            'en';

    final traditional =
        normalized.scriptCode ==
            'Hant';

    switch (mode) {
      case ThemeMode.system:
        if (english) {
          return 'Follow system';
        }

        if (traditional) {
          return '跟隨系統';
        }

        return '跟随系统';

      case ThemeMode.light:
        if (english) {
          return 'Light';
        }

        if (traditional) {
          return '淺色';
        }

        return '浅色';

      case ThemeMode.dark:
        if (english) {
          return 'Dark';
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
      context:
          context,

      builder:
          (
        bottomSheetContext,
      ) {
        return SafeArea(
          child:
              RadioGroup<ThemeMode>(
            groupValue:
                themeMode,

            onChanged:
                (
              value,
            ) {
              if (
                value != null
              ) {
                Navigator.pop(
                  bottomSheetContext,
                  value,
                );
              }
            },

            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                for (
                  final mode
                  in ThemeMode.values
                )
                  RadioListTile<
                      ThemeMode>(
                    value:
                        mode,

                    secondary:
                        Icon(
                      _themeModeIcon(
                        mode,
                      ),
                    ),

                    title:
                        Text(
                      _themeModeName(
                        locale,
                        mode,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (
      selected == null ||
      !mounted ||
      selected ==
          themeMode
    ) {
      return;
    }

    setState(() {
      themeMode =
          selected;
    });

    widget
        .onThemeModeChanged(
      selected,
    );
  }

  // ==========================================================
  // Delete account
  // ==========================================================

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
      context:
          context,

      barrierDismissible:
          false,

      builder:
          (_) {
        return _DeleteAccountDialog(
          email:
              user.email,
        );
      },
    );

    if (
      confirmed != true ||
      !mounted
    ) {
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

      Navigator.of(
        context,
      ).pop();
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
            content:
                Text(
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
            content:
                Text(
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

  // ==========================================================
  // UI
  // ==========================================================

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
        Theme.of(
      context,
    ).colorScheme;

    return Scaffold(
      appBar:
          AppBar(
        title:
            Text(
          l10n.settings,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
        centerTitle:
            true,
      ),

      body:
          ListView(
        padding:
            const EdgeInsets.all(
          20,
        ),

        children: [
          Text(
            l10n.preferences,
            style:
                const TextStyle(
              fontSize:
                  14,
              fontWeight:
                  FontWeight.w600,
              color:
                  Colors.grey,
            ),
          ),

          const SizedBox(
            height:
                12,
          ),

          Card(
            elevation:
                0,
            child:
                SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal:
                    16,
              ),

              secondary:
                  _changingNotification
                      ? const SizedBox(
                          width:
                              24,
                          height:
                              24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.2,
                          ),
                        )
                      : const Icon(
                          Icons.notifications_outlined,
                        ),

              title:
                  Text(
                l10n.notifications,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              subtitle:
                  Text(
                _notificationSubtitle(
                  locale,
                ),
              ),

              value:
                  notificationsEnabled,

              onChanged:
                  _changingNotification
                      ? null
                      : _changeNotificationSetting,
            ),
          ),

          const SizedBox(
            height:
                12,
          ),

          Card(
            elevation:
                0,
            child:
                ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal:
                    16,
              ),

              leading:
                  Icon(
                _themeModeIcon(
                  themeMode,
                ),
              ),

              title:
                  Text(
                _themeTitle(
                  locale,
                ),
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              subtitle:
                  Text(
                _themeSubtitle(
                  locale,
                ),
              ),

              trailing:
                  Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    _themeModeName(
                      locale,
                      themeMode,
                    ),
                    style:
                        TextStyle(
                      color:
                          colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                    width:
                        4,
                  ),
                  Icon(
                    Icons.chevron_right,
                    color:
                        colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              onTap:
                  _showThemePicker,
            ),
          ),

          const SizedBox(
            height:
                32,
          ),

          Text(
            l10n.appSection,
            style:
                const TextStyle(
              fontSize:
                  14,
              fontWeight:
                  FontWeight.w600,
              color:
                  Colors.grey,
            ),
          ),

          const SizedBox(
            height:
                12,
          ),

          Card(
            elevation:
                0,
            child:
                ListTile(
              leading:
                  const Icon(
                Icons.language_outlined,
              ),

              title:
                  Text(
                l10n.language,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              trailing:
                  Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    _languageName(
                      locale,
                    ),
                    style:
                        TextStyle(
                      color:
                          colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                    width:
                        4,
                  ),
                  Icon(
                    Icons.chevron_right,
                    color:
                        colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              onTap:
                  _showLanguagePicker,
            ),
          ),

          const SizedBox(
            height:
                32,
          ),

          Text(
            l10n.accountSection,
            style:
                const TextStyle(
              fontSize:
                  14,
              fontWeight:
                  FontWeight.w600,
              color:
                  Colors.grey,
            ),
          ),

          const SizedBox(
            height:
                12,
          ),

          Card(
            elevation:
                0,
            child:
                ListTile(
              leading:
                  _isDeletingAccount
                      ? SizedBox(
                          width:
                              24,
                          height:
                              24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.2,
                            color:
                                colorScheme.error,
                          ),
                        )
                      : Icon(
                          Icons.delete_forever_outlined,
                          color:
                              colorScheme.error,
                        ),

              title:
                  Text(
                l10n.deleteAccount,
                style:
                    TextStyle(
                  color:
                      colorScheme.error,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              subtitle:
                  Text(
                l10n.deleteAccountSubtitle,
              ),

              trailing:
                  Icon(
                Icons.chevron_right,
                color:
                    colorScheme.error,
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

    if (
      matches ==
      _emailMatches
    ) {
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

    FocusScope.of(
      context,
    ).unfocus();

    Navigator.of(
      context,
    ).pop(
      true,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        context.l10n;

    final colorScheme =
        Theme.of(
      context,
    ).colorScheme;

    return AlertDialog(
      scrollable:
          true,

      title:
          Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color:
                colorScheme.error,
          ),
          const SizedBox(
            width:
                10,
          ),
          Expanded(
            child:
                Text(
              l10n.deleteAccount,
            ),
          ),
        ],
      ),

      content:
          Column(
        mainAxisSize:
            MainAxisSize.min,

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            l10n.deleteAccountDescription,
          ),

          const SizedBox(
            height:
                20,
          ),

          Text(
            l10n.deleteAccountEmailPrompt(
              widget.email,
            ),
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(
            height:
                12,
          ),

          TextField(
            controller:
                _controller,

            keyboardType:
                TextInputType.emailAddress,

            autocorrect:
                false,

            enableSuggestions:
                false,

            textInputAction:
                TextInputAction.done,

            onChanged:
                _onEmailChanged,

            onSubmitted:
                (_) {
              if (_emailMatches) {
                _confirm();
              }
            },

            decoration:
                InputDecoration(
              hintText:
                  l10n.deleteAccountEmailHint,

              prefixIcon:
                  const Icon(
                Icons.email_outlined,
              ),

              border:
                  const OutlineInputBorder(),
            ),
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed:
              () {
            FocusScope.of(
              context,
            ).unfocus();

            Navigator.of(
              context,
            ).pop(
              false,
            );
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
              FilledButton.styleFrom(
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
