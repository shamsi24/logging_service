import 'package:flutter_test/flutter_test.dart';
import 'package:logging_service/logging_service.dart';

void main() {
  NetworkLogEntry entry(String id) => NetworkLogEntry(
        id: id,
        method: 'GET',
        uri: Uri.parse('https://api.test/$id'),
        startedAt: DateTime(2026),
      );

  group('NetworkLogStore', () {
    test('keeps the newest call first', () {
      final store = NetworkLogStore()
        ..add(entry('1'))
        ..add(entry('2'));

      expect(store.entries.map((e) => e.id), ['2', '1']);
    });

    test('drops the oldest call once the buffer is full', () {
      final store = NetworkLogStore(maxEntries: 3);
      for (var i = 1; i <= 5; i++) {
        store.add(entry('$i'));
      }

      expect(store.entries.length, 3);
      expect(store.entries.map((e) => e.id), ['5', '4', '3']);
    });

    test('updates the entry that owns the id', () {
      final store = NetworkLogStore()
        ..add(entry('1'))
        ..add(entry('2'));

      store.update(
        '1',
        (e) => e.completeWith(completedAt: DateTime(2026), statusCode: 204),
      );

      expect(store.byId('1')!.statusCode, 204);
      expect(store.byId('2')!.statusCode, isNull);
    });

    test('ignores an update for an unknown id instead of throwing', () {
      final store = NetworkLogStore()..add(entry('1'));

      expect(
        () => store.update('missing', (e) => e),
        returnsNormally,
      );
      expect(store.entries.length, 1);
    });

    test('notifies listeners on add and clear', () {
      final store = NetworkLogStore();
      var notifications = 0;
      store.listenable.addListener(() => notifications++);

      store.add(entry('1'));
      store.clear();

      expect(notifications, 2);
      expect(store.entries, isEmpty);
    });
  });
}
