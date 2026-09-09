import 'package:flutter/foundation.dart';

/// Lifecycle state of a captured call.
enum NetworkLogState {
  inProgress,
  success,
  failure,
}

/// A single captured HTTP call.
///
/// The model is client agnostic: it references neither Dio nor any other HTTP
/// package, so adapters for other clients can reuse it as is.
@immutable
class NetworkLogEntry {
  const NetworkLogEntry({
    required this.id,
    required this.method,
    required this.uri,
    required this.startedAt,
    this.requestHeaders = const <String, String>{},
    this.requestBody,
    this.completedAt,
    this.statusCode,
    this.statusMessage,
    this.responseHeaders = const <String, String>{},
    this.responseBody,
    this.responseSizeInBytes,
    this.errorType,
    this.errorMessage,
  });

  /// Unique id of the call, used to pair a response back to its request.
  final String id;

  final String method;
  final Uri uri;
  final DateTime startedAt;

  final Map<String, String> requestHeaders;
  final Object? requestBody;

  final DateTime? completedAt;
  final int? statusCode;
  final String? statusMessage;
  final Map<String, String> responseHeaders;
  final Object? responseBody;
  final int? responseSizeInBytes;

  final String? errorType;
  final String? errorMessage;

  NetworkLogState get state {
    if (errorType != null || errorMessage != null) {
      return NetworkLogState.failure;
    }
    if (completedAt == null) {
      return NetworkLogState.inProgress;
    }
    final code = statusCode;
    if (code == null || code >= 400) {
      return NetworkLogState.failure;
    }
    return NetworkLogState.success;
  }

  bool get hasError => state == NetworkLogState.failure;

  bool get isInProgress => state == NetworkLogState.inProgress;

  Duration? get duration => completedAt?.difference(startedAt);

  int? get elapsedMilliseconds => duration?.inMilliseconds;

  String get elapsedLabel {
    final elapsed = elapsedMilliseconds;
    return elapsed == null ? '—' : '$elapsed ms';
  }

  String get url => uri.toString();

  String get path => uri.path.isEmpty ? '/' : uri.path;

  String get statusLabel => statusCode?.toString() ?? '—';

  bool get hasRequestBody => requestBody != null;

  bool get hasResponseBody => responseBody != null;

  String get sizeLabel {
    final bytes = responseSizeInBytes;
    if (bytes == null) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  NetworkLogEntry completeWith({
    required DateTime completedAt,
    int? statusCode,
    String? statusMessage,
    Map<String, String> responseHeaders = const <String, String>{},
    Object? responseBody,
    int? responseSizeInBytes,
  }) {
    return copyWith(
      completedAt: completedAt,
      statusCode: statusCode,
      statusMessage: statusMessage,
      responseHeaders: responseHeaders,
      responseBody: responseBody,
      responseSizeInBytes: responseSizeInBytes,
    );
  }

  NetworkLogEntry failWith({
    required DateTime completedAt,
    required String errorType,
    String? errorMessage,
    int? statusCode,
    String? statusMessage,
    Map<String, String> responseHeaders = const <String, String>{},
    Object? responseBody,
    int? responseSizeInBytes,
  }) {
    return copyWith(
      completedAt: completedAt,
      errorType: errorType,
      errorMessage: errorMessage,
      statusCode: statusCode,
      statusMessage: statusMessage,
      responseHeaders: responseHeaders,
      responseBody: responseBody,
      responseSizeInBytes: responseSizeInBytes,
    );
  }

  NetworkLogEntry copyWith({
    DateTime? completedAt,
    int? statusCode,
    String? statusMessage,
    Map<String, String>? responseHeaders,
    Object? responseBody,
    int? responseSizeInBytes,
    String? errorType,
    String? errorMessage,
  }) {
    return NetworkLogEntry(
      id: id,
      method: method,
      uri: uri,
      startedAt: startedAt,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      completedAt: completedAt ?? this.completedAt,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      responseBody: responseBody ?? this.responseBody,
      responseSizeInBytes: responseSizeInBytes ?? this.responseSizeInBytes,
      errorType: errorType ?? this.errorType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
