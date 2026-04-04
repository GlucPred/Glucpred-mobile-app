import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/alerts_service.dart';
import '../utils/logger.dart';

class DoctorAlertsScreen extends StatefulWidget {
  const DoctorAlertsScreen({super.key});

  @override
  State<DoctorAlertsScreen> createState() => _DoctorAlertsScreenState();
}

class _DoctorAlertsScreenState extends State<DoctorAlertsScreen> with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'Todas';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _alerts = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    AppLogger.debug('DoctorAlertsScreen: Loading patient alerts...');
    setState(() => _isLoading = true);
    
    final result = await AlertsService.getMyPatientsAlerts();
    AppLogger.debug('DoctorAlertsScreen: Success=${result['success']}, count=${(result['alerts'] as List?)?.length ?? 0}');
    
    if (result['success']) {
      setState(() {
        _alerts = (result['alerts'] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error al cargar alertas')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    List<Map<String, dynamic>> filtered = _alerts;

    // Filtrar por búsqueda (nombre del paciente)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((alert) {
        final name = (alert['patient_name'] ?? '').toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrar por categoría
    if (_selectedFilter == 'Críticas') {
      filtered = filtered.where((alert) => alert['severity'] == 'critico').toList();
    } else if (_selectedFilter == 'Recordatorios') {
      filtered = filtered.where((alert) => alert['alert_type'] == 'recordatorio').toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            
            // Indicador de búsqueda activa
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0073E6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0073E6),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF0073E6),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Buscando: "$_searchQuery"',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0073E6),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF0073E6),
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Lista de alertas
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredAlerts.isEmpty
                      ? _buildEmptyState(isDark)
                      : RefreshIndicator(
                          onRefresh: _loadAlerts,
                          child: ListView.separated(
                            itemCount: filteredAlerts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final alert = filteredAlerts[index];
                              return _buildAlertCard(alert, isDark);
                            },
                          ),
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

  Widget _buildAlertCard(Map<String, dynamic> alert, bool isDark) {
    final patientName = alert['patient_name'] ?? 'Paciente';
    final severity = alert['severity'] ?? 'info';
    final title = alert['title'] ?? 'Alerta';
    final glucoseValue = alert['glucose_value'];
    final createdAt = DateTime.parse(alert['created_at']);
    final timeStr = DateFormat('hh:mm a').format(createdAt);
    
    Color statusColor;
    String statusText;
    
    switch (severity) {
      case 'critico':
        statusColor = const Color(0xFFC72331);
        statusText = 'Crítico';
        break;
      case 'advertencia':
        statusColor = const Color(0xFFFBC318);
        statusText = 'Advertencia';
        break;
      default:
        statusColor = const Color(0xFF337536);
        statusText = 'Normal';
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
                    patientName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
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
                        timeStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                        ),
                      ),
                      if (glucoseValue != null) ...[
                        const SizedBox(width: 16),
                        Text(
                          '${glucoseValue.toStringAsFixed(0)} mg/dl',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                          ),
                        ),
                      ],
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
                statusText,
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
    final isSearching = _searchQuery.isNotEmpty;
    final isRecordatorios = _selectedFilter == 'Recordatorios';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.warning_amber_rounded,
            size: 80,
            color: isDark ? const Color(0xFF0073E6) : const Color(0xFF0073E6),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching 
                ? 'No se encontraron alertas'
                : isRecordatorios
                    ? 'No hay recordatorios'
                    : 'No hay alertas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            ),
          ),
          if (isSearching) ...[
            const SizedBox(height: 8),
            Text(
              'Intenta con otro nombre de paciente',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSearchDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
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
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Nombre del paciente...',
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0A0E27) : Colors.grey[50],
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
              borderSide: const BorderSide(color: Color(0xFF0073E6), width: 2),
            ),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
            Navigator.pop(context);
            if (_searchQuery.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Buscando: $_searchQuery'),
                  backgroundColor: const Color(0xFF0073E6),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: Text(
              'Limpiar',
              style: TextStyle(
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text.trim();
              });
              Navigator.pop(context);
              if (_searchQuery.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Buscando: $_searchQuery'),
                    backgroundColor: const Color(0xFF0073E6),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
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
