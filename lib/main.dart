import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'widgets/main_navigation.dart';
import 'screens/login_selection_screen.dart';

// ValueNotifier global para el estado del tema oscuro
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

void main() {
  runApp(const GlucPredApp());
}

class GlucPredApp extends StatelessWidget {
  const GlucPredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'GlucPred - Monitoreo de Glucosa',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const LoginSelectionScreen(),
      // home: const MainNavigation(), // Will be used after login
        );
      },
    );
  }
}
