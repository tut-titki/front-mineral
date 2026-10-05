import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/src/dashboard_screen.dart';
import 'package:mineral/src/demo_store.dart';
import 'package:mineral/src/order_filters.dart';
import 'package:mineral/src/models.dart';
import 'package:mineral/src/ui.dart';
import 'package:mineral/theme.dart';

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
      [147, 149, 143],
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
    testWidgets('search and multiple filters apply together in $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      final store = DemoStore();
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
              child: OrdersScreen(
                store: store,
                onOrder: (_) {},
                onCreate: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(OrdersScreen));
      final s = AppLocalizations.of(context);
      expect(find.byType(OrderCard), findsNWidgets(6));
      expect(find.byType(FilterChip), findsNothing);

      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tap(find.byTooltip(s.filters));
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text(s.equipment), findsNothing);
      expect(find.text(s.priority), findsNothing);
      await tap(find.widgetWithText(FilterChip, 'Дробление'));
      await tap(find.widgetWithText(FilterChip, uiText(context, 'В работе')));
      await tap(find.widgetWithText(FilterChip, uiText(context, 'Принят')));
      await tap(find.widgetWithText(FilledButton, s.applyFilters));
      expect(find.byType(OrderCard), findsNWidgets(2));
      expect(find.byType(InputChip), findsNWidgets(3));

      await tester.enterText(find.byType(TextField), ' 147 ');
      await tester.pumpAndSettle();
      expect(find.byType(OrderCard), findsOneWidget);
      await tap(find.byTooltip(s.filters));
      await tap(
        find.descendant(
          of: find.byType(OrderFilterPanel),
          matching: find.widgetWithText(TextButton, s.resetFilters),
        ),
      );
      await tap(find.byTooltip(s.closeFilters));
      expect(find.byType(InputChip), findsNWidgets(3));

      await tap(find.byTooltip(s.clearSearch));
      expect(find.byType(OrderCard), findsNWidgets(2));
      await tap(find.widgetWithText(TextButton, s.resetFilters));
      expect(find.byType(OrderCard), findsNWidgets(6));
      await tester.enterText(find.byType(TextField), 'Данияр');
      await tester.pumpAndSettle();
      expect(find.byType(OrderCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
