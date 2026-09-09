import 'package:flutter/material.dart';

import '../../../model/network_log_entry.dart';
import '../widget/headers_section.dart';
import '../widget/json_body_view.dart';
import '../widget/key_value_tile.dart';
import '../widget/section_header.dart';

/// Request section of the detail screen.
class LogDetailRequestView extends StatelessWidget {
  const LogDetailRequestView({super.key, required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionHeader(title: 'Request'),
        KeyValueTile(label: 'URL', value: entry.url),
        KeyValueTile(label: 'Method', value: entry.method, copyable: false),
        KeyValueTile(
          label: 'Started at',
          value: entry.startedAt.toIso8601String(),
          copyable: false,
        ),
        JsonBodyView(title: 'Body', body: entry.requestBody),
        HeadersSection(
          title: 'Request headers',
          headers: entry.requestHeaders,
        ),
      ],
    );
  }
}
