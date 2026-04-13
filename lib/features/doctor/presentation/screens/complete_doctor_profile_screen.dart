import 'package:flutter/material.dart';
import 'package:glucpred/core/widgets/doctor_main_navigation.dart';
import 'package:glucpred/features/auth/data/services/auth_service.dart';

class CompleteDoctorProfileScreen extends StatefulWidget {
  const CompleteDoctorProfileScreen({super.key});

  @override
  State<CompleteDoctorProfileScreen> createState() => _CompleteDoctorProfileScreenState();
}

class _CompleteDoctorProfileScreenState extends State<CompleteDoctorProfileScreen> {
  final TextEditingController _colegiaturaController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _centroTrabajoController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _colegiaturaController.dispose();
    _especialidadController.dispose();
    _centroTrabajoController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    // Validar campos obligatorios
    if (_colegiaturaController.text.isEmpty ||
        _especialidadController.text.isEmpty ||
        _centroTrabajoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Llamar al endpoint para actualizar el perfil del médico
    final body = {
      'numero_colegiatura': _colegiaturaController.text,
      'especialidad': _especialidadController.text,
      'centro_trabajo': _centroTrabajoController.text,
    };

    final result = await AuthService.completeProfile(body);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? '¡Perfil completado exitosamente!'),
          backgroundColor: const Color(0xFF337536),
        ),
      );

      // Navegar a la pantalla principal del médico
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorMainNavigation(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al completar perfil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSkip() {
    // Navegar a la pantalla principal sin completar
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorMainNavigation(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título principal
            const Text(
              'Datos del médico',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresar tus datos',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 32),

            _buildTextField(
              controller: _colegiaturaController,
              label: 'Número de colegiatura',
              hint: 'Ingresar número de colegiatura',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _especialidadController,
              label: 'Especialidad',
              hint: 'Ingresar especialidad',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _centroTrabajoController,
              label: 'Centro de trabajo',
              hint: 'Ingresar centro de trabajo',
              isDark: isDark,
            ),
            const SizedBox(height: 40),

            // Botón de completar perfil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0073E6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
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
                    : const Text(
                        'Completar perfil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón de "Lo haré más tarde"
            TextButton(
              onPressed: _isLoading ? null : _handleSkip,
              child: const Text(
                'Lo haré más tarde',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
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
          ),
        ),
      ],
    );
  }
}
