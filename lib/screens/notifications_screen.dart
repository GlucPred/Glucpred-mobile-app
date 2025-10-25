import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0: Todas, 1: Críticas, 2: Recordatorios

  @override
  Widget build(BuildContext context) {
    final alerts = _getFilteredAlerts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0073E6)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buscar alertas')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildTabButton('Todas', 0)),
                const SizedBox(width: 8),
                Expanded(child: _buildTabButton('Críticas', 1)),
                const SizedBox(width: 8),
                Expanded(child: _buildTabButton('Recordatorios', 2)),
              ],
            ),
          ),
          
          // Lista de alertas
          Expanded(
            child: alerts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      return _buildAlertCard(alerts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTab = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF0073E6) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF6C7C93),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? const Color(0xFF0073E6) : const Color(0xFFE0E6EB),
            width: 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAlertCard(_Alert alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                if (alert.actionButton != null)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alert.buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      alert.actionButton!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Hora: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C7C93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  alert.time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(width: 16),
                if (alert.value != null) ...[
                  Text(
                    alert.value!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Recomendaciones:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7C93),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              alert.recommendation,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7C93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info,
            size: 64,
            color: const Color(0xFF0073E6),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay más alertas',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6C7C93),
            ),
          ),
        ],
      ),
    );
  }

  List<_Alert> _getFilteredAlerts() {
    final allAlerts = [
      _Alert(
        title: 'Hiperglucemia detectada',
        time: '10:30 AM',
        value: '185 mg/dl',
        recommendation: 'Revisar medicación y consultar médico.',
        type: 'critical',
        actionButton: 'Crítico',
        buttonColor: const Color(0xFFC72331),
      ),
      _Alert(
        title: 'Hipoglucemia leve',
        time: '07:20 AM',
        value: '68 mg/dl',
        recommendation: 'Consumir 15g de carbohidratos rápidos.',
        type: 'critical',
        actionButton: 'Crítico',
        buttonColor: const Color(0xFFFBC318),
      ),
      _Alert(
        title: 'Recordatorio de medición',
        time: '06:24 AM',
        value: null,
        recommendation: 'Es hora de medir tu glucosa.',
        type: 'reminder',
        actionButton: 'Recordatorio',
        buttonColor: const Color(0xFF0073E6),
      ),
    ];

    // Filtrar según la pestaña seleccionada
    if (_selectedTab == 1) {
      // Solo críticas
      return allAlerts.where((alert) => alert.type == 'critical').toList();
    } else if (_selectedTab == 2) {
      // Solo recordatorios
      return allAlerts.where((alert) => alert.type == 'reminder').toList();
    }
    
    // Todas
    return allAlerts;
  }
}

class _Alert {
  final String title;
  final String time;
  final String? value;
  final String recommendation;
  final String type; // 'critical' o 'reminder'
  final String? actionButton;
  final Color? buttonColor;

  _Alert({
    required this.title,
    required this.time,
    this.value,
    required this.recommendation,
    required this.type,
    this.actionButton,
    this.buttonColor,
  });
}
