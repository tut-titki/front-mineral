import 'helpers/backend_api_fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/reports/models/report_snapshot.dart';
import 'package:mineral/features/reports/screens/reports_screen.dart';

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
      final now = DateTime.now();
      final api = testApi(
        handle: (request) async => request.url.path == '/api/work-orders'
            ? jsonResponse([
                orderJson(id: 1, createdAt: now),
                orderJson(
                  id: 2,
                  createdAt: now.subtract(const Duration(days: 2)),
                ),
                orderJson(
                  id: 3,
                  createdAt: now.subtract(const Duration(days: 15)),
                ),
              ])
            : null,
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: ReportsScreen(api: api)),
          ),
        ),
      );
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
      await tester.tap(find.text(s.weekPeriod));
      await tester.pumpAndSettle();
      expect(count('2'), findsOneWidget);
      await tester.tap(find.text(s.allTimePeriod));
      await tester.pumpAndSettle();
      expect(count('3'), findsOneWidget);
      await tester.tap(find.byTooltip(s.exportReport));
      await tester.pumpAndSettle();
      expect(find.text(s.exportPdf), findsOneWidget);
      expect(find.text(s.exportExcel), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
