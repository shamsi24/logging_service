import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';

import 'copy_value_button.dart';
import 'section_header.dart';

/// Shows a decoded body as a JSON tree, or as plain text when it is not JSON.
class JsonBodyView extends StatelessWidget {
  const JsonBodyView({super.key, required this.title, required this.body});

  final String title;
  final Object? body;

  @override
  Widget build(BuildContext context) {
    if (body == null) return const SizedBox.shrink();
    final isStructured = body is Map || body is List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: SectionHeader(title: title)),
            CopyValueButton(value: body.toString(), label: title),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isStructured
              ? JsonView(json: body, shrinkWrap: true)
              : SelectableText(body.toString()),
        ),
      ],
    );
  }
}
