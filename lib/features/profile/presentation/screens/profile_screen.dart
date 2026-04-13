import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:glucpred/core/config/theme.dart';
import 'package:glucpred/features/auth/data/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para Perfil
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Controladores para Datos del paciente
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _diagnosisDateController = TextEditingController();

  // Imagen de perfil
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  
  // Estado de carga y edición
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  
  // Valores originales para detectar cambios
  Map<String, dynamic> _originalValues = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.getProfile();

    if (result['success']) {
      final user = result['user'];
      final profile = result['profile'];

      setState(() {
        // Datos de usuario
        _nameController.text = user['nombre_completo'] ?? '';
        _usernameController.text = user['username'] ?? '';
        _phoneController.text = user['numero_celular'] ?? '';
        _emailController.text = user['email'] ?? '';

        // Datos del perfil médico
        _ageController.text = profile['edad']?.toString() ?? '';
        _weightController.text = profile['peso']?.toString() ?? '';
        _heightController.text = profile['altura']?.toString() ?? '';
        _medicationsController.text = profile['medicamentos'] ?? '';
        _medicalHistoryController.text = profile['antecedentes'] ?? '';
        
        // Formatear fecha de diagnóstico de YYYY-MM-DD a DD/MM/YYYY
        if (profile['fecha_diagnostico'] != null && profile['fecha_diagnostico'].toString().isNotEmpty) {
          try {
            final parts = profile['fecha_diagnostico'].toString().split('-');
            if (parts.length == 3) {
              _diagnosisDateController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
            } else {
              _diagnosisDateController.text = profile['fecha_diagnostico'];
            }
          } catch (e) {
            _diagnosisDateController.text = profile['fecha_diagnostico'];
          }
        }

        // Guardar valores originales
        _originalValues = {
          'nombre_completo': _nameController.text,
          'username': _usernameController.text,
          'numero_celular': _phoneController.text,
          'email': _emailController.text,
          'edad': _ageController.text,
          'peso': _weightController.text,
          'altura': _heightController.text,
          'medicamentos': _medicationsController.text,
          'antecedentes': _medicalHistoryController.text,
          'fecha_diagnostico': _diagnosisDateController.text,
        };

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al cargar perfil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    // Detectar qué campos cambiaron
    Map<String, dynamic> changedFields = {};

    if (_nameController.text != _originalValues['nombre_completo']) {
      changedFields['nombre_completo'] = _nameController.text;
    }
    if (_usernameController.text != _originalValues['username']) {
      changedFields['username'] = _usernameController.text;
    }
    if (_phoneController.text != _originalValues['numero_celular']) {
      changedFields['numero_celular'] = _phoneController.text;
    }
    if (_emailController.text != _originalValues['email']) {
      changedFields['email'] = _emailController.text;
    }
    if (_ageController.text != _originalValues['edad']) {
      changedFields['edad'] = int.tryParse(_ageController.text) ?? 0;
    }
    if (_weightController.text != _originalValues['peso']) {
      changedFields['peso'] = double.tryParse(_weightController.text) ?? 0.0;
    }
    if (_heightController.text != _originalValues['altura']) {
      changedFields['altura'] = double.tryParse(_heightController.text) ?? 0.0;
    }
    if (_medicationsController.text != _originalValues['medicamentos']) {
      changedFields['medicamentos'] = _medicationsController.text;
    }
    if (_medicalHistoryController.text != _originalValues['antecedentes']) {
      changedFields['antecedentes'] = _medicalHistoryController.text;
    }
    if (_diagnosisDateController.text != _originalValues['fecha_diagnostico']) {
      // Convertir de DD/MM/YYYY a YYYY-MM-DD
      try {
        final parts = _diagnosisDateController.text.split('/');
        if (parts.length == 3) {
          changedFields['fecha_diagnostico'] = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      } catch (e) {
        // Si hay error, no enviar la fecha
      }
    }

    if (changedFields.isEmpty) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay cambios para guardar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await AuthService.updateProfile(changedFields);

    setState(() {
      _isSaving = false;
    });

    if (result['success']) {
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Perfil actualizado correctamente'),
          backgroundColor: const Color(0xFF337536),
        ),
      );

      // Recargar el perfil para obtener datos actualizados (incluyendo IMC)
      _loadProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al actualizar perfil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      // Restaurar valores originales
      _nameController.text = _originalValues['nombre_completo'];
      _usernameController.text = _originalValues['username'];
      _phoneController.text = _originalValues['numero_celular'];
      _emailController.text = _originalValues['email'];
      _ageController.text = _originalValues['edad'];
      _weightController.text = _originalValues['peso'];
      _heightController.text = _originalValues['altura'];
      _medicationsController.text = _originalValues['medicamentos'];
      _medicalHistoryController.text = _originalValues['antecedentes'];
      _diagnosisDateController.text = _originalValues['fecha_diagnostico'];
      
      _isEditing = false;
    });
  }

  String _calculateIMC() {
    // Calcular IMC automáticamente desde peso y altura actuales
    final weight = double.tryParse(_weightController.text);
    final heightCm = double.tryParse(_heightController.text);
    
    if (weight != null && heightCm != null && heightCm > 0) {
      // Convertir altura de cm a metros
      final heightM = heightCm / 100;
      final imc = weight / (heightM * heightM);
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
    return 'N/A';
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
        final day = selectedDate.day.toString().padLeft(2, '0');
        final month = selectedDate.month.toString().padLeft(2, '0');
        final year = selectedDate.year.toString();
        _diagnosisDateController.text = '$day/$month/$year';
      });
    }
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
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Editar perfil',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Foto de perfil
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: _profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),

            // Sección: Perfil
            _buildSectionTitle('Perfil', isDark),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _nameController,
              label: 'Nombre completo',
              icon: Icons.person_outline,
              enabled: _isEditing,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _usernameController,
              label: 'Nombre de usuario',
              icon: Icons.alternate_email,
              enabled: _isEditing,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Número de celular',
              icon: Icons.phone_outlined,
              enabled: _isEditing,
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              enabled: _isEditing,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),

            // Sección: Datos del paciente
            _buildSectionTitle('Datos del paciente', isDark),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ageController,
                    label: 'Edad',
                    icon: Icons.cake_outlined,
                    enabled: _isEditing,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _weightController,
                    label: 'Peso (kg)',
                    icon: Icons.monitor_weight_outlined,
                    enabled: _isEditing,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _heightController,
              label: 'Altura (cm)',
              icon: Icons.height,
              enabled: _isEditing,
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: TextEditingController(text: _calculateIMC()),
              label: 'IMC',
              icon: Icons.analytics_outlined,
              enabled: false,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _medicationsController,
              label: 'Medicamentos',
              icon: Icons.medication_outlined,
              enabled: _isEditing,
              isDark: isDark,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _medicalHistoryController,
              label: 'Antecedentes',
              icon: Icons.medical_information_outlined,
              enabled: _isEditing,
              isDark: isDark,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _diagnosisDateController,
              label: 'Fecha de diagnóstico',
              icon: Icons.calendar_today_outlined,
              enabled: _isEditing,
              isDark: isDark,
              readOnly: true,
              onTap: _isEditing ? _showDatePickerDialog : null,
            ),
            const SizedBox(height: 30),

            // Botones de acción
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _cancelEdit,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled
              ? (isDark ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor)
              : Colors.grey,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled
              ? AppTheme.primaryColor
              : Colors.grey,
          size: 20,
        ),
        filled: true,
        fillColor: enabled
            ? (isDark ? AppTheme.darkCardColor.withOpacity(0.5) : Colors.white)
            : (isDark ? AppTheme.darkCardColor.withOpacity(0.3) : Colors.grey.shade50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkCardColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkCardColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppTheme.darkCardColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
