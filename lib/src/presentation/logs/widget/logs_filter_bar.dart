import 'package:flutter/material.dart';

import '../controller/logs_controller.dart';
import 'logs_method_filter.dart';
import 'logs_status_filter.dart';

/// Composes the filter inputs into a single horizontally scrollable row.
class LogsFilterBar extends StatelessWidget {
  const LogsFilterBar({super.key, required this.controller});

  final LogsController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          LogsStatusFilter(controller: controller),
          const SizedBox(width: 12),
          const SizedBox(height: 20, child: VerticalDivider(width: 1)),
          const SizedBox(width: 12),
          LogsMethodFilter(controller: controller),
        ],
      ),
    );
  }
}
