import 'package:flutter/material.dart';

import '../../../model/network_log_entry.dart';
import '../../../store/network_log_store.dart';
import '../body/log_detail_body.dart';
import '../controller/log_detail_controller.dart';

/// Entry point of the detail screen. Wires the controller and the store.
///
/// The entry is resolved by id on every store change, so a call that is still
/// in flight when the screen opens fills in as soon as it completes.
class LogDetailPage extends StatefulWidget {
  const LogDetailPage({super.key, required this.entryId, this.store});

  final String entryId;

  /// Defaults to [NetworkLogStore.instance].
  final NetworkLogStore? store;

  @override
  State<LogDetailPage> createState() => _LogDetailPageState();
}

class _LogDetailPageState extends State<LogDetailPage> {
  late final NetworkLogStore _store = widget.store ?? NetworkLogStore.instance;
  final LogDetailController _controller = LogDetailController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<NetworkLogEntry>>(
      valueListenable: _store.listenable,
      builder: (_, __, ___) {
        final entry = _store.byId(widget.entryId);
        if (entry == null) {
          return const Scaffold(
            body: Center(child: Text('This call is no longer available')),
          );
        }
        return LogDetailBody(entry: entry, controller: _controller);
      },
    );
  }
}
