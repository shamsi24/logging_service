import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging_service/logging_service.dart';

void main() {
  const config = RedactionConfig();

  group('RedactionConfig', () {
    test('masks known headers case insensitively', () {
      final result = config.redactHeaders({
        'Authorization': 'Bearer secret',
        'Accept': 'application/json',
      });

      expect(result['Authorization'], config.mask);
      expect(result['Accept'], 'application/json');
    });

    test('masks nested body keys and keeps the rest', () {
      final result = config.redactBody({
        'user': {'name': 'Shamsi', 'password': 'hunter2'},
        'items': [
          {'token': 'abc', 'id': 7},
        ],
      });

      final user = (result! as Map)['user'] as Map;
      final item = ((result as Map)['items'] as List).first as Map;

      expect(user['name'], 'Shamsi');
      expect(user['password'], config.mask);
      expect(item['token'], config.mask);
      expect(item['id'], 7);
    });

    test('masks a serialized JSON body', () {
      final result = config.redactBody('{"password":"hunter2","id":1}');
      final decoded = jsonDecode(result! as String) as Map<String, dynamic>;

      expect(decoded['password'], config.mask);
      expect(decoded['id'], 1);
    });

    test('leaves a non JSON string untouched', () {
      expect(config.redactBody('plain text'), 'plain text');
    });

    test('masks query parameters in the url', () {
      final result = config.redactUri(
        Uri.parse('https://api.test/v1/me?access_token=abc&page=2'),
      );

      expect(result.queryParameters['access_token'], config.mask);
      expect(result.queryParameters['page'], '2');
    });

    test('disabled config changes nothing', () {
      const disabled = RedactionConfig.disabled();
      expect(
        disabled.redactHeaders({'Authorization': 'Bearer secret'}),
        {'Authorization': 'Bearer secret'},
      );
      expect(disabled.redactBody({'password': 'hunter2'}),
          {'password': 'hunter2'});
    });
  });
}
