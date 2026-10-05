import 'package:flutter/material.dart';

import 'phone_input_formatter.dart';

import 'package:mineral/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const new({super.key});

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

    // Вызов Api login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/logo_blue.png', height: 85),
                  SizedBox(height: 20),
                  Text(
                    "Вход",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: const [PhoneInputFormatter()],
                    autofillHints: [AutofillHints.telephoneNumber],
                    decoration: InputDecoration(
                      labelText: "Номер телефона",
                      hintText: "+7 700 123 45 67",
                      border: OutlineInputBorder(),
                    ),
                    validator: validatePhone,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    autofillHints: [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: "Пароль",
                      border: OutlineInputBorder(),
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

                    validator: (value) => value == null || value.isEmpty
                        ? "Введите пароль"
                        : null,
                  ),
                  SizedBox(height: 24),
                  FilledButton(onPressed: _login, child: Text("Войти")),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text("Создать аккаунт"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
