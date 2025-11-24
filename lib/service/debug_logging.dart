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

  /// Debug print - avtomatik olaraq uzun mətnləri parçalayır
  void _log(String message) {
    debugPrint(message, wrapWidth: 1024);
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
      _log('🐙 REQUEST [${options.method}] => URL: ${options.uri}');
      _log('⏰ TIME: ${DateTime.now()}');
      if (options.headers.isNotEmpty) {
        final filteredHeaders = _filterHeaders(options.headers);
        if (filteredHeaders.isNotEmpty) {
          _log('📋 HEADERS:\n${_prettyPrint(filteredHeaders)}');
        }
      }
      if (options.data != null) {
        _log('📦 BODY:\n${_prettyPrint(options.data)}');
      }
      _log('─' * 80);
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
      _log(
          '🦑 RESPONSE [${response.statusCode}] => ${response.requestOptions.method} ${response.requestOptions.uri}');
      _log('⏰ TIME: ${DateTime.now()}');
      _log('⏱️  ELAPSED TIME: $elapsedMilliseconds ms');
      if (response.headers.map.isNotEmpty) {
        final filteredHeaders = _filterHeaders(response.headers.map);
        if (filteredHeaders.isNotEmpty) {
          _log('📋 HEADERS:\n${_prettyPrint(filteredHeaders)}');
        }
      }
      if (response.data != null) {
        _log('📦 DATA:\n${_prettyPrint(response.data)}');
      }
      _log('─' * 80);
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
      _log(
          '🦀 ERROR [${err.response?.statusCode}] => ${err.requestOptions.method} ${err.requestOptions.path}');
      _log('⏰ TIME: ${DateTime.now()}');
      _log('⏱️  ELAPSED TIME: $elapsedMilliseconds ms');
      _log('❌ ERROR TYPE: ${err.type}');
      _log('💬 MESSAGE: ${err.message}');
      if (err.response?.data != null) {
        _log('📦 ERROR DATA:\n${_prettyPrint(err.response?.data)}');
      }
      _log('─' * 80);
    }
    debug.addError(err);
    return super.onError(err, handler);
  }
}
