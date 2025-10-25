import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'widgets/main_navigation.dart';

void main() {
  runApp(const GlucPredApp());
}

class GlucPredApp extends StatelessWidget {
  const GlucPredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucPred - Monitoreo de Glucosa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
