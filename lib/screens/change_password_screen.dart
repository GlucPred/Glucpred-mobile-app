import 'package:flutter/material.dart';
import '../config/theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // Validar que las contraseñas coincidan
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Color(0xFFC72331),
          ),
        );
        return;
      }

      setState(() { _isSubmitting = true; });

      // Simular cambio de contraseña exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente'),
          backgroundColor: Color(0xFF337536),
        ),
      );

      setState(() { _isSubmitting = false; });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF9FAFB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF0073E6),
          ),
        ),
        title: const Text('Cambiar contraseña'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 2,
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      Text(
                        'Contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Descripción
                      const Text(
                        'Elige una contraseña segura para actualizarla',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C7C93),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Campo: Contraseña nueva
                      Text(
                        'Contraseña nueva',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          hintText: 'Ingresar contraseña nueva',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB3C3D3),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: isDark ? AppTheme.darkCardColor : const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE0E6EB),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE0E6EB),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0073E6),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF6C7C93),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Campo: Confirmar contraseña nueva
                      Text(
                        'Confirmar contraseña nueva',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Ingresar contraseña para confirmar',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB3C3D3),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: isDark ? AppTheme.darkCardColor : const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE0E6EB),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE0E6EB),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0073E6),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF6C7C93),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirme su contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Botón de cambiar contraseña
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0073E6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: const Color(0xFF0073E6).withValues(alpha: 0.6),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Cambiar contraseña',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
