import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging_service/logging_service.dart';

/// Answers every call from a callback instead of hitting the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responder);

  final Future<ResponseBody> Function(RequestOptions options) responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      responder(options);

  @override
  void close({bool force = false}) {}
}

void main() {
  late NetworkLogStore store;

  Dio dioWith(
    Future<ResponseBody> Function(RequestOptions options) responder, {
    RedactionConfig redaction = const RedactionConfig(),
  }) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeAdapter(responder);
    dio.interceptors.add(
      DioLoggingInterceptor(
        store: store,
        redaction: redaction,
        enabled: true,
        printer: null,
      ),
    );
    return dio;
  }

  setUp(() => store = NetworkLogStore());

  test('pairs concurrent calls to the same url with their own response',
      () async {
    final dio = dioWith((options) async {
      final isSlow = options.headers['X-Case'] == 'slow';
      if (isSlow) {
        await Future<void>.delayed(const Duration(milliseconds: 60));
        return ResponseBody.fromString('{"ok":"slow"}', 201);
      }
      return ResponseBody.fromString('{"ok":"fast"}', 200);
    });

    await Future.wait([
      dio.post<dynamic>('/v1/jobs',
          options: Options(headers: {'X-Case': 'slow'})),
      dio.post<dynamic>('/v1/jobs',
          options: Options(headers: {'X-Case': 'fast'})),
    ]);

    final slow = store.entries.firstWhere(
      (e) => e.requestHeaders['X-Case'] == 'slow',
    );
    final fast = store.entries.firstWhere(
      (e) => e.requestHeaders['X-Case'] == 'fast',
    );

    expect(slow.statusCode, 201);
    expect(fast.statusCode, 200);
    expect(slow.elapsedMilliseconds, greaterThanOrEqualTo(50));
    expect(fast.elapsedMilliseconds, lessThan(slow.elapsedMilliseconds!));
  });

  test('redacts credentials before they reach the store', () async {
    final dio = dioWith(
      (options) async => ResponseBody.fromString(
        '{"access_token":"real-token"}',
        200,
        headers: {
          'content-type': ['application/json'],
          'set-cookie': ['session=abc'],
        },
      ),
    );

    await dio.post<dynamic>(
      '/v1/login?api_key=plain',
      data: {'username': 'shamsi', 'password': 'hunter2'},
      options: Options(headers: {'Authorization': 'Bearer plain'}),
    );

    final entry = store.entries.single;
    final mask = const RedactionConfig().mask;

    expect(entry.requestHeaders['Authorization'], mask);
    expect((entry.requestBody! as Map)['password'], mask);
    expect((entry.requestBody! as Map)['username'], 'shamsi');
    expect(entry.uri.queryParameters['api_key'], mask);
    expect(entry.responseHeaders['set-cookie'], mask);
    expect((entry.responseBody! as Map)['access_token'], mask);
  });

  test('records a failure with its type and status code', () async {
    final dio = dioWith(
      (options) async => ResponseBody.fromString('{"error":"nope"}', 404),
    );

    await expectLater(
      dio.get<dynamic>('/v1/missing'),
      throwsA(isA<DioException>()),
    );

    final entry = store.entries.single;
    expect(entry.hasError, isTrue);
    expect(entry.statusCode, 404);
    expect(entry.errorType, DioExceptionType.badResponse.name);
    expect(entry.elapsedMilliseconds, isNotNull);
  });

  test('flattens FormData so it can be inspected and exported', () async {
    final dio = dioWith(
      (options) async => ResponseBody.fromString('{}', 200),
    );

    await dio.post<dynamic>(
      '/v1/upload',
      data: FormData.fromMap({'title': 'report'}),
    );

    final body = store.entries.single.requestBody! as Map;
    expect((body['fields'] as Map)['title'], 'report');
    expect(body['files'], isEmpty);
  });

  test('drives the console printer through the interceptor', () async {
    final output = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeAdapter(
        (options) async => ResponseBody.fromString('{"ok":true}', 200),
      );
    dio.interceptors.add(
      DioLoggingInterceptor(
        store: store,
        enabled: true,
        printer: NetworkLogPrinter(useColors: false, sink: output.add),
      ),
    );

    await dio.get<dynamic>('/v1/ping');

    expect(output, hasLength(2));
    expect(output.first, startsWith('→ GET'));
    expect(output.last, startsWith('← 200'));
    expect(output.last, isNot(contains('\n')));
  });

  test('captures nothing while disabled', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeAdapter(
        (options) async => ResponseBody.fromString('{}', 200),
      );
    dio.interceptors.add(
      DioLoggingInterceptor(store: store, enabled: false, printer: null),
    );

    await dio.get<dynamic>('/v1/ping');

    expect(store.entries, isEmpty);
  });
}
