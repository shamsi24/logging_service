import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../presentation/logs/page/logs_page.dart';
import '../store/network_log_store.dart';
import 'shake_service.dart';

/// Opens the inspector on a shake gesture, and on demand.
class DebugTool {
  DebugTool({NetworkLogStore? store, bool? enabled})
      : store = store ?? NetworkLogStore.instance,
        enabled = enabled ?? kDebugMode;

  final NetworkLogStore store;

  /// Defaults to [kDebugMode]. Set it to keep the inspector reachable on a
  /// profile or release build handed to testers.
  final bool enabled;

  bool _isOpened = false;
  ShakeService? _shakeService;

  bool get isOpened => _isOpened;

  /// Starts listening for the shake gesture.
  ///
  /// [apiKey] is accepted for backwards compatibility and is ignored.
  void start(BuildContext context, [String? apiKey]) {
    if (!enabled || _shakeService != null) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    _shakeService = ShakeService(onPhoneShake: () => _open(navigator))..start();
  }

  /// Opens the inspector without waiting for a shake.
  void open(BuildContext context) {
    _open(Navigator.of(context, rootNavigator: true));
  }

  void dispose() {
    _shakeService?.stop();
    _shakeService = null;
  }

  void _open(NavigatorState navigator) {
    if (!enabled || _isOpened) return;
    _isOpened = true;
    navigator
        .push(
          MaterialPageRoute<void>(
            builder: (_) => LogsPage(store: store),
          ),
        )
        .whenComplete(() => _isOpened = false);
  }
}
