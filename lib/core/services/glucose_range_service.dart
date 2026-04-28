import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GlucoseZone { criticalLow, low, normal, high, criticalHigh }

/// Service that holds user-configured glucose ranges from SharedPreferences
/// and provides color/zone helpers for glucose values throughout the app.
///
/// Implements ChangeNotifier so UI rebuilds when the user saves new ranges
/// in AlertRangesScreen.
class GlucoseRangeService extends ChangeNotifier {
  static const _keyMin = 'range_min';
  static const _keyMax = 'range_max';
  static const _keyLowCritical = 'range_low_critical';
  static const _keyHighCritical = 'range_high_critical';

  // Clinical defaults: 70 / 140 / 60 / 180
  double _min = 70.0;
  double _max = 140.0;
  double _lowCritical = 60.0;
  double _highCritical = 180.0;

  double get min => _min;
  double get max => _max;
  double get lowCritical => _lowCritical;
  double get highCritical => _highCritical;

  /// E.g. "70 – 140 mg/dL"
  String get rangeText =>
      '${_min.toStringAsFixed(0)} – ${_max.toStringAsFixed(0)} mg/dL';

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _min = double.tryParse(prefs.getString(_keyMin) ?? '') ?? 70.0;
    _max = double.tryParse(prefs.getString(_keyMax) ?? '') ?? 140.0;
    _lowCritical =
        double.tryParse(prefs.getString(_keyLowCritical) ?? '') ?? 60.0;
    _highCritical =
        double.tryParse(prefs.getString(_keyHighCritical) ?? '') ?? 180.0;
    notifyListeners();
  }

  // ── Zone classification ───────────────────────────────────────────────────

  GlucoseZone getZone(double glucose) {
    if (glucose < _lowCritical) return GlucoseZone.criticalLow;
    if (glucose < _min) return GlucoseZone.low;
    if (glucose <= _max) return GlucoseZone.normal;
    if (glucose <= _highCritical) return GlucoseZone.high;
    return GlucoseZone.criticalHigh;
  }

  /// Returns the semantic color for a glucose value.
  Color getColor(double glucose) {
    switch (getZone(glucose)) {
      case GlucoseZone.criticalLow:
      case GlucoseZone.criticalHigh:
        return const Color(0xFFC72331);
      case GlucoseZone.low:
      case GlucoseZone.high:
        return const Color(0xFFD4880A);
      case GlucoseZone.normal:
        return const Color(0xFF337536);
    }
  }

  /// Human-readable zone name in Spanish.
  String getZoneLabel(double glucose) {
    switch (getZone(glucose)) {
      case GlucoseZone.criticalLow:
        return 'Crítico bajo';
      case GlucoseZone.low:
        return 'Bajo';
      case GlucoseZone.normal:
        return 'Normal';
      case GlucoseZone.high:
        return 'Alto';
      case GlucoseZone.criticalHigh:
        return 'Crítico alto';
    }
  }

  bool isInRange(double glucose) => glucose >= _min && glucose <= _max;

  /// Percentage of [values] that fall within [_min]..[_max].
  double calculateInRangePercentage(List<double> values) {
    if (values.isEmpty) return 0.0;
    final inRange = values.where(isInRange).length;
    return (inRange / values.length) * 100.0;
  }
}
