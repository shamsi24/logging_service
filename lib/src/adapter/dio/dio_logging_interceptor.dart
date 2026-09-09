import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/redaction_config.dart';
import '../../console/network_log_printer.dart';
import '../../model/network_log_entry.dart';
import '../../store/network_log_store.dart';

/// Dio adapter that feeds [NetworkLogStore] with client agnostic entries.
///
/// Every value is redacted here, before it reaches the store or the console.
class DioLoggingInterceptor extends Interceptor {
  DioLoggingInterceptor({
    NetworkLogStore? store,
    this.redaction = const RedactionConfig(),
    this.printer = const NetworkLogPrinter(),
    bool? enabled,
  })  : store = store ?? NetworkLogStore.instance,
        enabled = enabled ?? kDebugMode;

  static const String _idKey = 'logging_service.entry_id';

  final NetworkLogStore store;
  final RedactionConfig redaction;

  /// Console output. Pass `null` to capture silently.
  final NetworkLogPrinter? printer;

  /// Defaults to [kDebugMode]. Set it to capture on profile or release builds,
  /// for instance so testers can inspect a staging build.
  final bool enabled;

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
    printer?.started(entry);

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
  ) {
    final id = options.extra[_idKey];
    if (id is! String) return;
    store.update(id, transform);
    final updated = store.byId(id);
    if (updated != null) printer?.completed(updated);
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
}
