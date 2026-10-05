import 'package:flutter/material.dart';
import 'package:mineral/l10n/app_localizations.dart';

import 'phone_input_formatter.dart';
import 'auth_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _patronymic = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  int _step = 0;
  bool _hidePassword = true;

  @override
  void dispose() {
    _lastName.dispose();
    _firstName.dispose();
    _patronymic.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _continue() {
    if (_nameFormKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() => _step = 1);
    }
  }

  void _register() {
    if (!_accountFormKey.currentState!.validate()) return;

    // Вызов Api регистрации
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: AppLocalizations.of(context).registrationTitle,
      subtitle: _step == 0
          ? AppLocalizations.of(context).nameSubtitle
          : AppLocalizations.of(context).accountSubtitle,
      step: _step + 1,
      onBack: () {
        FocusScope.of(context).unfocus();
        if (_step == 1) {
          setState(() => _step = 0);
        } else {
          Navigator.of(context).pop();
        }
      },
      footer: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(AppLocalizations.of(context).alreadyHaveAccount),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _step == 0 ? _buildNameStep() : _buildAccountStep(),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Form(
      key: _nameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _lastName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: [AutofillHints.familyName],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).lastName,
            ),
            validator: (value) => (value ?? '').trim().isEmpty
                ? AppLocalizations.of(context).enterLastName
                : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _firstName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: [AutofillHints.givenName],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).firstName,
            ),
            validator: (value) => (value ?? '').trim().isEmpty
                ? AppLocalizations.of(context).enterFirstName
                : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _patronymic,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: [AutofillHints.middleName],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).patronymic,
              helperText: AppLocalizations.of(context).ifAvailable,
            ),
          ),
          SizedBox(height: 28),
          FilledButton(
            onPressed: _continue,
            child: Text(AppLocalizations.of(context).continueButton),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep() {
    return Form(
      key: _accountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: const [PhoneInputFormatter()],
            autofillHints: [AutofillHints.telephoneNumber],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).phoneLabel,
              hintText: "+7 700 123 45 67",
            ),
            validator: (value) => validatePhone(
              value,
              emptyMessage: AppLocalizations.of(context).enterPhone,
              incompleteMessage: AppLocalizations.of(context).incompletePhone,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _password,
            obscureText: _hidePassword,
            autofillHints: [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).passwordLabel,
              helperText: AppLocalizations.of(context).passwordHint,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
                },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),

            validator: (value) {
              if (value == null || value.length < 8) {
                return AppLocalizations.of(context).passwordTooShort;
              }
              return null;
            },
          ),
          SizedBox(height: 28),
          FilledButton(
            onPressed: _register,
            child: Text(AppLocalizations.of(context).registerButton),
          ),
        ],
      ),
    );
  }
}
