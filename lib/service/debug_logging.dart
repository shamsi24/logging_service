import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging_service/storage/debug_storage.dart';

class DebugLogging extends Interceptor {
  final debug = DebugStorage();
  final Stopwatch stopwatch = Stopwatch();

  /// Standart headerlərin siyahısı - bunlar print olunmayacaq
  static const _standardHeaders = {
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

  /// Pretty print JSON data
  String _prettyPrint(dynamic data) {
    if (data == null) return 'null';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Print uzun mətnləri hissə-hissə (Flutter console limiti ucun)
  void _printLongText(String text, {String prefix = ''}) {
    const int chunkSize = 800; // Flutter console limiti
    final int length = text.length;

    if (length <= chunkSize) {
      print('$prefix$text');
      return;
    }

    for (int i = 0; i < length; i += chunkSize) {
      final int end = (i + chunkSize < length) ? i + chunkSize : length;
      print('$prefix${text.substring(i, end)}');
    }
  }

  /// Standart headerləri filtreləyir, yalnız custom headerləri qaytarır
  Map<String, dynamic> _filterHeaders(Map<String, dynamic> headers) {
    final filtered = <String, dynamic>{};
    headers.forEach((key, value) {
      if (!_standardHeaders.contains(key.toLowerCase())) {
        filtered[key] = value;
      }
    });
    return filtered;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    stopwatch.start();
    if (kDebugMode) {
      print('🐙 REQUEST [${options.method}] => URL: ${options.uri}');
      print('⏰ TIME: ${DateTime.now()}');
      if (options.headers.isNotEmpty) {
        final filteredHeaders = _filterHeaders(options.headers);
        if (filteredHeaders.isNotEmpty) {
          _printLongText(_prettyPrint(filteredHeaders),
              prefix: '📋 HEADERS:\n');
        }
      }
      if (options.data != null) {
        _printLongText(_prettyPrint(options.data), prefix: '📦 BODY:\n');
      }
      print('─' * 80);
    }
    debug.addRequest(options);
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    stopwatch.stop();
    final elapsedMilliseconds = stopwatch.elapsedMilliseconds;
    stopwatch.reset();

    if (kDebugMode) {
      print(
          '🦑 RESPONSE [${response.statusCode}] => ${response.requestOptions.method} ${response.requestOptions.uri}');
      print('⏰ TIME: ${DateTime.now()}');
      print('⏱️  ELAPSED TIME: $elapsedMilliseconds ms');
      if (response.headers.map.isNotEmpty) {
        final filteredHeaders = _filterHeaders(response.headers.map);
        if (filteredHeaders.isNotEmpty) {
          _printLongText(_prettyPrint(filteredHeaders),
              prefix: '📋 HEADERS:\n');
        }
      }
      if (response.data != null) {
        _printLongText(_prettyPrint(response.data), prefix: '📦 DATA:\n');
      }
      print('─' * 80);
    }
    debug.addResponse(response);
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    stopwatch.stop();
    final elapsedMilliseconds = stopwatch.elapsedMilliseconds;
    stopwatch.reset();

    if (kDebugMode) {
      print(
          '🦀 ERROR [${err.response?.statusCode}] => ${err.requestOptions.method} ${err.requestOptions.path}');
      print('⏰ TIME: ${DateTime.now()}');
      print('⏱️  ELAPSED TIME: $elapsedMilliseconds ms');
      print('❌ ERROR TYPE: ${err.type}');
      print('💬 MESSAGE: ${err.message}');
      if (err.response?.data != null) {
        _printLongText(_prettyPrint(err.response?.data),
            prefix: '📦 ERROR DATA:\n');
      }
      print('─' * 80);
    }
    debug.addError(err);
    return super.onError(err, handler);
  }
}
