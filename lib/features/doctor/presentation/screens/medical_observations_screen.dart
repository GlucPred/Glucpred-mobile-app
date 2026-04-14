import 'package:flutter/material.dart';
import 'package:glucpred/features/doctor/data/services/doctor_patient_service.dart';
import 'package:intl/intl.dart';

class MedicalObservationsScreen extends StatefulWidget {
  final int patientUserId;
  final String patientName;

  const MedicalObservationsScreen({
    super.key,
    required this.patientUserId,
    required this.patientName,
  });

  @override
  State<MedicalObservationsScreen> createState() => _MedicalObservationsScreenState();
}

class _MedicalObservationsScreenState extends State<MedicalObservationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _observations = [];
  List<Map<String, dynamic>> _filteredObservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadObservations();
    _searchController.addListener(_filterObservations);
  }

  Future<void> _loadObservations() async {
    setState(() => _isLoading = true);

    try {
      final result = await DoctorPatientService.getObservations(widget.patientUserId);

      if (result['success']) {
        final observations = List<Map<String, dynamic>>.from(result['observations'] ?? []);
        setState(() {
          _observations = observations;
          _filteredObservations = observations;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error al cargar observaciones')),
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

  void _filterObservations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredObservations = _observations.where((obs) {
        final text = (obs['observation'] ?? obs['observation_text'] ?? '').toLowerCase();
        return text.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteObservation(int observationId) async {
    final result = await DoctorPatientService.deleteObservation(observationId);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Observación eliminada')),
        );
        _loadObservations(); // Recargar lista
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al eliminar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddObservationDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva observación'),
          content: TextField(
            controller: textController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Escribe la observación...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Escribe algo antes de guardar')),
                  );
                  return;
                }

                Navigator.pop(context);

                final result = await DoctorPatientService.createObservation(
                  widget.patientUserId,
                  text,
                );

                if (result['success']) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Observación creada')),
                    );
                    _loadObservations();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredObservations.isEmpty
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
                                _searchController.text.isEmpty
                                    ? 'No hay observaciones médicas'
                                    : 'No se encontraron observaciones',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredObservations.length,
                          itemBuilder: (context, index) {
                            final observation = _filteredObservations[index];
                            return _buildObservationCard(observation, isDark);
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


  Widget _buildObservationCard(Map<String, dynamic> observation, bool isDark) {
    final createdAt = DateTime.parse(observation['created_at']);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
    final observationId = observation['id'];
    final observationText = observation['observation'] ?? observation['observation_text'] ?? '';
    
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0073E6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_note,
                    color: Color(0xFF0073E6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDark ? Colors.blue[300] : const Color(0xFF0073E6),
                    size: 20,
                  ),
                  onPressed: () {
                    _showEditObservationDialog(observationId, observationText);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDark ? Colors.red[300] : Colors.red,
                    size: 20,
                  ),
                  onPressed: () {
                    _showDeleteConfirmation(observationId);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              observationText,
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

  void _showEditObservationDialog(int observationId, String currentText) {
    final textController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar observación'),
          content: TextField(
            controller: textController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Escribe la observación...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La observación no puede estar vacía')),
                  );
                  return;
                }
                Navigator.pop(context);
                final result = await DoctorPatientService.updateObservation(observationId, text);
                if (result['success']) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Observación actualizada')),
                    );
                    _loadObservations();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Error al actualizar'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int observationId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
        title: Text(
          'Eliminar observación',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta observación?',
          style: TextStyle(
            color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteObservation(observationId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC72331),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
