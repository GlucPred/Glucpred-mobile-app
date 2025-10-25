import 'package:flutter/material.dart';
import '../models/risk_prediction.dart';

class RiskCard extends StatelessWidget {
  final RiskPrediction prediction;

  const RiskCard({
    super.key,
    required this.prediction,
  });

  Color _getRiskColor() {
    switch (prediction.level) {
      case 'high':
        return const Color(0xFFC72331); // Rojo de la paleta
      case 'medium':
        return const Color(0xFFFBC318); // Amarillo de la paleta
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              _getRiskIcon(),
              color: _getRiskColor(),
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
                      color: const Color(0xFF000000), // Negro de la paleta
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Riesgo de ${prediction.timeFrame}',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6C7C93), // Gris de la paleta
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
                color: _getRiskColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRiskColor(),
                  width: 1.5,
                ),
              ),
              child: Text(
                prediction.levelLabel.split(' ')[1], // Solo "bajo", "moderado", "alto"
                style: TextStyle(
                  color: _getRiskColor(),
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
