import 'package:flutter/material.dart';

import '../controller/logs_controller.dart';

/// Drops every captured call from the store.
class ClearLogsButton extends StatelessWidget {
  const ClearLogsButton({super.key, required this.controller});

  final LogsController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Clear',
      icon: const Icon(Icons.delete_outline),
      onPressed: controller.clearLogs,
    );
  }
}
