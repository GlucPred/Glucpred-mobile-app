import 'package:flutter/material.dart';
import 'package:glucpred/features/auth/data/services/auth_service.dart';
import 'package:glucpred/features/auth/presentation/screens/verify_code_screen.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreCompletoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nombreCompletoController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _celularController.text.isEmpty ||
        _contrasenaController.text.isEmpty ||
        _confirmarContrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final registrationData = {
      'nombre_completo': _nombreCompletoController.text.trim(),
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'numero_celular': _celularController.text.trim(),
      'password': _contrasenaController.text,
      'confirmar_password': _confirmarContrasenaController.text,
    };

    final result = await AuthService.initiateRegistration(
      nombreCompleto: registrationData['nombre_completo']!,
      username: registrationData['username']!,
      email: registrationData['email']!,
      numeroCelular: registrationData['numero_celular']!,
      password: registrationData['password']!,
      confirmarPassword: registrationData['confirmar_password']!,
      rol: 'Paciente',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(
            email: result['email'] ?? registrationData['email']!,
            rol: 'Paciente',
            registrationData: registrationData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al crear la cuenta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Paciente'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título principal
            Text(
              'Registro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // Sección: Datos personales
            _buildSectionTitle('Datos personales', 'Ingresar tus datos', isDark),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _nombreCompletoController,
              label: 'Nombre completo',
              hint: 'Ingresar nombres completos',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _usernameController,
              label: 'Usuario',
              hint: 'Ingresar nombre de usuario',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _emailController,
              label: 'Correo electrónico',
              hint: 'Ingresar correo electrónico',
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _celularController,
              label: 'Número de celular',
              hint: 'Ingresar número de celular',
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _contrasenaController,
              label: 'Contraseña',
              hint: 'Ingresar contraseña',
              isDark: isDark,
              isPassword: true,
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _confirmarContrasenaController,
              label: 'Confirmar contraseña',
              hint: 'Ingresar contraseña para confirmar',
              isDark: isDark,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 40),

            // Botón de crear cuenta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0073E6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                  disabledBackgroundColor:
                      const Color(0xFF0073E6).withOpacity(0.6),
                ),
                child: _isLoading
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
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Link para volver al inicio
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'Volver al inicio',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C7C93),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, bool isDark) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF6C7C93),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1A1F3A) : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0073E6),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: isDark ? const Color(0xFF6C7C93) : const Color(0xFF6C7C93),
                    ),
                    onPressed: onToggleVisibility,
                  )
                : suffixIcon != null
                    ? Icon(
                        suffixIcon,
                        color: isDark ? const Color(0xFF6C7C93) : const Color(0xFF6C7C93),
                      )
                    : null,
          ),
        ),
      ],
    );
  }
}
