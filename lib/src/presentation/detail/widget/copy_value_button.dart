import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copies a single value to the clipboard and confirms it.
class CopyValueButton extends StatelessWidget {
  const CopyValueButton({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy, size: 18),
      tooltip: 'Copy $label',
      onPressed: () => _copy(ScaffoldMessenger.of(context)),
    );
  }

  Future<void> _copy(ScaffoldMessengerState messenger) async {
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }
}
