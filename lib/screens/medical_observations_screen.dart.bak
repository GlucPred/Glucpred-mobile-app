import 'package:flutter/material.dart';
import '../services/patient_data_service.dart';
import '../models/patient.dart';

class MedicalObservationsScreen extends StatefulWidget {
  final String patientName;

  const MedicalObservationsScreen({
    super.key,
    required this.patientName,
  });

  @override
  State<MedicalObservationsScreen> createState() => _MedicalObservationsScreenState();
}

class _MedicalObservationsScreenState extends State<MedicalObservationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PatientDataService _patientService = PatientDataService();
  Patient? _patient;
  List<MedicalObservation> _observations = [];

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  void _loadObservations() {
    _patient = _patientService.findPatientByName(widget.patientName);
    if (_patient != null) {
      setState(() {
        _observations = _patient!.observaciones;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Observaciones médicas'),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF0073E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Center(
              child: Text(
                'Observaciones médicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Campo de búsqueda
            TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? const Color(0xFF6C7C93) : const Color(0xFF6C7C93),
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
            const SizedBox(height: 24),

            // Lista de observaciones
            Expanded(
              child: _observations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 80,
                            color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay observaciones médicas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _observations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final obs = _observations[index];
                        return _buildObservationCard(
                          title: obs.title,
                          date: obs.formattedDate,
                          time: obs.formattedTime,
                          text: obs.description,
                          isDark: isDark,
                          onDelete: () {
                            setState(() {
                              _patientService.deleteObservation(_patient!.id, obs.id);
                              _loadObservations();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Observación eliminada'),
                                backgroundColor: Color(0xFF337536),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddObservationDialog(),
        backgroundColor: const Color(0xFF0073E6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddObservationDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
        title: Text(
          'Nueva observación médica',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(
                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0073E6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(
                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0073E6), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos'),
                    backgroundColor: Color(0xFFC72331),
                  ),
                );
                return;
              }

              _patientService.addObservationByName(
                patientName: widget.patientName,
                title: titleController.text,
                description: descriptionController.text,
              );

              setState(() {
                _loadObservations();
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Observación agregada exitosamente'),
                  backgroundColor: Color(0xFF337536),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0073E6),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard({
    required String title,
    required String date,
    required String time,
    required String text,
    required bool isDark,
    required VoidCallback onDelete,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFC72331)),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$date • $time',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
