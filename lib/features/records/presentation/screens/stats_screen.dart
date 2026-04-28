import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/core/services/glucose_range_service.dart';
import 'package:glucpred/features/records/presentation/viewmodels/stats_view_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsViewModel>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsViewModel>(
      builder: (context, vm, _) {
        final isLoading = vm.isLoading;
        final statistics = vm.statistics;
        final recentReadings = vm.recentReadings;

        if (isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Estadísticas')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (statistics == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Estadísticas')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay datos disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: vm.loadStatistics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
            ),
          );
        }

    final totalReadings = statistics['total_readings'] ?? 0;
    final average = statistics['average'] ?? 0.0;

    // Use user-configured ranges for % calculation when we have reading values.
    final rangeService = context.watch<GlucoseRangeService>();
    final glucoseValues = recentReadings
        .map((r) => (r['glucose_value'] as num?)?.toDouble() ?? 0.0)
        .toList();
    final normalPercentage = glucoseValues.isNotEmpty
        ? rangeService.calculateInRangePercentage(glucoseValues)
        : vm.normalPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: vm.loadStatistics,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.loadStatistics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                context,
                'Promedio (7 días)',
                '${average.toStringAsFixed(0)} mg/dl',
                Icons.trending_flat,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                context,
                'Lecturas en rango',
                '${normalPercentage.toStringAsFixed(0)}%',
                Icons.check_circle,
                Colors.green,
                subtitle: 'Rango: ${rangeService.rangeText}',
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                context,
                'Lecturas totales',
                '$totalReadings lecturas',
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
              if (recentReadings.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No hay lecturas recientes',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...recentReadings.map((reading) => _buildReadingItem(context, reading)),
            ],
          ),
        ),
      ),
    );
      }, // end Consumer builder
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
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
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
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

  Widget _buildReadingItem(BuildContext context, Map<String, dynamic> reading) {
    final glucoseValue = reading['glucose_value']?.toDouble() ?? 0.0;
    final measurementTime = DateTime.parse(reading['measurement_time']);
    final rangeService = context.read<GlucoseRangeService>();
    final statusColor = rangeService.getColor(glucoseValue);
    final zoneLabel = rangeService.getZoneLabel(glucoseValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withAlpha(26),
          child: Text(
            glucoseValue.toStringAsFixed(0),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text('${glucoseValue.toStringAsFixed(0)} mg/dl'),
        subtitle: Text(
          _formatDateTime(measurementTime),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Chip(
          label: Text(
            zoneLabel,
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: statusColor.withAlpha(26),
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
