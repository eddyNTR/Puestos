import 'package:flutter/material.dart';
import 'dart:async';

/// Controlador centralizado para splash screen
/// Maneja animaciones, timers y navegación
class SplashController {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Timer _navigationTimer;

  AnimationController get animationController => _animationController;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;

  /// Inicializa el controlador con vsync
  void initialize(TickerProvider vsync) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );

    // Fade animation: 0 → 1
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Scale animation: 0.8 → 1.0
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Inicia animaciones
    _animationController.forward();
  }

  /// Programa navegación después de delay
  void scheduleNavigation({
    required Duration delay,
    required Future<void> Function() onNavigate,
  }) {
    _navigationTimer = Timer(delay, onNavigate);
  }

  /// Limpia recursos
  void dispose() {
    _navigationTimer.cancel();
    _animationController.dispose();
  }
}
