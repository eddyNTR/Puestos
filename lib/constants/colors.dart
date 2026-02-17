import 'package:flutter/material.dart';

/// Colores centralizados de la app
/// Reutilizable en toda la aplicación
class AppColors {
  // Previene instanciación
  AppColors._();

  // Colores de fondo
  static const Color bgDark = Color(0xFF181A20);
  static const Color bgLight = Color(0xFF1A1200);
  static const Color surface = Color(0xFF23272F);

  // Colores primarios
  static const Color primary = Color(0xFFFF9800); // Naranja EMSA
  static const Color primaryDark = Color(0xFFE68900);

  // Colores secundarios
  static const Color secondary = Color(0xFFF8D082); // Naranja claro

  // Colores de estado
  static const Color success = Color(0xFF388E3C); // Verde
  static const Color error = Color(0xFFFF0054); // Rojo
  static const Color warning = Color(0xFFFF9800); // Naranja

  // Colores de texto
  static const Color textPrimary = Color(0xFFF8D082);
  static const Color textSecondary = Color(0xFFBBBBBB);
}
