import 'helpers/backend_api_fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/features/master/screens/dashboard_screen.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/features/orders/widgets/order_filters.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  test('filter drafts are independent and criteria combine', () {
    final store = DemoStore();
    addTearDown(store.dispose);
    final filters = OrderFilters(
      areas: {'Дробление'},
      statuses: {OrderStatus.working, OrderStatus.accepted, OrderStatus.closed},
    );
    expect(
      store.orders.where((o) => filters.matches(o, store)).map((o) => o.number),
      [147, 149, 141, 139, 143],
    );
    final draft = filters.copy();
    draft.areas.clear();
    draft.employees.add(2);
    expect(filters.areas, {'Дробление'});
    expect(filters.employees, isEmpty);
    expect(
      store.orders.where((o) => draft.matches(o, store)).map((o) => o.number),
      [149],
    );
  });

  for (final language in ['ru', 'kk']) {
    testWidgets('backend search and board work in $language', (tester) async {
      final api = testApi(
        handle: (request) async => request.url.path == '/api/work-orders/board'
            ? jsonResponse(
                boardJson(
                  issued: [orderJson(id: 773)],
                  inProgress: [orderJson(id: 774, status: 'IN_PROGRESS')],
                ),
              )
            : request.url.path == '/api/work-orders'
            ? jsonResponse([
                orderJson(id: 773),
                orderJson(id: 774, status: 'IN_PROGRESS'),
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
            body: SingleChildScrollView(
              child: OrdersScreen(api: api, onOrder: (_) {}, onCreate: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ApiOrderCard), findsNWidgets(2));
      await tester.enterText(find.byType(TextField), ' 773 ');
      await tester.pumpAndSettle();
      expect(find.byType(ApiOrderCard), findsOneWidget);
      final context = tester.element(find.byType(OrdersScreen));
      await tester.tap(find.byTooltip(strings(context).clearSearch));
      await tester.pumpAndSettle();
      expect(find.byType(ApiOrderCard), findsNWidgets(2));
      await tester.tap(find.text(uiText(context, 'Канбан')));
      await tester.pumpAndSettle();
      expect(find.byType(ApiOrderCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
