import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Textos animados de bienvenida
class SplashText extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final String appName;
  final String subtitle;

  const SplashText({
    super.key,
    required this.fadeAnimation,
    this.appName = 'EMSA',
    this.subtitle = 'Gestión de Puestos',
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        children: [
          Text(
            appName,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
