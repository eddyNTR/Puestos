import 'package:flutter/material.dart';

/// Utilidades para mostrar notificaciones (SnackBars)
/// Se puede reutilizar en toda la app
class UIHelper {
  // Evita instancias
  UIHelper._();

  /// Muestra notificación reutilizable (éxito, error, validación)
  static void showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  /// Notificación de éxito (verde)
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, const Color(0xFF388E3C));
  }

  /// Notificación de error (rojo)
  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, const Color(0xFFFF0054));
  }

  /// Notificación de advertencia (naranja)
  static void showWarning(BuildContext context, String message) {
    showSnackBar(context, message, const Color(0xFFFF9800));
  }
}
