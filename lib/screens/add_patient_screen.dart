import 'package:flutter/material.dart';
import '../services/doctor_patient_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _availablePatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailablePatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailablePatients() async {
    setState(() => _isLoading = true);

    try {
      final result = await DoctorPatientService.getAvailablePatients();

      if (result['success']) {
        final patients = List<Map<String, dynamic>>.from(result['patients'] ?? []);
        setState(() {
          _availablePatients = patients;
          _filteredPatients = patients;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al cargar pacientes'),
              backgroundColor: const Color(0xFFC72331),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFC72331),
          ),
        );
      }
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _availablePatients;
      } else {
        _filteredPatients = _availablePatients.where((patient) {
          final nombre = (patient['nombre_completo'] ?? '').toLowerCase();
          return nombre.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _assignPatient(int patientUserId, String nombre) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
          title: Text(
            'Confirmar asignación',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0A0E27),
            ),
          ),
          content: Text(
            '¿Deseas agregar a $nombre a tu lista de pacientes?',
            style: TextStyle(
              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0073E6),
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      final result = await DoctorPatientService.assignPatient(patientUserId);

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Paciente agregado exitosamente'),
              backgroundColor: const Color(0xFF337536),
            ),
          );
          
          // Recargar lista y regresar
          await _loadAvailablePatients();
          if (mounted) {
            Navigator.pop(context, true); // Regresar con resultado exitoso
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al agregar paciente'),
              backgroundColor: const Color(0xFFC72331),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFC72331),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text('Agregar Pacientes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
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
          ),

          // Lista de pacientes disponibles
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No hay pacientes disponibles'
                                  : 'No se encontraron pacientes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                              ),
                            ),
                            if (_searchController.text.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Todos los pacientes registrados ya están asignados a un médico',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return _buildPatientCard(patient, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, bool isDark) {
    final nombre = patient['nombre_completo'] ?? 'Sin nombre';
    final edad = patient['edad'] ?? 0;
    final patientUserId = patient['patient_user_id'];
    final genero = patient['genero'] ?? '';
    final ultimaGlucosa = patient['ultima_glucosa'];
    final medicamentos = patient['medicamentos'] ?? 'No especificado';
    final antecedentes = patient['antecedentes'] ?? 'No especificado';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y botón
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0073E6).withOpacity(0.1),
                  radius: 24,
                  child: Icon(
                    genero.toUpperCase() == 'M' ? Icons.person : Icons.person_outline,
                    color: const Color(0xFF0073E6),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$edad años${genero.isNotEmpty ? " • ${genero.toUpperCase() == 'M' ? 'Masculino' : 'Femenino'}" : ""}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _assignPatient(patientUserId, nombre),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0073E6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    'Asignar',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
            
            if (ultimaGlucosa != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1A1F3A).withOpacity(0.5)
                      : const Color(0xFFF8FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: isDark ? const Color(0xFF0073E6) : const Color(0xFF0073E6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Última glucosa: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                      ),
                    ),
                    Text(
                      '${ultimaGlucosa.toStringAsFixed(0)} mg/dL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.medical_services_outlined,
              'Medicamentos',
              medicamentos,
              isDark,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.history_edu_outlined,
              'Antecedentes',
              antecedentes,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
