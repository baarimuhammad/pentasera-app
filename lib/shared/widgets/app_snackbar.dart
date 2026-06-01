import 'package:flutter/material.dart';

/// Helper class for showing themed snackbars.
class AppSnackbar {
  AppSnackbar._();

  /// Show a success snackbar (green).
  static void success(BuildContext context, String message) {
    _show(context, message, const Color(0xFF22C55E), Icons.check_circle);
  }

  /// Show an error snackbar (red).
  static void error(BuildContext context, String message) {
    _show(context, message, const Color(0xFFEF4444), Icons.error);
  }

  /// Show an info snackbar (blue).
  static void info(BuildContext context, String message) {
    _show(context, message, const Color(0xFF3B82F6), Icons.info);
  }

  /// Show a warning snackbar (amber).
  static void warning(BuildContext context, String message) {
    _show(context, message, const Color(0xFFF59E0B), Icons.warning_amber);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
