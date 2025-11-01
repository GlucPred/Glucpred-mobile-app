import 'package:flutter/material.dart';

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

  final List<Map<String, String>> _observations = [
    {
      'date': '03/10/2025',
      'text': 'Control estable, mantener dosis actual.',
    },
    {
      'date': '05/08/2025',
      'text': 'Ajuste de medición, programar seguimiento.',
    },
    {
      'date': '22/07/2025',
      'text': 'Ajuste de medición, programar monitoreo.',
    },
    {
      'date': '03/07/2025',
      'text': 'Paciente refiere mejora, continuar monitoreo.',
    },
  ];

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
              child: ListView.separated(
                itemCount: _observations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildObservationCard(
                    date: _observations[index]['date']!,
                    text: _observations[index]['text']!,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationCard({
    required String date,
    required String text,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF0073E6)),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showEditObservationDialog(date, text, isDark);
                      },
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFF0073E6)),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showDeleteConfirmationDialog(date, isDark);
                      },
                    ),
                  ],
                ),
              ],
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

  void _showEditObservationDialog(String date, String text, bool isDark) {
    final TextEditingController editController = TextEditingController(text: text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Editar observación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Escribe la observación...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Observación actualizada'),
                  backgroundColor: Color(0xFF337536),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0073E6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(String date, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¿Eliminar observación?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Observación eliminada'),
                  backgroundColor: Color(0xFFC72331),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC72331),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
