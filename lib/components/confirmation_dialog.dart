import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color confirmColor = const Color(0xFFFF9800),
    Color cancelColor = const Color(0xFF388E3C),
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1200),
          title: Text(title, style: const TextStyle(color: Color(0xFFFF9800))),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFFF8D082)),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFF9800), width: 2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText, style: TextStyle(color: cancelColor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText, style: TextStyle(color: confirmColor)),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
