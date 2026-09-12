import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'about.dart';
import 'settings.dart';

class ProfilePage
    extends StatefulWidget {
  final bool isDarkMode;

  final ValueChanged<bool>
  onThemeChanged;

  const ProfilePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  bool _isEditingUsername = false;

  late final TextEditingController
  _usernameController;

  late final FocusNode
  _usernameFocusNode;

  @override
  void initState() {
    super.initState();

    _usernameController =
        TextEditingController();

    _usernameFocusNode =
        FocusNode();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight:
            FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation:
        AuthService.instance,
        builder: (
            context,
            _,
            ) {
          final user =
              AuthService
                  .instance
                  .currentUser;

          if (user == null) {
            return const SizedBox
                .shrink();
          }

          return ListView(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor:
                      Theme.of(
                        context,
                      )
                          .colorScheme
                          .surfaceContainerHighest,
                      backgroundImage:
                      user.avatarUrl
                          .isNotEmpty
                          ? NetworkImage(
                        user.avatarUrl,
                      )
                          : null,
                      child: user
                          .avatarUrl
                          .isEmpty
                          ? Icon(
                        Icons
                            .person_outline,
                        size: 48,
                        color:
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                      )
                          : null,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    _buildUsernameEditor(
                      context,
                      user.username,
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      user.email,
                      style:
                      TextStyle(
                        fontSize: 14,
                        color:
                        Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 36,
              ),

              _buildMenuItem(
                context,
                icon: Icons
                    .settings_outlined,
                title: 'Settings',
                onTap:
                _openSettings,
              ),

              const SizedBox(
                height: 12,
              ),

              _buildMenuItem(
                context,
                icon:
                Icons.info_outline,
                title: 'About',
                onTap: _openAbout,
              ),

              const SizedBox(
                height: 32,
              ),

              Divider(
                color: Theme.of(
                  context,
                ).dividerColor,
              ),

              const SizedBox(
                height: 12,
              ),

              ListTile(
                contentPadding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 4,
                ),
                leading: Icon(
                  Icons.logout,
                  color: Colors
                      .red.shade400,
                ),
                title: Text(
                  'Log Out',
                  style:
                  TextStyle(
                    color: Colors
                        .red
                        .shade400,
                    fontWeight:
                    FontWeight
                        .w500,
                  ),
                ),
                onTap: () =>
                    _showLogoutDialog(
                      context,
                    ),
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

  Widget _buildUsernameEditor(
      BuildContext context,
      String username,
      ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    if (_isEditingUsername) {
      return Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints:
            const BoxConstraints(
              minWidth: 100,
              maxWidth: 220,
            ),
            child: TextField(
              controller:
              _usernameController,
              focusNode:
              _usernameFocusNode,
              autofocus: true,
              maxLength: 20,
              textAlign:
              TextAlign.center,
              textInputAction:
              TextInputAction
                  .done,
              style:
              const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w600,
              ),
              decoration:
              const InputDecoration(
                isDense: true,
                counterText: '',
                border:
                InputBorder.none,
                enabledBorder:
                InputBorder.none,
                focusedBorder:
                InputBorder.none,
                filled: true,
                fillColor:
                Colors.transparent,
                contentPadding:
                EdgeInsets
                    .symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
              ),
              onSubmitted: (_) =>
                  _saveUsername(),
            ),
          ),

          const SizedBox(
            width: 2,
          ),

          IconButton(
            onPressed:
            _saveUsername,
            tooltip: 'Save',
            icon: Icon(
              Icons.check,
              size: 20,
              color:
              colorScheme.primary,
            ),
            visualDensity:
            VisualDensity
                .compact,
          ),

          IconButton(
            onPressed:
            _cancelUsernameEdit,
            tooltip: 'Cancel',
            icon: Icon(
              Icons.close,
              size: 20,
              color: colorScheme
                  .onSurfaceVariant,
            ),
            visualDensity:
            VisualDensity
                .compact,
          ),
        ],
      );
    }

    return InkWell(
      borderRadius:
      BorderRadius.circular(
        10,
      ),
      onTap: () =>
          _startUsernameEdit(
            username,
          ),
      child: Padding(
        padding:
        const EdgeInsets
            .symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Text(
              username,
              style:
              const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w600,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Icon(
              Icons.edit_outlined,
              size: 16,
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _startUsernameEdit(
      String username,
      ) {
    _usernameController.text =
        username;

    _usernameController.selection =
        TextSelection(
          baseOffset: 0,
          extentOffset:
          username.length,
        );

    setState(() {
      _isEditingUsername = true;
    });

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        if (mounted) {
          _usernameFocusNode
              .requestFocus();
        }
      },
    );
  }

  Future<void> _saveUsername() async {
    try {
      await AuthService.instance
          .updateUsername(
        _usernameController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isEditingUsername =
        false;
      });

      FocusScope.of(context)
          .unfocus();
    } on AuthException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message,
          ),
          behavior:
          SnackBarBehavior
              .floating,
        ),
      );
    }
  }

  void _cancelUsernameEdit() {
    setState(() {
      _isEditingUsername = false;
    });

    FocusScope.of(context)
        .unfocus();
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
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        onTap: onTap,
        child: Container(
          padding:
          const EdgeInsets
              .symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration:
          BoxDecoration(
            color: Theme.of(
              context,
            ).cardColor,
            borderRadius:
            BorderRadius
                .circular(
              16,
            ),
            border: Border.all(
              color: Theme.of(
                context,
              ).dividerColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color:
                Theme.of(
                  context,
                )
                    .colorScheme
                    .onSurface,
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Text(
                  title,
                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight
                        .w500,
                  ),
                ),
              ),

              Icon(
                Icons
                    .chevron_right,
                color:
                Theme.of(
                  context,
                )
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SettingsPage(
              notificationsEnabled:
              true,
              darkModeEnabled:
              widget.isDarkMode,
              onNotificationsChanged:
                  (_) {},
              onDarkModeChanged:
              widget
                  .onThemeChanged,
            ),
      ),
    );
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const AboutPage(),
      ),
    );
  }

  // ============================================================
  // Logout
  // ============================================================

  void _showLogoutDialog(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Log Out',
          ),
          content:
          const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                  ),
              child:
              const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                AuthService
                    .instance
                    .logout();
              },
              child: Text(
                'Log Out',
                style:
                TextStyle(
                  color: Colors
                      .red
                      .shade400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}