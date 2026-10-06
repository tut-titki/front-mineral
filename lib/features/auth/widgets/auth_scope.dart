import 'package:flutter/material.dart';
import '../data/auth_session.dart';

class AuthScope extends InheritedNotifier<AuthSession> {
  const AuthScope({
    super.key,
    required AuthSession session,
    required super.child,
  }) : super(notifier: session);
  static AuthSession? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
}
