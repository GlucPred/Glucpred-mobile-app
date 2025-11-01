import 'package:flutter/material.dart';
import '../widgets/main_navigation.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _usuarioCorreoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _medicamentosController = TextEditingController();
  final TextEditingController _antecedentesController = TextEditingController();
  final TextEditingController _fechaDiagnosticoController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreCompletoController.dispose();
    _usuarioCorreoController.dispose();
    _celularController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _medicamentosController.dispose();
    _antecedentesController.dispose();
    _fechaDiagnosticoController.dispose();
    super.dispose();
  }

  void _showYearPickerDialog() async {
    final currentYear = DateTime.now().year;
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar año de diagnóstico'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1900),
              lastDate: DateTime(currentYear),
              selectedDate: _fechaDiagnosticoController.text.isNotEmpty
                  ? DateTime(int.parse(_fechaDiagnosticoController.text))
                  : DateTime(currentYear),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      setState(() {
        _fechaDiagnosticoController.text = selectedYear.toString();
      });
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
            const Text(
              'Registro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
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
              controller: _usuarioCorreoController,
              label: 'Usuario o correo electrónico',
              hint: 'Ingresar usuario o correo electrónico',
              isDark: isDark,
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

            // Sección: Datos del paciente
            _buildSectionTitle('Datos del paciente', 'Ingresar tus datos', isDark),
            const SizedBox(height: 20),

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
              hint: 'Ingresar altura ( para cálculo de IMC)',
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
              hint: 'Ingresar fecha de diagnóstico',
              isDark: isDark,
              readOnly: true,
              onTap: _showYearPickerDialog,
              suffixIcon: Icons.calendar_today,
            ),
            const SizedBox(height: 40),

            // Botón de crear cuenta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validar campos
                  if (_nombreCompletoController.text.isEmpty ||
                      _usuarioCorreoController.text.isEmpty ||
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

                  // Validar que las contraseñas coincidan
                  if (_contrasenaController.text != _confirmarContrasenaController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Las contraseñas no coinciden'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // TODO: Implementar lógica de registro real más adelante
                  // Por ahora, navegar a la pantalla principal
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Cuenta creada exitosamente!'),
                      backgroundColor: Color(0xFF337536),
                    ),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigation(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0073E6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
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
