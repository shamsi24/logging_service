import 'package:flutter/material.dart';

import '../../../model/network_log_entry.dart';
import '../../common/log_visuals.dart';

/// Colored badge for the response status code.
class StatusCodeChip extends StatelessWidget {
  const StatusCodeChip({super.key, required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = LogVisuals.state(entry.state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        entry.isInProgress ? 'IN PROGRESS' : entry.statusLabel,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
