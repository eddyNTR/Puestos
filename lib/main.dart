import 'package:flutter/material.dart';
import 'config/app_initializer.dart';
import 'theme/app_theme.dart';
import 'screens/puestos_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Puestos',
      theme: AppTheme().themeData,
      home: const SplashScreen(),
      routes: {'/home': (context) => const PuestosScreen()},
    );
  }
}
