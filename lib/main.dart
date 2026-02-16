import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'screens/puestos_screen.dart';

void main() async {
  await AppConfig.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Puestos',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF181A20),
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFFF9800), // Naranja EMSA
          onPrimary: Color(0xFF181A20),
          secondary: Color(0xFF388E3C), // Verde EMSA
          onSecondary: Color(0xFFFFFFFF),
          error: Color(0xFFD32F2F),
          onError: Color(0xFFFFFFFF),
          background: Color(0xFF181A20),
          onBackground: Color(0xFFF6F6F6),
          surface: Color(0xFF23272F),
          onSurface: Color(0xFFFF9800),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF23272F),
          foregroundColor: Color(0xFFFF9800),
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF388E3C),
          foregroundColor: Color(0xFFFFFFFF),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: const Color(0xFF23272F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF23272F),
          labelStyle: TextStyle(color: Color(0xFFFF9800)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF388E3C)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF388E3C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFFF9800), width: 2),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFFF9800)),
          bodyMedium: TextStyle(color: Color(0xFFF6F6F6)),
          titleLarge: TextStyle(
            color: Color(0xFFFF9800),
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        cardColor: Color(0xFF23272F),
      ),
      home: const PuestosScreen(),
    );
  }
}
