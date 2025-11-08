import 'package:flutter/material.dart';
import '../widgets/main_navigation.dart';
import '../services/auth_service.dart';

class CompletePatientProfileScreen extends StatefulWidget {
  const CompletePatientProfileScreen({super.key});

  @override
  State<CompletePatientProfileScreen> createState() => _CompletePatientProfileScreenState();
}

class _CompletePatientProfileScreenState extends State<CompletePatientProfileScreen> {
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _medicamentosController = TextEditingController();
  final TextEditingController _antecedentesController = TextEditingController();
  final TextEditingController _fechaDiagnosticoController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _edadController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _medicamentosController.dispose();
    _antecedentesController.dispose();
    _fechaDiagnosticoController.dispose();
    super.dispose();
  }

  Future<void> _showDatePickerDialog() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha de diagnóstico',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (selectedDate != null) {
      setState(() {
        // Mostrar en formato dd/MM/yyyy para el usuario
        final day = selectedDate.day.toString().padLeft(2, '0');
        final month = selectedDate.month.toString().padLeft(2, '0');
        final year = selectedDate.year.toString();
        _fechaDiagnosticoController.text = '$day/$month/$year';
      });
    }
  }

  Future<void> _handleComplete() async {
    // Validar campos obligatorios
    if (_edadController.text.isEmpty ||
        _pesoController.text.isEmpty ||
        _alturaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos obligatorios: Edad, Peso y Altura'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Convertir fecha de dd/MM/yyyy a yyyy-MM-dd
    String? fechaDiagnostico;
    if (_fechaDiagnosticoController.text.isNotEmpty) {
      try {
        final parts = _fechaDiagnosticoController.text.split('/');
        if (parts.length == 3) {
          final day = parts[0];
          final month = parts[1];
          final year = parts[2];
          fechaDiagnostico = '$year-$month-$day';
        }
      } catch (e) {
        // Si hay error en el formato, no enviar la fecha
        fechaDiagnostico = null;
      }
    }

    // Llamar al endpoint para actualizar el perfil del paciente
    final body = {
      'edad': int.tryParse(_edadController.text) ?? 0,
      'peso': double.tryParse(_pesoController.text) ?? 0.0,
      'altura': double.tryParse(_alturaController.text) ?? 0.0,
      'medicamentos': _medicamentosController.text,
      'antecedentes': _antecedentesController.text,
      if (fechaDiagnostico != null) 'fecha_diagnostico': fechaDiagnostico,
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

      // Navegar a la pantalla principal
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
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
        builder: (context) => const MainNavigation(),
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
              'Datos del paciente',
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
              controller: _edadController,
              label: 'Edad',
              hint: 'Ingresar edad',
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _pesoController,
              label: 'Peso',
              hint: 'Ingresar peso',
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _alturaController,
              label: 'Altura',
              hint: 'Ingresar altura (para cálculo de IMC)',
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _medicamentosController,
              label: 'Medicamentos',
              hint: 'Ingresar medicamentos actuales',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _antecedentesController,
              label: 'Antecedentes',
              hint: 'Ingresar antecedentes',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _fechaDiagnosticoController,
              label: 'Fecha de diagnóstico',
              hint: 'dd/mm/yyyy',
              isDark: isDark,
              readOnly: true,
              onTap: _showDatePickerDialog,
              suffixIcon: Icons.calendar_today,
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
            suffixIcon: suffixIcon != null
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
