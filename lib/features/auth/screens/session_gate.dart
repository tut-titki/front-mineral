import 'package:flutter/material.dart';
import '../data/auth_session.dart';
import 'login_screen.dart';
import 'package:mineral/l10n/app_locale.dart';
import 'package:mineral/l10n/app_localizations.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key, required this.session, this.restoration});
  final AuthSession session;
  final Future<AuthUser?>? restoration;
  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late Future<AuthUser?> _restore;
  bool _navigating = false;
  @override
  void initState() {
    super.initState();
    _restore = widget.restoration ?? widget.session.restore();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AuthUser?>(
    future: _restore,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).authNetworkError),
                  TextButton(
                    onPressed: () =>
                        setState(() => _restore = widget.session.restore()),
                    child: Text(AppLocalizations.of(context).retry),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      final user = snapshot.data;
      if (user == null) return const LoginScreen();
      if (!_navigating) {
        _navigating = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          appLocale.value = Locale(user.language == 'kk' ? 'kk' : 'ru');
          Navigator.of(context).pushNamedAndRemoveUntil(
            user.mobileRoute!,
            (_) => false,
            arguments: user.id,
          );
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
  );
}
