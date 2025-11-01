import 'package:flutter/material.dart';
import '../widgets/main_navigation.dart';
import '../widgets/doctor_main_navigation.dart';

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

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
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

                    // Google button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Iniciar con Google')));
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Icon(Icons.g_mobiledata, color: Color(0xFF0073E6), size: 20),
                        ),
                        label: const Text('Continuar con Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Credenciales temporales para pruebas
                          // TODO: Implementar autenticación real más adelante
                          if (_userController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            // Navegar a la pantalla principal según el rol
                            final Widget destination = widget.role == 'Médico'
                                ? const DoctorMainNavigation()
                                : const MainNavigation();
                            
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => destination,
                              ),
                              (route) => false, // Elimina todas las rutas anteriores
                            );
                          } else {
                            // Mostrar mensaje si los campos están vacíos
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor ingresa usuario y contraseña'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0073E6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Volver al inicio'),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Olvidaste tu contraseña')));
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
