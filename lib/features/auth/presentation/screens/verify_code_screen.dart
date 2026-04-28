import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glucpred/core/config/theme.dart';
import 'package:glucpred/core/widgets/main_navigation.dart';
import 'package:glucpred/core/widgets/doctor_main_navigation.dart';
import 'package:glucpred/features/auth/data/services/auth_service.dart';
import 'package:glucpred/features/profile/presentation/screens/complete_patient_profile_screen.dart';
import 'package:glucpred/features/doctor/presentation/screens/complete_doctor_profile_screen.dart';

/// OTP verification screen shown after `POST /api/auth/register`.
///
/// [email]            — email returned by the initiate-registration call
/// [rol]              — 'Paciente' or 'Medico' (for post-verify routing)
/// [registrationData] — full form data used when the user taps "Reenviar"
class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String rol;
  final Map<String, dynamic> registrationData;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.rol,
    required this.registrationData,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const int _otpLength = 6;
  static const int _expirySeconds = 600; // 10 minutes

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  int _secondsLeft = _expirySeconds;
  Timer? _timer;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Timer
  // -----------------------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _expirySeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        setState(() {});
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _expired => _secondsLeft <= 0;

  // -----------------------------------------------------------------------
  // OTP helpers
  // -----------------------------------------------------------------------

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste: fill from current index forward
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < digits.length && index + i < _otpLength; i++) {
        _controllers[index + i].text = digits[i];
      }
      final nextFocus = (index + digits.length).clamp(0, _otpLength - 1);
      FocusScope.of(context).requestFocus(_focusNodes[nextFocus]);
      return;
    }

    setState(() => _errorText = null);

    if (value.isNotEmpty && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    // Auto-verify when last digit is entered
    if (index == _otpLength - 1 && value.isNotEmpty) {
      _verify();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  // -----------------------------------------------------------------------
  // Actions
  // -----------------------------------------------------------------------

  Future<void> _verify() async {
    final code = _otpValue;
    if (code.length < _otpLength) {
      setState(() => _errorText = 'Por favor completa el código de 6 dígitos');
      return;
    }
    if (_expired) {
      setState(() => _errorText = 'El código ha expirado. Solicita uno nuevo.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    final result = await AuthService.verifyRegistration(
      email: widget.email,
      code: code,
    );

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (result['success'] == true) {
      final user = result['user'] as Map<String, dynamic>? ?? {};
      final bool primerInicio = user['primer_inicio_sesion'] ?? true;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('¡Cuenta creada exitosamente!'),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 2),
      ));

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Widget destination;
      if (primerInicio) {
        destination = widget.rol == 'Medico'
            ? const CompleteDoctorProfileScreen()
            : const CompletePatientProfileScreen();
      } else {
        destination = widget.rol == 'Medico'
            ? const DoctorMainNavigation()
            : const MainNavigation();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } else {
      setState(() => _errorText = result['message'] ?? 'Código inválido o expirado');
      // Clear the OTP boxes on error
      for (final c in _controllers) {
        c.clear();
      }
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);

    final data = widget.registrationData;
    final result = await AuthService.initiateRegistration(
      nombreCompleto: data['nombre_completo'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? widget.email,
      numeroCelular: data['numero_celular'] ?? '',
      password: data['password'] ?? '',
      confirmarPassword: data['confirmar_password'] ?? '',
      rol: widget.rol,
    );

    if (!mounted) return;
    setState(() => _isResending = false);

    if (result['success'] == true) {
      _startTimer();
      for (final c in _controllers) {
        c.clear();
      }
      FocusScope.of(context).requestFocus(_focusNodes[0]);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nuevo código enviado a tu correo'),
        backgroundColor: AppTheme.successColor,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Error al reenviar código'),
        backgroundColor: AppTheme.dangerColor,
      ));
    }
  }

  // -----------------------------------------------------------------------
  // UI
  // -----------------------------------------------------------------------

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verificación de correo',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icon ──────────────────────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_read_outlined,
                    size: 36, color: primary),
              ),
              const SizedBox(height: 24),

              // ── Title ─────────────────────────────────────────────────
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
              const SizedBox(height: 10),

              // ── Subtitle ──────────────────────────────────────────────
              Text(
                'Enviamos un código de 6 dígitos a',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ── OTP boxes ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_otpLength, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _OtpBox(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      isDark: isDark,
                      hasError: _errorText != null,
                      onChanged: (v) => _onDigitChanged(i, v),
                      onBackspace: () => _onBackspace(i),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // ── Error ─────────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _errorText != null
                    ? Padding(
                        key: ValueKey(_errorText),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _errorText!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.dangerColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox(key: ValueKey('no-error')),
              ),
              const SizedBox(height: 16),

              // ── Timer ─────────────────────────────────────────────────
              Text(
                _expired
                    ? 'El código ha expirado'
                    : 'El código expira en $_timerLabel',
                style: TextStyle(
                  fontSize: 13,
                  color: _expired
                      ? AppTheme.dangerColor
                      : (isDark
                          ? AppTheme.darkTextSecondaryColor
                          : AppTheme.textSecondaryColor),
                  fontWeight:
                      _expired ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 32),

              // ── Verify button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isVerifying || _expired) ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                    disabledBackgroundColor: primary.withOpacity(0.5),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verificar cuenta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Resend ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No recibiste el código? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.darkTextSecondaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                  _isResending
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : GestureDetector(
                          onTap: _resend,
                          child: Text(
                            'Reenviar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual OTP digit box
// ---------------------------------------------------------------------------
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
            color:
                isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: isDark ? const Color(0xFF1A1F3A) : const Color(0xFFF9FAFB),
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
                color: hasError ? AppTheme.dangerColor : primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
