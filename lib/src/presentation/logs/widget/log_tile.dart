import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/network_log_entry.dart';
import '../../common/log_visuals.dart';

/// One row of the call list.
class LogTile extends StatelessWidget {
  const LogTile({super.key, required this.entry, required this.onTap});

  final NetworkLogEntry entry;
  final VoidCallback onTap;

  static final DateFormat _time = DateFormat('HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateColor = LogVisuals.state(entry.state);

    return ListTile(
      onTap: onTap,
      leading: Container(
        height: 30,
        width: 54,
        decoration: BoxDecoration(
          color: LogVisuals.method(entry.method),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          entry.method.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(
        entry.path,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_time.format(entry.startedAt)}  ·  ${entry.elapsedLabel}  ·  ${entry.sizeLabel}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: stateColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          entry.isInProgress ? '···' : entry.statusLabel,
          style: TextStyle(
            color: stateColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
