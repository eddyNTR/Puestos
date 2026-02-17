import 'package:flutter/material.dart';

class ConfirmLocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool visible;

  const ConfirmLocationButton({
    super.key,
    required this.onPressed,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      left: 16,
      child: FloatingActionButton.small(
        onPressed: onPressed,
        backgroundColor: const Color(0xFFFF9800),
        elevation: 6,
        child: const Icon(Icons.check, color: Color(0xFF212121), size: 18),
      ),
    );
  }
}
