import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  final _weightController = TextEditingController(text: '72');
  final _heightController = TextEditingController(text: '1.63');
  final _medicationsController = TextEditingController(text: 'Metformina 850 mg (2 veces al día)');
  final _medicalHistoryController = TextEditingController(text: 'Hipertensión arterial, colesterol alto');
  final _diagnosisDateController = TextEditingController(text: '2018');

  // Imagen de perfil
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _calculateIMC();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _medicationsController.dispose();
    _medicalHistoryController.dispose();
    _diagnosisDateController.dispose();
    super.dispose();
  }

  String _calculateIMC() {
    try {
      final weight = double.tryParse(_weightController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
      final height = double.tryParse(_heightController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
      
      if (weight != null && height != null && height > 0) {
        final imc = weight / (height * height);
        String category = '';
        
        if (imc < 18.5) {
          category = 'bajo peso';
        } else if (imc >= 18.5 && imc < 25) {
          category = 'normal';
        } else if (imc >= 25 && imc < 30) {
          category = 'sobrepeso';
        } else {
          category = 'obesidad';
        }
        
        return '${imc.toStringAsFixed(1)} ($category)';
      }
    } catch (e) {
      // Si hay error en el cálculo
    }
    return 'N/A';
  }

  // Métodos para manejo de imagen de perfil
  Future<void> _showImageSourceDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleccionar foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0073E6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF0073E6),
                    ),
                  ),
                  title: Text(
                    'Tomar foto',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0073E6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF0073E6),
                    ),
                  ),
                  title: Text(
                    'Elegir de galería',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Color(0xFF337536),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: const Color(0xFFC72331),
        ),
      );
    }
  }

  void _deleteProfileImage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar foto de perfil'),
          content: const Text('¿Estás seguro de que quieres eliminar tu foto de perfil?'),
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
                  _profileImage = null;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Foto de perfil eliminada'),
                    backgroundColor: Color(0xFF337536),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC72331),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
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
                side: BorderSide(
                  color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Avatar con botón de editar
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF6C7C93),
                            backgroundImage: _profileImage != null 
                                ? FileImage(_profileImage!) 
                                : null,
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Botones de editar y eliminar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF0073E6)),
                          onPressed: _showImageSourceDialog,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0073E6).withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFFC72331)),
                          onPressed: _profileImage != null ? _deleteProfileImage : null,
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
                side: BorderSide(
                  color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildDataField('Edad', _ageController),
                    const SizedBox(height: 16),
                    _buildDataFieldEditable('Peso (kg)', _weightController),
                    const SizedBox(height: 16),
                    _buildDataFieldEditable('Altura (m)', _heightController),
                    const SizedBox(height: 16),
                    _buildIMCField(),
                    const SizedBox(height: 16),
                    _buildDataField('Medicamentos actuales', _medicationsController),
                    const SizedBox(height: 16),
                    _buildDataField('Antecedentes médicos', _medicalHistoryController),
                    const SizedBox(height: 16),
                    _buildDateField('Fecha de diagnóstico', _diagnosisDateController),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF000000),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF000000),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
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

  Widget _buildIMCField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'IMC',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF000000),
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
                  _calculateIMC(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              // Espacio para mantener alineación pero sin icono de editar
              const SizedBox(width: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataFieldEditable(String label, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF000000),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
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
                  _showEditDialogWithIMCUpdate(label, controller);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF000000),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
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
                  _showYearPickerDialog(label, controller);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showYearPickerDialog(String label, TextEditingController controller) {
    final currentYear = DateTime.now().year;
    final selectedYear = int.tryParse(controller.text) ?? currentYear;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Seleccionar $label'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1900),
              lastDate: DateTime(currentYear),
              selectedDate: DateTime(selectedYear),
              onChanged: (DateTime dateTime) {
                setState(() {
                  controller.text = dateTime.year.toString();
                });
                Navigator.pop(context);
              },
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
          ],
        );
      },
    );
  }

  void _showEditDialogWithIMCUpdate(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        final editController = TextEditingController(text: controller.text);
        return AlertDialog(
          title: Text('Editar $label'),
          content: TextField(
            controller: editController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  // El IMC se recalculará automáticamente en el siguiente build
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
