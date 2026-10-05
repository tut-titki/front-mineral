import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mineral/features/auth/screens/login_screen.dart';
import 'package:mineral/features/splash/screens/splash_screen.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/features/master/screens/master_shell.dart';
import 'package:mineral/core/services/photo_picker_service.dart';
import 'package:mineral/core/services/notification_sound.dart';
import 'package:mineral/core/theme/app_theme.dart';
import 'package:mineral/l10n/app_locale.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/features/executor/screens/executor_screen.dart';

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
        routes: {
          '/master': (_) => MasterShell(store: store),
          '/executor': (_) => ExecutorScreen(store: store, employeeId: 1),
        },
        home: const SplashScreen(nextScreen: LoginScreen()),
      ),
    );
  }
}
