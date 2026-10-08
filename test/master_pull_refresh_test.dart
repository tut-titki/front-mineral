import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/master/screens/master_shell.dart';
import 'package:mineral/features/orders/screens/equipment_history_screen.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/shared/widgets/backend_refresh_view.dart';
import 'package:mineral/shared/widgets/backend_section.dart';
import 'helpers/backend_api_fixture.dart';

Widget host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  testWidgets('initial page loading has one indicator for all sections', (
    tester,
  ) async {
    final first = Completer<String>();
    final second = Completer<String>();
    await tester.pumpWidget(
      host(
        Scaffold(
          body: BackendRefreshView(
            child: Column(
              children: [
                BackendSection<String>(
                  load: () => first.future,
                  builder: (_, data) => Text(data),
                ),
                BackendSection<String>(
                  load: () => second.future,
                  builder: (_, data) => Text(data),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    first.complete('first section');
    await tester.pump();
    await tester.pump();
    expect(find.text('first section'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    second.complete('second section');
    await tester.pumpAndSettle();
    expect(find.text('second section'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'refresh of an unloaded section uses only the gesture indicator',
    (tester) async {
      final pending = Completer<String>();
      var loads = 0;
      await tester.pumpWidget(
        host(
          Scaffold(
            body: BackendRefreshView(
              child: BackendSection<String>(
                load: () async {
                  if (++loads == 1) throw StateError('offline');
                  return pending.future;
                },
                builder: (_, data) => Text(data),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(loads, 2);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
      pending.complete('recovered data');
      await tester.pumpAndSettle();
      expect(find.text('recovered data'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pull on short content awaits all loaders, including failed ones',
    (tester) async {
      final pending = Completer<String>();
      var firstLoads = 0;
      var secondLoads = 0;
      await tester.pumpWidget(
        host(
          Scaffold(
            body: BackendRefreshView(
              child: Column(
                children: [
                  BackendSection<String>(
                    load: () async =>
                        ++firstLoads == 1 ? 'old data' : await pending.future,
                    builder: (_, data) => Text(data),
                  ),
                  BackendSection<String>(
                    load: () async {
                      if (++secondLoads == 1) throw StateError('offline');
                      return 'recovered';
                    },
                    builder: (_, data) => Text(data),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh), findsNothing);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(firstLoads, 2);
      expect(secondLoads, 2);
      expect(find.text('recovered'), findsOneWidget);
      expect(find.text('old data'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
      pending.complete('fresh data');
      await tester.pumpAndSettle();
      expect(find.text('fresh data'), findsOneWidget);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all master tabs refresh their data without refresh buttons', (
    tester,
  ) async {
    final requests = <String, int>{};
    final api = testApi(
      handle: (request) async {
        requests.update(
          request.url.path,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        return null;
      },
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(host(MasterShell(api: api)));
    await tester.pumpAndSettle();
    for (final page in [0, 1, 2, 3]) {
      tester
          .widget<NavigationBar>(find.byType(NavigationBar))
          .onDestinationSelected!(page);
      await tester.pumpAndSettle();
      expect(find.byType(RefreshIndicator), findsOneWidget);
      final indicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      expect(indicator.color, const Color(0xFF01408B));
      expect(indicator.backgroundColor, Colors.white);
      expect(find.byIcon(Icons.refresh), findsNothing);
      expect(find.byTooltip('Обновить'), findsNothing);
      final before = Map<String, int>.from(requests);
      final refresh = tester
          .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
          .show();
      await tester.pumpAndSettle();
      await refresh;
      for (final path in before.keys) {
        // Only the current tab's mounted loaders should run again.
        expect(requests[path]!, greaterThanOrEqualTo(before[path]!));
      }
      expect(
        requests.values.fold<int>(0, (sum, count) => sum + count),
        greaterThan(before.values.fold<int>(0, (sum, count) => sum + count)),
      );
      if (page == 0) {
        for (final path in before.keys) {
          expect(requests[path], greaterThan(before[path]!));
        }
      }
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('empty equipment history refreshes from the server by gesture', (
    tester,
  ) async {
    var loads = 0;
    final api = testApi(
      handle: (request) async {
        if (request.url.path == '/api/equipment/2/history') {
          loads++;
          return jsonResponse({'name': 'Насос', 'orders': []});
        }
        return null;
      },
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(
      host(EquipmentHistoryScreen(api: api, equipmentId: 2)),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(loads, 2);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
