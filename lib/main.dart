import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/core/config/theme.dart';
import 'package:glucpred/features/auth/presentation/screens/splash_screen.dart';
import 'package:glucpred/features/auth/data/repositories/auth_repository.dart';
import 'package:glucpred/features/records/data/repositories/records_repository.dart';
import 'package:glucpred/features/alerts/data/repositories/alerts_repository.dart';
import 'package:glucpred/features/analysis/data/repositories/analysis_repository.dart';
import 'package:glucpred/features/doctor/data/repositories/doctor_patient_repository.dart';
import 'package:glucpred/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:glucpred/features/records/presentation/viewmodels/home_view_model.dart';
import 'package:glucpred/features/alerts/presentation/viewmodels/alerts_view_model.dart';
import 'package:glucpred/features/records/presentation/viewmodels/stats_view_model.dart';
import 'package:glucpred/features/doctor/presentation/viewmodels/doctor_home_view_model.dart';
import 'package:glucpred/features/doctor/presentation/viewmodels/doctor_patient_view_model.dart';
import 'package:glucpred/features/settings/presentation/viewmodels/settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GlucPredApp());
}

class GlucPredApp extends StatelessWidget {
  const GlucPredApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final recordsRepo = RecordsRepository();
    final alertsRepo = AlertsRepository();
    final analysisRepo = AnalysisRepository();
    final doctorRepo = DoctorPatientRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SettingsViewModel()..loadSettings()),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepo)),
        ChangeNotifierProvider(
            create: (_) => HomeViewModel(recordsRepo, analysisRepo)),
        ChangeNotifierProvider(create: (_) => AlertsViewModel(alertsRepo)),
        ChangeNotifierProvider(create: (_) => StatsViewModel(recordsRepo)),
        ChangeNotifierProvider(
            create: (_) => DoctorHomeViewModel(authRepo, doctorRepo)),
        ChangeNotifierProvider(
            create: (_) => DoctorPatientViewModel(doctorRepo)),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'GlucPred - Monitoreo de Glucosa',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'),
              Locale('en', 'US'),
            ],
            locale: const Locale('es', 'ES'),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
