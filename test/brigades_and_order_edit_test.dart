import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/features/team/screens/brigade_screen.dart';
import 'package:mineral/features/master/screens/dashboard_screen.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/orders/screens/order_screens.dart';
import 'package:mineral/shared/widgets/ui.dart';
import 'package:mineral/core/theme/app_theme.dart';

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
    testWidgets('brigade opens its complete roster in $language', (
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
              child: TeamScreen(store: store),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ерлан Ахметов'), findsNothing);
      expect(find.text('Бригада №1'), findsOneWidget);
      await tester.tap(find.text('Бригада №1'));
      await tester.pumpAndSettle();
      expect(find.byType(BrigadeMembersScreen), findsOneWidget);
      expect(find.text('Ерлан Ахметов'), findsOneWidget);
      expect(find.text('Алексей Ким'), findsOneWidget);
      expect(find.text('Данияр Садыков'), findsNothing);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(BrigadeMembersScreen), findsNothing);
    });
  }

  testWidgets('detail is flat and editing actions open from its top', (
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
    final order = store.orders.first;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: OrderDetailScreen(store: store, order: order),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Panel), findsNothing);
    expect(find.text('Переназначить'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byTooltip('Редактирование наряда'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Редактирование наряда'));
    await tester.pumpAndSettle();
    for (final label in [
      'Переназначить',
      'Изменить приоритет',
      'Отменить наряд',
      'Изменить срок выполнения',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('Изменить приоритет'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Обычный — в порядке очереди'));
    await tester.pumpAndSettle();
    expect(order.priority, 'Обычный');
    expect(order.history.last.kind, OrderEventKind.priority);
    await tester.tap(find.byTooltip('Редактирование наряда'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изменить срок выполнения'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
