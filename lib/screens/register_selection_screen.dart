import 'package:flutter/material.dart';

class RegisterSelectionScreen extends StatelessWidget {
  const RegisterSelectionScreen({super.key});

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
                        'Registro',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtítulo
                      Text(
                        'Selecciona tu tipo de usuario para registrarte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Paciente con icono
                      Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 64,
                            color: const Color(0xFF0073E6),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Navegar a pantalla de registro de paciente
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registro de Paciente - Próximamente')),
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
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // Médico con icono
                      Column(
                        children: [
                          Icon(
                            Icons.medical_services,
                            size: 64,
                            color: const Color(0xFF0073E6),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Navegar a pantalla de registro de médico
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registro de Médico - Próximamente')),
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
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Enlace para volver al inicio
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Volver al inicio',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                            fontSize: 13,
                            decoration: TextDecoration.underline,
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
