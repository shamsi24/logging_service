import 'package:flutter/foundation.dart';

import '../../../model/log_filter.dart';
import '../../../model/network_log_entry.dart';
import '../../../store/network_log_store.dart';

/// Holds the UI state of the call list: the search query and the filters.
///
/// It performs no I/O; it only derives the visible entries from the store and
/// the current [LogFilter].
class LogsController {
  LogsController({NetworkLogStore? store})
      : store = store ?? NetworkLogStore.instance {
    _visibleEntries = ValueNotifier<List<NetworkLogEntry>>(
      _filter.value.apply(this.store.entries),
    );
    this.store.listenable.addListener(_recompute);
    _filter.addListener(_recompute);
  }

  final NetworkLogStore store;

  final ValueNotifier<LogFilter> _filter =
      ValueNotifier<LogFilter>(const LogFilter());

  late final ValueNotifier<List<NetworkLogEntry>> _visibleEntries;

  ValueListenable<LogFilter> get filter => _filter;

  ValueListenable<List<NetworkLogEntry>> get visibleEntries => _visibleEntries;

  ValueListenable<List<NetworkLogEntry>> get allEntries => store.listenable;

  void updateQuery(String query) {
    _filter.value = _filter.value.copyWith(query: query);
  }

  void toggleMethod(String method) {
    _filter.value = _filter.value.toggleMethod(method);
  }

  void selectStatus(LogStatusFilter status) {
    _filter.value = _filter.value.copyWith(status: status);
  }

  void resetFilter() {
    _filter.value = const LogFilter();
  }

  void clearLogs() {
    store.clear();
  }

  void dispose() {
    store.listenable.removeListener(_recompute);
    _filter.removeListener(_recompute);
    _visibleEntries.dispose();
    _filter.dispose();
  }

  void _recompute() {
    _visibleEntries.value = _filter.value.apply(store.entries);
  }
}
