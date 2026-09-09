import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging_service/logging_service.dart';

void main() {
  NetworkLogEntry entry({
    required String id,
    required String method,
    required String path,
    int statusCode = 200,
  }) {
    return NetworkLogEntry(
      id: id,
      method: method,
      uri: Uri.parse('https://api.test$path'),
      startedAt: DateTime(2026),
      completedAt: DateTime(2026, 1, 1, 0, 0, 0, 120),
      statusCode: statusCode,
    );
  }

  late NetworkLogStore store;

  setUp(() {
    store = NetworkLogStore()
      ..add(entry(id: '1', method: 'GET', path: '/v1/users'))
      ..add(entry(id: '2', method: 'POST', path: '/v1/login'))
      ..add(
          entry(id: '3', method: 'POST', path: '/v1/orders', statusCode: 500));
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LogsPage(store: store)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists every captured call', (tester) async {
    await pumpPage(tester);

    expect(find.text('/v1/users'), findsOneWidget);
    expect(find.text('/v1/login'), findsOneWidget);
    expect(find.text('Network calls (3)'), findsOneWidget);
  });

  testWidgets('search narrows the list', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'login');
    await tester.pumpAndSettle();

    expect(find.text('/v1/login'), findsOneWidget);
    expect(find.text('/v1/users'), findsNothing);
    expect(find.text('Network calls (1)'), findsOneWidget);
  });

  testWidgets('method chip filters the list', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'POST'));
    await tester.pumpAndSettle();

    expect(find.text('/v1/login'), findsOneWidget);
    expect(find.text('/v1/orders'), findsOneWidget);
    expect(find.text('/v1/users'), findsNothing);
  });

  testWidgets('error chip keeps only failed calls', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Error'));
    await tester.pumpAndSettle();

    expect(find.text('/v1/orders'), findsOneWidget);
    expect(find.text('/v1/login'), findsNothing);
  });

  testWidgets('empty state explains that filters hide everything',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'nothing-matches');
    await tester.pumpAndSettle();

    expect(find.text('No call matches the filters'), findsOneWidget);
  });

  testWidgets('clear button empties the store', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Clear'));
    await tester.pumpAndSettle();

    expect(store.entries, isEmpty);
    expect(find.text('No call captured yet'), findsOneWidget);
  });

  testWidgets('a new call shows up while the page is open', (tester) async {
    await pumpPage(tester);

    store.add(entry(id: '4', method: 'PUT', path: '/v1/profile'));
    await tester.pumpAndSettle();

    expect(find.text('/v1/profile'), findsOneWidget);
    expect(find.text('Network calls (4)'), findsOneWidget);
  });

  testWidgets('opening a call shows its detail and the cURL action',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('/v1/login'));
    await tester.pumpAndSettle();

    expect(find.text('Detail'), findsOneWidget);
    expect(find.byTooltip('Copy as cURL'), findsOneWidget);
    expect(find.text('https://api.test/v1/login'), findsOneWidget);
  });
}
