import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('kk'),
  ];

  /// No description provided for @exportReport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт'**
  String get exportReport;

  /// No description provided for @reportPeriodHint.
  ///
  /// In ru, this message translates to:
  /// **'Наряды, выданные за выбранный период'**
  String get reportPeriodHint;

  /// No description provided for @todayPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get todayPeriod;

  /// No description provided for @weekPeriod.
  ///
  /// In ru, this message translates to:
  /// **'7 дней'**
  String get weekPeriod;

  /// No description provided for @monthPeriod.
  ///
  /// In ru, this message translates to:
  /// **'30 дней'**
  String get monthPeriod;

  /// No description provided for @allTimePeriod.
  ///
  /// In ru, this message translates to:
  /// **'Всё время'**
  String get allTimePeriod;

  /// No description provided for @noPeriodEmployees.
  ///
  /// In ru, this message translates to:
  /// **'За этот период нет исполнителей с нарядами'**
  String get noPeriodEmployees;

  /// No description provided for @editOrder.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование наряда'**
  String get editOrder;

  /// No description provided for @changeDeadline.
  ///
  /// In ru, this message translates to:
  /// **'Изменить срок выполнения'**
  String get changeDeadline;

  /// No description provided for @brigadeMembers.
  ///
  /// In ru, this message translates to:
  /// **'Состав бригады'**
  String get brigadeMembers;

  /// No description provided for @brigades.
  ///
  /// In ru, this message translates to:
  /// **'Бригады'**
  String get brigades;

  /// No description provided for @teamBrigadeSearch.
  ///
  /// In ru, this message translates to:
  /// **'Бригада, имя или специальность'**
  String get teamBrigadeSearch;

  /// No description provided for @eventDeadline.
  ///
  /// In ru, this message translates to:
  /// **'Срок изменён: {value}'**
  String eventDeadline(String value);

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @applyFilters.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get resetFilters;

  /// No description provided for @closeFilters.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть фильтры'**
  String get closeFilters;

  /// No description provided for @statusFilter.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get statusFilter;

  /// No description provided for @onlyOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Только просроченные'**
  String get onlyOverdue;

  /// No description provided for @clearSearch.
  ///
  /// In ru, this message translates to:
  /// **'Очистить поиск'**
  String get clearSearch;

  /// No description provided for @attachPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить фото'**
  String get attachPhoto;

  /// No description provided for @choosePhotoSource.
  ///
  /// In ru, this message translates to:
  /// **'Выберите источник фото'**
  String get choosePhotoSource;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите телефон и пароль вашего аккаунта.'**
  String get loginSubtitle;

  /// No description provided for @registrationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registrationTitle;

  /// No description provided for @nameSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Укажите фамилию, имя и отчество.'**
  String get nameSubtitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте телефон и придумайте пароль.'**
  String get accountSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войти'**
  String get alreadyHaveAccount;

  /// No description provided for @phoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get hidePassword;

  /// No description provided for @enterPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get enterPassword;

  /// No description provided for @loginButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginButton;

  /// No description provided for @lastName.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get lastName;

  /// No description provided for @firstName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get firstName;

  /// No description provided for @patronymic.
  ///
  /// In ru, this message translates to:
  /// **'Отчество'**
  String get patronymic;

  /// No description provided for @enterLastName.
  ///
  /// In ru, this message translates to:
  /// **'Введите фамилию'**
  String get enterLastName;

  /// No description provided for @enterFirstName.
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get enterFirstName;

  /// No description provided for @ifAvailable.
  ///
  /// In ru, this message translates to:
  /// **'При наличии'**
  String get ifAvailable;

  /// No description provided for @continueButton.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueButton;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 8 символов'**
  String get passwordHint;

  /// No description provided for @passwordTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать минимум 8 символов'**
  String get passwordTooShort;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerButton;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @enterPhone.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона'**
  String get enterPhone;

  /// No description provided for @incompletePhone.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер полностью'**
  String get incompletePhone;

  /// No description provided for @stepLabel.
  ///
  /// In ru, this message translates to:
  /// **'Шаг {step} из 2'**
  String stepLabel(int step);

  /// No description provided for @dashboard.
  ///
  /// In ru, this message translates to:
  /// **'Обзор смены'**
  String get dashboard;

  /// No description provided for @greeting.
  ///
  /// In ru, this message translates to:
  /// **'Здравствуйте, Серик. Вот что происходит на участке.'**
  String get greeting;

  /// No description provided for @createOrder.
  ///
  /// In ru, this message translates to:
  /// **'Создать наряд'**
  String get createOrder;

  /// No description provided for @issuedOrders.
  ///
  /// In ru, this message translates to:
  /// **'Выдано нарядов'**
  String get issuedOrders;

  /// No description provided for @completed.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get completed;

  /// No description provided for @overdue.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get overdue;

  /// No description provided for @awaitingAcceptance.
  ///
  /// In ru, this message translates to:
  /// **'На приёмке'**
  String get awaitingAcceptance;

  /// No description provided for @equipmentStopped.
  ///
  /// In ru, this message translates to:
  /// **'Оборудование в простое'**
  String get equipmentStopped;

  /// No description provided for @needsAttention.
  ///
  /// In ru, this message translates to:
  /// **'Требуют внимания'**
  String get needsAttention;

  /// No description provided for @noAttention.
  ///
  /// In ru, this message translates to:
  /// **'Нет нарядов, требующих внимания'**
  String get noAttention;

  /// No description provided for @shiftTeam.
  ///
  /// In ru, this message translates to:
  /// **'Команда на смене'**
  String get shiftTeam;

  /// No description provided for @allTeam.
  ///
  /// In ru, this message translates to:
  /// **'Вся команда →'**
  String get allTeam;

  /// No description provided for @allAreas.
  ///
  /// In ru, this message translates to:
  /// **'Все участки'**
  String get allAreas;

  /// No description provided for @allEquipment.
  ///
  /// In ru, this message translates to:
  /// **'Всё оборудование'**
  String get allEquipment;

  /// No description provided for @allPriorities.
  ///
  /// In ru, this message translates to:
  /// **'Все приоритеты'**
  String get allPriorities;

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @overduePlural.
  ///
  /// In ru, this message translates to:
  /// **'Просрочены'**
  String get overduePlural;

  /// No description provided for @issuedPlural.
  ///
  /// In ru, this message translates to:
  /// **'Выданные'**
  String get issuedPlural;

  /// No description provided for @acceptedPlural.
  ///
  /// In ru, this message translates to:
  /// **'Принятые'**
  String get acceptedPlural;

  /// No description provided for @working.
  ///
  /// In ru, this message translates to:
  /// **'В работе'**
  String get working;

  /// No description provided for @queued.
  ///
  /// In ru, this message translates to:
  /// **'В очереди'**
  String get queued;

  /// No description provided for @completedPlural.
  ///
  /// In ru, this message translates to:
  /// **'Выполненные'**
  String get completedPlural;

  /// No description provided for @pausedPlural.
  ///
  /// In ru, this message translates to:
  /// **'Приостановлены'**
  String get pausedPlural;

  /// No description provided for @rework.
  ///
  /// In ru, this message translates to:
  /// **'На доработке'**
  String get rework;

  /// No description provided for @rejectedPlural.
  ///
  /// In ru, this message translates to:
  /// **'Отклонены'**
  String get rejectedPlural;

  /// No description provided for @cancelledPlural.
  ///
  /// In ru, this message translates to:
  /// **'Отменены'**
  String get cancelledPlural;

  /// No description provided for @orders.
  ///
  /// In ru, this message translates to:
  /// **'Наряды'**
  String get orders;

  /// No description provided for @ordersSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Назначения, сроки и текущие статусы работ'**
  String get ordersSubtitle;

  /// No description provided for @newOrder.
  ///
  /// In ru, this message translates to:
  /// **'Новый наряд'**
  String get newOrder;

  /// No description provided for @listView.
  ///
  /// In ru, this message translates to:
  /// **'Список'**
  String get listView;

  /// No description provided for @kanban.
  ///
  /// In ru, this message translates to:
  /// **'Канбан'**
  String get kanban;

  /// No description provided for @orderSearch.
  ///
  /// In ru, this message translates to:
  /// **'Номер, работа или оборудование'**
  String get orderSearch;

  /// No description provided for @area.
  ///
  /// In ru, this message translates to:
  /// **'Участок'**
  String get area;

  /// No description provided for @equipment.
  ///
  /// In ru, this message translates to:
  /// **'Оборудование'**
  String get equipment;

  /// No description provided for @employee.
  ///
  /// In ru, this message translates to:
  /// **'Исполнитель'**
  String get employee;

  /// No description provided for @allEmployees.
  ///
  /// In ru, this message translates to:
  /// **'Все исполнители'**
  String get allEmployees;

  /// No description provided for @priority.
  ///
  /// In ru, this message translates to:
  /// **'Приоритет'**
  String get priority;

  /// No description provided for @noFilteredOrders.
  ///
  /// In ru, this message translates to:
  /// **'По выбранным фильтрам нарядов нет'**
  String get noFilteredOrders;

  /// No description provided for @overdueOrders.
  ///
  /// In ru, this message translates to:
  /// **'Просроченные'**
  String get overdueOrders;

  /// No description provided for @demoRating.
  ///
  /// In ru, this message translates to:
  /// **'Демо-рейтинг'**
  String get demoRating;

  /// No description provided for @available.
  ///
  /// In ru, this message translates to:
  /// **'Свободен'**
  String get available;

  /// No description provided for @team.
  ///
  /// In ru, this message translates to:
  /// **'Команда'**
  String get team;

  /// No description provided for @teamSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка исполнителей, специальности и доступность'**
  String get teamSubtitle;

  /// No description provided for @employeeSearch.
  ///
  /// In ru, this message translates to:
  /// **'Имя или специальность'**
  String get employeeSearch;

  /// No description provided for @onlyAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Только свободные'**
  String get onlyAvailable;

  /// No description provided for @noEmployees.
  ///
  /// In ru, this message translates to:
  /// **'Исполнители не найдены'**
  String get noEmployees;

  /// No description provided for @aiControl.
  ///
  /// In ru, this message translates to:
  /// **'ИИ-контроль'**
  String get aiControl;

  /// No description provided for @aiSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендации цифрового контролёра. Финальное решение принимает мастер.'**
  String get aiSubtitle;

  /// No description provided for @deadlineControl.
  ///
  /// In ru, this message translates to:
  /// **'Контроль сроков'**
  String get deadlineControl;

  /// No description provided for @deadlineHelp.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание за 30 минут до срока. Эскалация, если обычный наряд не принят за 10 минут, аварийный — за 3 минуты.'**
  String get deadlineHelp;

  /// No description provided for @completionCheck.
  ///
  /// In ru, this message translates to:
  /// **'Проверка выполнения'**
  String get completionCheck;

  /// No description provided for @noReviewOrders.
  ///
  /// In ru, this message translates to:
  /// **'Нет нарядов на проверке'**
  String get noReviewOrders;

  /// No description provided for @photoAnalysis.
  ///
  /// In ru, this message translates to:
  /// **'Анализ фото до / после'**
  String get photoAnalysis;

  /// No description provided for @photoAnalysisHelp.
  ///
  /// In ru, this message translates to:
  /// **'Проверка наличия и актуальности фото, сравнение оборудования и видимых дефектов. При низкой уверенности потребуется проверка мастера.'**
  String get photoAnalysisHelp;

  /// No description provided for @orderReport.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт по наряду'**
  String get orderReport;

  /// No description provided for @orderReportHelp.
  ///
  /// In ru, this message translates to:
  /// **'Работы, материалы, хронология, соблюдение срока и объяснение оценки собраны в карточке наряда.'**
  String get orderReportHelp;

  /// No description provided for @equipmentAnomalies.
  ///
  /// In ru, this message translates to:
  /// **'Аномалии оборудования'**
  String get equipmentAnomalies;

  /// No description provided for @employeeRating.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг исполнителей'**
  String get employeeRating;

  /// No description provided for @ratingHelp.
  ///
  /// In ru, this message translates to:
  /// **'Качество, выполнение в срок, доработки, сложность работ и обоснованность отказов формируют оценку.'**
  String get ratingHelp;

  /// No description provided for @masterAssistant.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент мастера'**
  String get masterAssistant;

  /// No description provided for @chatHelp.
  ///
  /// In ru, this message translates to:
  /// **'Макет чата. Ответы демонстрационные.'**
  String get chatHelp;

  /// No description provided for @chatHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: кто сейчас свободен?'**
  String get chatHint;

  /// No description provided for @showDemoAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Показать демо-ответ'**
  String get showDemoAnswer;

  /// No description provided for @reportsRating.
  ///
  /// In ru, this message translates to:
  /// **'Отчёты и рейтинг'**
  String get reportsRating;

  /// No description provided for @reportsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сводка текущей демонстрационной смены'**
  String get reportsSubtitle;

  /// No description provided for @pdfNotReady.
  ///
  /// In ru, this message translates to:
  /// **'Выгрузку PDF подключим вместе с backend'**
  String get pdfNotReady;

  /// No description provided for @exportPdf.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт PDF'**
  String get exportPdf;

  /// No description provided for @excelNotReady.
  ///
  /// In ru, this message translates to:
  /// **'Выгрузку Excel подключим вместе с backend'**
  String get excelNotReady;

  /// No description provided for @exportExcel.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт Excel'**
  String get exportExcel;

  /// No description provided for @periodNotReady.
  ///
  /// In ru, this message translates to:
  /// **'Отчёты за произвольный период подключим после добавления истории на backend'**
  String get periodNotReady;

  /// No description provided for @selectPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать период'**
  String get selectPeriod;

  /// No description provided for @totalOrders.
  ///
  /// In ru, this message translates to:
  /// **'Всего нарядов'**
  String get totalOrders;

  /// No description provided for @closed.
  ///
  /// In ru, this message translates to:
  /// **'Закрыто'**
  String get closed;

  /// No description provided for @rejected.
  ///
  /// In ru, this message translates to:
  /// **'Отклонено'**
  String get rejected;

  /// No description provided for @equipmentDowntime.
  ///
  /// In ru, this message translates to:
  /// **'Простои оборудования'**
  String get equipmentDowntime;

  /// No description provided for @downtimeReportHelp.
  ///
  /// In ru, this message translates to:
  /// **'Макет отчёта: время остановки по оборудованию, причины и доля плановых / внеплановых работ.'**
  String get downtimeReportHelp;

  /// No description provided for @usedMaterials.
  ///
  /// In ru, this message translates to:
  /// **'Списанные материалы'**
  String get usedMaterials;

  /// No description provided for @materialsReportHelp.
  ///
  /// In ru, this message translates to:
  /// **'Макет отчёта: расход по материалам, участкам и исполнителям, сравнение с нормативами.'**
  String get materialsReportHelp;

  /// No description provided for @notificationCenter.
  ///
  /// In ru, this message translates to:
  /// **'Центр уведомлений'**
  String get notificationCenter;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Локальные уведомления прототипа. Push не подключён.'**
  String get notificationsSubtitle;

  /// No description provided for @noNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Новых уведомлений нет'**
  String get noNotifications;

  /// No description provided for @awaitingReview.
  ///
  /// In ru, this message translates to:
  /// **'Работа ожидает приёмки'**
  String get awaitingReview;

  /// No description provided for @emergencyAwaiting.
  ///
  /// In ru, this message translates to:
  /// **'Аварийный наряд ожидает ответа'**
  String get emergencyAwaiting;

  /// No description provided for @normalPriority.
  ///
  /// In ru, this message translates to:
  /// **'Обычный'**
  String get normalPriority;

  /// No description provided for @permissionDenied.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите доступ к камере или фото в настройках приложения.'**
  String get permissionDenied;

  /// No description provided for @pickerFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть камеру или галерею. Попробуйте ещё раз.'**
  String get pickerFailed;

  /// No description provided for @photoLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить фото. Выберите другой снимок.'**
  String get photoLoadFailed;

  /// No description provided for @deadline.
  ///
  /// In ru, this message translates to:
  /// **'Срок исполнения'**
  String get deadline;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @select.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get select;

  /// No description provided for @executionTime.
  ///
  /// In ru, this message translates to:
  /// **'Время исполнения'**
  String get executionTime;

  /// No description provided for @futureDeadline.
  ///
  /// In ru, this message translates to:
  /// **'Выберите срок в будущем.'**
  String get futureDeadline;

  /// No description provided for @createOrderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создание наряда'**
  String get createOrderTitle;

  /// No description provided for @workDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание работ'**
  String get workDescription;

  /// No description provided for @unplanned.
  ///
  /// In ru, this message translates to:
  /// **'Внеплановый'**
  String get unplanned;

  /// No description provided for @planned.
  ///
  /// In ru, this message translates to:
  /// **'Плановый'**
  String get planned;

  /// No description provided for @optionalWorkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название работы (необязательно)'**
  String get optionalWorkTitle;

  /// No description provided for @problemWorks.
  ///
  /// In ru, this message translates to:
  /// **'Проблема и необходимые работы'**
  String get problemWorks;

  /// No description provided for @voiceInput.
  ///
  /// In ru, this message translates to:
  /// **'Голосовой ввод'**
  String get voiceInput;

  /// No description provided for @voiceNotReady.
  ///
  /// In ru, this message translates to:
  /// **'Голосовой ввод подключим позже.'**
  String get voiceNotReady;

  /// No description provided for @describeProblem.
  ///
  /// In ru, this message translates to:
  /// **'Опишите проблему'**
  String get describeProblem;

  /// No description provided for @locationAssignee.
  ///
  /// In ru, this message translates to:
  /// **'Место и исполнитель'**
  String get locationAssignee;

  /// No description provided for @brigade.
  ///
  /// In ru, this message translates to:
  /// **'Бригада'**
  String get brigade;

  /// No description provided for @selectEmployee.
  ///
  /// In ru, this message translates to:
  /// **'Выберите исполнителя'**
  String get selectEmployee;

  /// No description provided for @selectBrigade.
  ///
  /// In ru, this message translates to:
  /// **'Выберите бригаду'**
  String get selectBrigade;

  /// No description provided for @deadlinePriority.
  ///
  /// In ru, this message translates to:
  /// **'Срок и приоритет'**
  String get deadlinePriority;

  /// No description provided for @emergencyPriority.
  ///
  /// In ru, this message translates to:
  /// **'Аварийный'**
  String get emergencyPriority;

  /// No description provided for @highPriority.
  ///
  /// In ru, this message translates to:
  /// **'Высокий'**
  String get highPriority;

  /// No description provided for @normHoursShort.
  ///
  /// In ru, this message translates to:
  /// **'Норматив, ч'**
  String get normHoursShort;

  /// No description provided for @dateTime.
  ///
  /// In ru, this message translates to:
  /// **'Дата и время'**
  String get dateTime;

  /// No description provided for @normHours.
  ///
  /// In ru, this message translates to:
  /// **'Норматив в часах'**
  String get normHours;

  /// No description provided for @normRange.
  ///
  /// In ru, this message translates to:
  /// **'Укажите от 1 минуты до 8760 часов'**
  String get normRange;

  /// No description provided for @optionalFaultCode.
  ///
  /// In ru, this message translates to:
  /// **'Шифр неисправности (необязательно)'**
  String get optionalFaultCode;

  /// No description provided for @notSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Не указан'**
  String get notSpecified;

  /// No description provided for @comment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get comment;

  /// No description provided for @faultPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фото неисправности · до 5'**
  String get faultPhotos;

  /// No description provided for @issueOrder.
  ///
  /// In ru, this message translates to:
  /// **'Выдать наряд'**
  String get issueOrder;

  /// No description provided for @reason.
  ///
  /// In ru, this message translates to:
  /// **'Причина'**
  String get reason;

  /// No description provided for @specifyReason.
  ///
  /// In ru, this message translates to:
  /// **'Укажите причину'**
  String get specifyReason;

  /// No description provided for @confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get confirm;

  /// No description provided for @employeeOrBrigade.
  ///
  /// In ru, this message translates to:
  /// **'Исполнитель или бригада'**
  String get employeeOrBrigade;

  /// No description provided for @orderPriority.
  ///
  /// In ru, this message translates to:
  /// **'Приоритет наряда'**
  String get orderPriority;

  /// No description provided for @masterScore.
  ///
  /// In ru, this message translates to:
  /// **'Оценка мастера'**
  String get masterScore;

  /// No description provided for @overdueSingular.
  ///
  /// In ru, this message translates to:
  /// **'Просрочен'**
  String get overdueSingular;

  /// No description provided for @orderInformation.
  ///
  /// In ru, this message translates to:
  /// **'Информация о наряде'**
  String get orderInformation;

  /// No description provided for @workType.
  ///
  /// In ru, this message translates to:
  /// **'Тип работ'**
  String get workType;

  /// No description provided for @description.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get description;

  /// No description provided for @issueDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата выдачи'**
  String get issueDate;

  /// No description provided for @norm.
  ///
  /// In ru, this message translates to:
  /// **'Норматив'**
  String get norm;

  /// No description provided for @faultCode.
  ///
  /// In ru, this message translates to:
  /// **'Шифр неисправности'**
  String get faultCode;

  /// No description provided for @master.
  ///
  /// In ru, this message translates to:
  /// **'Мастер'**
  String get master;

  /// No description provided for @orderDowntime.
  ///
  /// In ru, this message translates to:
  /// **'Простой оборудования'**
  String get orderDowntime;

  /// No description provided for @stopped.
  ///
  /// In ru, this message translates to:
  /// **'Оборудование остановлено'**
  String get stopped;

  /// No description provided for @noDowntime.
  ///
  /// In ru, this message translates to:
  /// **'Нет активного простоя'**
  String get noDowntime;

  /// No description provided for @beforeWork.
  ///
  /// In ru, this message translates to:
  /// **'До выполнения'**
  String get beforeWork;

  /// No description provided for @afterWork.
  ///
  /// In ru, this message translates to:
  /// **'После выполнения'**
  String get afterWork;

  /// No description provided for @reassign.
  ///
  /// In ru, this message translates to:
  /// **'Переназначить'**
  String get reassign;

  /// No description provided for @changePriority.
  ///
  /// In ru, this message translates to:
  /// **'Изменить приоритет'**
  String get changePriority;

  /// No description provided for @cancelOrderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отмена наряда'**
  String get cancelOrderTitle;

  /// No description provided for @cancelOrder.
  ///
  /// In ru, this message translates to:
  /// **'Отменить наряд'**
  String get cancelOrder;

  /// No description provided for @workerReport.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт исполнителя'**
  String get workerReport;

  /// No description provided for @completedWorks.
  ///
  /// In ru, this message translates to:
  /// **'Выполненные работы'**
  String get completedWorks;

  /// No description provided for @materials.
  ///
  /// In ru, this message translates to:
  /// **'Материалы'**
  String get materials;

  /// No description provided for @notSpecifiedPlural.
  ///
  /// In ru, this message translates to:
  /// **'Не указаны'**
  String get notSpecifiedPlural;

  /// No description provided for @changeScore.
  ///
  /// In ru, this message translates to:
  /// **'Изменить оценку'**
  String get changeScore;

  /// No description provided for @acceptedByMaster.
  ///
  /// In ru, this message translates to:
  /// **'Работы приняты мастером'**
  String get acceptedByMaster;

  /// No description provided for @acceptClose.
  ///
  /// In ru, this message translates to:
  /// **'Принять и закрыть'**
  String get acceptClose;

  /// No description provided for @returnRework.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть на доработку'**
  String get returnRework;

  /// No description provided for @toRework.
  ///
  /// In ru, this message translates to:
  /// **'На доработку'**
  String get toRework;

  /// No description provided for @actionHistory.
  ///
  /// In ru, this message translates to:
  /// **'История действий'**
  String get actionHistory;

  /// No description provided for @reports.
  ///
  /// In ru, this message translates to:
  /// **'Отчёты'**
  String get reports;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @shift.
  ///
  /// In ru, this message translates to:
  /// **'Смена'**
  String get shift;

  /// No description provided for @shiftManagement.
  ///
  /// In ru, this message translates to:
  /// **'УПРАВЛЕНИЕ СМЕНОЙ'**
  String get shiftManagement;

  /// No description provided for @masterRole.
  ///
  /// In ru, this message translates to:
  /// **'Мастер смены'**
  String get masterRole;

  /// No description provided for @offShift.
  ///
  /// In ru, this message translates to:
  /// **'Не на смене'**
  String get offShift;

  /// No description provided for @aiDemoLabel.
  ///
  /// In ru, this message translates to:
  /// **'Демонстрационные данные · ИИ не подключён'**
  String get aiDemoLabel;

  /// No description provided for @photoOpenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть фото'**
  String get photoOpenFailed;

  /// No description provided for @noPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фото не прикреплены'**
  String get noPhotos;

  /// No description provided for @camera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get gallery;

  /// No description provided for @statusIssued.
  ///
  /// In ru, this message translates to:
  /// **'Выдан'**
  String get statusIssued;

  /// No description provided for @statusAccepted.
  ///
  /// In ru, this message translates to:
  /// **'Принят'**
  String get statusAccepted;

  /// No description provided for @statusPaused.
  ///
  /// In ru, this message translates to:
  /// **'Приостановлен'**
  String get statusPaused;

  /// No description provided for @statusReview.
  ///
  /// In ru, this message translates to:
  /// **'На проверке'**
  String get statusReview;

  /// No description provided for @statusClosed.
  ///
  /// In ru, this message translates to:
  /// **'Закрыт'**
  String get statusClosed;

  /// No description provided for @statusRejected.
  ///
  /// In ru, this message translates to:
  /// **'Отклонён'**
  String get statusRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменён'**
  String get statusCancelled;

  /// No description provided for @emergencyFull.
  ///
  /// In ru, this message translates to:
  /// **'Аварийный — срочно в работу'**
  String get emergencyFull;

  /// No description provided for @normalFull.
  ///
  /// In ru, this message translates to:
  /// **'Обычный — в порядке очереди'**
  String get normalFull;

  /// No description provided for @noAiVerdict.
  ///
  /// In ru, this message translates to:
  /// **'Нет заключения'**
  String get noAiVerdict;

  /// No description provided for @aiUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'ИИ пока не подключён.'**
  String get aiUnavailable;

  /// No description provided for @positiveNorm.
  ///
  /// In ru, this message translates to:
  /// **'Норматив должен быть больше нуля'**
  String get positiveNorm;

  /// No description provided for @onShiftAssignee.
  ///
  /// In ru, this message translates to:
  /// **'Выберите исполнителя или бригаду на смене'**
  String get onShiftAssignee;

  /// No description provided for @futureDeadlineError.
  ///
  /// In ru, this message translates to:
  /// **'Срок должен быть в будущем'**
  String get futureDeadlineError;

  /// No description provided for @fivePhotos.
  ///
  /// In ru, this message translates to:
  /// **'Не более 5 фото'**
  String get fivePhotos;

  /// No description provided for @employeeOffShift.
  ///
  /// In ru, this message translates to:
  /// **'Сотрудник не на смене'**
  String get employeeOffShift;

  /// No description provided for @brigadeOffShift.
  ///
  /// In ru, this message translates to:
  /// **'Бригада не на смене'**
  String get brigadeOffShift;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @complex.
  ///
  /// In ru, this message translates to:
  /// **'Минеральный комплекс'**
  String get complex;

  /// No description provided for @orderNumber.
  ///
  /// In ru, this message translates to:
  /// **'Наряд №{number}'**
  String orderNumber(String number);

  /// No description provided for @orderNumberUpper.
  ///
  /// In ru, this message translates to:
  /// **'НАРЯД №{number}'**
  String orderNumberUpper(String number);

  /// No description provided for @issuePreview.
  ///
  /// In ru, this message translates to:
  /// **'Выдача: {date}'**
  String issuePreview(String date);

  /// No description provided for @issuedAt.
  ///
  /// In ru, this message translates to:
  /// **'Выдан {date}'**
  String issuedAt(String date);

  /// No description provided for @dueAt.
  ///
  /// In ru, this message translates to:
  /// **'До {date}'**
  String dueAt(String date);

  /// No description provided for @hoursValue.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч'**
  String hoursValue(String hours);

  /// No description provided for @scoreValue.
  ///
  /// In ru, this message translates to:
  /// **'{score} из 5'**
  String scoreValue(String score);

  /// No description provided for @employeeGrade.
  ///
  /// In ru, this message translates to:
  /// **'{specialty} · {grade} разряд'**
  String employeeGrade(String specialty, String grade);

  /// No description provided for @workingOrder.
  ///
  /// In ru, this message translates to:
  /// **'В работе · №{number}'**
  String workingOrder(String number);

  /// No description provided for @workingQueue.
  ///
  /// In ru, this message translates to:
  /// **'В работе · №{number} · очередь {count}'**
  String workingQueue(String number, String count);

  /// No description provided for @queuedCount.
  ///
  /// In ru, this message translates to:
  /// **'В очереди · {count}'**
  String queuedCount(String count);

  /// No description provided for @assignedOrder.
  ///
  /// In ru, this message translates to:
  /// **'Занят · назначен №{number}'**
  String assignedOrder(String number);

  /// No description provided for @brigadeAvailability.
  ///
  /// In ru, this message translates to:
  /// **'На смене: {total} · свободны: {free} · заняты: {busy}'**
  String brigadeAvailability(String total, String free, String busy);

  /// No description provided for @overdueMinutes.
  ///
  /// In ru, this message translates to:
  /// **'Просрочка · {minutes} мин.'**
  String overdueMinutes(String minutes);

  /// No description provided for @removePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Удалить фото {number}'**
  String removePhoto(String number);

  /// No description provided for @boardCount.
  ///
  /// In ru, this message translates to:
  /// **'{label} · {count}'**
  String boardCount(String label, String count);

  /// No description provided for @shiftTime.
  ///
  /// In ru, this message translates to:
  /// **'Смена №{number} · {time}'**
  String shiftTime(String number, String time);

  /// No description provided for @aiVerdict.
  ///
  /// In ru, this message translates to:
  /// **'Вердикт ИИ: {verdict}'**
  String aiVerdict(String verdict);

  /// No description provided for @aiSummary.
  ///
  /// In ru, this message translates to:
  /// **'{explanation}\nОценка ИИ: {aiScore} / 5.\nИтоговая оценка: {score} / 5.\nОкончательное решение принимает мастер.'**
  String aiSummary(String explanation, String aiScore, String score);

  /// No description provided for @eventIssued.
  ///
  /// In ru, this message translates to:
  /// **'Наряд выдан: {assignee}'**
  String eventIssued(String assignee);

  /// No description provided for @eventReassigned.
  ///
  /// In ru, this message translates to:
  /// **'Переназначен: {assignee}'**
  String eventReassigned(String assignee);

  /// No description provided for @eventPriority.
  ///
  /// In ru, this message translates to:
  /// **'Приоритет изменён: {priority}'**
  String eventPriority(String priority);

  /// No description provided for @eventScore.
  ///
  /// In ru, this message translates to:
  /// **'Оценка мастера: {score} / 5'**
  String eventScore(String score);

  /// No description provided for @eventReason.
  ///
  /// In ru, this message translates to:
  /// **'{status}: {reason}'**
  String eventReason(String status, String reason);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
