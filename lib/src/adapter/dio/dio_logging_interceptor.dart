import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/redaction_config.dart';
import '../../model/network_log_entry.dart';
import '../../store/network_log_store.dart';

/// Dio adapter that feeds [NetworkLogStore] with client agnostic entries.
///
/// Every value is redacted here, before it reaches the store or the console.
class DioLoggingInterceptor extends Interceptor {
  DioLoggingInterceptor({
    NetworkLogStore? store,
    this.redaction = const RedactionConfig(),
    this.printToConsole = true,
    bool? enabled,
  })  : store = store ?? NetworkLogStore.instance,
        enabled = enabled ?? kDebugMode;

  static const String _idKey = 'logging_service.entry_id';

  final NetworkLogStore store;
  final RedactionConfig redaction;

  /// Mirrors every call to the Dart developer log.
  final bool printToConsole;

  /// Defaults to [kDebugMode]. Set it to capture on profile or release builds,
  /// for instance so testers can inspect a staging build.
  final bool enabled;

  /// Headers that carry no diagnostic value and only add console noise.
  static const Set<String> _noisyHeaders = <String>{
    'connection',
    'keep-alive',
    'cache-control',
    'transfer-encoding',
    'content-encoding',
    'content-length',
    'content-type',
    'date',
    'server',
    'vary',
    'accept-encoding',
    'pragma',
    'expires',
    'cf-cache-status',
    'cf-ray',
    'report-to',
    'nel',
    'alt-svc',
    'x-ratelimit-limit',
    'x-ratelimit-remaining',
    'access-control-allow-origin',
    'access-control-allow-methods',
    'access-control-allow-headers',
    'access-control-max-age',
  };

  var _counter = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) return super.onRequest(options, handler);

    final id = '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';
    options.extra[_idKey] = id;

    final entry = NetworkLogEntry(
      id: id,
      method: options.method,
      uri: redaction.redactUri(options.uri),
      startedAt: DateTime.now(),
      requestHeaders: redaction.redactHeaders(_normalize(options.headers)),
      requestBody: redaction.redactBody(_readBody(options.data)),
    );
    store.add(entry);
    _printRequest(entry);

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (!enabled) return super.onResponse(response, handler);

    _complete(
      response.requestOptions,
      (entry) => entry.completeWith(
        completedAt: DateTime.now(),
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        responseHeaders:
            redaction.redactHeaders(_normalizeResponse(response.headers)),
        responseBody: redaction.redactBody(_readBody(response.data)),
        responseSizeInBytes: _sizeOf(response.headers, response.data),
      ),
      _printResponse,
    );

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) return super.onError(err, handler);

    final response = err.response;
    _complete(
      err.requestOptions,
      (entry) => entry.failWith(
        completedAt: DateTime.now(),
        errorType: err.type.name,
        errorMessage: err.message,
        statusCode: response?.statusCode,
        statusMessage: response?.statusMessage,
        responseHeaders: response == null
            ? const <String, String>{}
            : redaction.redactHeaders(_normalizeResponse(response.headers)),
        responseBody: redaction.redactBody(_readBody(response?.data)),
        responseSizeInBytes:
            response == null ? null : _sizeOf(response.headers, response.data),
      ),
      _printError,
    );

    return super.onError(err, handler);
  }

  /// Applies [transform] to the entry that belongs to [options].
  ///
  /// The call is matched by the id stored in [RequestOptions.extra] rather than
  /// by URL, so concurrent calls to the same endpoint never overwrite each
  /// other. Unknown ids are dropped instead of throwing.
  void _complete(
    RequestOptions options,
    NetworkLogEntry Function(NetworkLogEntry entry) transform,
    void Function(NetworkLogEntry entry) print,
  ) {
    final id = options.extra[_idKey];
    if (id is! String) return;
    store.update(id, transform);
    final updated = store.byId(id);
    if (updated != null) print(updated);
  }

  Map<String, String> _normalize(Map<String, dynamic> headers) {
    return headers.map(
      (key, value) => MapEntry(
        key,
        value is Iterable ? value.join(', ') : '$value',
      ),
    );
  }

  Map<String, String> _normalizeResponse(Headers headers) {
    return headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );
  }

  /// Converts a Dio specific payload into a plain Dart value.
  ///
  /// [FormData] is flattened so the detail screen and the cURL export can show
  /// it instead of the previous "not supported yet" placeholder.
  Object? _readBody(Object? data) {
    if (data is FormData) {
      return <String, dynamic>{
        'fields': <String, dynamic>{
          for (final field in data.fields) field.key: field.value,
        },
        'files': <String>[
          for (final file in data.files) file.value.filename ?? file.key,
        ],
      };
    }
    return data;
  }

  int? _sizeOf(Headers headers, Object? data) {
    final declared =
        int.tryParse(headers.value(Headers.contentLengthHeader) ?? '');
    if (declared != null) return declared;
    if (data == null) return null;
    try {
      final encoded = data is String ? data : jsonEncode(data);
      return utf8.encode(encoded).length;
    } on JsonUnsupportedObjectError {
      return null;
    }
  }

  void _printRequest(NetworkLogEntry entry) {
    if (!printToConsole) return;
    _log([
      '🐙 REQUEST [${entry.method}] => ${entry.url}',
      '⏰ TIME: ${entry.startedAt}',
      _headerBlock(entry.requestHeaders),
      if (entry.hasRequestBody) '📦 BODY:\n${_pretty(entry.requestBody)}',
    ]);
  }

  void _printResponse(NetworkLogEntry entry) {
    if (!printToConsole) return;
    _log([
      '🦑 RESPONSE [${entry.statusLabel}] => ${entry.method} ${entry.url}',
      '⏱️  ELAPSED: ${entry.elapsedLabel}   📐 SIZE: ${entry.sizeLabel}',
      _headerBlock(entry.responseHeaders),
      if (entry.hasResponseBody) '📦 DATA:\n${_pretty(entry.responseBody)}',
    ]);
  }

  void _printError(NetworkLogEntry entry) {
    if (!printToConsole) return;
    _log([
      '🦀 ERROR [${entry.statusLabel}] => ${entry.method} ${entry.url}',
      '⏱️  ELAPSED: ${entry.elapsedLabel}',
      '❌ TYPE: ${entry.errorType}',
      if (entry.errorMessage != null) '💬 MESSAGE: ${entry.errorMessage}',
      if (entry.hasResponseBody)
        '📦 ERROR DATA:\n${_pretty(entry.responseBody)}',
    ]);
  }

  String? _headerBlock(Map<String, String> headers) {
    final interesting = <String, String>{
      for (final header in headers.entries)
        if (!_noisyHeaders.contains(header.key.toLowerCase()))
          header.key: header.value,
    };
    if (interesting.isEmpty) return null;
    return '📋 HEADERS:\n${_pretty(interesting)}';
  }

  void _log(List<String?> lines) {
    for (final line in lines) {
      if (line != null) developer.log(line);
    }
    developer.log('─' * 80);
  }

  String _pretty(Object? data) {
    if (data == null) return 'null';
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } on JsonUnsupportedObjectError {
      return data.toString();
    }
  }
}
