import 'package:flutter/material.dart';

import '../controller/logs_controller.dart';

/// Search input for the call list. The controller owns the value.
class LogsSearchField extends StatelessWidget {
  const LogsSearchField({super.key, required this.controller});

  final LogsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        onChanged: controller.updateQuery,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          isDense: true,
          prefixIcon: Icon(Icons.search),
          hintText: 'Search url, method or status',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
