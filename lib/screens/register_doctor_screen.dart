import 'package:flutter/material.dart';
import '../widgets/doctor_main_navigation.dart';

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _usuarioCorreoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  final TextEditingController _colegiaturaController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  
  String? _centroTrabajo;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreCompletoController.dispose();
    _usuarioCorreoController.dispose();
    _celularController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    _colegiaturaController.dispose();
    _especialidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Médico'),
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

            // Sección: Datos del médico
            _buildSectionTitle('Datos del médico', 'Ingresar tus datos', isDark),
            const SizedBox(height: 20),

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

            _buildDropdownField(
              label: 'Centro de trabajo',
              hint: 'Ingresar centro de trabajo',
              value: _centroTrabajo,
              items: ['Clínica', 'Hospital'],
              onChanged: (value) {
                setState(() {
                  _centroTrabajo = value;
                });
              },
              isDark: isDark,
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
                      _confirmarContrasenaController.text.isEmpty ||
                      _colegiaturaController.text.isEmpty ||
                      _especialidadController.text.isEmpty ||
                      _centroTrabajo == null) {
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
                      content: Text('¡Cuenta de médico creada exitosamente!'),
                      backgroundColor: Color(0xFF337536),
                    ),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorMainNavigation(),
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
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
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
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F3A) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? const Color(0xFF6C7C93) : const Color(0xFF6C7C93),
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              dropdownColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
