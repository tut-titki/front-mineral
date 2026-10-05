import 'package:flutter/material.dart';

import 'phone_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  const new({super.key});

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
    const blue = Color(0xFF01408B);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Назад',
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_step == 1) {
                          setState(() => _step = 0);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Создание аккаунта',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    _stepIndicator(0, 'Личные данные'),
                    const SizedBox(width: 12),
                    _stepIndicator(1, 'Доступ к аккаунту'),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E7F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: blue, width: 1.5),
                        ),
                      ),
                      filledButtonTheme: FilledButtonThemeData(
                        style: FilledButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _step == 0
                            ? _buildNameStep()
                            : _buildAccountStep(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator(int index, String label) {
    final active = _step >= index;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 4,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF01408B) : const Color(0xFFDDE3ED),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${index + 1}. $label',
            style: TextStyle(
              color: active ? const Color(0xFF01408B) : const Color(0xFF748095),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Form(
      key: _nameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Как вас зовут?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Укажите данные для вашего профиля.',
            style: TextStyle(color: Color(0xFF748095)),
          ),
          SizedBox(height: 24),
          TextFormField(
            controller: _lastName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: [AutofillHints.familyName],
            decoration: InputDecoration(labelText: "Фамилия"),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Введите фамилию' : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _firstName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: [AutofillHints.givenName],
            decoration: InputDecoration(labelText: "Имя"),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Введите имя' : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _patronymic,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: [AutofillHints.middleName],
            decoration: InputDecoration(
              labelText: "Отчество",
              helperText: 'При наличии',
            ),
          ),
          SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _continue,
            label: const Text('Продолжить'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
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
          Text("Данные для входа", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          const Text(
            'Используйте телефон и пароль для входа в аккаунт.',
            style: TextStyle(color: Color(0xFF748095)),
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
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: validatePhone,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _password,
            obscureText: _hidePassword,
            autofillHints: [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: "Пароль",
              helperText: "Минимум 8 символов",
              prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                return "Пароль должен содержать минимум 8 символов";
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          FilledButton(onPressed: _register, child: Text("Зарегистрироваться")),
        ],
      ),
    );
  }
}
