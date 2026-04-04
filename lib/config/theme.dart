import 'package:flutter/material.dart';

class AppTheme {
  // Colores de la paleta oficial (modo claro)
  static const Color primaryColor = Color(0xFF0073E6); // Azul principal
  static const Color successColor = Color(0xFF337536); // Verde
  static const Color warningColor = Color(0xFFB8860B); // Amarillo accesible (4.5:1 sobre blanco)
  static const Color warningColorBright = Color(0xFFFBC318); // Amarillo original (solo sobre fondos oscuros)
  static const Color dangerColor = Color(0xFFC72331); // Rojo
  static const Color textPrimaryColor = Color(0xFF000000); // Negro
  static const Color textSecondaryColor = Color(0xFF6C7C93); // Gris
  static const Color backgroundColor = Color(0xFFFFF9FAF9); // Blanco/Fondo
  static const Color borderColor = Color(0xFFE0E6EB); // Gris claro
  static const Color lightBlueColor = Color(0xFFB3C3D3); // Azul claro
  static const Color cardColor = Color(0xFFFFFFFF); // Blanco
  
  // Colores para modo oscuro - mejorados para mejor contraste
  static const Color darkBackgroundColor = Color(0xFF0A0E27); // Fondo oscuro azulado
  static const Color darkCardColor = Color(0xFF1A1F3A); // Tarjetas oscuras con tinte azul
  static const Color darkTextPrimaryColor = Color(0xFFFFFFFF); // Blanco puro
  static const Color darkTextSecondaryColor = Color(0xFFB3C3D3); // Gris azulado claro
  static const Color darkBorderColor = Color(0xFF2C3E50); // Borde oscuro con contraste
  static const Color darkSurfaceColor = Color(0xFF151B3B); // Superficie alternativa
  
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
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimaryColor, height: 1.5),
        bodyMedium: TextStyle(color: textPrimaryColor, height: 1.5),
        bodySmall: TextStyle(color: textSecondaryColor, height: 1.5),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: darkCardColor,
        background: darkBackgroundColor,
        error: dangerColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkBorderColor, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceColor,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: Color(0xFF4A9EFF), // Azul más claro para mejor contraste
        unselectedItemColor: darkTextSecondaryColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkTextPrimaryColor, height: 1.5),
        bodyMedium: TextStyle(color: darkTextPrimaryColor, height: 1.5),
        bodySmall: TextStyle(color: darkTextSecondaryColor, height: 1.5),
        titleLarge: TextStyle(color: darkTextPrimaryColor, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: darkTextPrimaryColor, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: darkTextSecondaryColor),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // Thumb blanco cuando está activado
          }
          return const Color(0xFF8B9AAB); // Thumb gris cuando está desactivado
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0073E6).withOpacity(0.5); // Track semi-transparente cuando está activado
          }
          return const Color(0xFF3D4A5C); // Track oscuro cuando está desactivado
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0073E6); // Borde azul cuando está activado
          }
          return const Color(0xFF3D4A5C); // Sin borde visible cuando está desactivado
        }),
        overlayColor: WidgetStateProperty.all(primaryColor.withOpacity(0.2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
    );
  }
}
