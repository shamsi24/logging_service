import 'package:flutter/foundation.dart';

import '../model/network_log_entry.dart';

/// In-memory ring buffer of captured calls.
///
/// The store is the single source of truth for every adapter and for the UI.
/// It exposes a [ValueListenable] so open screens update while calls arrive.
class NetworkLogStore {
  NetworkLogStore({int maxEntries = 200}) : _maxEntries = maxEntries;

  /// Default store used by the adapters and by [DebugTool].
  static final NetworkLogStore instance = NetworkLogStore();

  final int _maxEntries;

  final ValueNotifier<List<NetworkLogEntry>> _entries =
      ValueNotifier<List<NetworkLogEntry>>(const <NetworkLogEntry>[]);

  /// Newest call first.
  ValueListenable<List<NetworkLogEntry>> get listenable => _entries;

  List<NetworkLogEntry> get entries => _entries.value;

  int get maxEntries => _maxEntries;

  void add(NetworkLogEntry entry) {
    final next = <NetworkLogEntry>[entry, ..._entriesWithoutOverflow()];
    _entries.value = next;
  }

  /// Replaces the entry with [id] by the result of [transform].
  ///
  /// A missing id is ignored: a response can arrive for a request that was
  /// never captured, for instance when an earlier interceptor rejected it.
  void update(
    String id,
    NetworkLogEntry Function(NetworkLogEntry entry) transform,
  ) {
    final current = _entries.value;
    final index = current.indexWhere((entry) => entry.id == id);
    if (index == -1) return;
    final next = List<NetworkLogEntry>.of(current);
    next[index] = transform(current[index]);
    _entries.value = next;
  }

  NetworkLogEntry? byId(String id) {
    for (final entry in _entries.value) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  void clear() {
    _entries.value = const <NetworkLogEntry>[];
  }

  List<NetworkLogEntry> _entriesWithoutOverflow() {
    final current = _entries.value;
    if (current.length < _maxEntries) return current;
    return current.sublist(0, _maxEntries - 1);
  }
}
