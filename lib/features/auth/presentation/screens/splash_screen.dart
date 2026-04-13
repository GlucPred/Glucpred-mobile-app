import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/features/auth/presentation/screens/login_selection_screen.dart';
import 'package:glucpred/core/widgets/main_navigation.dart';
import 'package:glucpred/core/widgets/doctor_main_navigation.dart';
import 'package:glucpred/features/auth/presentation/viewmodels/auth_view_model.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final vm = context.read<AuthViewModel>();
    final isAuth = await vm.checkAuth();

    if (!mounted) return;

    if (isAuth) {
      final rol = (vm.userRole ?? '').toLowerCase();
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
