import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../services/auth_service.dart';
import 'forgot_password_page.dart';

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

  bool _isSendingCode = false;

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
  // Login / register
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey
        .currentState!
        .validate()) {
      return;
    }

    FocusScope.of(context)
        .unfocus();

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
    } on AuthException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        localizedErrorMessage(
          context,
          e.message,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        context.l10n.operationFailed,
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
  // Register code
  // ============================================================

  Future<void> _sendCode() async {
    if (_isSendingCode ||
        _countdown > 0) {
      return;
    }

    final email =
    _emailController.text.trim();

    if (email.isEmpty ||
        !email.contains('@')) {
      _showMessage(
        context.l10n.invalidEmail,
      );

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSendingCode = true;
    });

    try {
      await AuthService.instance
          .sendVerificationCode(
        email,
      );

      if (!mounted) {
        return;
      }

      _startCountdown();

      _showMessage(
        context.l10n
            .verificationCodeSent,
      );
    } on AuthException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        localizedErrorMessage(
          context,
          e.message,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        context.l10n.operationFailed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  void _startCountdown() {
    _timer?.cancel();

    setState(() {
      _countdown = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_countdown <= 1) {
          timer.cancel();

          setState(() {
            _countdown = 0;
          });

          return;
        }

        setState(() {
          _countdown--;
        });
      },
    );
  }

  // ============================================================
  // Forgot password
  // ============================================================

  Future<void> _openForgotPassword() async {
    FocusScope.of(context).unfocus();

    final email =
    await Navigator.of(context)
        .push<String>(
      MaterialPageRoute(
        builder: (_) =>
            ForgotPasswordPage(
              initialEmail:
              _emailController.text.trim(),
            ),
      ),
    );

    if (!mounted ||
        email == null ||
        email.isEmpty) {
      return;
    }

    /**
     * 密码重置完成以后：
     *
     * 返回登录模式；
     * 自动填回邮箱；
     * 清空旧密码。
     */
    setState(() {
      _isLogin = true;

      _emailController.text =
          email;

      _passwordController.clear();
      _codeController.clear();
    });
  }

  // ============================================================
  // General UI
  // ============================================================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(message),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  void _switchMode(
      bool login,
      ) {
    if (_isLogin == login) {
      return;
    }

    _timer?.cancel();

    setState(() {
      _isLogin = login;

      _countdown = 0;

      _codeController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final l10n =
        context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child:
          SingleChildScrollView(
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
                  CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Center(
                      child: Text(
                        _isLogin
                            ? l10n.welcomeBack
                            : l10n.createAccount,
                        style: theme
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Center(
                      child: Text(
                        _isLogin
                            ? l10n.loginSubtitle
                            : l10n.registerSubtitle,
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

                    Container(
                      height: 50,
                      padding:
                      const EdgeInsets.all(
                        4,
                      ),
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
                            title:
                            l10n.login,
                            selected:
                            _isLogin,
                            onTap: () =>
                                _switchMode(
                                  true,
                                ),
                          ),
                          _ModeButton(
                            title:
                            l10n.register,
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

                    _InputLabel(
                      label:
                      l10n.email,
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
                      TextInputAction.next,
                      decoration:
                      _inputDecoration(
                        context,
                        hintText:
                        l10n.emailHint,
                        icon:
                        Icons.email_outlined,
                      ),
                      validator:
                          (value) {
                        if (value ==
                            null ||
                            value
                                .trim()
                                .isEmpty) {
                          return l10n
                              .emailRequired;
                        }

                        if (!value
                            .contains(
                          '@',
                        )) {
                          return l10n
                              .invalidEmail;
                        }

                        return null;
                      },
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(
                        height: 20,
                      ),

                      _InputLabel(
                        label: l10n
                            .verificationCode,
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      TextFormField(
                        controller:
                        _codeController,
                        keyboardType:
                        TextInputType.number,
                        textInputAction:
                        TextInputAction.next,
                        maxLength: 6,
                        decoration:
                        _inputDecoration(
                          context,
                          hintText: l10n
                              .verificationCodeHint,
                          icon: Icons
                              .verified_outlined,
                          suffix:
                          TextButton(
                            onPressed:
                            _countdown >
                                0 ||
                                _isSendingCode
                                ? null
                                : _sendCode,
                            child:
                            _isSendingCode
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                2,
                              ),
                            )
                                : Text(
                              _countdown >
                                  0
                                  ? '${_countdown}s'
                                  : l10n
                                  .getVerificationCode,
                            ),
                          ),
                        ).copyWith(
                          counterText:
                          '',
                        ),
                        validator:
                            (value) {
                          final code =
                              value
                                  ?.trim() ??
                                  '';

                          if (code
                              .isEmpty) {
                            return l10n
                                .verificationCodeRequired;
                          }

                          if (code.length !=
                              6 ||
                              !RegExp(
                                r'^\d{6}$',
                              ).hasMatch(
                                code,
                              )) {
                            return l10n
                                .verificationCodeLength;
                          }

                          return null;
                        },
                      ),
                    ],

                    const SizedBox(
                      height: 20,
                    ),

                    _InputLabel(
                      label:
                      l10n.password,
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
                      TextInputAction.done,
                      onFieldSubmitted:
                          (_) => _submit(),
                      decoration:
                      _inputDecoration(
                        context,
                        hintText: _isLogin
                            ? l10n
                            .passwordHintLogin
                            : l10n
                            .passwordHintRegister,
                        icon: Icons
                            .lock_outline_rounded,
                        suffix:
                        IconButton(
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
                        if (value ==
                            null ||
                            value.isEmpty) {
                          return l10n
                              .passwordRequired;
                        }

                        if (value.length <
                            8) {
                          return l10n
                              .passwordMinLength;
                        }

                        if (value.length >
                            128) {
                          return l10n
                              .passwordMaxLength;
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
                        Alignment.centerRight,
                        child:
                        TextButton(
                          onPressed:
                          _openForgotPassword,
                          child: Text(
                            l10n
                                .forgotPassword,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 20,
                    ),

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
                        child:
                        _isLoading
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
                              ? l10n
                              .login
                              : l10n
                              .register,
                          style:
                          const TextStyle(
                            fontSize:
                            16,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Center(
                      child:
                      TextButton(
                        onPressed: () =>
                            _switchMode(
                              !_isLogin,
                            ),
                        child: Text(
                          _isLogin
                              ? l10n
                              .noAccountRegister
                              : l10n
                              .haveAccountLogin,
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
      hintText:
      hintText,
      prefixIcon:
      Icon(icon),
      suffixIcon:
      suffix,
      filled:
      true,
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
        borderSide:
        BorderSide(
          color: theme
              .colorScheme
              .primary,
          width: 1.5,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        BorderSide(
          color: theme
              .colorScheme
              .error,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        BorderSide(
          color: theme
              .colorScheme
              .error,
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
      style:
      const TextStyle(
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
        onTap:
        onTap,
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
                : Colors.transparent,
            borderRadius:
            BorderRadius
                .circular(
              12,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                blurRadius: 8,
                offset:
                const Offset(
                  0,
                  2,
                ),
                color: Colors.black
                    .withValues(
                  alpha: 0.06,
                ),
              ),
            ]
                : null,
          ),
          alignment:
          Alignment.center,
          child: Text(
            title,
            style:
            TextStyle(
              fontWeight:
              selected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}