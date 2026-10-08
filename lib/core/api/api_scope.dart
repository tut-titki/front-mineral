import 'package:flutter/widgets.dart';

import 'api_services.dart';

/// Gives nested screens access to the same authenticated API client.
class ApiScope extends InheritedWidget {
  const ApiScope({super.key, required this.api, required super.child});

  final ApiServices api;

  static ApiServices? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ApiScope>()?.api;

  @override
  bool updateShouldNotify(ApiScope oldWidget) => api != oldWidget.api;
}
