class RiskPrediction {
  final String level; // 'low', 'medium', 'high'
  final String timeFrame;
  final String description;

  RiskPrediction({
    required this.level,
    required this.timeFrame,
    required this.description,
  });

  String get levelLabel {
    switch (level) {
      case 'high':
        return 'Riesgo alto';
      case 'medium':
        return 'Riesgo moderado';
      default:
        return 'Riesgo bajo';
    }
  }
}
