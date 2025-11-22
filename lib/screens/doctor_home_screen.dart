import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';
import 'add_patient_screen.dart';
import '../services/doctor_patient_service.dart';
import '../services/auth_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _patients = [];
  String _doctorName = 'Dr. Juan';
  int _totalPatients = 0;
  int _activePatients = 0;
  int _criticalAlerts = 0;
  double _avgGlucose = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
    _loadPatientsSummary();
  }

  Future<void> _loadDoctorInfo() async {
    final userInfo = await AuthService.getUserInfo();
    final nombreCompleto = userInfo['nombre_completo'] ?? 'Doctor';
    setState(() {
      _doctorName = nombreCompleto;
    });
  }

  Future<void> _loadPatientsSummary() async {
    setState(() => _isLoading = true);

    try {
      final result = await DoctorPatientService.getPatientsSummary();

      if (result['success']) {
        final patients = List<Map<String, dynamic>>.from(result['patients'] ?? []);
        
        // Calcular indicadores
        int activeCount = patients.length;
        int alertsCount = 0;
        double totalGlucose = 0.0;

        for (var patient in patients) {
          alertsCount += (patient['alertas_count'] as int? ?? 0);
          totalGlucose += (patient['ultima_glucosa'] as num? ?? 0).toDouble();
        }

        double avgGlucose = patients.isEmpty ? 0.0 : totalGlucose / patients.length;

        setState(() {
          _patients = patients;
          _totalPatients = result['total'] ?? 0;
          _activePatients = activeCount;
          _criticalAlerts = alertsCount;
          _avgGlucose = avgGlucose;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error al cargar pacientes')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
          title: const Text('Home'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Agregar paciente',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPatientScreen(),
                ),
              );
              
              // Si se agregó un paciente, recargar la lista
              if (result == true) {
                _loadPatientsSummary();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatientsSummary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo
              Text(
                'Hola, $_doctorName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Panel de control
              Text(
                'Panel de control',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualiza el estado actual de tus pacientes y accede a sus reportes detallados.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                ),
              ),
              const SizedBox(height: 24),

              // Resumen de pacientes
              Text(
                'Resumen de pacientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Tabla de pacientes
              _buildPatientTable(isDark, context),
              const SizedBox(height: 32),

              // Indicadores
              Text(
                'Indicadores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Tarjetas de indicadores
              Row(
                children: [
                  Expanded(
                    child: _buildIndicatorCard(
                      title: 'Pacientes activos',
                      value: '$_activePatients',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildIndicatorCard(
                      title: 'Alertas Críticas',
                      value: '$_criticalAlerts',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildIndicatorCard(
                      title: 'Promedio de glucosa',
                      value: '${_avgGlucose.toStringAsFixed(0)} mg/dL',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientTable(bool isDark, BuildContext context) {
    if (_patients.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No hay pacientes asignados',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Encabezados
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Paciente',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Estado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Última glucosa',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alertas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
            ),
            const SizedBox(height: 4),
            // Filas de pacientes
            ..._patients.map((patient) => _buildPatientRow(
                  patientData: patient,
                  isDark: isDark,
                  context: context,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientRow({
    required Map<String, dynamic> patientData,
    required bool isDark,
    required BuildContext context,
  }) {
    final name = patientData['nombre_completo'] ?? 'Sin nombre';
    final edad = patientData['edad']?.toString() ?? '0';
    final status = patientData['estado'] ?? 'Estable';
    final glucoseValue = (patientData['ultima_glucosa'] as num?)?.toDouble() ?? 0.0;
    final glucose = '${glucoseValue.toStringAsFixed(0)} mg/dL';
    final alerts = (patientData['alertas_count'] ?? 0).toString();
    final patientUserId = patientData['patient_user_id'] as int;
    Color statusColor;
    Color statusBgColor;
    switch (status) {
      case 'Estable':
        statusColor = const Color(0xFF337536);
        statusBgColor = const Color(0xFF337536).withOpacity(0.1);
        break;
      case 'Moderada':
        statusColor = const Color(0xFFFBC318);
        statusBgColor = const Color(0xFFFBC318).withOpacity(0.1);
        break;
      case 'Crítica':
        statusColor = const Color(0xFFC72331);
        statusBgColor = const Color(0xFFC72331).withOpacity(0.1);
        break;
      default:
        statusColor = const Color(0xFF6C7C93);
        statusBgColor = const Color(0xFF6C7C93).withOpacity(0.1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre del paciente
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Estado como etiqueta (badge)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Última glucosa
          Expanded(
            flex: 2,
            child: Text(
              glucose,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Alertas
          Expanded(
            child: Text(
              alerts,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Icono de lupa
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0073E6)),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(
                    patientUserId: patientUserId,
                    patientName: name,
                    patientAge: edad,
                    currentStatus: status,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard({
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
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
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
