import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final TextEditingController _nombreController = TextEditingController(text: 'Juan Alberto Monteblanco');
  final TextEditingController _usuarioController = TextEditingController(text: 'jamont0');
  final TextEditingController _celularController = TextEditingController(text: '939688777');
  final TextEditingController _correoController = TextEditingController(text: 'jamont0@gmail.com');
  final TextEditingController _colegiaturaController = TextEditingController(text: '235899');
  final TextEditingController _especialidadController = TextEditingController(text: 'Endocrinología');
  
  String _centroTrabajo = 'Clínica';

  @override
  void dispose() {
    _nombreController.dispose();
    _usuarioController.dispose();
    _celularController.dispose();
    _correoController.dispose();
    _colegiaturaController.dispose();
    _especialidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título
            Text(
              'Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Perfil médico
            Text(
              'Perfil médico',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 16),

            // Card de perfil
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar y botones
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C7C93),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'O',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0073E6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Información
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileField(
                                label: 'Nombre completo',
                                value: 'Juan Alberto Monteblanco',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildProfileField(
                                label: 'Nombre de usuario',
                                value: 'jamont0',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildProfileField(
                                label: 'Número de celular',
                                value: '939688777',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildProfileField(
                                label: 'Correo electrónico',
                                value: 'jamont0@gmail.com',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Botones de acción
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0073E6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF0073E6), size: 20),
                            onPressed: () {
                              // TODO: Editar perfil
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0073E6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.copy, color: Color(0xFF0073E6), size: 20),
                            onPressed: () {
                              // TODO: Copiar información
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Sección: Datos del médico
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Datos del médico',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de datos del médico
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDataField(
                      label: 'Número de colegiatura',
                      controller: _colegiaturaController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildDataField(
                      label: 'Especialidad',
                      controller: _especialidadController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownDataField(
                      label: 'Centro de trabajo',
                      value: _centroTrabajo,
                      items: ['Clínica', 'Hospital'],
                      onChanged: (value) {
                        setState(() {
                          _centroTrabajo = value!;
                        });
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón guardar cambios
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cambios guardados exitosamente'),
                      backgroundColor: Color(0xFF337536),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0073E6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF0073E6) : const Color(0xFF0073E6),
                  ),
                ),
              ),
              const Icon(
                Icons.edit,
                size: 16,
                color: Color(0xFF0073E6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF0073E6) : const Color(0xFF0073E6),
                  ),
                ),
              ),
              const Icon(
                Icons.edit,
                size: 18,
                color: Color(0xFF0073E6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownDataField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF0073E6) : const Color(0xFF0073E6),
                  ),
                ),
              ),
              const Icon(
                Icons.edit,
                size: 18,
                color: Color(0xFF0073E6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
