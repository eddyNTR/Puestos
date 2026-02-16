import 'package:flutter/material.dart';
import 'dart:async';
import 'puestos_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Navegar después de 3 segundos
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo con animación
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFFFF9800),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/icon/emsa.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Texto de la app
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const Text(
                    'EMSA',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestión de Puestos',
                    style: TextStyle(
                      color: Color(0xFFF8D082),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Loading indicator personalizado
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo de fondo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF388E3C).withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                    ),
                    // Indicador giratorio
                    RotationTransition(
                      turns: _animationController,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFFFF9800),
                              width: 3,
                            ),
                            right: BorderSide(
                              color: const Color(0xFF388E3C),
                              width: 3,
                            ),
                            bottom: BorderSide(
                              color: Colors.transparent,
                              width: 3,
                            ),
                            left: BorderSide(
                              color: Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Texto de carga
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Iniciando...',
                style: TextStyle(
                  color: Color(0xFFF8D082),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
