import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/master/screens/dashboard_screen.dart';
import 'package:mineral/features/master/screens/equipment_anomalies_screen.dart';
import 'package:mineral/features/master/screens/equipment_failure_forecast_screen.dart';
import 'package:mineral/features/master/screens/master_shell.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'helpers/backend_api_fixture.dart';

Widget host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final language in ['ru', 'kk']) {
    testWidgets(
      'forecast preview opens all and refreshes from the server in $language',
      (tester) async {
        phone(tester);
        var loads = 0;
        final api = testApi(
          handle: (request) async {
            if (request.url.path == '/api/analytics/failure-forecast') {
              loads++;
              expect(request.url.queryParameters, {'days': '30'});
              return jsonResponse(
                List.generate(
                  7,
                  (i) => {
                    'equipment': {'name': 'Pump ${i + 1}'},
                    'probability': .7,
                    'recentFailures': i + 1,
                  },
                ),
              );
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
            home: MasterShell(api: api),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Pump 5'), findsOneWidget);
        expect(find.text('Pump 6'), findsNothing);
        final all = find.text(
          language == 'ru' ? 'Весь прогноз' : 'Толық болжам',
        );
        await tester.ensureVisible(all);
        await tester.tap(all);
        await tester.pumpAndSettle();
        expect(find.byType(EquipmentFailureForecastScreen), findsOneWidget);
        expect(find.text('Pump 6'), findsOneWidget);
        expect(find.text('Pump 7'), findsOneWidget);
        expect(loads, 2);
        final refresh = tester
            .state<RefreshIndicatorState>(find.byType(RefreshIndicator).last)
            .show();
        await tester.pumpAndSettle();
        await refresh;
        expect(loads, 3);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'overview shows five anomalies and opens all on a separate page',
    (tester) async {
      phone(tester);
      var loads = 0;
      final api = testApi(
        handle: (request) async {
          if (request.url.path == '/api/analytics/anomalies') {
            loads++;
            return jsonResponse(
              List.generate(
                7,
                (i) => {
                  'title': 'Anomaly ${i + 1}',
                  'description': 'Description ${i + 1}',
                },
              ),
            );
          }
          return null;
        },
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(host(MasterShell(api: api)));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        Colors.white,
      );
      final overview = find.byType(DashboardScreen);
      expect(
        find.descendant(of: overview, matching: find.text('Обзор смены')),
        findsNothing,
      );
      expect(find.text('Текущая ситуация на производстве'), findsNothing);
      final create = tester.widget<FloatingActionButton>(
        find.byKey(const ValueKey('master-create-order-fab')),
      );
      expect(create.backgroundColor, const Color(0xFF01408B));
      expect(find.text('Anomaly 5'), findsOneWidget);
      expect(find.text('Anomaly 6'), findsNothing);
      final all = find.text('Все аномалии');
      await tester.ensureVisible(all);
      await tester.tap(all);
      await tester.pumpAndSettle();
      expect(find.byType(EquipmentAnomaliesScreen), findsOneWidget);
      expect(find.text('Anomaly 6'), findsOneWidget);
      expect(find.text('Anomaly 7'), findsOneWidget);
      expect(loads, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'chat composer stays visible while history scrolls and keyboard is open',
    (tester) async {
      phone(tester);
      final api = testApi(
        handle: (request) async => request.url.path == '/api/assistant/history'
            ? jsonResponse(
                List.generate(
                  30,
                  (i) => {
                    'role': 'assistant',
                    'content':
                        'Message $i with a long answer to the master shift question.',
                  },
                ),
              )
            : null,
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(host(MasterShell(api: api)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).at(3));
      await tester.pumpAndSettle();
      final input = find.byKey(const ValueKey('chat-input'));
      final send = find.byKey(const ValueKey('chat-send'));
      final beforeInput = tester.getRect(input);
      final beforeSend = tester.getRect(send);
      expect(beforeSend.bottom, lessThan(844));
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(input), beforeInput);
      expect(tester.getRect(send), beforeSend);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.getRect(send).bottom, lessThanOrEqualTo(844 - 280));
      expect(tester.getRect(input).top, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reports keep drafts until apply and export is in the appbar', (
    tester,
  ) async {
    phone(tester);
    final queries = <Map<String, String>>[];
    final api = testApi(
      handle: (request) async {
        if (request.url.path == '/api/reports/shift') {
          queries.add(request.url.queryParameters);
          return jsonResponse({'issued': 1, 'completed': 0, 'overdue': 0});
        }
        return null;
      },
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(host(MasterShell(api: api)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(ReportsScreen));
    final s = AppLocalizations.of(context);
    expect(find.text(s.reportsRating), findsNothing);
    expect(find.text(s.reportPeriodHint), findsNothing);
    expect(find.byType(DropdownButtonFormField<int>), findsNothing);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byTooltip(s.exportReport),
      ),
      findsOneWidget,
    );
    final initial = Map<String, String>.from(queries.last);
    await tester.tap(find.text('Фильтры'));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(4));
    await tester.tap(find.text(s.weekPeriod));
    await tester.ensureVisible(find.text('Отмена'));
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(queries.last, initial);
    await tester.tap(find.text('Фильтры'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.weekPeriod));
    await tester.ensureVisible(find.text('Применить'));
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();
    expect(queries.last, {'period': 'week'});
    await tester.tap(find.byTooltip(s.exportReport));
    await tester.pumpAndSettle();
    expect(find.text(s.exportPdf), findsOneWidget);
    expect(find.text(s.exportExcel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
