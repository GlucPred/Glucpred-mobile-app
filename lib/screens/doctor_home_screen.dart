import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              'Hola, Dr. Juan',
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
                    value: '9',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIndicatorCard(
                    title: 'Alertas Críticas',
                    value: '3',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIndicatorCard(
                    title: 'Promedio de glucosa',
                    value: '118 mg/dL',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientTable(bool isDark, BuildContext context) {
    final patients = [
      {'name': 'Ana Sofia', 'age': '52', 'status': 'Estable', 'glucose': '245 mg/dL', 'alerts': '0'},
      {'name': 'Ana Ruiz', 'age': '45', 'status': 'Crítica', 'glucose': '245 mg/dL', 'alerts': '2'},
      {'name': 'Luis Vega', 'age': '38', 'status': 'Moderada', 'glucose': '168 mg/dL', 'alerts': '1'},
      {'name': 'Carlos Méndez', 'age': '60', 'status': 'Estable', 'glucose': '98 mg/dL', 'alerts': '0'},
      {'name': 'Diana Huamán', 'age': '29', 'status': 'Crítica', 'glucose': '136 mg/dL', 'alerts': '2'},
      {'name': 'Lucía Torres', 'age': '41', 'status': 'Moderada', 'glucose': '210 mg/dL', 'alerts': '1'},
      {'name': 'Jorge Salazar', 'age': '55', 'status': 'Crítica', 'glucose': '210 mg/dL', 'alerts': '3'},
      {'name': 'María Campos', 'age': '33', 'status': 'Estable', 'glucose': '105 mg/dL', 'alerts': '2'},
      {'name': 'Eduardo Piers', 'age': '47', 'status': 'Moderada', 'glucose': '155 mg/dL', 'alerts': '1'},
    ];

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
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Paciente',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Última glucosa',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Alertas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Filas de pacientes
            ...patients.map((patient) => _buildPatientRow(
                  name: patient['name']!,
                  age: patient['age']!,
                  status: patient['status']!,
                  glucose: patient['glucose']!,
                  alerts: patient['alerts']!,
                  isDark: isDark,
                  context: context,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientRow({
    required String name,
    required String age,
    required String status,
    required String glucose,
    required String alerts,
    required bool isDark,
    required BuildContext context,
  }) {
    Color statusColor;
    switch (status) {
      case 'Estable':
        statusColor = const Color(0xFF337536);
        break;
      case 'Moderada':
        statusColor = const Color(0xFFFBC318);
        break;
      case 'Crítica':
        statusColor = const Color(0xFFC72331);
        break;
      default:
        statusColor = const Color(0xFF6C7C93);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              glucose,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ),
          Expanded(
            child: Text(
              alerts,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0073E6)),
            iconSize: 20,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(
                    patientName: name,
                    patientAge: age,
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
