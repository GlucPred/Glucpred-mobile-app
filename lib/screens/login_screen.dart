import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/main_navigation.dart';
import '../widgets/doctor_main_navigation.dart';
import 'complete_patient_profile_screen.dart';
import 'complete_doctor_profile_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_userController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa usuario y contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(
        username: _userController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        if (!mounted) return;

        // Verificar si es primer inicio (manejar ambos nombres del campo)
        final user = result['user'];
        final bool esPrimerInicio = user['es_primer_inicio'] ?? user['primer_inicio_sesion'] ?? false;
        final String rol = user['rol'] ?? '';

        if (esPrimerInicio) {
          // Redirigir a completar perfil según el rol
          Widget destination;
          if (rol == 'Medico') {
            destination = const CompleteDoctorProfileScreen();
          } else {
            destination = const CompletePatientProfileScreen();
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => destination),
            (route) => false,
          );
        } else {
          // Navegar a la pantalla principal según el rol
          Widget destination;
          if (rol == 'Medico') {
            destination = const DoctorMainNavigation();
          } else {
            destination = const MainNavigation();
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => destination),
            (route) => false,
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
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
        title: Text('Inicio de Sesión'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Inicio de Sesión - ${widget.role}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ingresa tus credenciales para acceder al monitoreo de glucosa',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93)),
                    ),
                    const SizedBox(height: 18),

                    // Usuario
                    TextField(
                      controller: _userController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Contraseña
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0073E6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: const Color(0xFF0073E6).withOpacity(0.6),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Iniciar sesión'),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.pop(context);
                      },
                      child: const Text('Volver al inicio'),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
