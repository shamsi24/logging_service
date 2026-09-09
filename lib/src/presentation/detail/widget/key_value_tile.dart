import 'package:flutter/material.dart';

import 'copy_value_button.dart';

/// Label and value row with a copy action.
class KeyValueTile extends StatelessWidget {
  const KeyValueTile({
    super.key,
    required this.label,
    required this.value,
    this.copyable = true,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: SelectableText(value),
      trailing: copyable ? CopyValueButton(value: value, label: label) : null,
    );
  }
}
