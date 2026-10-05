// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginSubtitle => 'Введите телефон и пароль вашего аккаунта.';

  @override
  String get registrationTitle => 'Регистрация';

  @override
  String get nameSubtitle => 'Укажите фамилию, имя и отчество.';

  @override
  String get accountSubtitle => 'Добавьте телефон и придумайте пароль.';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get phoneLabel => 'Номер телефона';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get lastName => 'Фамилия';

  @override
  String get firstName => 'Имя';

  @override
  String get patronymic => 'Отчество';

  @override
  String get enterLastName => 'Введите фамилию';

  @override
  String get enterFirstName => 'Введите имя';

  @override
  String get ifAvailable => 'При наличии';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get passwordHint => 'Минимум 8 символов';

  @override
  String get passwordTooShort => 'Пароль должен содержать минимум 8 символов';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get back => 'Назад';

  @override
  String get enterPhone => 'Введите номер телефона';

  @override
  String get incompletePhone => 'Введите номер полностью';

  @override
  String stepLabel(int step) {
    return 'Шаг $step из 2';
  }
}
