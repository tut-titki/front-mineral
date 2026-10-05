import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/main.dart';
import 'package:mineral/core/theme/app_theme.dart';

Future<void> openLogin(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MainApp());
  await tester.pump(const Duration(milliseconds: 2500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('splash and login open executor with three mobile destinations', (
    tester,
  ) async {
    await openLogin(tester);
    expect(find.text('Вход'), findsOneWidget);
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Введите номер телефона'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '7001234567');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Мои наряды'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.text('ИИ'), findsNothing);
    final context = tester.element(find.byType(NavigationBar));
    expect(Theme.of(context).colorScheme.primary, AppColors.primary);
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Мой рейтинг'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration keeps both steps and opens master', (tester) async {
    await openLogin(tester);
    await tester.tap(find.text('Создать аккаунт'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Омаров');
    await tester.enterText(find.byType(TextFormField).at(1), 'Серик');
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
    await tester.enterText(find.byType(TextFormField).at(0), '7001234567');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(find.text('Зарегистрироваться'));
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();
    expect(find.text('Обзор смены'), findsOneWidget);
    expect(find.text('Создание аккаунта'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
