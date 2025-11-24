import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging_service/storage/debug_storage.dart';

class DebugLogging extends Interceptor {
  final debug = DebugStorage();
  final Stopwatch stopwatch = Stopwatch();

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

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    stopwatch.start();
    if (kDebugMode) {
      print('🐙 REQUEST [${options.method}] => URL: ${options.uri}');
      print('⏰ TIME: ${DateTime.now()}');
      if (options.headers.isNotEmpty) {
        print('📋 HEADERS:\n${_prettyPrint(options.headers)}');
      }
      if (options.data != null) {
        print('📦 BODY:\n${_prettyPrint(options.data)}');
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
        print('📋 HEADERS:\n${_prettyPrint(response.headers.map)}');
      }
      if (response.data != null) {
        print('📦 DATA:\n${_prettyPrint(response.data)}');
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
        print('📦 ERROR DATA:\n${_prettyPrint(err.response?.data)}');
      }
      print('─' * 80);
    }
    debug.addError(err);
    return super.onError(err, handler);
  }
}
