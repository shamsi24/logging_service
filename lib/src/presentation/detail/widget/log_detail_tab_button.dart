import 'package:flutter/material.dart';

import '../controller/log_detail_controller.dart';

/// One section switch of the detail footer.
class LogDetailTabButton extends StatelessWidget {
  const LogDetailTabButton({
    super.key,
    required this.controller,
    required this.tab,
    required this.label,
  });

  final LogDetailController controller;
  final LogDetailTab tab;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LogDetailTab>(
      valueListenable: controller.tab,
      builder: (context, selected, __) {
        final isSelected = selected == tab;
        return TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          onPressed: () => controller.select(tab),
          child: Text(label),
        );
      },
    );
  }
}
