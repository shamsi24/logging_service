import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../store/network_log_store.dart';
import '../body/logs_body.dart';
import '../controller/logs_controller.dart';

/// Entry point of the inspector. Wires the controller and nothing else.
class LogsPage extends StatefulWidget {
  const LogsPage({super.key, this.store});

  /// Defaults to [NetworkLogStore.instance].
  final NetworkLogStore? store;

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late final LogsController _controller = LogsController(store: widget.store);

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LogsBody(controller: _controller);
}
