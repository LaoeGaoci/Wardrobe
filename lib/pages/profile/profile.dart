import 'package:flutter/material.dart';

import 'about.dart';
import 'settings.dart';

class ProfilePage extends StatefulWidget {
  /// 当前是否为深色模式
  final bool isDarkMode;

  /// 修改主题
  final ValueChanged<bool> onThemeChanged;

  const ProfilePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// 是否开启通知
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // ============================================================
          // Profile Header
          // ============================================================
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'User Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                Text(
                  'user@email.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // ============================================================
          // Settings
          // ============================================================
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: _openSettings,
          ),

          const SizedBox(height: 12),

          // ============================================================
          // About
          // ============================================================
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: _openAbout,
          ),

          const SizedBox(height: 32),

          Divider(color: Theme.of(context).dividerColor),

          const SizedBox(height: 12),

          // ============================================================
          // Log Out
          // ============================================================
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Menu Item
  // ============================================================

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Open Settings
  // ============================================================

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SettingsPage(
            notificationsEnabled: notificationsEnabled,

            // ⭐ 从 WardrobeApp 传进来的主题状态
            darkModeEnabled: widget.isDarkMode,

            // 通知开关
            onNotificationsChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },

            // ⭐ Dark Mode
            // 修改后直接通知 WardrobeApp
            onDarkModeChanged: widget.onThemeChanged,
          );
        },
      ),
    );
  }

  // ============================================================
  // Open About
  // ============================================================

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  }

  // ============================================================
  // Log Out Dialog
  // ============================================================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out'),

          content: const Text('Are you sure you want to log out?'),

          actions: [
            // Cancel
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            // Log Out
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // TODO:
                // 添加真正的退出登录逻辑
              },
              child: Text(
                'Log Out',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          ],
        );
      },
    );
  }
}
