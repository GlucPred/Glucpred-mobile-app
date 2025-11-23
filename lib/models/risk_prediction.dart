class RiskPrediction {
  final String level; // 'low', 'medium', 'high'
  final String timeFrame;
  final String description;
  final String? prediction; // Del backend: 'Hiperglucemia', 'Hipoglucemia', 'Normal'
  final Map<String, double>? probabilities; // Del backend
  final String? alertLevel; // Del backend: 'Bajo', 'Medio', 'Alto'

  RiskPrediction({
    required this.level,
    required this.timeFrame,
    required this.description,
    this.prediction,
    this.probabilities,
    this.alertLevel,
  });

  String get levelLabel {
    // Si tenemos alertLevel del backend, usarlo
    if (alertLevel != null) {
      return 'Riesgo $alertLevel';
    }
    
    // Fallback a la lógica local
    switch (level) {
      case 'high':
        return 'Riesgo alto';
      case 'medium':
        return 'Riesgo moderado';
      default:
        return 'Riesgo bajo';
    }
  }
  
  // Obtener el riesgo mayor (hiperglucemia o hipoglucemia) con su porcentaje
  String get majorRiskWithPercentage {
    if (probabilities == null) return timeFrame;
    
    double hiperglucemia = probabilities!['Hiperglucemia'] ?? 0.0;
    double hipoglucemia = probabilities!['Hipoglucemia'] ?? 0.0;
    
    if (hiperglucemia > hipoglucemia && hiperglucemia > 0.0) {
      return 'Hiperglucemia ${(hiperglucemia * 100).toStringAsFixed(1)}%';
    } else if (hipoglucemia > 0.0) {
      return 'Hipoglucemia ${(hipoglucemia * 100).toStringAsFixed(1)}%';
    }
    
    return timeFrame;
  }
}
