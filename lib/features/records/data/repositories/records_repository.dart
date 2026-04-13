import 'package:glucpred/features/records/data/services/records_service.dart';

class RecordsRepository {
  Future<Map<String, dynamic>> getLatestReading() =>
      RecordsService.getLatestReading();

  Future<Map<String, dynamic>> getTrend({int hours = 12}) =>
      RecordsService.getTrend(hours: hours);

  Future<Map<String, dynamic>> getStatistics({int hours = 168}) =>
      RecordsService.getStatistics(hours: hours);

  Future<Map<String, dynamic>> getHistory(
          {required int limit, required int offset}) =>
      RecordsService.getHistory(limit: limit, offset: offset);

  double calculateNormalPercentage(
          Map<String, dynamic> classifications, int totalReadings) =>
      RecordsService.calculateNormalPercentage(classifications, totalReadings);
}
