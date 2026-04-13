import 'package:glucpred/features/analysis/data/services/analysis_service.dart';
import 'package:glucpred/features/analysis/data/services/health_connect_service.dart';

class AnalysisRepository {
  Future<Map<String, dynamic>> predictEpisode({
    required double glucose,
    required double insulin30min,
    required double carbs30min,
    double? heartRate,
    int? steps15min,
    double? calories15min,
  }) =>
      AnalysisService.predictEpisode(
        glucose: glucose,
        insulin30min: insulin30min,
        carbs30min: carbs30min,
        heartRate: heartRate,
        steps15min: steps15min,        calories15min: calories15min,
      );

  Future<Map<String, dynamic>> readHealthData() =>
      HealthConnectService.readHealthData();
}
