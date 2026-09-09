import 'package:flutter_test/flutter_test.dart';
import 'package:logging_service/logging_service.dart';

void main() {
  NetworkLogEntry entry({
    required String id,
    String method = 'GET',
    String url = 'https://api.test/v1/users',
    int? statusCode = 200,
    String? errorType,
  }) {
    return NetworkLogEntry(
      id: id,
      method: method,
      uri: Uri.parse(url),
      startedAt: DateTime(2026),
      completedAt: DateTime(2026),
      statusCode: statusCode,
      errorType: errorType,
    );
  }

  final entries = [
    entry(id: '1'),
    entry(id: '2', method: 'POST', url: 'https://api.test/v1/login'),
    entry(id: '3', method: 'POST', statusCode: 500, errorType: 'badResponse'),
  ];

  group('LogFilter', () {
    test('is inactive by default and returns the source list', () {
      const filter = LogFilter();
      expect(filter.isActive, isFalse);
      expect(filter.apply(entries), same(entries));
    });

    test('matches the url case insensitively', () {
      const filter = LogFilter(query: 'LOGIN');
      expect(filter.apply(entries).map((e) => e.id), ['2']);
    });

    test('matches the status code', () {
      const filter = LogFilter(query: '500');
      expect(filter.apply(entries).map((e) => e.id), ['3']);
    });

    test('filters by method', () {
      const filter = LogFilter(methods: {'POST'});
      expect(filter.apply(entries).map((e) => e.id), ['2', '3']);
    });

    test('filters by outcome', () {
      const failures = LogFilter(status: LogStatusFilter.failure);
      const successes = LogFilter(status: LogStatusFilter.success);

      expect(failures.apply(entries).map((e) => e.id), ['3']);
      expect(successes.apply(entries).map((e) => e.id), ['1', '2']);
    });

    test('combines query, method and outcome', () {
      const filter = LogFilter(
        query: 'users',
        methods: {'POST'},
        status: LogStatusFilter.failure,
      );
      expect(filter.apply(entries).map((e) => e.id), ['3']);
    });

    test('toggleMethod adds and removes', () {
      const filter = LogFilter();
      final added = filter.toggleMethod('GET');
      expect(added.methods, {'GET'});
      expect(added.toggleMethod('GET').methods, isEmpty);
    });
  });
}
