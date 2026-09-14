import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<Locale> onLocaleChanged;

  const SettingsPage({
    super.key,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.onNotificationsChanged,
    required this.onDarkModeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  late bool notificationsEnabled;
  late bool darkModeEnabled;

  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();

    notificationsEnabled =
        widget.notificationsEnabled;

    darkModeEnabled =
        widget.darkModeEnabled;
  }

  // ============================================================
  // Locale
  // ============================================================

  Locale _normalizedLocale(
      Locale locale,
      ) {
    if (locale.languageCode == 'en') {
      return const Locale('en');
    }

    final countryCode =
        locale.countryCode;

    if (locale.scriptCode == 'Hant' ||
        countryCode == 'TW' ||
        countryCode == 'HK' ||
        countryCode == 'MO') {
      return const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      );
    }

    return const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
    );
  }

  String _languageName(
      Locale locale,
      ) {
    final normalized =
    _normalizedLocale(locale);

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
      Localizations.localeOf(context),
    );

    final selected =
    await showModalBottomSheet<
        Locale>(
      context: context,
      builder: (
          bottomSheetContext,
          ) {
        return SafeArea(
          child: RadioGroup<Locale>(
            groupValue:
            currentLocale,
            onChanged: (value) {
              if (value != null) {
                Navigator.pop(
                  bottomSheetContext,
                  value,
                );
              }
            },
            child: const Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                RadioListTile<Locale>(
                  value:
                  Locale.fromSubtags(
                    languageCode: 'zh',
                    scriptCode: 'Hans',
                  ),
                  title:
                  Text('简体中文'),
                ),
                RadioListTile<Locale>(
                  value:
                  Locale.fromSubtags(
                    languageCode: 'zh',
                    scriptCode: 'Hant',
                  ),
                  title:
                  Text('繁體中文'),
                ),
                RadioListTile<Locale>(
                  value: Locale('en'),
                  title:
                  Text('English'),
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
  // Delete account
  // ============================================================

  Future<void> _showDeleteAccountDialog() async {
    final user = AuthService.instance.currentUser;

    if (user == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _DeleteAccountDialog(
          email: user.email,
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) {
      return;
    }

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      await AuthService.instance.deleteAccount();

      if (!mounted) {
        return;
      }

      // 这里只退出 SettingsPage。
      //
      // deleteAccount() 会：
      // currentUser = null
      // notifyListeners()
      //
      // AuthGate 会自动把首页切换成 AuthPage。
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDeletingAccount = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              localizedErrorMessage(
                context,
                e.message,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDeletingAccount = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.operationFailed,
            ),
            behavior: SnackBarBehavior.floating,
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
    final l10n = context.l10n;

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
          style: const TextStyle(
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color: Colors.grey,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

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
              onChanged: (value) {
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
                    .dark_mode_outlined,
              ),
              title: Text(
                l10n.darkMode,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight
                      .w500,
                ),
              ),
              subtitle: Text(
                l10n
                    .darkModeSubtitle,
              ),
              value:
              darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  darkModeEnabled =
                      value;
                });

                widget
                    .onDarkModeChanged(
                  value,
                );
              },
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color: Colors.grey,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

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
              trailing: Text(
                _languageName(
                  locale,
                ),
                style:
                const TextStyle(
                  color:
                  Colors.grey,
                ),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color: Colors.grey,
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
                Icons.chevron_right,
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
    extends State<_DeleteAccountDialog> {
  late final TextEditingController
  _controller;

  bool _emailMatches = false;

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
        value.trim().toLowerCase() ==
            widget.email.trim().toLowerCase();

    if (matches == _emailMatches) {
      return;
    }

    setState(() {
      _emailMatches = matches;
    });
  }

  void _confirm() {
    if (!_emailMatches) {
      return;
    }

    // 先主动关闭软键盘，
    // 避免 Dialog 退出动画和 IME 动画同时进行。
    FocusScope.of(context).unfocus();

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final l10n = context.l10n;

    final colorScheme =
        Theme.of(context).colorScheme;

    return AlertDialog(
      // 关键：
      // 键盘弹出、横屏、小屏设备时允许内容滚动，
      // 避免 RenderFlex overflow。
      scrollable: true,

      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.deleteAccount,
            ),
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deleteAccountDescription,
          ),

          const SizedBox(height: 20),

          Text(
            l10n.deleteAccountEmailPrompt(
              widget.email,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _controller,

            // 不要 autofocus。
            //
            // 让用户点击输入框以后
            // 再弹出键盘，会稳定很多。
            autofocus: false,

            keyboardType:
            TextInputType.emailAddress,

            autocorrect: false,

            enableSuggestions: false,

            textInputAction:
            TextInputAction.done,

            onChanged: _onEmailChanged,

            onSubmitted: (_) {
              if (_emailMatches) {
                _confirm();
              }
            },

            decoration: InputDecoration(
              hintText:
              l10n.deleteAccountEmailHint,
              prefixIcon: const Icon(
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
          onPressed: () {
            FocusScope.of(context)
                .unfocus();

            Navigator.of(context)
                .pop(false);
          },
          child: Text(
            l10n.cancel,
          ),
        ),

        FilledButton(
          onPressed:
          _emailMatches
              ? _confirm
              : null,
          style: FilledButton.styleFrom(
            backgroundColor:
            colorScheme.error,
            foregroundColor:
            colorScheme.onError,
          ),
          child: Text(
            l10n.deleteAccount,
          ),
        ),
      ],
    );
  }
}