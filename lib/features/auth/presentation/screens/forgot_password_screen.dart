import 'package:flutter/material.dart';
import 'package:glucpred/core/config/theme.dart';
import 'package:glucpred/features/auth/data/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final username = _usernameController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingrese su usuario o correo electrónico'), backgroundColor: AppTheme.dangerColor));
      return;
    }
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingrese su nueva contraseña'), backgroundColor: AppTheme.dangerColor));
      return;
    }
    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor confirme su contraseña'), backgroundColor: AppTheme.dangerColor));
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: AppTheme.dangerColor));
      return;
    }
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres'), backgroundColor: AppTheme.dangerColor));
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.forgotPassword(usernameOrEmail: username, newPassword: newPassword);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña restablecida exitosamente'), backgroundColor: AppTheme.successColor));
      Future.delayed(const Duration(seconds: 1), () { if (mounted) Navigator.pop(context); });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Error al restablecer contraseña'), backgroundColor: AppTheme.dangerColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Olvidaste tu contraseña',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Título
              Text(
                'Olvidaste tu contraseña',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Descripción
              Text(
                'Ingresar su nueva contraseña para restablecer su cuenta',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Tarjeta con formulario
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo: Usuario o correo electrónico
                    Text(
                      'Usuario o correo electrónico',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ingresar usuario o contraseña',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkBackgroundColor : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Campo: Contraseña nueva
                    Text(
                      'Contraseña nueva',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ingresar contraseña nueva',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkBackgroundColor : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                            color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Campo: Confirmar contraseña
                    Text(
                      'Confirmar contraseña',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ingresar contraseña para confirmar',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkBackgroundColor : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Botón Confirmar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text(
                          'Confirmar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Botón Volver al inicio
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Volver al inicio',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
