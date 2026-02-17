import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/splash_controller.dart';
import '../components/splash_logo.dart';
import '../components/splash_text.dart';
import '../components/splash_loader.dart';
import 'puestos_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SplashController _splashController;

  @override
  void initState() {
    super.initState();
    _splashController = SplashController();
    _splashController.initialize(this);

    // Navega a home después de 3 segundos
    _splashController.scheduleNavigation(
      delay: const Duration(seconds: 3),
      onNavigate: _navigateToHome,
    );
  }

  // Navega a pantalla principal
  Future<void> _navigateToHome() async {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            SplashLogo(
              scaleAnimation: _splashController.scaleAnimation,
              fadeAnimation: _splashController.fadeAnimation,
            ),
            const SizedBox(height: 40),
            // Textos de bienvenida
            SplashText(fadeAnimation: _splashController.fadeAnimation),
            const SizedBox(height: 60),
            // Loading indicator
            SplashLoader(fadeAnimation: _splashController.fadeAnimation),
          ],
        ),
      ),
    );
  }
}
