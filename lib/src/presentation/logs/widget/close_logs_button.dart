import 'package:flutter/material.dart';

/// Leaves the inspector.
class CloseLogsButton extends StatelessWidget {
  const CloseLogsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Close',
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
