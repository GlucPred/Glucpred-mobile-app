import 'package:flutter/material.dart';
import '../services/glucose_service.dart';
import '../models/glucose_reading.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final readings = GlucoseService.getHistoricalReadings(10);
    final avgGlucose = readings.map((r) => r.value).reduce((a, b) => a + b) / readings.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              context,
              'Promedio (7 días)',
              '${avgGlucose.toStringAsFixed(0)} mg/dl',
              Icons.trending_flat,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              'Lecturas en rango',
              '78%',
              Icons.check_circle,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              'Lecturas totales',
              '${readings.length} lecturas',
              Icons.analytics,
              Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Historial reciente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...readings.map((reading) => _buildReadingItem(context, reading)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingItem(BuildContext context, GlucoseReading reading) {
    Color statusColor;
    switch (reading.status) {
      case 'high':
        statusColor = Colors.orange;
        break;
      case 'low':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Text(
            reading.value.toStringAsFixed(0),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text('${reading.value.toStringAsFixed(0)} mg/dl'),
        subtitle: Text(
          _formatDateTime(reading.timestamp),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Chip(
          label: Text(
            reading.statusLabel.split(' ')[1], // Solo "normal", "alto", "bajo"
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
          side: BorderSide(color: statusColor),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
