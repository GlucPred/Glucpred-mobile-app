import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_selection_screen.dart';
import '../widgets/main_navigation.dart';
import '../widgets/doctor_main_navigation.dart';

/// Pantalla de splash que verifica si hay una sesión activa
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Pequeño delay para mostrar el splash
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Verificar si hay sesión activa
    final isAuth = await AuthService.isAuthenticated();
    
    if (isAuth) {
      // Obtener información del usuario para saber su rol
      final userInfo = await AuthService.getUserInfo();
      final rol = userInfo['rol']?.toString().toLowerCase() ?? '';
      
      // Navegar según el rol
      if (rol == 'medico') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DoctorMainNavigation()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } else {
      // No hay sesión, ir a login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F23) : const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o icono de la app
            Icon(
              Icons.favorite,
              size: 80,
              color: const Color(0xFF0073E6),
            ),
            const SizedBox(height: 24),
            const Text(
              'GlucPred',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0073E6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitoreo Inteligente de Glucosa',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0073E6)),
            ),
          ],
        ),
      ),
    );
  }
}
