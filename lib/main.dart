import 'package:flutter/material.dart';

import 'auth/login_screen.dart';
import 'splash_screen.dart';
import 'src/demo_store.dart';
import 'src/master_shell.dart';
import 'src/photo_picker_service.dart';
import 'theme.dart';

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final store = DemoStore();

  @override
  void initState() {
    super.initState();
    PhotoPickerService.instance.recoverLostPhotos();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mineral · Мастер смены',
      theme: buildAppTheme(),
      routes: {'/master': (_) => MasterShell(store: store)},
      home: const SplashScreen(nextScreen: LoginScreen()),
    );
  }
}
