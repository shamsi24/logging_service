import 'dart:convert';

import '../model/network_log_entry.dart';

/// Renders a captured call as a runnable cURL command.
///
/// Values are already redacted by the adapter, so a shared command never
/// carries a real credential.
class CurlBuilder {
  const CurlBuilder._();

  static String build(NetworkLogEntry entry) {
    final parts = <String>[
      'curl -X ${entry.method.toUpperCase()}',
      "  '${_escape(entry.url)}'",
    ];

    for (final header in entry.requestHeaders.entries) {
      parts.add("  -H '${_escape('${header.key}: ${header.value}')}'");
    }

    final body = _bodyAsString(entry.requestBody);
    if (body != null && body.isNotEmpty) {
      parts.add("  --data '${_escape(body)}'");
    }

    return parts.join(' \\\n');
  }

  static String? _bodyAsString(Object? body) {
    if (body == null) return null;
    if (body is String) return body;
    try {
      return jsonEncode(body);
    } on JsonUnsupportedObjectError {
      return body.toString();
    }
  }

  /// Terminates the single quoted section, inserts an escaped quote and
  /// reopens it, which is the only safe way to quote for POSIX shells.
  static String _escape(String value) => value.replaceAll("'", r"'\''");
}
