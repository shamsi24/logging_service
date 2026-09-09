import 'package:flutter_test/flutter_test.dart';
import 'package:logging_service/logging_service.dart';

void main() {
  NetworkLogEntry entry({
    String method = 'POST',
    Map<String, String> headers = const {},
    Object? body,
  }) {
    return NetworkLogEntry(
      id: '1',
      method: method,
      uri: Uri.parse('https://api.test/v1/login'),
      startedAt: DateTime(2026),
      requestHeaders: headers,
      requestBody: body,
    );
  }

  group('CurlBuilder', () {
    test('renders method, url, headers and body', () {
      final command = CurlBuilder.build(
        entry(
          headers: {'Content-Type': 'application/json'},
          body: {'user': 'shamsi'},
        ),
      );

      expect(command, contains('curl -X POST'));
      expect(command, contains("'https://api.test/v1/login'"));
      expect(command, contains("-H 'Content-Type: application/json'"));
      expect(command, contains(r'--data ' "'" r'{"user":"shamsi"}' "'"));
    });

    test('omits the data flag when there is no body', () {
      expect(
          CurlBuilder.build(entry(method: 'GET')), isNot(contains('--data')));
    });

    test('escapes single quotes so the command stays runnable', () {
      final command = CurlBuilder.build(entry(body: "it's"));
      expect(command, contains(r"'it'\''s'"));
    });
  });
}
