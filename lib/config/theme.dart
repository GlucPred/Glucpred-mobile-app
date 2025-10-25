import 'package:flutter/material.dart';

class AppTheme {
  // Colores de la paleta oficial
  static const Color primaryColor = Color(0xFF0073E6); // Azul principal
  static const Color successColor = Color(0xFF337536); // Verde
  static const Color warningColor = Color(0xFFFBC318); // Amarillo
  static const Color dangerColor = Color(0xFFC72331); // Rojo
  static const Color textPrimaryColor = Color(0xFF000000); // Negro
  static const Color textSecondaryColor = Color(0xFF6C7C93); // Gris
  static const Color backgroundColor = Color(0xFFFFF9FAF9); // Blanco/Fondo
  static const Color borderColor = Color(0xFFE0E6EB); // Gris claro
  static const Color lightBlueColor = Color(0xFFB3C3D3); // Azul claro
  static const Color cardColor = Color(0xFFFFFFFF); // Blanco
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor, // #0073E6
        unselectedItemColor: textSecondaryColor, // #6C7C93
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
