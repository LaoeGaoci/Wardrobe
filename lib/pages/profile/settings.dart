import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

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
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool notificationsEnabled;
  late bool darkModeEnabled;

  @override
  void initState() {
    super.initState();

    notificationsEnabled = widget.notificationsEnabled;
    darkModeEnabled = widget.darkModeEnabled;
  }

  Locale _normalizedLocale(Locale locale) {
    if (locale.languageCode == 'en') {
      return const Locale('en');
    }

    final countryCode = locale.countryCode;

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

  String _languageName(Locale locale) {
    final normalized = _normalizedLocale(locale);

    if (normalized.languageCode == 'en') {
      return 'English';
    }

    if (normalized.scriptCode == 'Hant') {
      return '繁體中文';
    }

    return '简体中文';
  }

  Future<void> _showLanguagePicker() async {
    final currentLocale = _normalizedLocale(
      Localizations.localeOf(context),
    );

    final selected = await showModalBottomSheet<Locale>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: RadioGroup<Locale>(
            groupValue: currentLocale,
            onChanged: (value) {
              if (value != null) {
                Navigator.pop(bottomSheetContext, value);
              }
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<Locale>(
                  value: Locale.fromSubtags(
                    languageCode: 'zh',
                    scriptCode: 'Hans',
                  ),
                  title: Text('简体中文'),
                ),
                RadioListTile<Locale>(
                  value: Locale.fromSubtags(
                    languageCode: 'zh',
                    scriptCode: 'Hant',
                  ),
                  title: Text('繁體中文'),
                ),
                RadioListTile<Locale>(
                  value: Locale('en'),
                  title: Text('English'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    widget.onLocaleChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.preferences,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              secondary: const Icon(
                Icons.notifications_outlined,
              ),
              title: Text(
                l10n.notifications,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.notificationsSubtitle,
              ),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });

                widget.onNotificationsChanged(value);
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              secondary: const Icon(
                Icons.dark_mode_outlined,
              ),
              title: Text(
                l10n.darkMode,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.darkModeSubtitle,
              ),
              value: darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  darkModeEnabled = value;
                });

                widget.onDarkModeChanged(value);
              },
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.appSection,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(
                Icons.language_outlined,
              ),
              title: Text(
                l10n.language,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                _languageName(locale),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              onTap: _showLanguagePicker,
            ),
          ),
        ],
      ),
    );
  }
}
