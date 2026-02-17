import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Logo animado del splash screen
class SplashLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  const SplashLogo({
    super.key,
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgDark,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset('assets/icon/emsa.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
