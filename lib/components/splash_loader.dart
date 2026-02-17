import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Loading indicator personalizado para splash screen
class SplashLoader extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Color loaderColor;

  const SplashLoader({
    super.key,
    required this.fadeAnimation,
    this.loaderColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
              backgroundColor: AppColors.bgDark,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Iniciando...',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
