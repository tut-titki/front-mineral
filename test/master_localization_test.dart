import 'helpers/backend_api_fixture.dart';
import 'package:flutter/material.dart';
import 'helpers/localization_assertions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/features/master/screens/master_shell.dart';
import 'package:mineral/core/theme/app_theme.dart';

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

  for (final width in [390.0, 1400.0]) {
    testWidgets('backend master pages localize at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = testApi();
      addTearDown(api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('kk'),
          theme: buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MasterShell(api: api),
        ),
      );
      await tester.pumpAndSettle();
      for (var index = 0; index < 6; index++) {
        final navigation = width < 1000
            ? find.byType(NavigationDestination).at(index)
            : find.byType(ListTile).at(index);
        await tester.tap(navigation);
        await tester.pumpAndSettle();
        checkNoRussianLabels(tester);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
