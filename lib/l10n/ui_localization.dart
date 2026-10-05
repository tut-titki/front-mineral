import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_localizations_ru.dart';
import '../src/models.dart';

AppLocalizations strings(BuildContext context) =>
    Localizations.of<AppLocalizations>(context, AppLocalizations) ??
    AppLocalizationsRu();

// Legacy UI labels are adapted at rendering time; domain values and mock data
// remain unchanged. All translations and parameterized messages live in ARB.
String uiText(BuildContext context, String source) {
  final s = strings(context);
  switch (source) {
    case "Вход":
      return s.loginTitle;
    case "Введите телефон и пароль вашего аккаунта.":
      return s.loginSubtitle;
    case "Регистрация":
      return s.registrationTitle;
    case "Укажите фамилию, имя и отчество.":
      return s.nameSubtitle;
    case "Добавьте телефон и придумайте пароль.":
      return s.accountSubtitle;
    case "Создать аккаунт":
      return s.createAccount;
    case "Уже есть аккаунт? Войти":
      return s.alreadyHaveAccount;
    case "Номер телефона":
      return s.phoneLabel;
    case "Пароль":
      return s.passwordLabel;
    case "Показать пароль":
      return s.showPassword;
    case "Скрыть пароль":
      return s.hidePassword;
    case "Введите пароль":
      return s.enterPassword;
    case "Войти":
      return s.loginButton;
    case "Фамилия":
      return s.lastName;
    case "Имя":
      return s.firstName;
    case "Отчество":
      return s.patronymic;
    case "Введите фамилию":
      return s.enterLastName;
    case "Введите имя":
      return s.enterFirstName;
    case "При наличии":
      return s.ifAvailable;
    case "Продолжить":
      return s.continueButton;
    case "Минимум 8 символов":
      return s.passwordHint;
    case "Пароль должен содержать минимум 8 символов":
      return s.passwordTooShort;
    case "Зарегистрироваться":
      return s.registerButton;
    case "Назад":
      return s.back;
    case "Введите номер телефона":
      return s.enterPhone;
    case "Введите номер полностью":
      return s.incompletePhone;
    case "Обзор смены":
      return s.dashboard;
    case "Здравствуйте, Серик. Вот что происходит на участке.":
      return s.greeting;
    case "Создать наряд":
      return s.createOrder;
    case "Выдано нарядов":
      return s.issuedOrders;
    case "Выполнено":
      return s.completed;
    case "Просрочено":
      return s.overdue;
    case "На приёмке":
      return s.awaitingAcceptance;
    case "Оборудование в простое":
      return s.equipmentStopped;
    case "Требуют внимания":
      return s.needsAttention;
    case "Нет нарядов, требующих внимания":
      return s.noAttention;
    case "Команда на смене":
      return s.shiftTeam;
    case "Вся команда →":
      return s.allTeam;
    case "Все участки":
      return s.allAreas;
    case "Всё оборудование":
      return s.allEquipment;
    case "Все приоритеты":
      return s.allPriorities;
    case "Все":
      return s.all;
    case "Просрочены":
      return s.overduePlural;
    case "Выданные":
      return s.issuedPlural;
    case "Принятые":
      return s.acceptedPlural;
    case "В работе":
      return s.working;
    case "В очереди":
      return s.queued;
    case "Выполненные":
      return s.completedPlural;
    case "Приостановлены":
      return s.pausedPlural;
    case "На доработке":
      return s.rework;
    case "Отклонены":
      return s.rejectedPlural;
    case "Отменены":
      return s.cancelledPlural;
    case "Наряды":
      return s.orders;
    case "Назначения, сроки и текущие статусы работ":
      return s.ordersSubtitle;
    case "Новый наряд":
      return s.newOrder;
    case "Список":
      return s.listView;
    case "Канбан":
      return s.kanban;
    case "Номер, работа или оборудование":
      return s.orderSearch;
    case "Участок":
      return s.area;
    case "Оборудование":
      return s.equipment;
    case "Исполнитель":
      return s.employee;
    case "Все исполнители":
      return s.allEmployees;
    case "Приоритет":
      return s.priority;
    case "По выбранным фильтрам нарядов нет":
      return s.noFilteredOrders;
    case "Просроченные":
      return s.overdueOrders;
    case "Демо-рейтинг":
      return s.demoRating;
    case "Свободен":
      return s.available;
    case "Команда":
      return s.team;
    case "Загрузка исполнителей, специальности и доступность":
      return s.teamSubtitle;
    case "Имя или специальность":
      return s.employeeSearch;
    case "Только свободные":
      return s.onlyAvailable;
    case "Исполнители не найдены":
      return s.noEmployees;
    case "ИИ-контроль":
      return s.aiControl;
    case "Рекомендации цифрового контролёра. Финальное решение принимает мастер.":
      return s.aiSubtitle;
    case "Контроль сроков":
      return s.deadlineControl;
    case "Напоминание за 30 минут до срока. Эскалация, если обычный наряд не принят за 10 минут, аварийный — за 3 минуты.":
      return s.deadlineHelp;
    case "Проверка выполнения":
      return s.completionCheck;
    case "Нет нарядов на проверке":
      return s.noReviewOrders;
    case "Анализ фото до / после":
      return s.photoAnalysis;
    case "Проверка наличия и актуальности фото, сравнение оборудования и видимых дефектов. При низкой уверенности потребуется проверка мастера.":
      return s.photoAnalysisHelp;
    case "Отчёт по наряду":
      return s.orderReport;
    case "Работы, материалы, хронология, соблюдение срока и объяснение оценки собраны в карточке наряда.":
      return s.orderReportHelp;
    case "Аномалии оборудования":
      return s.equipmentAnomalies;
    case "Рейтинг исполнителей":
      return s.employeeRating;
    case "Качество, выполнение в срок, доработки, сложность работ и обоснованность отказов формируют оценку.":
      return s.ratingHelp;
    case "Ассистент мастера":
      return s.masterAssistant;
    case "Макет чата. Ответы демонстрационные.":
      return s.chatHelp;
    case "Например: кто сейчас свободен?":
      return s.chatHint;
    case "Показать демо-ответ":
      return s.showDemoAnswer;
    case "Отчёты и рейтинг":
      return s.reportsRating;
    case "Сводка текущей демонстрационной смены":
      return s.reportsSubtitle;
    case "Выгрузку PDF подключим вместе с backend":
      return s.pdfNotReady;
    case "Экспорт PDF":
      return s.exportPdf;
    case "Выгрузку Excel подключим вместе с backend":
      return s.excelNotReady;
    case "Экспорт Excel":
      return s.exportExcel;
    case "Отчёты за произвольный период подключим после добавления истории на backend":
      return s.periodNotReady;
    case "Выбрать период":
      return s.selectPeriod;
    case "Всего нарядов":
      return s.totalOrders;
    case "Закрыто":
      return s.closed;
    case "Отклонено":
      return s.rejected;
    case "Простои оборудования":
      return s.equipmentDowntime;
    case "Макет отчёта: время остановки по оборудованию, причины и доля плановых / внеплановых работ.":
      return s.downtimeReportHelp;
    case "Списанные материалы":
      return s.usedMaterials;
    case "Макет отчёта: расход по материалам, участкам и исполнителям, сравнение с нормативами.":
      return s.materialsReportHelp;
    case "Центр уведомлений":
      return s.notificationCenter;
    case "Локальные уведомления прототипа. Push не подключён.":
      return s.notificationsSubtitle;
    case "Новых уведомлений нет":
      return s.noNotifications;
    case "Работа ожидает приёмки":
      return s.awaitingReview;
    case "Аварийный наряд ожидает ответа":
      return s.emergencyAwaiting;
    case "Обычный":
      return s.normalPriority;
    case "Разрешите доступ к камере или фото в настройках приложения.":
      return s.permissionDenied;
    case "Не удалось открыть камеру или галерею. Попробуйте ещё раз.":
      return s.pickerFailed;
    case "Не удалось загрузить фото. Выберите другой снимок.":
      return s.photoLoadFailed;
    case "Срок исполнения":
      return s.deadline;
    case "Отмена":
      return s.cancel;
    case "Выбрать":
      return s.select;
    case "Время исполнения":
      return s.executionTime;
    case "Выберите срок в будущем.":
      return s.futureDeadline;
    case "Создание наряда":
      return s.createOrderTitle;
    case "Описание работ":
      return s.workDescription;
    case "Внеплановый":
      return s.unplanned;
    case "Плановый":
      return s.planned;
    case "Название работы (необязательно)":
      return s.optionalWorkTitle;
    case "Проблема и необходимые работы":
      return s.problemWorks;
    case "Голосовой ввод":
      return s.voiceInput;
    case "Голосовой ввод подключим позже.":
      return s.voiceNotReady;
    case "Опишите проблему":
      return s.describeProblem;
    case "Место и исполнитель":
      return s.locationAssignee;
    case "Бригада":
      return s.brigade;
    case "Выберите исполнителя":
      return s.selectEmployee;
    case "Выберите бригаду":
      return s.selectBrigade;
    case "Срок и приоритет":
      return s.deadlinePriority;
    case "Аварийный":
      return s.emergencyPriority;
    case "Высокий":
      return s.highPriority;
    case "Норматив, ч":
      return s.normHoursShort;
    case "Дата и время":
      return s.dateTime;
    case "Норматив в часах":
      return s.normHours;
    case "Укажите от 1 минуты до 8760 часов":
      return s.normRange;
    case "Шифр неисправности (необязательно)":
      return s.optionalFaultCode;
    case "Не указан":
      return s.notSpecified;
    case "Комментарий":
      return s.comment;
    case "Фото неисправности · до 5":
      return s.faultPhotos;
    case "Выдать наряд":
      return s.issueOrder;
    case "Причина":
      return s.reason;
    case "Укажите причину":
      return s.specifyReason;
    case "Подтвердить":
      return s.confirm;
    case "Исполнитель или бригада":
      return s.employeeOrBrigade;
    case "Приоритет наряда":
      return s.orderPriority;
    case "Оценка мастера":
      return s.masterScore;
    case "Просрочен":
      return s.overdueSingular;
    case "Информация о наряде":
      return s.orderInformation;
    case "Тип работ":
      return s.workType;
    case "Описание":
      return s.description;
    case "Дата выдачи":
      return s.issueDate;
    case "Норматив":
      return s.norm;
    case "Шифр неисправности":
      return s.faultCode;
    case "Мастер":
      return s.master;
    case "Простой оборудования":
      return s.orderDowntime;
    case "Оборудование остановлено":
      return s.stopped;
    case "Нет активного простоя":
      return s.noDowntime;
    case "До выполнения":
      return s.beforeWork;
    case "После выполнения":
      return s.afterWork;
    case "Переназначить":
      return s.reassign;
    case "Изменить приоритет":
      return s.changePriority;
    case "Отмена наряда":
      return s.cancelOrderTitle;
    case "Отменить наряд":
      return s.cancelOrder;
    case "Отчёт исполнителя":
      return s.workerReport;
    case "Выполненные работы":
      return s.completedWorks;
    case "Материалы":
      return s.materials;
    case "Не указаны":
      return s.notSpecifiedPlural;
    case "Изменить оценку":
      return s.changeScore;
    case "Работы приняты мастером":
      return s.acceptedByMaster;
    case "Принять и закрыть":
      return s.acceptClose;
    case "Вернуть на доработку":
      return s.returnRework;
    case "На доработку":
      return s.toRework;
    case "История действий":
      return s.actionHistory;
    case "Отчёты":
      return s.reports;
    case "Уведомления":
      return s.notifications;
    case "Смена":
      return s.shift;
    case "УПРАВЛЕНИЕ СМЕНОЙ":
      return s.shiftManagement;
    case "Мастер смены":
      return s.masterRole;
    case "Не на смене":
      return s.offShift;
    case "Демонстрационные данные · ИИ не подключён":
      return s.aiDemoLabel;
    case "Не удалось открыть фото":
      return s.photoOpenFailed;
    case "Фото не прикреплены":
      return s.noPhotos;
    case "Камера":
      return s.camera;
    case "Галерея":
      return s.gallery;
    case "Выдан":
      return s.statusIssued;
    case "Принят":
      return s.statusAccepted;
    case "Приостановлен":
      return s.statusPaused;
    case "На проверке":
      return s.statusReview;
    case "Закрыт":
      return s.statusClosed;
    case "Отклонён":
      return s.statusRejected;
    case "Отменён":
      return s.statusCancelled;
    case "Аварийный — срочно в работу":
      return s.emergencyFull;
    case "Обычный — в порядке очереди":
      return s.normalFull;
    case "Нет заключения":
      return s.noAiVerdict;
    case "ИИ пока не подключён.":
      return s.aiUnavailable;
    case "Норматив должен быть больше нуля":
      return s.positiveNorm;
    case "Выберите исполнителя или бригаду на смене":
      return s.onShiftAssignee;
    case "Срок должен быть в будущем":
      return s.futureDeadlineError;
    case "Не более 5 фото":
      return s.fivePhotos;
    case "Сотрудник не на смене":
      return s.employeeOffShift;
    case "Бригада не на смене":
      return s.brigadeOffShift;
    case "Язык":
      return s.language;
    case "Минеральный комплекс":
      return s.complex;
  }
  RegExpMatch? match;
  match = RegExp(r'^Наряд №(\d+)$').firstMatch(source);
  if (match != null) return s.orderNumber(match[1]!);
  match = RegExp(r'^НАРЯД №(\d+)$').firstMatch(source);
  if (match != null) return s.orderNumberUpper(match[1]!);
  match = RegExp(r'^Выдача: (.+)$').firstMatch(source);
  if (match != null) return s.issuePreview(match[1]!);
  match = RegExp(r'^Выдан (.+)$').firstMatch(source);
  if (match != null) return s.issuedAt(match[1]!);
  match = RegExp(r'^До (.+)$').firstMatch(source);
  if (match != null) return s.dueAt(match[1]!);
  match = RegExp(r'^([\d.,]+) ч$').firstMatch(source);
  if (match != null) return s.hoursValue(match[1]!);
  match = RegExp(r'^([\d.,]+) из 5$').firstMatch(source);
  if (match != null) return s.scoreValue(match[1]!);
  match = RegExp(r'^(.+) · (\d+) разряд$').firstMatch(source);
  if (match != null) return s.employeeGrade(match[1]!, match[2]!);
  match = RegExp(r'^В работе · №(\d+) · очередь (\d+)$').firstMatch(source);
  if (match != null) return s.workingQueue(match[1]!, match[2]!);
  match = RegExp(r'^В работе · №(\d+)$').firstMatch(source);
  if (match != null) return s.workingOrder(match[1]!);
  match = RegExp(r'^В очереди · (\d+)$').firstMatch(source);
  if (match != null) return s.queuedCount(match[1]!);
  match = RegExp(r'^Занят · назначен №(\d+)$').firstMatch(source);
  if (match != null) return s.assignedOrder(match[1]!);
  match = RegExp(
    r'^На смене: (\d+) · свободны: (\d+) · заняты: (\d+)$',
  ).firstMatch(source);
  if (match != null) {
    return s.brigadeAvailability(match[1]!, match[2]!, match[3]!);
  }
  match = RegExp(r'^Просрочка · (\d+) мин\.$').firstMatch(source);
  if (match != null) return s.overdueMinutes(match[1]!);
  match = RegExp(r'^Удалить фото (\d+)$').firstMatch(source);
  if (match != null) return s.removePhoto(match[1]!);
  match = RegExp(r'^Смена №(\d+) · (.+)$').firstMatch(source);
  if (match != null) return s.shiftTime(match[1]!, match[2]!);
  match = RegExp(r'^Вердикт ИИ: (.+)$').firstMatch(source);
  if (match != null) return s.aiVerdict(uiText(context, match[1]!));
  match = RegExp(
    r'^([\s\S]*?)\nОценка ИИ: ([\d.,]+) / 5\.\nИтоговая оценка: ([\d.,]+) / 5\.\nОкончательное решение принимает мастер\.$',
  ).firstMatch(source);
  if (match != null) {
    return s.aiSummary(uiText(context, match[1]!), match[2]!, match[3]!);
  }
  match = RegExp(r'^(.+) · (\d+)$').firstMatch(source);
  if (match != null) {
    final label = uiText(context, match[1]!);
    if (label != match[1]) return s.boardCount(label, match[2]!);
  }
  return source;
}

String eventText(BuildContext context, OrderEvent event) {
  final s = strings(context);
  final value = event.value ?? '';
  switch (event.kind) {
    case OrderEventKind.issued:
      return s.eventIssued(value);
    case OrderEventKind.reassigned:
      return s.eventReassigned(value);
    case OrderEventKind.priority:
      return s.eventPriority(uiText(context, value));
    case OrderEventKind.score:
      return s.eventScore(value);
    case OrderEventKind.deadline:
      return s.eventDeadline(value);
    case OrderEventKind.status:
      final label = uiText(context, event.status!.label);
      final reason = event.reason == 'Работы приняты мастером'
          ? s.acceptedByMaster
          : event.reason;
      return reason.isEmpty ? label : s.eventReason(label, reason);
    case null:
      return event.title; // Mock/imported history is not translated.
  }
}

String eventAuthor(BuildContext context, OrderEvent event) {
  if (event.kind == null) return event.author;
  return event.author.replaceFirst(
    'Мастер · ',
    '${strings(context).master} · ',
  );
}
