import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/glucose_reading.dart';

class GlucoseCard extends StatelessWidget {
  final GlucoseReading reading;

  const GlucoseCard({
    super.key,
    required this.reading,
  });

  Color _getStatusColor(bool isDark) {
    switch (reading.status) {
      case 'high':
        return isDark ? AppTheme.warningColorBright : AppTheme.warningColor;
      case 'low':
        return const Color(0xFFC72331); // Rojo de la paleta
      default:
        return const Color(0xFF337536); // Verde de la paleta
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                color: _getStatusColor(isDark),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(isDark),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                reading.statusLabel,
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
