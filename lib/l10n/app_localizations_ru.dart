// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get exportReport => 'Экспорт';

  @override
  String get reportPeriodHint => 'Наряды, выданные за выбранный период';

  @override
  String get todayPeriod => 'Сегодня';

  @override
  String get weekPeriod => '7 дней';

  @override
  String get monthPeriod => '30 дней';

  @override
  String get allTimePeriod => 'Всё время';

  @override
  String get noPeriodEmployees => 'За этот период нет исполнителей с нарядами';

  @override
  String get editOrder => 'Редактирование наряда';

  @override
  String get changeDeadline => 'Изменить срок выполнения';

  @override
  String get brigadeMembers => 'Состав бригады';

  @override
  String get brigades => 'Бригады';

  @override
  String get teamBrigadeSearch => 'Бригада, имя или специальность';

  @override
  String eventDeadline(String value) {
    return 'Срок изменён: $value';
  }

  @override
  String get filters => 'Фильтры';

  @override
  String get applyFilters => 'Применить';

  @override
  String get resetFilters => 'Сбросить';

  @override
  String get closeFilters => 'Закрыть фильтры';

  @override
  String get statusFilter => 'Статус';

  @override
  String get onlyOverdue => 'Только просроченные';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get attachPhoto => 'Прикрепить фото';

  @override
  String get choosePhotoSource => 'Выберите источник фото';

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

  @override
  String get dashboard => 'Обзор смены';

  @override
  String get greeting => 'Здравствуйте, Серик. Вот что происходит на участке.';

  @override
  String get createOrder => 'Создать наряд';

  @override
  String get issuedOrders => 'Выдано нарядов';

  @override
  String get completed => 'Выполнено';

  @override
  String get overdue => 'Просрочено';

  @override
  String get awaitingAcceptance => 'На приёмке';

  @override
  String get equipmentStopped => 'Оборудование в простое';

  @override
  String get needsAttention => 'Требуют внимания';

  @override
  String get noAttention => 'Нет нарядов, требующих внимания';

  @override
  String get shiftTeam => 'Команда на смене';

  @override
  String get allTeam => 'Вся команда →';

  @override
  String get allAreas => 'Все участки';

  @override
  String get allEquipment => 'Всё оборудование';

  @override
  String get allPriorities => 'Все приоритеты';

  @override
  String get all => 'Все';

  @override
  String get overduePlural => 'Просрочены';

  @override
  String get issuedPlural => 'Выданные';

  @override
  String get acceptedPlural => 'Принятые';

  @override
  String get working => 'В работе';

  @override
  String get queued => 'В очереди';

  @override
  String get completedPlural => 'Выполненные';

  @override
  String get pausedPlural => 'Приостановлены';

  @override
  String get rework => 'На доработке';

  @override
  String get rejectedPlural => 'Отклонены';

  @override
  String get cancelledPlural => 'Отменены';

  @override
  String get orders => 'Наряды';

  @override
  String get ordersSubtitle => 'Назначения, сроки и текущие статусы работ';

  @override
  String get newOrder => 'Новый наряд';

  @override
  String get listView => 'Список';

  @override
  String get kanban => 'Канбан';

  @override
  String get orderSearch => 'Номер, работа или оборудование';

  @override
  String get area => 'Участок';

  @override
  String get equipment => 'Оборудование';

  @override
  String get employee => 'Исполнитель';

  @override
  String get allEmployees => 'Все исполнители';

  @override
  String get priority => 'Приоритет';

  @override
  String get noFilteredOrders => 'По выбранным фильтрам нарядов нет';

  @override
  String get overdueOrders => 'Просроченные';

  @override
  String get demoRating => 'Демо-рейтинг';

  @override
  String get available => 'Свободен';

  @override
  String get team => 'Команда';

  @override
  String get teamSubtitle =>
      'Загрузка исполнителей, специальности и доступность';

  @override
  String get employeeSearch => 'Имя или специальность';

  @override
  String get onlyAvailable => 'Только свободные';

  @override
  String get noEmployees => 'Исполнители не найдены';

  @override
  String get aiControl => 'ИИ-контроль';

  @override
  String get aiSubtitle =>
      'Рекомендации цифрового контролёра. Финальное решение принимает мастер.';

  @override
  String get deadlineControl => 'Контроль сроков';

  @override
  String get deadlineHelp =>
      'Напоминание за 30 минут до срока. Эскалация, если обычный наряд не принят за 10 минут, аварийный — за 3 минуты.';

  @override
  String get completionCheck => 'Проверка выполнения';

  @override
  String get noReviewOrders => 'Нет нарядов на проверке';

  @override
  String get photoAnalysis => 'Анализ фото до / после';

  @override
  String get photoAnalysisHelp =>
      'Проверка наличия и актуальности фото, сравнение оборудования и видимых дефектов. При низкой уверенности потребуется проверка мастера.';

  @override
  String get orderReport => 'Отчёт по наряду';

  @override
  String get orderReportHelp =>
      'Работы, материалы, хронология, соблюдение срока и объяснение оценки собраны в карточке наряда.';

  @override
  String get equipmentAnomalies => 'Аномалии оборудования';

  @override
  String get employeeRating => 'Рейтинг исполнителей';

  @override
  String get ratingHelp =>
      'Качество, выполнение в срок, доработки, сложность работ и обоснованность отказов формируют оценку.';

  @override
  String get masterAssistant => 'Ассистент мастера';

  @override
  String get chatHelp => 'Макет чата. Ответы демонстрационные.';

  @override
  String get chatHint => 'Например: кто сейчас свободен?';

  @override
  String get showDemoAnswer => 'Показать демо-ответ';

  @override
  String get reportsRating => 'Отчёты и рейтинг';

  @override
  String get reportsSubtitle => 'Сводка текущей демонстрационной смены';

  @override
  String get pdfNotReady => 'Выгрузку PDF подключим вместе с backend';

  @override
  String get exportPdf => 'Экспорт PDF';

  @override
  String get excelNotReady => 'Выгрузку Excel подключим вместе с backend';

  @override
  String get exportExcel => 'Экспорт Excel';

  @override
  String get periodNotReady =>
      'Отчёты за произвольный период подключим после добавления истории на backend';

  @override
  String get selectPeriod => 'Выбрать период';

  @override
  String get totalOrders => 'Всего нарядов';

  @override
  String get closed => 'Закрыто';

  @override
  String get rejected => 'Отклонено';

  @override
  String get equipmentDowntime => 'Простои оборудования';

  @override
  String get downtimeReportHelp =>
      'Макет отчёта: время остановки по оборудованию, причины и доля плановых / внеплановых работ.';

  @override
  String get usedMaterials => 'Списанные материалы';

  @override
  String get materialsReportHelp =>
      'Макет отчёта: расход по материалам, участкам и исполнителям, сравнение с нормативами.';

  @override
  String get notificationCenter => 'Центр уведомлений';

  @override
  String get notificationsSubtitle =>
      'Локальные уведомления прототипа. Push не подключён.';

  @override
  String get noNotifications => 'Новых уведомлений нет';

  @override
  String get awaitingReview => 'Работа ожидает приёмки';

  @override
  String get emergencyAwaiting => 'Аварийный наряд ожидает ответа';

  @override
  String get normalPriority => 'Обычный';

  @override
  String get permissionDenied =>
      'Разрешите доступ к камере или фото в настройках приложения.';

  @override
  String get pickerFailed =>
      'Не удалось открыть камеру или галерею. Попробуйте ещё раз.';

  @override
  String get photoLoadFailed =>
      'Не удалось загрузить фото. Выберите другой снимок.';

  @override
  String get deadline => 'Срок исполнения';

  @override
  String get cancel => 'Отмена';

  @override
  String get select => 'Выбрать';

  @override
  String get executionTime => 'Время исполнения';

  @override
  String get futureDeadline => 'Выберите срок в будущем.';

  @override
  String get createOrderTitle => 'Создание наряда';

  @override
  String get workDescription => 'Описание работ';

  @override
  String get unplanned => 'Внеплановый';

  @override
  String get planned => 'Плановый';

  @override
  String get optionalWorkTitle => 'Название работы (необязательно)';

  @override
  String get problemWorks => 'Проблема и необходимые работы';

  @override
  String get voiceInput => 'Голосовой ввод';

  @override
  String get voiceNotReady => 'Голосовой ввод подключим позже.';

  @override
  String get describeProblem => 'Опишите проблему';

  @override
  String get locationAssignee => 'Место и исполнитель';

  @override
  String get brigade => 'Бригада';

  @override
  String get selectEmployee => 'Выберите исполнителя';

  @override
  String get selectBrigade => 'Выберите бригаду';

  @override
  String get deadlinePriority => 'Срок и приоритет';

  @override
  String get emergencyPriority => 'Аварийный';

  @override
  String get highPriority => 'Высокий';

  @override
  String get normHoursShort => 'Норматив, ч';

  @override
  String get dateTime => 'Дата и время';

  @override
  String get normHours => 'Норматив в часах';

  @override
  String get normRange => 'Укажите от 1 минуты до 8760 часов';

  @override
  String get optionalFaultCode => 'Шифр неисправности (необязательно)';

  @override
  String get notSpecified => 'Не указан';

  @override
  String get comment => 'Комментарий';

  @override
  String get faultPhotos => 'Фото неисправности · до 5';

  @override
  String get issueOrder => 'Выдать наряд';

  @override
  String get reason => 'Причина';

  @override
  String get specifyReason => 'Укажите причину';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get employeeOrBrigade => 'Исполнитель или бригада';

  @override
  String get orderPriority => 'Приоритет наряда';

  @override
  String get masterScore => 'Оценка мастера';

  @override
  String get overdueSingular => 'Просрочен';

  @override
  String get orderInformation => 'Информация о наряде';

  @override
  String get workType => 'Тип работ';

  @override
  String get description => 'Описание';

  @override
  String get issueDate => 'Дата выдачи';

  @override
  String get norm => 'Норматив';

  @override
  String get faultCode => 'Шифр неисправности';

  @override
  String get master => 'Мастер';

  @override
  String get orderDowntime => 'Простой оборудования';

  @override
  String get stopped => 'Оборудование остановлено';

  @override
  String get noDowntime => 'Нет активного простоя';

  @override
  String get beforeWork => 'До выполнения';

  @override
  String get afterWork => 'После выполнения';

  @override
  String get reassign => 'Переназначить';

  @override
  String get changePriority => 'Изменить приоритет';

  @override
  String get cancelOrderTitle => 'Отмена наряда';

  @override
  String get cancelOrder => 'Отменить наряд';

  @override
  String get workerReport => 'Отчёт исполнителя';

  @override
  String get completedWorks => 'Выполненные работы';

  @override
  String get materials => 'Материалы';

  @override
  String get notSpecifiedPlural => 'Не указаны';

  @override
  String get changeScore => 'Изменить оценку';

  @override
  String get acceptedByMaster => 'Работы приняты мастером';

  @override
  String get acceptClose => 'Принять и закрыть';

  @override
  String get returnRework => 'Вернуть на доработку';

  @override
  String get toRework => 'На доработку';

  @override
  String get actionHistory => 'История действий';

  @override
  String get reports => 'Отчёты';

  @override
  String get notifications => 'Уведомления';

  @override
  String get shift => 'Смена';

  @override
  String get shiftManagement => 'УПРАВЛЕНИЕ СМЕНОЙ';

  @override
  String get masterRole => 'Мастер смены';

  @override
  String get offShift => 'Не на смене';

  @override
  String get aiDemoLabel => 'Демонстрационные данные · ИИ не подключён';

  @override
  String get photoOpenFailed => 'Не удалось открыть фото';

  @override
  String get noPhotos => 'Фото не прикреплены';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get statusIssued => 'Выдан';

  @override
  String get statusAccepted => 'Принят';

  @override
  String get statusPaused => 'Приостановлен';

  @override
  String get statusReview => 'На проверке';

  @override
  String get statusClosed => 'Закрыт';

  @override
  String get statusRejected => 'Отклонён';

  @override
  String get statusCancelled => 'Отменён';

  @override
  String get emergencyFull => 'Аварийный — срочно в работу';

  @override
  String get normalFull => 'Обычный — в порядке очереди';

  @override
  String get noAiVerdict => 'Нет заключения';

  @override
  String get aiUnavailable => 'ИИ пока не подключён.';

  @override
  String get positiveNorm => 'Норматив должен быть больше нуля';

  @override
  String get onShiftAssignee => 'Выберите исполнителя или бригаду на смене';

  @override
  String get futureDeadlineError => 'Срок должен быть в будущем';

  @override
  String get fivePhotos => 'Не более 5 фото';

  @override
  String get employeeOffShift => 'Сотрудник не на смене';

  @override
  String get brigadeOffShift => 'Бригада не на смене';

  @override
  String get language => 'Язык';

  @override
  String get complex => 'Минеральный комплекс';

  @override
  String orderNumber(String number) {
    return 'Наряд №$number';
  }

  @override
  String orderNumberUpper(String number) {
    return 'НАРЯД №$number';
  }

  @override
  String issuePreview(String date) {
    return 'Выдача: $date';
  }

  @override
  String issuedAt(String date) {
    return 'Выдан $date';
  }

  @override
  String dueAt(String date) {
    return 'До $date';
  }

  @override
  String hoursValue(String hours) {
    return '$hours ч';
  }

  @override
  String scoreValue(String score) {
    return '$score из 5';
  }

  @override
  String employeeGrade(String specialty, String grade) {
    return '$specialty · $grade разряд';
  }

  @override
  String workingOrder(String number) {
    return 'В работе · №$number';
  }

  @override
  String workingQueue(String number, String count) {
    return 'В работе · №$number · очередь $count';
  }

  @override
  String queuedCount(String count) {
    return 'В очереди · $count';
  }

  @override
  String assignedOrder(String number) {
    return 'Занят · назначен №$number';
  }

  @override
  String brigadeAvailability(String total, String free, String busy) {
    return 'На смене: $total · свободны: $free · заняты: $busy';
  }

  @override
  String overdueMinutes(String minutes) {
    return 'Просрочка · $minutes мин.';
  }

  @override
  String removePhoto(String number) {
    return 'Удалить фото $number';
  }

  @override
  String boardCount(String label, String count) {
    return '$label · $count';
  }

  @override
  String shiftTime(String number, String time) {
    return 'Смена №$number · $time';
  }

  @override
  String aiVerdict(String verdict) {
    return 'Вердикт ИИ: $verdict';
  }

  @override
  String aiSummary(String explanation, String aiScore, String score) {
    return '$explanation\nОценка ИИ: $aiScore / 5.\nИтоговая оценка: $score / 5.\nОкончательное решение принимает мастер.';
  }

  @override
  String eventIssued(String assignee) {
    return 'Наряд выдан: $assignee';
  }

  @override
  String eventReassigned(String assignee) {
    return 'Переназначен: $assignee';
  }

  @override
  String eventPriority(String priority) {
    return 'Приоритет изменён: $priority';
  }

  @override
  String eventScore(String score) {
    return 'Оценка мастера: $score / 5';
  }

  @override
  String eventReason(String status, String reason) {
    return '$status: $reason';
  }
}
