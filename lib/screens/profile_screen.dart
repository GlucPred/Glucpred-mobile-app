import 'package:flutter/material.dart';
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
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor,
                      child: const Text(
                        'AS',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
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
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
