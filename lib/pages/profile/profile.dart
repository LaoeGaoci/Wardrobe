import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../services/users/auth_service.dart';
import '../../services/notification/notification_service.dart';
import '../../widgets/wardrobe_image.dart';
import 'about.dart';
import 'settings.dart';

class ProfilePage extends StatefulWidget {
  /// 当前主题模式：
  ///
  /// ThemeMode.system -> 跟随系统
  /// ThemeMode.light  -> 浅色
  /// ThemeMode.dark   -> 深色
  final ThemeMode themeMode;

  /// 修改主题模式
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// 修改语言
  final ValueChanged<Locale> onLocaleChanged;

  const ProfilePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditingUsername = false;

  late final TextEditingController _usernameController;

  late final FocusNode _usernameFocusNode;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();

    _usernameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: AnimatedBuilder(
        animation: AuthService.instance,

        builder: (context, _) {
          final user = AuthService.instance.currentUser;

          if (user == null) {
            return const SizedBox.shrink();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

            children: [
              // ==================================================
              // Profile
              // ==================================================
              Center(
                child: Column(
                  children: [
                    WardrobeAvatar(
                      user: user,
                      radius: 42,
                      fallbackIcon: Icons.person_outline,
                    ),

                    const SizedBox(height: 14),

                    _buildUsernameEditor(context, user.username),

                    const SizedBox(height: 4),

                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ==================================================
              // Settings
              // ==================================================
              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                title: l10n.settings,
                onTap: _openSettings,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // About
              // ==================================================
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: l10n.about,
                onTap: _openAbout,
              ),

              const SizedBox(height: 32),

              Divider(color: Theme.of(context).dividerColor),

              const SizedBox(height: 12),

              // ==================================================
              // Logout
              // ==================================================
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),

                leading: Icon(Icons.logout, color: Colors.red.shade400),

                title: Text(
                  l10n.logout,
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                onTap: () => _showLogoutDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // Username
  // ============================================================

  Widget _buildUsernameEditor(BuildContext context, String username) {
    final colorScheme = Theme.of(context).colorScheme;

    final l10n = context.l10n;

    if (_isEditingUsername) {
      return Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 220),

            child: TextField(
              controller: _usernameController,

              focusNode: _usernameFocusNode,

              autofocus: true,

              maxLength: 20,

              textAlign: TextAlign.center,

              textInputAction: TextInputAction.done,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),

              decoration: const InputDecoration(
                isDense: true,

                counterText: '',

                border: InputBorder.none,

                enabledBorder: InputBorder.none,

                focusedBorder: InputBorder.none,

                filled: true,

                fillColor: Colors.transparent,

                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
              ),

              onSubmitted: (_) => _saveUsername(),
            ),
          ),

          const SizedBox(width: 2),

          IconButton(
            onPressed: _saveUsername,

            tooltip: l10n.save,

            icon: Icon(Icons.check, size: 20, color: colorScheme.primary),

            visualDensity: VisualDensity.compact,
          ),

          IconButton(
            onPressed: _cancelUsernameEdit,

            tooltip: l10n.cancel,

            icon: Icon(
              Icons.close,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),

            visualDensity: VisualDensity.compact,
          ),
        ],
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),

      onTap: () => _startUsernameEdit(username),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Text(
              username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(width: 6),

            Icon(
              Icons.edit_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _startUsernameEdit(String username) {
    _usernameController.text = username;

    _usernameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: username.length,
    );

    setState(() {
      _isEditingUsername = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _usernameFocusNode.requestFocus();
      }
    });
  }

  Future<void> _saveUsername() async {
    try {
      await AuthService.instance.updateUsername(_usernameController.text);

      if (!mounted) {
        return;
      }

      setState(() {
        _isEditingUsername = false;
      });

      FocusScope.of(context).unfocus();
    } on AuthException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizedErrorMessage(context, e.message)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancelUsernameEdit() {
    setState(() {
      _isEditingUsername = false;
    });

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // Menu
  // ============================================================

  Widget _buildMenuItem(
    BuildContext context, {
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
  // Settings
  // ============================================================

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          // 不再写死 true。
          //
          // 直接从 NotificationService 获取：
          //
          // 用户通知意愿
          // &&
          // Android 系统真实通知权限
          notificationsEnabled: NotificationService.instance.enabled,

          // 当前主题模式。
          themeMode: widget.themeMode,

          // SettingsPage 本身已经监听
          // NotificationService。
          //
          // ProfilePage 不需要额外保存通知状态。
          onNotificationsChanged: (_) {},

          onThemeModeChanged: widget.onThemeModeChanged,

          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
  }

  // ============================================================
  // About
  // ============================================================

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutPage()),
    );
  }

  // ============================================================
  // Logout
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    final l10n = context.l10n;

    showDialog<void>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.logout),

          content: Text(l10n.logoutConfirm),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await AuthService.instance.logout();
              },

              child: Text(
                l10n.logout,
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          ],
        );
      },
    );
  }
}
