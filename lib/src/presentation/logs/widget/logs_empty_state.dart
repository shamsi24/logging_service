import 'package:flutter/material.dart';

/// Shown when nothing is captured yet or when the filters exclude everything.
class LogsEmptyState extends StatelessWidget {
  const LogsEmptyState({super.key, required this.filtered});

  /// Whether the list is empty because of an active filter.
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered ? Icons.filter_alt_off : Icons.wifi_tethering,
              size: 48,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 12),
            Text(
              filtered ? 'No call matches the filters' : 'No call captured yet',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
