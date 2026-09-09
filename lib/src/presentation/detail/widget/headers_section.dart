import 'package:flutter/material.dart';

import 'key_value_tile.dart';
import 'section_header.dart';

/// Renders a header map, or nothing when it is empty.
class HeadersSection extends StatelessWidget {
  const HeadersSection({
    super.key,
    required this.title,
    required this.headers,
  });

  final String title;
  final Map<String, String> headers;

  @override
  Widget build(BuildContext context) {
    if (headers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        for (final header in headers.entries)
          KeyValueTile(label: header.key, value: header.value),
      ],
    );
  }
}
