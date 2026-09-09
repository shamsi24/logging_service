import 'package:flutter/material.dart';

import '../../model/network_log_entry.dart';

/// Colors shared by the list and the detail screen.
class LogVisuals {
  const LogVisuals._();

  static Color method(String method) {
    return switch (method.toUpperCase()) {
      'GET' => const Color(0xFF2E7D32),
      'POST' => const Color(0xFFEF6C00),
      'PUT' => const Color(0xFF1565C0),
      'PATCH' => const Color(0xFF6A1B9A),
      'DELETE' => const Color(0xFFC62828),
      _ => const Color(0xFF455A64),
    };
  }

  static Color state(NetworkLogState state) {
    return switch (state) {
      NetworkLogState.success => const Color(0xFF2E7D32),
      NetworkLogState.failure => const Color(0xFFC62828),
      NetworkLogState.inProgress => const Color(0xFF9E9E9E),
    };
  }
}
