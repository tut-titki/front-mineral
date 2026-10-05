// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get loginTitle => 'Кіру';

  @override
  String get loginSubtitle => 'Телефон нөміріңіз бен құпиясөзіңізді енгізіңіз.';

  @override
  String get registrationTitle => 'Тіркелу';

  @override
  String get nameSubtitle =>
      'Тегіңізді, атыңызды және әкеңіздің атын енгізіңіз.';

  @override
  String get accountSubtitle =>
      'Телефон нөміріңізді енгізіп, құпиясөз жасаңыз.';

  @override
  String get createAccount => 'Тіркелгі жасау';

  @override
  String get alreadyHaveAccount => 'Тіркелгіңіз бар ма? Кіру';

  @override
  String get phoneLabel => 'Телефон нөмірі';

  @override
  String get passwordLabel => 'Құпиясөз';

  @override
  String get showPassword => 'Құпиясөзді көрсету';

  @override
  String get hidePassword => 'Құпиясөзді жасыру';

  @override
  String get enterPassword => 'Құпиясөзді енгізіңіз';

  @override
  String get loginButton => 'Кіру';

  @override
  String get lastName => 'Тегі';

  @override
  String get firstName => 'Аты';

  @override
  String get patronymic => 'Әкесінің аты';

  @override
  String get enterLastName => 'Тегіңізді енгізіңіз';

  @override
  String get enterFirstName => 'Атыңызды енгізіңіз';

  @override
  String get ifAvailable => 'Бар болса';

  @override
  String get continueButton => 'Жалғастыру';

  @override
  String get passwordHint => 'Кемінде 8 таңба';

  @override
  String get passwordTooShort => 'Құпиясөз кемінде 8 таңбадан тұруы керек';

  @override
  String get registerButton => 'Тіркелу';

  @override
  String get back => 'Артқа';

  @override
  String get enterPhone => 'Телефон нөмірін енгізіңіз';

  @override
  String get incompletePhone => 'Телефон нөмірін толық енгізіңіз';

  @override
  String stepLabel(int step) {
    return '2 қадамның $step-қадамы';
  }
}
