import 'dart:convert';
import 'dart:io';
import 'helpers/localization_assertions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/core/theme/app_theme.dart';
import 'package:mineral/features/executor/screens/completion_screen.dart';
import 'package:mineral/features/executor/screens/executor_screen.dart';
import 'package:mineral/features/executor/screens/executor_order_screen.dart';
import 'package:mineral/features/executor/screens/executor_result_screen.dart';
import 'package:mineral/features/notifications/screens/notifications_screen.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/app_locale.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

final _ru =
    jsonDecode(File('lib/l10n/app_ru.arb').readAsStringSync())
        as Map<String, dynamic>;
final _kk =
    jsonDecode(File('lib/l10n/app_kk.arb').readAsStringSync())
        as Map<String, dynamic>;

Widget localized(Widget home) => ValueListenableBuilder<Locale?>(
  valueListenable: appLocale,
  builder: (_, locale, _) => MaterialApp(
    locale: locale,
    theme: buildAppTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

void main() {
  test('Russian and Kazakh ARB keys and placeholders match', () {
    expect(
      _kk.keys.where((k) => !k.startsWith('@')).toSet(),
      _ru.keys.where((k) => !k.startsWith('@')).toSet(),
    );
    for (final entry in _ru.entries.where((e) => !e.key.startsWith('@'))) {
      expect((_kk[entry.key] as String).trim(), isNotEmpty);
      final params = RegExp(r'\{(\w+)\}');
      expect(
        params.allMatches(_kk[entry.key]).map((m) => m[1]).toSet(),
        params.allMatches(entry.value).map((m) => m[1]).toSet(),
        reason: entry.key,
      );
    }
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('executor tabs, history and live language switch at $width', (
      tester,
    ) async {
      final store = DemoStore();
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      appLocale.value = const Locale('kk');
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        store.dispose();
        appLocale.value = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        localized(ExecutorScreen(store: store, employeeId: 1)),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ExecutorScreen));
      final s = strings(context);
      expect(find.text(s.myOrders), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'orders');
      checkNoRussianLabels(tester);
      await tester.enterText(find.byType(TextField), 'мойынтір');
      await tester.pumpAndSettle();
      expect(find.text(s.noSearchResults), findsNothing);
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text(s.history));
      await tester.pumpAndSettle();
      expect(find.text(s.orderHistory), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'history');
      checkNoRussianLabels(tester);
      await tester.tap(find.text(s.profile).last);
      await tester.pumpAndSettle();
      expect(find.text(s.myRating), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'profile');
      checkNoRussianLabels(tester);
      appLocale.value = const Locale('ru');
      await tester.pumpAndSettle();
      expect(find.text('Мой рейтинг'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('all order statuses, reports and notices use Kazakh labels', (
    tester,
  ) async {
    final store = DemoStore();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    appLocale.value = const Locale('kk');
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      store.dispose();
      appLocale.value = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final order = store.assignedTo(1).first;
    for (final status in OrderStatus.values) {
      order.status = status;
      await tester.pumpWidget(
        localized(
          ExecutorOrderScreen(store: store, order: order, employeeId: 1),
        ),
      );
      await tester.pumpAndSettle();
      checkNoRussianLabels(tester);
      expect(tester.takeException(), isNull, reason: status.name);
      await tester.pumpWidget(const SizedBox());
    }
    for (final status in [
      OrderStatus.review,
      OrderStatus.rework,
      OrderStatus.closed,
    ]) {
      order.status = status;
      await tester.pumpWidget(
        localized(
          ExecutorResultScreen(store: store, order: order, employeeId: 1),
        ),
      );
      await tester.pumpAndSettle();
      checkNoRussianLabels(tester);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
    await tester.pumpWidget(
      localized(
        Builder(
          builder: (context) => NotificationsScreen.forUser(
            context: context,
            repository: store,
            userId: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    checkNoRussianLabels(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kazakh completion validates fields and keeps catalog IDs', (
    tester,
  ) async {
    final store = DemoStore();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    appLocale.value = const Locale('kk');
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      store.dispose();
      appLocale.value = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final order = store.assignedTo(1).first;
    order.status = OrderStatus.working;
    order.planned = false;
    await tester.pumpWidget(
      localized(CompletionScreen(store: store, order: order, employeeId: 1)),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(CompletionScreen));
    final s = strings(context);
    expect(find.text(s.closeOrderNumber('${order.number}')), findsOneWidget);
    checkNoRussianLabels(tester);
    await tester.tap(find.text(s.submitForReview));
    await tester.pumpAndSettle();
    expect(find.text(s.describeCompletedWork), findsWidgets);
    expect(find.text(s.selectFaultCode), findsOneWidget);
    checkNoRussianLabels(tester);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Тығыздағыш ауыстырылды',
    );
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(uiText(context, store.executorFaultCodes.first)).last,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(s.addMaterial));
    await tester.tap(find.text(s.addMaterial));
    await tester.pumpAndSettle();
    checkNoRussianLabels(tester);
    await tester.tap(find.text(uiText(context, 'Выберите материал')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(uiText(context, store.executorMaterials.first)).last,
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '2');
    await tester.tap(find.text(s.addMaterial).last);
    await tester.pumpAndSettle();
    expect(
      find.text(uiText(context, store.executorMaterials.first)),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    final draft = store.executionDraft(1, order.number)!;
    expect(draft.faultCode, store.executorFaultCodes.first);
    expect(draft.materials, {store.executorMaterials.first: 2});
    expect(draft.work, 'Тығыздағыш ауыстырылды');
    expect(tester.takeException(), isNull);
  });
}
