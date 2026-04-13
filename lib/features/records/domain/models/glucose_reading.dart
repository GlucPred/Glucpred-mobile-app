class GlucoseReading {
  final double value;
  final DateTime timestamp;
  final String status; // 'normal', 'high', 'low'

  GlucoseReading({
    required this.value,
    required this.timestamp,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case 'high':
        return 'Nivel alto';
      case 'low':
        return 'Nivel bajo';
      default:
        return 'Nivel normal';
    }
  }
}
