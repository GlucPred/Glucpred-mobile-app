import 'package:flutter/material.dart';
import 'package:glucpred/core/config/theme.dart';
import 'package:glucpred/features/auth/data/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ── Step tracking ────────────────────────────────────────────────────────
  int _step = 1; // 1 = request code  |  2 = verify + new password

  // ── Step 1 ───────────────────────────────────────────────────────────────
  final _step1Controller = TextEditingController();
  String _maskedEmail = '';

  // ── Step 2 ───────────────────────────────────────────────────────────────
  static const int _otpLength = 6;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // ── Shared ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _step1Controller.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 1 — send OTP
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _sendCode() async {
    final input = _step1Controller.text.trim();
    if (input.isEmpty) {
      setState(() => _errorText = 'Por favor ingresa tu usuario o correo electrónico');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final result = await AuthService.sendPasswordResetCode(usernameOrEmail: input);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        _maskedEmail = result['masked_email'] ?? 'tu correo registrado';
        _step = 2;
        _errorText = null;
      });
      // Focus first OTP box
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => FocusScope.of(context).requestFocus(_otpFocusNodes[0]));
    } else {
      setState(() => _errorText = result['message'] ?? 'Error al enviar el código');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2 — OTP helpers
  // ─────────────────────────────────────────────────────────────────────────

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  void _onOtpDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < digits.length && index + i < _otpLength; i++) {
        _otpControllers[index + i].text = digits[i];
      }
      final nextFocus = (index + digits.length).clamp(0, _otpLength - 1);
      FocusScope.of(context).requestFocus(_otpFocusNodes[nextFocus]);
      return;
    }
    setState(() => _errorText = null);
    if (value.isNotEmpty && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    }
  }

  void _onOtpBackspace(int index) {
    if (_otpControllers[index].text.isEmpty && index > 0) {
      _otpControllers[index - 1].clear();
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2 — confirm reset
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _confirmReset() async {
    final code = _otpValue;
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (code.length < _otpLength) {
      setState(() => _errorText = 'Por favor completa el código de 6 dígitos');
      return;
    }
    if (newPassword.isEmpty) {
      setState(() => _errorText = 'Ingresa tu nueva contraseña');
      return;
    }
    if (newPassword.length < 8) {
      setState(() => _errorText = 'La contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _errorText = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final result = await AuthService.confirmPasswordReset(
      usernameOrEmail: _step1Controller.text.trim(),
      code: code,
      newPassword: newPassword,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Contraseña restablecida exitosamente'),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 2),
      ));
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _errorText = result['message'] ?? 'Código inválido o expirado');
      for (final c in _otpControllers) {
        c.clear();
      }
      if (_otpFocusNodes.isNotEmpty) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resend from step 2
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _resendCode() async {
    final input = _step1Controller.text.trim();
    if (input.isEmpty) return;

    setState(() => _isLoading = true);

    final result = await AuthService.sendPasswordResetCode(usernameOrEmail: input);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      for (final c in _otpControllers) {
        c.clear();
      }
      FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nuevo código enviado'),
        backgroundColor: AppTheme.successColor,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = const Color(0xFF0073E6);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark
                  ? AppTheme.darkTextPrimaryColor
                  : AppTheme.textPrimaryColor),
          onPressed: () {
            if (_step == 2) {
              setState(() {
                _step = 1;
                _errorText = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Recuperar contraseña',
          style: TextStyle(
            color: isDark
                ? AppTheme.darkTextPrimaryColor
                : AppTheme.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 1
              ? _buildStep1(isDark, primary)
              : _buildStep2(isDark, primary),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 1 UI
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStep1(bool isDark, Color primary) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Progress
          _StepIndicator(current: 1, total: 2),
          const SizedBox(height: 28),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_reset, size: 36, color: primary),
          ),
          const SizedBox(height: 20),

          Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.darkTextPrimaryColor
                  : AppTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Ingresa tu usuario o correo electrónico y te enviaremos un código de verificación.',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Input
          _FieldLabel('Usuario o correo electrónico', isDark),
          const SizedBox(height: 8),
          TextField(
            controller: _step1Controller,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkTextPrimaryColor
                  : AppTheme.textPrimaryColor,
            ),
            decoration: _inputDecoration(
              'Ingresar usuario o correo',
              isDark,
              hasError: _errorText != null,
            ),
            onSubmitted: (_) => _sendCode(),
          ),

          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(_errorText!,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.dangerColor)),
          ],
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                elevation: 0,
                disabledBackgroundColor: primary.withOpacity(0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text('Enviar código',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Volver al inicio de sesión',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppTheme.darkTextSecondaryColor
                    : AppTheme.textSecondaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2 UI
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStep2(bool isDark, Color primary) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _StepIndicator(current: 2, total: 2),
          const SizedBox(height: 28),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_email_read_outlined, size: 36, color: primary),
          ),
          const SizedBox(height: 20),

          Text(
            'Revisa tu correo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.darkTextPrimaryColor
                  : AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa el código enviado a $_maskedEmail',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // ── OTP boxes ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_otpLength, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _OtpBox(
                  controller: _otpControllers[i],
                  focusNode: _otpFocusNodes[i],
                  isDark: isDark,
                  hasError: _errorText != null,
                  onChanged: (v) => _onOtpDigitChanged(i, v),
                  onBackspace: () => _onOtpBackspace(i),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Resend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No recibiste el código? ',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
              GestureDetector(
                onTap: _isLoading ? null : _resendCode,
                child: Text(
                  'Reenviar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── New password ─────────────────────────────────────────────
          _FieldLabel('Nueva contraseña', isDark),
          const SizedBox(height: 8),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkTextPrimaryColor
                  : AppTheme.textPrimaryColor,
            ),
            decoration: _inputDecoration(
              'Mínimo 8 caracteres',
              isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                  color: isDark
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _FieldLabel('Confirmar contraseña', isDark),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkTextPrimaryColor
                  : AppTheme.textPrimaryColor,
            ),
            decoration: _inputDecoration(
              'Repetir contraseña',
              isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: isDark
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),

          if (_errorText != null) ...[
            const SizedBox(height: 12),
            Text(_errorText!,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.dangerColor),
                textAlign: TextAlign.center),
          ],
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                elevation: 0,
                disabledBackgroundColor: primary.withOpacity(0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text('Restablecer contraseña',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint, bool isDark,
      {bool hasError = false, Widget? suffixIcon}) {
    final borderColor = hasError
        ? AppTheme.dangerColor
        : (isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB));
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: isDark
            ? AppTheme.darkTextSecondaryColor
            : AppTheme.textSecondaryColor,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.grey[50],
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? AppTheme.dangerColor : const Color(0xFF0073E6),
              width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Shared widgets
// ──────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i + 1 == current;
        final done = i + 1 < current;
        return Row(
          children: [
            Container(
              width: active ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: (active || done)
                    ? const Color(0xFF0073E6)
                    : const Color(0xFFE0E6EB),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            if (i < total - 1)
              Container(
                  width: 24, height: 2, color: const Color(0xFFE0E6EB)),
          ],
        );
      }),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0073E6);
    final borderColor = hasError
        ? AppTheme.dangerColor
        : (isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB));

    return SizedBox(
      width: 44,
      height: 56,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.logicalKey.keyLabel == 'Backspace' &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppTheme.darkTextPrimaryColor
                : AppTheme.textPrimaryColor,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor:
                isDark ? const Color(0xFF1A1F3A) : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: hasError ? AppTheme.dangerColor : primary, width: 2),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
