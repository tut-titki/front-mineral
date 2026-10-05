import 'package:flutter/material.dart';
import 'package:mineral/l10n/app_localizations.dart';

import 'package:mineral/features/auth/formatters/phone_input_formatter.dart';
import 'package:mineral/features/auth/widgets/auth_page.dart';

import 'package:mineral/features/auth/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    // Временный переход для визуального прототипа, без авторизации API.
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushNamedAndRemoveUntil('/master', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: AppLocalizations.of(context).loginTitle,
      subtitle: AppLocalizations.of(context).loginSubtitle,
      showLogo: true,
      footer: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
          );
        },
        child: Text(AppLocalizations.of(context).createAccount),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: const [PhoneInputFormatter()],
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).phoneLabel,
                hintText: '+7 700 123 45 67',
              ),
              validator: (value) => validatePhone(
                value,
                emptyMessage: AppLocalizations.of(context).enterPhone,
                incompleteMessage: AppLocalizations.of(context).incompletePhone,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).passwordLabel,
                suffixIcon: IconButton(
                  tooltip: _hidePassword
                      ? AppLocalizations.of(context).showPassword
                      : AppLocalizations.of(context).hidePassword,
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? AppLocalizations.of(context).enterPassword
                  : null,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _login,
              child: Text(AppLocalizations.of(context).loginButton),
            ),
          ],
        ),
      ),
    );
  }
}
