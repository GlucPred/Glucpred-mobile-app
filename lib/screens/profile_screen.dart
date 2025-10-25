import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para Perfil paciente
  final _nameController = TextEditingController(text: 'Ana Sofía Ramírez Torres');
  final _usernameController = TextEditingController(text: 'asramirez');
  final _phoneController = TextEditingController(text: '999888777');
  final _emailController = TextEditingController(text: 'asramirez@gmail.com');
  
  // Controladores para Datos del paciente
  final _ageController = TextEditingController(text: '52 años');
  final _weightController = TextEditingController(text: '72 kg');
  final _heightController = TextEditingController(text: '1.63 m');
  final _imcController = TextEditingController(text: '271 (sobrepeso leve)');
  final _medicationsController = TextEditingController(text: 'Metformina 850 mg (2 veces al día)');
  final _medicalHistoryController = TextEditingController(text: 'Hipertensión arterial, colesterol alto');
  final _diagnosisDateController = TextEditingController(text: '2018');

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _imcController.dispose();
    _medicationsController.dispose();
    _medicalHistoryController.dispose();
    _diagnosisDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Perfil paciente
            _buildSectionTitle('Perfil paciente'),
            const SizedBox(height: 16),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE0E6EB), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Avatar con botón de editar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF6C7C93),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0073E6),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Botones de editar y eliminar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF0073E6)),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0073E6).withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFFC72331)),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFC72331).withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Campos del perfil
                    _buildProfileField('Nombre completo', _nameController),
                    const SizedBox(height: 16),
                    _buildProfileField('Nombre de usuario', _usernameController),
                    const SizedBox(height: 16),
                    _buildProfileField('Número de celular', _phoneController),
                    const SizedBox(height: 16),
                    _buildProfileField('Correo electrónico', _emailController),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sección: Datos del paciente
            _buildSectionTitle('Datos del paciente'),
            const SizedBox(height: 16),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE0E6EB), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildDataField('Edad', _ageController),
                    const SizedBox(height: 16),
                    _buildDataField('Peso', _weightController),
                    const SizedBox(height: 16),
                    _buildDataField('Altura', _heightController),
                    const SizedBox(height: 16),
                    _buildDataField('IMC', _imcController),
                    const SizedBox(height: 16),
                    _buildDataField('Medicamentos actuales', _medicationsController),
                    const SizedBox(height: 16),
                    _buildDataField('Antecedentes médicos', _medicalHistoryController),
                    const SizedBox(height: 16),
                    _buildDataField('Fecha de diagnóstico', _diagnosisDateController),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cambios guardados correctamente'),
                      backgroundColor: Color(0xFF337536),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0073E6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6C7C93),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000000),
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
                  controller.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C7C93),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: const Color(0xFF0073E6),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  _showEditDialog(label, controller);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataField(String label, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000000),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C7C93),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: const Color(0xFF0073E6),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  _showEditDialog(label, controller);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        final editController = TextEditingController(text: controller.text);
        return AlertDialog(
          title: Text('Editar $label'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0073E6), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF6C7C93)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  controller.text = editController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0073E6),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
