import 'package:flutter/material.dart';

import '../../../model/log_filter.dart';
import '../controller/logs_controller.dart';

/// Single select chips for the outcome filter.
class LogsStatusFilter extends StatelessWidget {
  const LogsStatusFilter({super.key, required this.controller});

  final LogsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LogFilter>(
      valueListenable: controller.filter,
      builder: (_, filter, __) {
        return Wrap(
          spacing: 6,
          children: [
            for (final status in LogStatusFilter.values)
              ChoiceChip(
                label: Text(status.label),
                selected: filter.status == status,
                onSelected: (_) => controller.selectStatus(status),
                labelStyle: const TextStyle(fontSize: 12),
                visualDensity: VisualDensity.compact,
              ),
          ],
        );
      },
    );
  }
}
