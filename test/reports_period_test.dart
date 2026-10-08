import 'helpers/backend_api_fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/reports/models/report_snapshot.dart';
import 'package:mineral/features/reports/screens/reports_screen.dart';
import 'package:mineral/features/master/screens/master_shell.dart';

void main() {
  final now = DateTime(2026, 10, 5, 12);
  DemoStore reportStore() {
    final store = DemoStore(clock: () => now);
    store.orders.clear();
    for (final item in [
      (0, OrderStatus.working),
      (1, OrderStatus.closed),
      (2, OrderStatus.rejected),
      (9, OrderStatus.rework),
    ]) {
      store.orders.add(
        WorkOrder(
          number: item.$1 + 1,
          title: 'Ремонт',
          description: 'Описание',
          area: 'Обогащение',
          equipment: 'Насос Н-12',
          employeeId: 3,
          priority: 'Обычный',
          createdAt: now.subtract(Duration(days: item.$1)),
          deadline: now.add(const Duration(hours: 1)),
          status: item.$2,
        ),
      );
    }
    return store;
  }

  test('report range includes full last day and filters its employees', () {
    final store = reportStore();
    addTearDown(store.dispose);
    final snapshot = ReportSnapshot(
      store,
      DateTimeRange(start: DateTime(2026, 10, 4), end: DateTime(2026, 10, 5)),
    );
    expect(snapshot.orders.map((o) => o.number), [1, 2]);
    expect(snapshot.ranking.map((e) => e.id), [3]);
    final empty = ReportSnapshot(
      store,
      DateTimeRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 2)),
    );
    expect(empty.orders, isEmpty);
    expect(empty.ranking, isEmpty);
    expect(ReportSnapshot(store, null).orders.length, 4);
  });

  for (final language in ['ru', 'kk']) {
    testWidgets('backend period selection and export menu in $language', (
      tester,
    ) async {
      final queries = <Map<String, String>>[];
      final api = testApi(
        handle: (request) async {
          if (request.url.path != '/api/reports/shift') return null;
          final query = request.url.queryParameters;
          queries.add(query);
          return jsonResponse({
            'issued': query['period'] == 'week'
                ? 2
                : query['from']!.startsWith('1999')
                ? 3
                : 1,
            'completed': 0,
            'overdue': 0,
          });
        },
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MasterShell(api: api),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ReportsScreen));
      final s = AppLocalizations.of(context);
      Finder count(String value) => find.descendant(
        of: find
            .ancestor(
              of: find.text(s.issuedOrders),
              matching: find.byType(Column),
            )
            .first,
        matching: find.text(value),
      );
      expect(count('1'), findsOneWidget);
      expect(queries.last['from'], endsWith('T19:00:00.000Z'));
      expect(queries.last['to'], endsWith('T18:59:59.999999Z'));
      await tester.tap(find.text(language == 'ru' ? 'Фильтры' : 'Сүзгілер'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.weekPeriod));
      await tester.ensureVisible(
        find.text(language == 'ru' ? 'Применить' : 'Қолдану'),
      );
      await tester.tap(find.text(language == 'ru' ? 'Применить' : 'Қолдану'));
      await tester.pumpAndSettle();
      expect(count('2'), findsOneWidget);
      expect(queries.last, {'period': 'week'});
      await tester.tap(find.text(language == 'ru' ? 'Фильтры' : 'Сүзгілер'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.allTimePeriod));
      await tester.ensureVisible(
        find.text(language == 'ru' ? 'Применить' : 'Қолдану'),
      );
      await tester.tap(find.text(language == 'ru' ? 'Применить' : 'Қолдану'));
      await tester.pumpAndSettle();
      expect(count('3'), findsOneWidget);
      expect(queries.last['from'], startsWith('1999-12-31'));
      await tester.tap(find.byTooltip(s.exportReport));
      await tester.pumpAndSettle();
      expect(find.text(s.exportPdf), findsOneWidget);
      expect(find.text(s.exportExcel), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
