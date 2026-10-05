import 'package:flutter/material.dart';
import 'dart:async';

import 'auth/login_screen.dart';
import 'splash_screen.dart';
import 'src/demo_store.dart';
import 'src/master_shell.dart';
import 'src/photo_picker_service.dart';
import 'src/notification_sound.dart';
import 'theme.dart';
import 'l10n/app_locale.dart';
import 'l10n/app_localizations.dart';
import 'l10n/ui_localization.dart';

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final notificationSound = NotificationSound();
  late final store = DemoStore(onOrderChanged: notificationSound.play);

  @override
  void initState() {
    super.initState();
    PhotoPickerService.instance.recoverLostPhotos();
  }

  @override
  void dispose() {
    store.dispose();
    unawaited(notificationSound.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, locale, _) => MaterialApp(
        locale: locale ?? const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) =>
            'Mineral · ${strings(context).masterRole}',
        theme: buildAppTheme(),
        routes: {'/master': (_) => MasterShell(store: store)},
        home: const SplashScreen(nextScreen: LoginScreen()),
      ),
    );
  }
}
