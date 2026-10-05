import 'package:flutter/material.dart';
import 'helpers/localization_assertions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_locale.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/features/master/screens/master_shell.dart';
import 'package:mineral/features/orders/screens/order_screens.dart';
import 'package:mineral/core/theme/app_theme.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  testWidgets('all ARB-backed labels and composed values translate to Kazakh', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('kk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SizedBox()),
      ),
    );
    final context = tester.element(find.byType(Scaffold));
    for (final entry in russianMessages.entries.where(
      (e) => !e.key.startsWith('@'),
    )) {
      final source = entry.value as String;
      if (source.contains('{')) continue;
      // Direct-key widgets need no adapter; audit every mapped source label.
      final mapped = uiText(context, source);
      if (mapped != source || source == kazakhMessages[entry.key]) {
        expect(mapped, kazakhMessages[entry.key], reason: entry.key);
      }
    }
    final s = strings(context);
    expect(uiText(context, 'Бригада №1'), s.brigadeNumber('1'));
    expect(
      uiText(context, 'Сварщик · 5 разряд'),
      s.employeeGrade(s.welderSpecialty, '5'),
    );
    expect(
      uiText(context, 'Дробилка КМД-1750 · Дробление'),
      '${s.crusherEquipment} · ${s.crushingArea}',
    );
    expect(uiText(context, 'Подшипник · шт: 2.0'), '${s.bearingMaterial}: 2.0');
    expect(
      uiText(
        context,
        'Демо-ответ: здесь появятся рекомендации по запросу «Кто свободен?». Для анализа необходимо подключить backend и ИИ.',
      ),
      s.masterDemoAnswer('Кто свободен?'),
    );
    expect(uiText(context, 'Пользовательский текст'), 'Пользовательский текст');
  });

  testWidgets(
    'master order details and imported history translate for every status',
    (tester) async {
      final store = DemoStore();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        store.dispose();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final order = store.orders.first;
      for (final status in OrderStatus.values) {
        order.status = status;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('kk'),
            theme: buildAppTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OrderDetailScreen(store: store, order: order),
          ),
        );
        await tester.pumpAndSettle();
        checkNoRussianLabels(tester);
        expect(tester.takeException(), isNull, reason: status.name);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
  for (final width in [390.0, 1400.0]) {
    testWidgets('master pages switch languages at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      final store = DemoStore();
      appLocale.value = const Locale('kk');
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        store.dispose();
        appLocale.value = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        ValueListenableBuilder<Locale?>(
          valueListenable: appLocale,
          builder: (context, locale, child) => MaterialApp(
            locale: locale,
            theme: buildAppTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MasterShell(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final s = AppLocalizations.of(tester.element(find.byType(MasterShell)));
      expect(find.text(s.dashboard), findsWidgets);
      checkNoRussianLabels(tester);
      expect(tester.takeException(), isNull);

      final destinations = [
        s.orders,
        s.team,
        if (width >= 1000) s.aiControl,
        s.reports,
      ];
      for (final destination in destinations) {
        final target = width >= 1000
            ? find.widgetWithText(ListTile, destination)
            : find.widgetWithText(NavigationDestination, destination);
        await tester.tap(target);
        await tester.pumpAndSettle();
        checkNoRussianLabels(tester);
        expect(tester.takeException(), isNull);
      }
      appLocale.value = const Locale('ru');
      await tester.pumpAndSettle();
      expect(find.text('Отчёты и рейтинг'), findsOneWidget);
      expect(store.orders.first.priority, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Kazakh form preserves mock values and translates new history', (
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
        locale: const Locale('kk'),
        theme: buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CreateOrderScreen(store: store),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final context = tester.element(find.byType(CreateOrderScreen));
    final s = AppLocalizations.of(context);
    expect(find.text(s.problemWorks), findsOneWidget);
    expect(uiText(context, 'Свободен'), s.available);
    expect(
      uiText(context, 'В работе · №147 · очередь 2'),
      s.workingQueue('147', '2'),
    );
    expect(uiText(context, 'Насос Н-12'), s.pumpEquipment);
    final seed = store.orders.first.history.first;
    expect(eventText(context, seed), s.orderIssuedLabel);
    final order = store.issueOrder(
      title: 'Тестовый ремонт',
      description: 'Описание теста',
      area: 'Обогащение',
      equipment: 'Насос Н-12',
      employeeId: 3,
      priority: 'Обычный',
      planned: false,
      normHours: 2,
    );
    expect(
      eventText(context, order.history.last),
      s.eventIssued(store.assignmentLabel(order)),
    );
    expect(order.description, 'Описание теста');
    expect(order.priority, 'Обычный');
    checkNoRussianLabels(tester);
    expect(tester.takeException(), isNull);
  });
}
