import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/src/demo_store.dart';
import 'package:mineral/src/models.dart';
import 'package:mineral/src/report_metrics.dart';
import 'package:mineral/src/report_snapshot.dart';
import 'package:mineral/src/reports_screen.dart';
import 'package:mineral/theme.dart';

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
    testWidgets('report presets, custom picker and export menu in $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      final store = reportStore();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        store.dispose();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          theme: buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ReportsScreen(store: store),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ReportsScreen));
      final s = AppLocalizations.of(context);
      Finder count(String text) => find.descendant(
        of: find.byType(ReportMetrics),
        matching: find.text(text),
      );
      expect(count('1'), findsOneWidget);
      await tester.tap(find.text(s.weekPeriod));
      await tester.pumpAndSettle();
      expect(count('3'), findsOneWidget);
      await tester.tap(find.text(s.allTimePeriod));
      await tester.pumpAndSettle();
      expect(count('4'), findsOneWidget);
      expect(find.text(s.exportPdf), findsNothing);
      await tester.tap(find.byTooltip(s.exportReport));
      await tester.pumpAndSettle();
      expect(find.text(s.exportPdf), findsOneWidget);
      expect(find.text(s.exportExcel), findsOneWidget);
      await tester.tapAt(const Offset(10, 500));
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.selectPeriod));
      await tester.pumpAndSettle();
      expect(find.byType(DateRangePickerDialog), findsOneWidget);
      final material = MaterialLocalizations.of(context);
      await tester.tap(find.byTooltip(material.inputDateModeButtonLabel));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).at(0),
        material.formatCompactDate(DateTime(2026, 10, 4)),
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        material.formatCompactDate(DateTime(2026, 10, 5)),
      );
      await tester.tap(find.text(material.okButtonLabel));
      await tester.pumpAndSettle();
      expect(find.byType(DateRangePickerDialog), findsNothing);
      expect(count('2'), findsOneWidget);
      expect(find.text('04.10.2026 — 05.10.2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
