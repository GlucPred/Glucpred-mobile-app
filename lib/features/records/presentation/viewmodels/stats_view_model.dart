import 'package:flutter/material.dart';
import 'package:glucpred/features/records/data/repositories/records_repository.dart';

class StatsViewModel extends ChangeNotifier {
  final RecordsRepository _repo;

  StatsViewModel(this._repo);

  bool _isLoading = false;
  Map<String, dynamic>? _statistics;
  List<dynamic> _recentReadings = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get statistics => _statistics;
  List<dynamic> get recentReadings => _recentReadings;
  String? get errorMessage => _errorMessage;

  double get normalPercentage {
    if (_statistics == null) return 0.0;
    final total = _statistics!['total_readings'] ?? 0;
    if (total == 0) return 0.0;
    final classifications =
        _statistics!['classifications'] as Map<String, dynamic>? ?? {};
    return _repo.calculateNormalPercentage(classifications, total);
  }

  Future<void> loadStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final statsResult = await _repo.getStatistics(hours: 168);
    final historyResult = await _repo.getHistory(limit: 10, offset: 0);

    if (statsResult['success'] == true) {
      _statistics = statsResult['statistics'] as Map<String, dynamic>?;
    } else {
      _errorMessage =
          statsResult['message'] ?? 'Error al cargar estadísticas';
    }

    if (historyResult['success'] == true) {
      _recentReadings = historyResult['records'] as List? ?? [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
