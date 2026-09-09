import 'package:flutter/material.dart';

import '../../../model/log_filter.dart';
import '../../common/log_visuals.dart';
import '../controller/logs_controller.dart';

/// Multi select chips for the HTTP method filter.
class LogsMethodFilter extends StatelessWidget {
  const LogsMethodFilter({super.key, required this.controller});

  final LogsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LogFilter>(
      valueListenable: controller.filter,
      builder: (_, filter, __) {
        return Wrap(
          spacing: 6,
          children: [
            for (final method in LogFilter.selectableMethods)
              FilterChip(
                label: Text(method),
                selected: filter.methods.contains(method),
                onSelected: (_) => controller.toggleMethod(method),
                labelStyle: TextStyle(
                  color: LogVisuals.method(method),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                visualDensity: VisualDensity.compact,
              ),
          ],
        );
      },
    );
  }
}
