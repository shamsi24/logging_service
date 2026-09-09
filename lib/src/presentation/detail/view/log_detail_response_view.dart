import 'package:flutter/material.dart';

import '../../../model/network_log_entry.dart';
import '../widget/headers_section.dart';
import '../widget/json_body_view.dart';
import '../widget/key_value_tile.dart';
import '../widget/section_header.dart';
import '../widget/status_code_chip.dart';

/// Response section of the detail screen, including the failure details.
class LogDetailResponseView extends StatelessWidget {
  const LogDetailResponseView({super.key, required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionHeader(title: 'Result'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: StatusCodeChip(entry: entry),
          ),
        ),
        if (entry.statusMessage != null && entry.statusMessage!.isNotEmpty)
          KeyValueTile(
            label: 'Status message',
            value: entry.statusMessage!,
            copyable: false,
          ),
        KeyValueTile(
          label: 'Elapsed',
          value: entry.elapsedLabel,
          copyable: false,
        ),
        KeyValueTile(label: 'Size', value: entry.sizeLabel, copyable: false),
        if (entry.errorType != null) ...[
          const SectionHeader(title: 'Error'),
          KeyValueTile(
            label: 'Type',
            value: entry.errorType!,
            copyable: false,
          ),
          if (entry.errorMessage != null)
            KeyValueTile(label: 'Message', value: entry.errorMessage!),
        ],
        JsonBodyView(title: 'Body', body: entry.responseBody),
        HeadersSection(
          title: 'Response headers',
          headers: entry.responseHeaders,
        ),
      ],
    );
  }
}
