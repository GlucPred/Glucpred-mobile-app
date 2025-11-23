/// Constantes de la aplicación GlucPred
class AppConstants {
  // Prevenir instanciación
  AppConstants._();

  // Rangos de glucosa (mg/dl)
  static const double glucoseMin = 70.0;
  static const double glucoseMax = 140.0;
  static const double glucoseLowThreshold = 90.0;
  static const double glucoseHighThreshold = 130.0;

  // Duración de animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Intervalos de actualización
  static const Duration refreshInterval = Duration(minutes: 5);
  
  // Formato de fecha
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Límites de gráficos
  static const int maxTrendPoints = 7;
  static const int maxHistoricalReadings = 50;
}
