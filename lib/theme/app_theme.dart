import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  static final AppTheme _instance = AppTheme._internal();

  factory AppTheme() {
    return _instance;
  }

  AppTheme._internal();

  /// Obtiene el ThemeData completo de la aplicación
  ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: _colorScheme,
    appBarTheme: _appBarTheme,
    floatingActionButtonTheme: _floatingActionButtonTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    textTheme: _textTheme,
    cardColor: AppColors.surface,
  );

  /// Define la paleta de colores de la aplicación
  ColorScheme get _colorScheme => ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.bgDark,
    secondary: AppColors.success,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    background: AppColors.bgDark,
    onBackground: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.primary,
  );

  /// Define el tema de la AppBar
  AppBarTheme get _appBarTheme => AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.primary,
    elevation: 2,
  );

  /// Define el tema del FloatingActionButton
  FloatingActionButtonThemeData get _floatingActionButtonTheme =>
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      );

  /// Define el tema de botones elevados
  ElevatedButtonThemeData get _elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );

  /// Define el tema de campos de entrada
  InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    labelStyle: const TextStyle(color: AppColors.primary),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.success),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.success),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  /// Define el tema de tipografía
  TextTheme get _textTheme => const TextTheme(
    bodyLarge: TextStyle(color: AppColors.primary),
    bodyMedium: TextStyle(color: AppColors.textPrimary),
    titleLarge: TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      color: AppColors.error,
      fontWeight: FontWeight.bold,
    ),
  );
}
