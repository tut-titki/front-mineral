import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mineral/app/app.dart';

export 'package:mineral/app/app.dart' show MainApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MainApp(demoMode: bool.fromEnvironment('DEMO_MODE')));
}
