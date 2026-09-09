import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../export/curl_builder.dart';
import '../../../model/network_log_entry.dart';

/// Copies the call as a runnable cURL command.
class CopyCurlButton extends StatelessWidget {
  const CopyCurlButton({super.key, required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.terminal),
      tooltip: 'Copy as cURL',
      onPressed: () => _copy(ScaffoldMessenger.of(context)),
    );
  }

  Future<void> _copy(ScaffoldMessengerState messenger) async {
    await Clipboard.setData(ClipboardData(text: CurlBuilder.build(entry)));
    messenger.showSnackBar(
      const SnackBar(content: Text('cURL command copied to clipboard')),
    );
  }
}
