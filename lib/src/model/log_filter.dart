import 'package:flutter/foundation.dart';

import 'network_log_entry.dart';

/// Outcome filter applied on top of the search query.
enum LogStatusFilter {
  all,
  success,
  failure;

  String get label => switch (this) {
        LogStatusFilter.all => 'All',
        LogStatusFilter.success => 'Success',
        LogStatusFilter.failure => 'Error',
      };
}

/// Search and filter criteria for the call list.
@immutable
class LogFilter {
  const LogFilter({
    this.query = '',
    this.methods = const <String>{},
    this.status = LogStatusFilter.all,
  });

  /// Free text matched against the URL, the HTTP method and the status code.
  final String query;

  /// Selected HTTP methods, upper case. Empty means every method.
  final Set<String> methods;

  final LogStatusFilter status;

  /// Methods offered by the filter bar.
  static const List<String> selectableMethods = <String>[
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
  ];

  bool get isActive =>
      query.trim().isNotEmpty ||
      methods.isNotEmpty ||
      status != LogStatusFilter.all;

  LogFilter copyWith({
    String? query,
    Set<String>? methods,
    LogStatusFilter? status,
  }) {
    return LogFilter(
      query: query ?? this.query,
      methods: methods ?? this.methods,
      status: status ?? this.status,
    );
  }

  LogFilter toggleMethod(String method) {
    final next = Set<String>.of(methods);
    if (!next.remove(method)) next.add(method);
    return copyWith(methods: next);
  }

  bool matches(NetworkLogEntry entry) {
    if (methods.isNotEmpty && !methods.contains(entry.method.toUpperCase())) {
      return false;
    }
    switch (status) {
      case LogStatusFilter.success:
        if (entry.state != NetworkLogState.success) return false;
      case LogStatusFilter.failure:
        if (entry.state != NetworkLogState.failure) return false;
      case LogStatusFilter.all:
        break;
    }
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return entry.url.toLowerCase().contains(needle) ||
        entry.method.toLowerCase().contains(needle) ||
        entry.statusLabel.contains(needle);
  }

  List<NetworkLogEntry> apply(List<NetworkLogEntry> entries) {
    if (!isActive) return entries;
    return entries.where(matches).toList(growable: false);
  }
}
