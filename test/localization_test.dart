import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/auth/login_screen.dart';
import 'package:mineral/auth/auth_page.dart';
import 'package:mineral/l10n/app_localizations.dart';

void main() {
  testWidgets('button text animates from default to auth style', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthPage(
          title: 'Login',
          subtitle: '',
          footer: TextButton(onPressed: () {}, child: const Text('Register')),
          child: const SizedBox(),
        ),
      ),
    );
    final context = tester.element(find.byType(TextButton));
    final style = Theme.of(context).textButtonTheme.style!;
    final base = Theme.of(context).textTheme.labelLarge!;
    Widget button(ButtonStyle? buttonStyle) => MaterialApp(
      home: Scaffold(
        body: TextButton(
          style: buttonStyle,
          onPressed: () {},
          child: const Text('Register'),
        ),
      ),
    );
    await tester.pumpWidget(button(TextButton.styleFrom(textStyle: base)));
    await tester.pumpAndSettle();
    await tester.pumpWidget(button(style));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  });
  for (final language in ['ru', 'kk']) {
    testWidgets('login and validation use $language translations', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(LoginScreen));
      final strings = AppLocalizations.of(context);
      expect(strings.localeName, language);
      expect(find.text(strings.phoneLabel), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, strings.loginButton));
      await tester.pumpAndSettle();
      expect(find.text(strings.enterPhone), findsOneWidget);
      expect(find.text(strings.enterPassword), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
