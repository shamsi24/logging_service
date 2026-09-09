import 'package:flutter_test/flutter_test.dart';
import 'package:logging_service/logging_service.dart';

void main() {
  late List<String> output;

  NetworkLogPrinter printer({
    bool useColors = false,
    int maxBodyLines = 40,
    bool includeCurlOnError = true,
  }) {
    return NetworkLogPrinter(
      useColors: useColors,
      maxBodyLines: maxBodyLines,
      includeCurlOnError: includeCurlOnError,
      sink: output.add,
    );
  }

  NetworkLogEntry request() => NetworkLogEntry(
        id: '1',
        method: 'POST',
        uri: Uri.parse('https://api.test/v1/login?page=2'),
        startedAt: DateTime(2026),
        requestHeaders: const {'Content-Type': 'application/json'},
        requestBody: const {'username': 'shamsi'},
      );

  NetworkLogEntry success() => request().completeWith(
        completedAt: DateTime(2026).add(const Duration(milliseconds: 118)),
        statusCode: 200,
        responseBody: const {'id': 7},
        responseSizeInBytes: 1240,
      );

  NetworkLogEntry failure() => request().failWith(
        completedAt: DateTime(2026).add(const Duration(milliseconds: 87)),
        errorType: 'badResponse',
        errorMessage: 'Http status error [401]',
        statusCode: 401,
        responseBody: const {'error': 'invalid_credentials'},
      );

  setUp(() => output = <String>[]);

  group('started', () {
    test('is a single line with method and target', () {
      printer().started(request());

      expect(output, hasLength(1));
      expect(output.single, '→ POST   /v1/login?page=2');
    });
  });

  group('a successful call', () {
    test('is one line with status, timing and size', () {
      printer().completed(success());

      expect(output, hasLength(1));
      expect(output.single, contains('200'));
      expect(output.single, contains('POST'));
      expect(output.single, contains('/v1/login?page=2'));
      expect(output.single, contains('118 ms'));
      expect(output.single, contains('1.2 KB'));
      expect(output.single.split('\n'), hasLength(1));
    });

    test('never prints the bodies or the headers', () {
      printer().completed(success());

      expect(output.single, isNot(contains('username')));
      expect(output.single, isNot(contains('Content-Type')));
      expect(output.single, isNot(contains('curl')));
    });
  });

  group('a failed call', () {
    test('expands into one framed block', () {
      printer().completed(failure());

      expect(output, hasLength(1));
      final block = output.single;
      expect(block, startsWith('┌─ ERROR'));
      expect(block.trimRight(), endsWith('─'));
      expect(block, contains('401'));
      expect(block, contains('badResponse'));
      expect(block, contains('Http status error [401]'));
      expect(block, contains('87 ms'));
    });

    test('includes both bodies and both header maps', () {
      printer().completed(failure());
      final block = output.single;

      expect(block, contains('request headers'));
      expect(block, contains('Content-Type: application/json'));
      expect(block, contains('request body'));
      expect(block, contains('"username": "shamsi"'));
      expect(block, contains('response body'));
      expect(block, contains('invalid_credentials'));
    });

    test('includes a runnable cURL command', () {
      printer().completed(failure());

      expect(output.single, contains('curl -X POST'));
      expect(output.single, contains("'https://api.test/v1/login?page=2'"));
    });

    test('drops the cURL command when it is turned off', () {
      printer(includeCurlOnError: false).completed(failure());

      expect(output.single, isNot(contains('curl')));
    });

    test('cuts a long body and says how much was dropped', () {
      final long = {for (var i = 0; i < 50; i++) 'key$i': i};
      printer(maxBodyLines: 10).completed(
        request().failWith(
          completedAt: DateTime(2026),
          errorType: 'badResponse',
          responseBody: long,
        ),
      );

      expect(output.single, contains('more lines'));
      expect(output.single, isNot(contains('key49')));
    });
  });

  group('colors', () {
    test('are absent when disabled', () {
      printer().completed(success());
      printer().completed(failure());

      for (final message in output) {
        expect(message, isNot(contains('\x1B[')));
      }
    });

    test('are emitted when enabled', () {
      printer(useColors: true).completed(success());

      expect(output.single, contains('\x1B['));
    });
  });
}
