import 'helpers/backend_api_fixture.dart';
import 'package:mineral/features/orders/screens/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/features/master/screens/dashboard_screen.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  test('deadline changes clear old norm, record history and notify once', () {
    final now = DateTime(2026, 10, 5, 12);
    final changes = <OrderEventKind>[];
    final store = DemoStore(clock: () => now, onOrderChanged: changes.add);
    addTearDown(store.dispose);
    final order = store.orders.first;
    order.normHours = 2;
    final before = order.deadline;
    final historySize = order.history.length;
    expect(
      () =>
          store.changeDeadline(order, now.subtract(const Duration(minutes: 1))),
      throwsArgumentError,
    );
    expect(order.deadline, before);
    expect(changes, isEmpty);
    final deadline = now.add(const Duration(hours: 4));
    store.changeDeadline(order, deadline);
    store.changeDeadline(order, deadline);
    expect(order.deadline, deadline);
    expect(order.normHours, isNull);
    expect(order.history.length, historySize + 1);
    expect(order.history.last.title, contains('→'));
    expect(changes, [OrderEventKind.deadline]);
    store.changeStatus(order, OrderStatus.closed);
    expect(
      () => store.changeDeadline(order, deadline.add(const Duration(hours: 1))),
      throwsStateError,
    );
  });

  for (final language in ['ru', 'kk']) {
    testWidgets('backend brigade opens complete roster in $language', (
      tester,
    ) async {
      final api = testApi(
        handle: (request) async {
          if (request.url.path == '/api/references/executors') {
            return jsonResponse([executorJson()]);
          }
          if (request.url.path == '/api/references/brigades') {
            return jsonResponse([
              {
                'id': 1,
                'name': 'Test Brigade',
                'members': [
                  {
                    'id': 7,
                    'fullName': 'Test Executor',
                    'specialty': 'Specialty',
                  },
                ],
              },
            ]);
          }
          return null;
        },
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: TeamScreen(api: api)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Test Executor'), findsNothing);
      await tester.tap(find.text('Test Brigade'));
      await tester.pumpAndSettle();
      expect(find.text('Test Executor'), findsOneWidget);
      expect(find.textContaining('3'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('close posts score and refreshes full order from server', (
    tester,
  ) async {
    var closed = false;
    var gets = 0;
    final api = testApi(
      handle: (request) async {
        if (request.method == 'POST') {
          closed = true;
          expect(request.body, contains('CLOSE'));
          expect(request.body, contains('masterScore'));
          expect(request.body, contains('clientActionId'));
          // The mutation response deliberately differs from the next GET.
          return jsonResponse(orderJson(status: 'AI_REVIEW'));
        }
        if (request.url.path == '/api/work-orders/773') {
          gets++;
          return jsonResponse(
            orderJson(status: closed ? 'CLOSED' : 'AI_REVIEW'),
          );
        }
        return null;
      },
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OrderDetailScreen(api: api, orderId: 773),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Принять и закрыть'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Закрыть наряд'));
    await tester.pumpAndSettle();
    expect(closed, true);
    expect(gets, greaterThanOrEqualTo(2));
    expect(find.text('Закрыт'), findsOneWidget);
    expect(find.text('Принять и закрыть'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
