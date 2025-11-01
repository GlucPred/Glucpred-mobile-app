import 'package:flutter/material.dart';

class DoctorAlertsScreen extends StatefulWidget {
  const DoctorAlertsScreen({super.key});

  @override
  State<DoctorAlertsScreen> createState() => _DoctorAlertsScreenState();
}

class _DoctorAlertsScreenState extends State<DoctorAlertsScreen> {
  String _selectedFilter = 'Todas';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _alerts = [
    {
      'name': 'Ana Sofia',
      'type': 'Alta',
      'time': '07:20 AM',
      'glucose': '245 mg/dl',
      'status': 'Crítico',
    },
    {
      'name': 'Ana Ruiz',
      'type': 'Alta',
      'time': '07:20 AM',
      'glucose': '245 mg/dl',
      'status': 'Crítico',
    },
    {
      'name': 'Luis Vega',
      'type': 'Alta',
      'time': '10:30 AM',
      'glucose': '168 mg/dl',
      'status': 'Crítico',
    },
    {
      'name': 'Carlos Mendez',
      'type': 'Alta',
      'time': '07:20 AM',
      'glucose': '98 mg/dl',
      'status': 'Normal',
    },
    {
      'name': 'Jorge Salazar',
      'type': 'Alta',
      'time': '07:20 AM',
      'glucose': '210 mg/dl',
      'status': 'Crítico',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    List<Map<String, dynamic>> filtered = _alerts;

    // Filtrar por categoría
    if (_selectedFilter == 'Críticas') {
      filtered = filtered.where((alert) => alert['status'] == 'Crítico').toList();
    } else if (_selectedFilter == 'Recordatorios') {
      // Filtrar recordatorios (ninguno en este caso)
      filtered = [];
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredAlerts = _filteredAlerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0073E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              _showSearchDialog(isDark);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Alertas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Filtros
            Row(
              children: [
                _buildFilterButton('Todas', isDark),
                const SizedBox(width: 12),
                _buildFilterButton('Críticas', isDark),
                const SizedBox(width: 12),
                _buildFilterButton('Recordatorios', isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Lista de alertas
            Expanded(
              child: filteredAlerts.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.separated(
                      itemCount: filteredAlerts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildAlertCard(
                          name: filteredAlerts[index]['name']!,
                          type: filteredAlerts[index]['type']!,
                          time: filteredAlerts[index]['time']!,
                          glucose: filteredAlerts[index]['glucose']!,
                          status: filteredAlerts[index]['status']!,
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

  Widget _buildFilterButton(String label, bool isDark) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF0073E6) : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : (isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? const Color(0xFF0073E6) : (isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB)),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required String name,
    required String type,
    required String time,
    required String glucose,
    required String status,
    required bool isDark,
  }) {
    Color statusColor;
    switch (status) {
      case 'Crítico':
        statusColor = const Color(0xFFC72331);
        break;
      case 'Normal':
        statusColor = const Color(0xFF337536);
        break;
      default:
        statusColor = const Color(0xFFFBC318);
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tipo de glucosa: $type',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Hora: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        glucose,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 80,
            color: isDark ? const Color(0xFF0073E6) : const Color(0xFF0073E6),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay recordatorios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Buscar alerta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Nombre del paciente...',
            prefixIcon: const Icon(Icons.search),
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
                SnackBar(
                  content: Text('Buscando: ${_searchController.text}'),
                  backgroundColor: const Color(0xFF0073E6),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0073E6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}
