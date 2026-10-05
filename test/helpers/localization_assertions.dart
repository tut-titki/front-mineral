import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final russianMessages =
    jsonDecode(File('lib/l10n/app_ru.arb').readAsStringSync())
        as Map<String, dynamic>;
final kazakhMessages =
    jsonDecode(File('lib/l10n/app_kk.arb').readAsStringSync())
        as Map<String, dynamic>;

void checkNoRussianLabels(WidgetTester tester) {
  final russianLabels = russianMessages.entries
      .where(
        (entry) =>
            !entry.key.startsWith('@') &&
            entry.value is String &&
            entry.value != kazakhMessages[entry.key] &&
            !entry.value.contains('{'),
      )
      .map((e) => e.value)
      .toSet();
  void check(String? value) => expect(
    russianLabels.contains(value),
    isFalse,
    reason: 'Untranslated UI: $value',
  );
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    check(text.data ?? text.textSpan?.toPlainText());
  }
  for (final tooltip in tester.widgetList<Tooltip>(find.byType(Tooltip))) {
    check(tooltip.message);
  }
  for (final field in tester.widgetList<InputDecorator>(
    find.byType(InputDecorator),
  )) {
    check(field.decoration.labelText);
    check(field.decoration.hintText);
    check(field.decoration.errorText);
  }
  for (final destination in tester.widgetList<NavigationDestination>(
    find.byType(NavigationDestination),
  )) {
    check(destination.label);
  }
}
