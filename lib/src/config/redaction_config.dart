import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Masking rules applied to every captured call.
///
/// Redaction runs at capture time, so a secret never reaches the store, the
/// console output, the detail screen or a generated cURL command.
@immutable
class RedactionConfig {
  const RedactionConfig({
    this.enabled = true,
    this.headerKeys = defaultHeaderKeys,
    this.bodyKeys = defaultBodyKeys,
    this.queryParameters = defaultQueryParameters,
    this.mask = '••• REDACTED •••',
  });

  /// Keeps every value untouched. Use it only on throwaway environments.
  const RedactionConfig.disabled()
      : enabled = false,
        headerKeys = const <String>{},
        bodyKeys = const <String>{},
        queryParameters = const <String>{},
        mask = '';

  static const Set<String> defaultHeaderKeys = <String>{
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-auth-token',
    'x-access-token',
    'x-csrf-token',
    'x-session-id',
  };

  static const Set<String> defaultBodyKeys = <String>{
    'password',
    'new_password',
    'old_password',
    'confirm_password',
    'pin',
    'otp',
    'secret',
    'client_secret',
    'token',
    'access_token',
    'refresh_token',
    'id_token',
    'api_key',
    'apikey',
    'authorization',
    'card_number',
    'pan',
    'cvv',
    'cvc',
  };

  static const Set<String> defaultQueryParameters = <String>{
    'token',
    'access_token',
    'refresh_token',
    'api_key',
    'apikey',
    'password',
    'secret',
    'signature',
  };

  final bool enabled;

  /// Header names to mask, compared case insensitively.
  final Set<String> headerKeys;

  /// JSON keys to mask anywhere in a request or response body.
  final Set<String> bodyKeys;

  /// Query parameter names to mask in the logged URL.
  final Set<String> queryParameters;

  final String mask;

  /// Returns a copy with [headerKeys], [bodyKeys] and [queryParameters] added
  /// on top of the defaults instead of replacing them.
  RedactionConfig extend({
    Set<String> headerKeys = const <String>{},
    Set<String> bodyKeys = const <String>{},
    Set<String> queryParameters = const <String>{},
  }) {
    return RedactionConfig(
      enabled: enabled,
      headerKeys: <String>{...this.headerKeys, ...headerKeys},
      bodyKeys: <String>{...this.bodyKeys, ...bodyKeys},
      queryParameters: <String>{...this.queryParameters, ...queryParameters},
      mask: mask,
    );
  }

  Map<String, String> redactHeaders(Map<String, String> headers) {
    if (!enabled || headers.isEmpty) return headers;
    return headers.map(
      (key, value) => MapEntry(
        key,
        headerKeys.contains(key.toLowerCase()) ? mask : value,
      ),
    );
  }

  Uri redactUri(Uri uri) {
    if (!enabled || uri.queryParameters.isEmpty) return uri;
    final hits = uri.queryParameters.keys
        .where((key) => queryParameters.contains(key.toLowerCase()));
    if (hits.isEmpty) return uri;
    return uri.replace(
      queryParameters: uri.queryParameters.map(
        (key, value) => MapEntry(
          key,
          queryParameters.contains(key.toLowerCase()) ? mask : value,
        ),
      ),
    );
  }

  /// Walks maps and lists recursively and masks every matching key.
  ///
  /// A [String] body is decoded as JSON first so that a serialized payload is
  /// redacted too; it is returned untouched when it is not valid JSON.
  Object? redactBody(Object? body) {
    if (!enabled || body == null) return body;
    if (body is Map) return _redactMap(body);
    if (body is List) return body.map(redactBody).toList();
    if (body is String) return _redactJsonString(body);
    return body;
  }

  Map<String, dynamic> _redactMap(Map<dynamic, dynamic> source) {
    final result = <String, dynamic>{};
    source.forEach((key, value) {
      final name = key.toString();
      result[name] =
          bodyKeys.contains(name.toLowerCase()) ? mask : redactBody(value);
    });
    return result;
  }

  Object? _redactJsonString(String source) {
    final trimmed = source.trim();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return source;
    try {
      final decoded = jsonDecode(trimmed);
      final redacted = redactBody(decoded);
      return jsonEncode(redacted);
    } on FormatException {
      return source;
    }
  }
}
