import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/core/services/glucose_range_service.dart';
import 'package:glucpred/features/records/domain/models/glucose_reading.dart';

class GlucoseCard extends StatelessWidget {
  final GlucoseReading reading;

  const GlucoseCard({
    super.key,
    required this.reading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rangeService = context.watch<GlucoseRangeService>();
    final color = rangeService.getColor(reading.value);
    final label = rangeService.getZoneLabel(reading.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Glucosa actual',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              reading.value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'mg/dl',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

