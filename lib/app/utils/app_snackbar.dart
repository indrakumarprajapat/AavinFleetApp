import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Consistent, high-contrast snackbars for fleet app messaging.
class AppSnackbar {
  static void success(String title, String message) {
    _show(
      title: title,
      message: message,
      background: const Color(0xFFE8F5E9),
      border: const Color(0xFF2E7D32),
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF2E7D32),
    );
  }

  static void error(String title, String message) {
    _show(
      title: title,
      message: _clean(message),
      background: const Color(0xFFFFEBEE),
      border: const Color(0xFFC62828),
      icon: Icons.error_rounded,
      iconColor: const Color(0xFFC62828),
      duration: const Duration(seconds: 4),
    );
  }

  static void info(String title, String message) {
    _show(
      title: title,
      message: message,
      background: const Color(0xFFE3F2FD),
      border: const Color(0xFF1565C0),
      icon: Icons.info_rounded,
      iconColor: const Color(0xFF1565C0),
    );
  }

  static void warning(String title, String message) {
    _show(
      title: title,
      message: message,
      background: const Color(0xFFFFF8E1),
      border: const Color(0xFFF9A825),
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFF57F17),
    );
  }

  static String _clean(String raw) {
    var msg = raw.trim();
    if (msg.startsWith('Exception:')) {
      msg = msg.substring('Exception:'.length).trim();
    }
    if (msg.startsWith('DioException')) {
      final idx = msg.indexOf('message:');
      if (idx >= 0) msg = msg.substring(idx + 8).trim();
    }
    return msg.isEmpty ? 'Something went wrong. Please try again.' : msg;
  }

  static void _show({
    required String title,
    required String message,
    required Color background,
    required Color border,
    required IconData icon,
    required Color iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: background,
      colorText: const Color(0xFF1A237E),
      titleText: Text(
        title,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF37474F),
          fontSize: 13.5,
          height: 1.35,
        ),
      ),
      icon: Icon(icon, color: iconColor, size: 28),
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 12,
      borderColor: border,
      borderWidth: 1,
      duration: duration,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
