import 'dart:convert';
import 'dart:developer' as developer;

import '../export/curl_builder.dart';
import '../model/network_log_entry.dart';
import 'console_palette.dart';

/// Receives a finished console message.
typedef ConsoleSink = void Function(String message);

void _developerSink(String message) => developer.log(message, name: 'network');

/// Console output for captured calls.
///
/// A call that succeeds is a single line: it went out, it came back, how long
/// it took and how big it was. A call that fails is expanded with the headers,
/// both bodies and a ready to run cURL command, because that is the only case
/// where the detail is worth the scrollback.
class NetworkLogPrinter {
  const NetworkLogPrinter({
    this.useColors = true,
    this.maxBodyLines = 40,
    this.includeCurlOnError = true,
    this.width = 72,
    this.sink = _developerSink,
  });

  /// Emits ANSI escape codes. Turn it off for a console that shows them raw.
  final bool useColors;

  /// Longest body block printed in an expanded error before it is cut.
  final int maxBodyLines;

  final bool includeCurlOnError;

  /// Character width of the error block frame.
  final int width;

  final ConsoleSink sink;

  ConsolePalette get _palette => ConsolePalette(enabled: useColors);

  /// One line saying the call left the app.
  void started(NetworkLogEntry entry) {
    final palette = _palette;
    sink(
      '${palette.dim('→')} '
      '${palette.method(entry.method.toUpperCase().padRight(6), entry.method)} '
      '${_target(entry)}',
    );
  }

  /// One line for a success, an expanded block for a failure.
  void completed(NetworkLogEntry entry) {
    if (entry.hasError) {
      _printFailure(entry);
    } else {
      _printSuccess(entry);
    }
  }

  void _printSuccess(NetworkLogEntry entry) {
    final palette = _palette;
    sink(
      '${palette.dim('←')} '
      '${palette.status(entry.statusLabel.padRight(4), entry.statusCode)} '
      '${palette.method(entry.method.toUpperCase().padRight(6), entry.method)} '
      '${_target(entry)} '
      '${palette.dim('· ${entry.elapsedLabel} · ${entry.sizeLabel}')}',
    );
  }

  void _printFailure(NetworkLogEntry entry) {
    final palette = _palette;
    final lines = <String>[
      '${palette.red('✖')} '
          '${palette.status(entry.statusLabel, entry.statusCode)} '
          '${entry.method.toUpperCase()} ${entry.url}',
      _field('elapsed', entry.elapsedLabel),
      if (entry.errorType != null) _field('type', entry.errorType!),
      if (entry.errorMessage != null) _field('message', entry.errorMessage!),
    ];

    final blocks = <String, String?>{
      'request headers': _headers(entry.requestHeaders),
      'request body': _body(entry.requestBody),
      'response headers': _headers(entry.responseHeaders),
      'response body': _body(entry.responseBody),
      if (includeCurlOnError) 'curl': CurlBuilder.build(entry),
    };

    // Sections are indented with spaces rather than a box prefix, so the
    // bodies and the cURL command stay copy-paste clean from a terminal.
    final buffer = StringBuffer()
      ..writeln(palette.red(_frame('┌─ ERROR ')))
      ..writeAll(lines.map((line) => '$line\n'));

    blocks.forEach((title, content) {
      if (content == null) return;
      buffer
        ..writeln(palette.red('── ') + palette.bold(title))
        ..writeAll(_truncate(content).map((line) => '  $line\n'));
    });

    buffer.write(palette.red(_frame('└─')));
    sink(buffer.toString());
  }

  /// Path and query, which is what identifies a call while scanning the log.
  String _target(NetworkLogEntry entry) {
    final query = entry.uri.query;
    final path = entry.uri.path.isEmpty ? '/' : entry.uri.path;
    return query.isEmpty ? path : '$path?$query';
  }

  String _field(String label, String value) => '${label.padRight(8)}: $value';

  String _frame(String prefix) {
    final filler = width - prefix.length;
    return filler > 0 ? prefix + ('─' * filler) : prefix;
  }

  String? _headers(Map<String, String> headers) {
    if (headers.isEmpty) return null;
    return headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  String? _body(Object? body) {
    if (body == null) return null;
    if (body is String) return body.isEmpty ? null : body;
    try {
      return const JsonEncoder.withIndent('  ').convert(body);
    } on JsonUnsupportedObjectError {
      return body.toString();
    }
  }

  /// Cuts a block at [maxBodyLines] and says how much was dropped.
  List<String> _truncate(String content) {
    final lines = content.split('\n');
    if (lines.length <= maxBodyLines) return lines;
    return [
      ...lines.take(maxBodyLines),
      _palette.dim('… ${lines.length - maxBodyLines} more lines'),
    ];
  }
}
