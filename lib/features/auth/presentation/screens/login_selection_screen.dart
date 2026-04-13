import 'package:flutter/material.dart';
import 'package:glucpred/features/auth/presentation/screens/login_screen.dart';
import 'package:glucpred/features/auth/presentation/screens/register_selection_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Título
                      Text(
                        'Bienvenido a Glucpred',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtítulo
                      Text(
                        'Tu asistente inteligente para el control y monitoreo de glucosa',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Logo
                      Icon(
                        Icons.water_drop,
                        size: 80,
                        color: const Color(0xFF0073E6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Glucpred',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Texto de selección
                      Text(
                        'Selecciona tu tipo de usuario para continuar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Paciente con icono y descripción
                      Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 48,
                            color: const Color(0xFF0073E6),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(role: 'Paciente'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0073E6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Paciente',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Monitorea tu glucosa, recibe\nalertas y recomendaciones\npersonalizadas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // Médico con icono y descripción
                      Column(
                        children: [
                          Icon(
                            Icons.medical_services,
                            size: 48,
                            color: const Color(0xFF0073E6),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(role: 'Médico'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0073E6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Médico',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supervisa a tus pacientes,\nrevisa tendencias y envía\nrecomendaciones.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Enlace de registro
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterSelectionScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: '¿No tienes una cuenta? ',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                              fontSize: 13,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Regístrate aquí.',
                                style: TextStyle(
                                  color: Color(0xFF0073E6),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
