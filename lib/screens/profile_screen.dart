import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para Perfil
  final _nameController = TextEditingController(text: 'Ana Sofía Ramírez Torres');
  final _usernameController = TextEditingController(text: 'asramirez');
  final _phoneController = TextEditingController(text: '939688777');
  final _emailController = TextEditingController(text: 'asramirez@gmail.com');
  
  // Controladores para Datos del paciente
  final _ageController = TextEditingController(text: '52');
  final _weightController = TextEditingController(text: '72');
  final _heightController = TextEditingController(text: '1.63');
  final _medicationsController = TextEditingController(text: 'Metformina 850 mg');
  final _medicalHistoryController = TextEditingController(text: 'Hipertensión arterial');
  final _diagnosisDateController = TextEditingController(text: '2018');

  // Imagen de perfil
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Listeners para recalcular IMC cuando cambian peso o altura
    _weightController.addListener(() => setState(() {}));
    _heightController.addListener(() => setState(() {}));
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

  // Mostrar diálogo de opciones de foto
  Future<void> _showImageSourceDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
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
                    color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    'Tomar foto',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
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
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    'Elegir de galería',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImage != null) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: AppTheme.dangerColor,
                      ),
                    ),
                    title: Text(
                      'Eliminar foto',
                      style: TextStyle(
                        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteProfileImage();
                    },
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // Seleccionar imagen de cámara o galería
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada'),
              backgroundColor: AppTheme.successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  // Eliminar foto de perfil
  void _deleteProfileImage() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
          title: Text(
            'Eliminar foto de perfil',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar tu foto de perfil?',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                ),
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
                    backgroundColor: AppTheme.successColor,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor,
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDiagnosisYear() async {
    final currentYear = DateTime.now().year;
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
          title: Text(
            'Seleccionar año de diagnóstico',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
            ),
          ),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              itemCount: currentYear - 1950 + 1,
              itemBuilder: (context, index) {
                final year = currentYear - index;
                return ListTile(
                  title: Text(
                    '$year',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, year),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      setState(() {
        _diagnosisDateController.text = '$selectedYear';
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
        ),
        filled: true,
        fillColor: isDark ? AppTheme.darkCardColor : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkCardColor : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkCardColor : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar section
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor,
                        backgroundImage: _profileImage != null 
                            ? FileImage(_profileImage!) 
                            : null,
                        child: _profileImage == null
                            ? const Text(
                                'AS',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _profileImage == null ? Icons.add : Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Perfil section
              Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Usuario',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Celular',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Correo',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Datos del paciente section
              Text(
                'Datos del paciente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _ageController,
                      label: 'Edad',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _weightController,
                      label: 'Peso (kg)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _heightController,
                      label: 'Altura (m)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'IMC',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                        ),
                        hintText: _calculateIMC(),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkBackgroundColor : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppTheme.darkBackgroundColor : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppTheme.darkBackgroundColor : Colors.grey[300]!,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _medicationsController,
                      label: 'Medicamentos',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _medicalHistoryController,
                      label: 'Antecedentes médicos',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _diagnosisDateController,
                      label: 'Fecha de diagnóstico',
                      readOnly: true,
                      onTap: _selectDiagnosisYear,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Guardar cambios button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cambios guardados exitosamente'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

}
