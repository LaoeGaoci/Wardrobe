import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/error_localizations.dart';
import '../../l10n/l10n.dart';
import '../../services/auth_service.dart';

class ForgotPasswordPage
    extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordPage({
    super.key,
    this.initialEmail = '',
  });

  @override
  State<ForgotPasswordPage>
  createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _emailController;

  final _codeController =
  TextEditingController();

  final _newPasswordController =
  TextEditingController();

  final _confirmPasswordController =
  TextEditingController();

  bool _isSubmitting = false;
  bool _isSendingCode = false;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  int _countdown = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _emailController =
        TextEditingController(
          text: widget.initialEmail,
        );
  }

  @override
  void dispose() {
    _timer?.cancel();

    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // Send code
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
          .sendPasswordResetCode(
        email,
      );

      if (!mounted) {
        return;
      }

      _startCountdown();

      /**
       * 注意：
       *
       * 后端为了防止账户枚举，
       * 即使邮箱不存在也会返回 success。
       *
       * 所以前端也不能显示
       * “该邮箱已注册”之类的信息。
       */
      _showMessage(
        context.l10n
            .passwordResetCodeSent,
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
  // Reset password
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey
        .currentState!
        .validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.instance
          .resetPassword(
        email:
        _emailController.text,
        verificationCode:
        _codeController.text,
        newPassword:
        _newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        context.l10n
            .passwordResetSuccess,
      );

      /**
       * 把邮箱返回登录页，
       * 登录页自动填入。
       */
      Navigator.of(context).pop(
        _emailController.text.trim(),
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
          _isSubmitting = false;
        });
      }
    }
  }

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

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final l10n =
        context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.forgotPasswordTitle,
        ),
      ),
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
                  CrossAxisAlignment.start,
                  children: [
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
                        child: const Icon(
                          Icons
                              .lock_reset_rounded,
                          color:
                          Colors.white,
                          size: 38,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Center(
                      child: Text(
                        l10n
                            .resetYourPassword,
                        style: theme
                            .textTheme
                            .headlineSmall
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
                        l10n
                            .forgotPasswordSubtitle,
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
                        counterText: '',
                      ),
                      validator:
                          (value) {
                        final code =
                            value?.trim() ??
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

                    const SizedBox(
                      height: 20,
                    ),

                    _InputLabel(
                      label: l10n
                          .newPassword,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextFormField(
                      controller:
                      _newPasswordController,
                      obscureText:
                      _obscureNewPassword,
                      textInputAction:
                      TextInputAction.next,
                      decoration:
                      _inputDecoration(
                        context,
                        hintText: l10n
                            .newPasswordHint,
                        icon:
                        Icons.lock_outline,
                        suffix:
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword =
                              !_obscureNewPassword;
                            });
                          },
                          icon: Icon(
                            _obscureNewPassword
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
                              .newPasswordRequired;
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

                    const SizedBox(
                      height: 20,
                    ),

                    _InputLabel(
                      label: l10n
                          .confirmPassword,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextFormField(
                      controller:
                      _confirmPasswordController,
                      obscureText:
                      _obscureConfirmPassword,
                      textInputAction:
                      TextInputAction.done,
                      onFieldSubmitted:
                          (_) => _submit(),
                      decoration:
                      _inputDecoration(
                        context,
                        hintText: l10n
                            .confirmPasswordHint,
                        icon:
                        Icons.lock_person_outlined,
                        suffix:
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
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
                              .confirmPasswordRequired;
                        }

                        if (value !=
                            _newPasswordController
                                .text) {
                          return l10n
                              .passwordsDoNotMatch;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      height: 54,
                      child:
                      FilledButton(
                        onPressed:
                        _isSubmitting
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
                        _isSubmitting
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
                          l10n
                              .resetPassword,
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