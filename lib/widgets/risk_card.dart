import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/risk_prediction.dart';

class RiskCard extends StatelessWidget {
  final RiskPrediction prediction;

  const RiskCard({
    super.key,
    required this.prediction,
  });

  Color _getRiskColor(bool isDark) {
    switch (prediction.level) {
      case 'high':
        return const Color(0xFFC72331); // Rojo de la paleta
      case 'medium':
        return isDark ? AppTheme.warningColorBright : AppTheme.warningColor;
      default:
        return const Color(0xFF337536); // Verde de la paleta
    }
  }

  IconData _getRiskIcon() {
    switch (prediction.level) {
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              _getRiskIcon(),
              color: _getRiskColor(isDark),
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Predicción de riesgo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Riesgo de ${prediction.majorRiskWithPercentage}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getRiskColor(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRiskColor(isDark),
                  width: 1.5,
                ),
              ),
              child: Text(
                prediction.levelLabel.split(' ')[1], // Solo "bajo", "moderado", "alto"
                style: TextStyle(
                  color: _getRiskColor(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
