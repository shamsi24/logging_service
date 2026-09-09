import 'package:flutter/foundation.dart';

/// Sections of the detail screen.
enum LogDetailTab {
  request,
  response;

  String get label => switch (this) {
        LogDetailTab.request => 'REQUEST',
        LogDetailTab.response => 'RESPONSE',
      };
}

/// Holds which section of the detail screen is visible.
class LogDetailController {
  final ValueNotifier<LogDetailTab> _tab =
      ValueNotifier<LogDetailTab>(LogDetailTab.request);

  ValueListenable<LogDetailTab> get tab => _tab;

  void select(LogDetailTab tab) => _tab.value = tab;

  void dispose() => _tab.dispose();
}
