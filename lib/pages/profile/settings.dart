import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsPage({
    super.key,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.onNotificationsChanged,
    required this.onDarkModeChanged,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
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
              title: const Text(
                'Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Receive outfit reminders',
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
              title: const Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Use dark appearance',
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

          const Text(
            'App',
            style: TextStyle(
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
              title: const Text(
                'Language',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Text(
                'English',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}