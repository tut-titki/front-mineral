import 'package:flutter/material.dart';
import 'package:mineral/auth/login_screen.dart';
import 'package:mineral/splash_screen.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/app_locale.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const logoBlue = Color(0xFF01408B);

    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, value, child) {
        return MaterialApp(
          locale: value,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: logoBlue),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: logoBlue,
                foregroundColor: Colors.white,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: logoBlue),
            ),
          ),
          home: const SplashScreen(nextScreen: LoginScreen()),
        );
      },
    );
  }
}
