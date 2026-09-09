import 'package:flutter/material.dart';

import '../../../model/network_log_entry.dart';
import '../../detail/page/log_detail_page.dart';
import '../controller/logs_controller.dart';
import 'log_tile.dart';
import 'logs_empty_state.dart';

/// Renders the filtered calls and updates while new ones arrive.
class LogsList extends StatelessWidget {
  const LogsList({super.key, required this.controller});

  final LogsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<NetworkLogEntry>>(
      valueListenable: controller.visibleEntries,
      builder: (_, entries, __) {
        if (entries.isEmpty) {
          return LogsEmptyState(filtered: controller.filter.value.isActive);
        }
        return ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return LogTile(
              entry: entry,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LogDetailPage(
                    entryId: entry.id,
                    store: controller.store,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
