import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
  });

  @override
  State<AuthPage> createState() =>
      _AuthPageState();
}

class _AuthPageState
    extends State<AuthPage> {
  final _formKey =
  GlobalKey<FormState>();

  final _emailController =
  TextEditingController();

  final _codeController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();

    _timer?.cancel();

    super.dispose();
  }

  // ============================================================
  // Login / Register
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await AuthService.instance.login(
          email:
          _emailController.text,
          password:
          _passwordController.text,
        );
      } else {
        await AuthService.instance.register(
          email:
          _emailController.text,
          verificationCode:
          _codeController.text,
          password:
          _passwordController.text,
        );
      }

      // 不需要手动 Navigator。
      //
      // AuthService 会更新 currentUser
      // 并 notifyListeners()。
      //
      // 如果你的应用入口已有 AuthGate，
      // 会自动切换到 HomePage。
    } on AuthException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '操作失败，请稍后重试',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // Verification Code
  // ============================================================

  Future<void> _sendCode() async {
    final email =
    _emailController.text.trim();

    if (email.isEmpty ||
        !email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '请输入有效的邮箱地址',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );

      return;
    }

    try {
      await AuthService.instance
          .sendVerificationCode(
        email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _countdown = 60;
      });

      _timer?.cancel();

      _timer = Timer.periodic(
        const Duration(seconds: 1),
            (timer) {
          if (_countdown <= 1) {
            timer.cancel();

            if (mounted) {
              setState(() {
                _countdown = 0;
              });
            }

            return;
          }

          if (mounted) {
            setState(() {
              _countdown--;
            });
          }
        },
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '验证码已发送',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // Mode
  // ============================================================

  void _switchMode(bool login) {
    if (_isLogin == login) {
      return;
    }

    setState(() {
      _isLogin = login;

      _codeController.clear();
      _passwordController.clear();
    });
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration:
                        BoxDecoration(
                          color: theme
                              .colorScheme
                              .primary,
                          borderRadius:
                          BorderRadius
                              .circular(
                            22,
                          ),
                        ),
                        child:
                        const Icon(
                          Icons
                              .checkroom_rounded,
                          color:
                          Colors.white,
                          size: 38,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // Title
                    Center(
                      child: Text(
                        _isLogin
                            ? '欢迎回来'
                            : '创建账号',
                        style: theme
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Center(
                      child: Text(
                        _isLogin
                            ? '登录你的衣柜，继续管理你的穿搭'
                            : '创建账号，开始整理你的专属衣柜',
                        textAlign:
                        TextAlign.center,
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // Login / Register mode
                    Container(
                      height: 50,
                      padding:
                      const EdgeInsets
                          .all(4),
                      decoration:
                      BoxDecoration(
                        color: theme
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius:
                        BorderRadius
                            .circular(
                          16,
                        ),
                      ),
                      child: Row(
                        children: [
                          _ModeButton(
                            title: '登录',
                            selected:
                            _isLogin,
                            onTap: () =>
                                _switchMode(
                                  true,
                                ),
                          ),
                          _ModeButton(
                            title: '注册',
                            selected:
                            !_isLogin,
                            onTap: () =>
                                _switchMode(
                                  false,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // Email
                    const _InputLabel(
                      label: '邮箱',
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextFormField(
                      controller:
                      _emailController,
                      keyboardType:
                      TextInputType
                          .emailAddress,
                      textInputAction:
                      TextInputAction
                          .next,
                      decoration:
                      _inputDecoration(
                        context,
                        hintText:
                        '请输入邮箱地址',
                        icon: Icons
                            .email_outlined,
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return '请输入邮箱';
                        }

                        if (!value
                            .contains('@')) {
                          return '请输入有效的邮箱地址';
                        }

                        return null;
                      },
                    ),

                    // Verification Code
                    if (!_isLogin) ...[
                      const SizedBox(
                        height: 20,
                      ),

                      const _InputLabel(
                        label: '验证码',
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      TextFormField(
                        controller:
                        _codeController,
                        keyboardType:
                        TextInputType
                            .number,
                        maxLength: 6,
                        decoration:
                        _inputDecoration(
                          context,
                          hintText:
                          '请输入验证码',
                          icon: Icons
                              .verified_outlined,
                          suffix:
                          TextButton(
                            onPressed:
                            _countdown >
                                0
                                ? null
                                : _sendCode,
                            child: Text(
                              _countdown >
                                  0
                                  ? '${_countdown}s'
                                  : '获取验证码',
                            ),
                          ),
                        ).copyWith(
                          counterText: '',
                        ),
                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return '请输入验证码';
                          }

                          if (value
                              .trim()
                              .length !=
                              6) {
                            return '验证码应为 6 位';
                          }

                          return null;
                        },
                      ),
                    ],

                    const SizedBox(
                      height: 20,
                    ),

                    // Password
                    const _InputLabel(
                      label: '密码',
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextFormField(
                      controller:
                      _passwordController,
                      obscureText:
                      _obscurePassword,
                      textInputAction:
                      TextInputAction
                          .done,
                      onFieldSubmitted:
                          (_) => _submit(),
                      decoration:
                      _inputDecoration(
                        context,
                        hintText: _isLogin
                            ? '请输入密码'
                            : '设置密码（至少 8 位）',
                        icon: Icons
                            .lock_outline_rounded,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                .visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return '请输入密码';
                        }

                        if (value.length <
                            8) {
                          return '密码至少需要 8 位';
                        }

                        return null;
                      },
                    ),

                    if (_isLogin) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      Align(
                        alignment:
                        Alignment
                            .centerRight,
                        child:
                        TextButton(
                          onPressed: () {
                            // TODO:
                            // 后续实现忘记密码 API。
                          },
                          child:
                          const Text(
                            '忘记密码？',
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 20,
                    ),

                    // Submit
                    SizedBox(
                      width:
                      double.infinity,
                      height: 54,
                      child:
                      FilledButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _submit,
                        style:
                        FilledButton
                            .styleFrom(
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              16,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2.5,
                            color:
                            Colors.white,
                          ),
                        )
                            : Text(
                          _isLogin
                              ? '登录'
                              : '注册',
                          style:
                          const TextStyle(
                            fontSize:
                            16,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Center(
                      child: TextButton(
                        onPressed: () =>
                            _switchMode(
                              !_isLogin,
                            ),
                        child: Text(
                          _isLogin
                              ? '还没有账号？立即注册'
                              : '已有账号？返回登录',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, {
        required String hintText,
        required IconData icon,
        Widget? suffix,
      }) {
    final theme =
    Theme.of(context);

    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: theme
          .colorScheme
          .surfaceContainerHighest
          .withValues(
        alpha: 0.45,
      ),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        BorderSide.none,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        BorderSide.none,
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide: BorderSide(
          color:
          theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide: BorderSide(
          color:
          theme.colorScheme.error,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide: BorderSide(
          color:
          theme.colorScheme.error,
          width: 1.5,
        ),
      ),
    );
  }
}

class _InputLabel
    extends StatelessWidget {
  final String label;

  const _InputLabel({
    required this.label,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight:
        FontWeight.w600,
      ),
    );
  }
}

class _ModeButton
    extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child:
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 200,
          ),
          decoration:
          BoxDecoration(
            color: selected
                ? theme
                .colorScheme
                .surface
                : Colors
                .transparent,
            borderRadius:
            BorderRadius
                .circular(
              12,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                blurRadius:
                8,
                offset:
                const Offset(
                  0,
                  2,
                ),
                color: Colors
                    .black
                    .withValues(
                  alpha:
                  0.06,
                ),
              ),
            ]
                : null,
          ),
          alignment:
          Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight:
              selected
                  ? FontWeight
                  .w600
                  : FontWeight
                  .normal,
            ),
          ),
        ),
      ),
    );
  }
}