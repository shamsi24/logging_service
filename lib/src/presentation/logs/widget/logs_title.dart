import 'package:flutter/material.dart';

import '../../../model/network_log_entry.dart';
import '../controller/logs_controller.dart';

/// App bar title with the number of calls currently visible.
class LogsTitle extends StatelessWidget {
  const LogsTitle({super.key, required this.controller});

  final LogsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<NetworkLogEntry>>(
      valueListenable: controller.visibleEntries,
      builder: (_, entries, __) {
        return Text(
          'Network calls (${entries.length})',
          style: const TextStyle(fontSize: 18),
        );
      },
    );
  }
}
