import 'package:flutter/material.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'package:mineral/l10n/app_localizations_ru.dart';
import 'package:mineral/shared/models/models.dart';
import 'backend_ui_labels.dart';

AppLocalizations strings(BuildContext context) =>
    Localizations.of<AppLocalizations>(context, AppLocalizations) ??
    AppLocalizationsRu();

// Legacy UI labels are adapted at rendering time; domain values and mock data
// remain unchanged. All translations and parameterized messages live in ARB.
String uiText(BuildContext context, String source) {
  final s = strings(context);
  switch (source) {
    case 'ACCEPTED':
    case 'Принято':
      return s.aiVerdictAcceptedLabel;
    case 'ACCEPTED_WITH_COMMENTS':
    case 'Принято с замечаниями':
      return s.aiVerdictCommentsLabel;
    case 'REWORK_REQUIRED':
    case 'Требуется доработка':
      return s.aiVerdictReworkLabel;
    case "Экспорт":
      return s.exportReport;
    case "Наряды, выданные за выбранный период":
      return s.reportPeriodHint;
    case "Сегодня":
      return s.todayPeriod;
    case "7 дней":
      return s.weekPeriod;
    case "30 дней":
      return s.monthPeriod;
    case "Всё время":
      return s.allTimePeriod;
    case "За этот период нет исполнителей с нарядами":
      return s.noPeriodEmployees;
    case "Редактирование наряда":
      return s.editOrder;
    case "Изменить срок выполнения":
      return s.changeDeadline;
    case "Состав бригады":
      return s.brigadeMembers;
    case "Бригады":
      return s.brigades;
    case "Бригада, имя или специальность":
      return s.teamBrigadeSearch;
    case "Фильтры":
      return s.filters;
    case "Применить":
      return s.applyFilters;
    case "Сбросить":
      return s.resetFilters;
    case "Закрыть фильтры":
      return s.closeFilters;
    case "Статус":
      return s.statusFilter;
    case "Только просроченные":
      return s.onlyOverdue;
    case "Очистить поиск":
      return s.clearSearch;
    case "Прикрепить фото":
      return s.attachPhoto;
    case "Выберите источник фото":
      return s.choosePhotoSource;
    case "Сначала приостановите или завершите текущий наряд":
      return s.finishCurrentFirst;
    case "Для штучного материала укажите целое количество":
      return s.wholePieceQuantity;
    case "Удалить материал":
      return s.removeMaterial;
    case "Удалить материал из отчёта?":
      return s.removeMaterialQuestion;
    case "Черновик сохранён":
      return s.draftSaved;
    case "Не удалось восстановить черновик. Повторите попытку — сохранённые данные не изменены.":
      return s.draftLoadFailed;
    case "Черновик не сохранён. Нажмите, чтобы повторить.":
      return s.draftSaveFailed;
    case "Результат проверки":
      return s.executionResult;
    case "Логин":
      return s.authLoginLabel;
    case "ПИН":
      return s.authPinLabel;
    case "Введите логин":
      return s.authEnterLogin;
    case "ПИН должен содержать от 4 до 12 символов":
      return s.authPinLength;
    case "Введите номер телефона и пароль.":
      return s.authSubtitle;
    case "Учётную запись выдаёт администратор.":
      return s.authAccountHint;
    case "Не удалось подключиться. Проверьте связь и повторите.":
      return s.authNetworkError;
    case "Эта роль доступна в веб-панели.":
      return s.authMobileRole;
    case "Слишком много попыток. Повторите позже.":
      return s.authRateLimited;
    case "Демонстрационные данные":
      return s.demoDataNotice;
    case "Введите номер от 10 до 15 цифр":
      return s.authInvalidPhone;
    case "Смена пароля":
      return s.changePasswordTitle;
    case "Текущий пароль":
      return s.currentPasswordLabel;
    case "Новый пароль":
      return s.newPasswordLabel;
    case "Пароль должен содержать от 6 до 128 символов":
      return s.newPasswordLength;
    case "Пароль изменён":
      return s.passwordChanged;
    case "Изменить пароль":
      return s.changePasswordButton;
    case "Забытый пароль сбрасывает администратор.":
      return s.passwordResetHint;
    case "Выполнен · идёт AI-проверка":
      return s.statusAiChecking;
    case "На проверке у мастера":
      return s.statusMasterReview;
    case "Проверяем отчёт…":
      return s.checkingReport;
    case "Наряд недоступен":
      return s.orderUnavailable;
    case "Фото должно быть не больше 15 МБ.":
      return s.photoTooLarge;
    case "Снимайте «до» и «после» с одной точки, чтобы результат ремонта был виден. До 5 фото, каждое не больше 15 МБ.":
      return s.photoCaptureHint;
    case "Переназначить наряд":
      return s.reassignOrderTitle;
    case "Переназначить наряд?":
      return s.reassignOrderQuestion;
    case "После переназначения наряд вернётся в статус «Выдан». Новый исполнитель получит уведомление.":
      return s.reassignOrderExplanation;
    case "Наряд отменён":
      return s.orderCancelledMessage;
    case "Наряд отправлен на доработку":
      return s.orderReworkMessage;
    case "Наряд закрыт":
      return s.orderClosedMessage;
    case "Наряд обновлён":
      return s.orderUpdatedMessage;
    case "Закрыть":
      return s.closeActionLabel;
    case "Наряд не найден":
      return s.orderNotFoundMessage;
    case "Это не ваш наряд":
      return s.notYourOrderMessage;
    case "ИИ-проверка выполнения":
      return s.aiWorkCheckTitle;
    case "Что выполнено хорошо":
      return s.workStrengthsTitle;
    case "Принять работу":
      return s.acceptWorkAction;
    case "Закрыть наряд":
      return s.closeWorkOrderAction;
    case "Наряд принят":
      return s.orderAcceptedMessage;
    case "Наряд отклонён":
      return s.orderRejectedMessage;
    case "Работа начата":
      return s.workStartedMessage;
    case "Работа приостановлена":
      return s.workPausedMessage;
    case "Работа выполнена":
      return s.workCompletedMessage;
    case "Сначала выберите оборудование.":
      return s.chooseEquipmentFirst;
    case "Сначала опишите неисправность.":
      return s.describeFaultFirst;
    case "Рекомендация применена.":
      return s.recommendationAppliedMessage;
    case "Не удалось выбрать фотографию.":
      return s.photoSelectionFailedMessage;
    case "Выберите участок.":
      return s.chooseAreaValidation;
    case "Выберите оборудование.":
      return s.chooseEquipmentValidation;
    case "Выберите исполнителя.":
      return s.chooseExecutorValidation;
    case "Выберите норматив.":
      return s.chooseNormativeValidation;
    case "Создание...":
      return s.creatingOrderLabel;
    case "Голосовой ввод подключим следующим этапом.":
      return s.voiceNextStageMessage;
    case "Описание — минимум 3 символа":
      return s.descriptionMinimumLabel;
    case "Получить AI-рекомендацию":
      return s.getAiRecommendationLabel;
    case "Выберите участок":
      return s.chooseAreaLabel;
    case "Оценка времени":
      return s.estimatedTimeLabel;
    case "Очередь":
      return s.queueLabel;
    case "Рейтинг":
      return s.ratingLabel;
    case "Уверенность":
      return s.confidenceLabel;
    case "Оценка ИИ":
      return s.aiScoreLabel;
    case "Статус наряда изменился. Обновите данные":
      return s.orderStatusChangedMessage;
    case "Наряд уже не в работе":
      return s.orderNotWorkingMessage;
    case "Заполните работы и шифр неисправности":
      return s.workAndFaultRequiredMessage;
    case "Проверьте материалы и фотографии":
      return s.checkMaterialsPhotosMessage;
    case "Наряд завершён":
      return s.orderFinishedMessage;
    case "Уплотнение 40×60":
      return s.mockSealMaterial;
    case "Масло И-40":
      return s.mockOilMaterial;
    case "Подшипник":
      return s.mockBearingShort;
    case "Смазка":
      return s.mockLubricantShort;
    case "Нет фото после выполненных работ":
      return s.mockMasterReworkReason;
    case "шт.":
      return s.pieceUnit;
    case "ч.":
      return s.hourUnit;
    case "шт":
      return s.piecesShortUnit;
    case "м":
      return s.meterUnit;
    case "кг":
      return s.kilogramUnit;
    case "л":
      return s.literUnit;
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
    case "Мои наряды":
      return s.myOrders;
    case "История нарядов":
      return s.orderHistory;
    case "Профиль":
      return s.profile;
    case "История":
      return s.history;
    case "Повторить":
      return s.retry;
    case "Завершённые, отменённые и отклонённые наряды":
      return s.archivedOrdersHint;
    case "Поиск по номеру или оборудованию":
      return s.executorSearch;
    case "По вашему запросу ничего не найдено":
      return s.noSearchResults;
    case "История пока пуста":
      return s.emptyHistory;
    case "Нет активных нарядов":
      return s.noActiveOrders;
    case "Не удалось обновить данные. Потяните список вниз, чтобы повторить.":
      return s.refreshFailed;
    case "Доброе утро":
      return s.goodMorning;
    case "Добрый день":
      return s.goodAfternoon;
    case "Добрый вечер":
      return s.goodEvening;
    case "Доброй ночи":
      return s.goodNight;
    case "Активных":
      return s.activeOrders;
    case "На смене":
      return s.onShift;
    case "Разряд":
      return s.grade;
    case "Мой рейтинг":
      return s.myRating;
    case "Пока нет оценки":
      return s.noRatingYet;
    case "После проверки выполненных нарядов здесь появятся рейтинг и его объяснение.":
      return s.executorRatingHint;
    case "Качество":
      return s.quality;
    case "В срок":
      return s.onTime;
    case "Доработки":
      return s.reworks;
    case "Закрыто нарядов":
      return s.closedOrders;
    case "Выйти":
      return s.logout;
    case "Оценка ожидается":
      return s.ratingPending;
    case "ИИ":
      return s.aiShort;
    case "Аварийный наряд — требуется ответ":
      return s.emergencyResponse;
    case "Вам назначен новый наряд":
      return s.newOrderAssigned;
    case "Наряд возвращён на доработку":
      return s.returnedForRework;
    case "Мастер закрыл наряд":
      return s.masterClosedOrder;
    case "Срок выполнения истёк":
      return s.deadlineExpired;
    case "Уведомлений пока нет":
      return s.noExecutorNotifications;
    case "Причина отказа":
      return s.rejectReason;
    case "Причина приостановки":
      return s.pauseReason;
    case "Наряд переназначен другому исполнителю.":
      return s.orderReassignedWarning;
    case "Принять в работу":
      return s.acceptWork;
    case "Поставить в очередь":
      return s.queueOrder;
    case "Отклонить":
      return s.rejectOrder;
    case "Возобновить работу":
      return s.resumeWork;
    case "Начать исполнение":
      return s.startExecution;
    case "Приостановить":
      return s.pauseWork;
    case "Исполнено":
      return s.workDone;
    case "Срок выполнения":
      return s.executionDeadline;
    case "Описание неисправности":
      return s.faultDescription;
    case "Фото до начала работ":
      return s.photosBeforeWork;
    case "Мастер не добавил фотографии":
      return s.masterNoPhotos;
    case "Оценка мастера пока не выставлена":
      return s.masterScorePending;
    case "Заключение по выполнению пока не получено.":
      return s.assessmentPending;
    case "Отчёт отправлен. Ожидает проверки мастером.":
      return s.reportAwaitingMaster;
    case "Уточните замечания у мастера":
      return s.askMasterRemarks;
    case "Ваш отчёт":
      return s.yourReport;
    case "Работы не указаны":
      return s.workNotSpecified;
    case "Фото после":
      return s.photosAfter;
    case "Перейти к доработке":
      return s.goToRework;
    case "Открыть наряд":
      return s.openOrder;
    case "Не удалось добавить фото. Проверьте разрешения.":
      return s.addPhotoFailed;
    case "Для внепланового наряда нужно фото после":
      return s.unplannedPhotoRequired;
    case "Добавьте выбранный материал в список":
      return s.commitSelectedMaterial;
    case "Материал":
      return s.material;
    case "Выберите материал":
      return s.selectMaterial;
    case "Количество":
      return s.quantity;
    case "Введите количество больше нуля":
      return s.positiveQuantity;
    case "Добавить материал":
      return s.addMaterial;
    case "Отправка…":
      return s.sending;
    case "Отправить на проверку":
      return s.submitForReview;
    case "Материалы и код":
      return s.materialsAndCode;
    case "Фото и комментарий":
      return s.photosAndComment;
    case "Что было сделано?":
      return s.whatWasDone;
    case "Опишите выполненные работы":
      return s.describeCompletedWork;
    case "Код неисправности":
      return s.faultCodeLabel;
    case "Выберите код":
      return s.selectCode;
    case "Выберите шифр":
      return s.selectFaultCode;
    case "Использованные материалы":
      return s.usedExecutorMaterials;
    case "Материалы не использовались":
      return s.noMaterialsUsed;
    case "Уменьшить":
      return s.decrease;
    case "Увеличить":
      return s.increase;
    case "Фото после выполнения работ":
      return s.photosAfterWork;
    case "Удалить фото":
      return s.removePhotoLabel;
    case "Сделать фото после":
      return s.takeAfterPhoto;
    case "Выбрать из галереи":
      return s.chooseFromGallery;
    case "Добавлено 5 из 5 фото. Удалите фото, чтобы добавить новое.":
      return s.photoLimitReached;
    case "Комментарий (необязательно)":
      return s.optionalComment;
    case "Дополнительная информация":
      return s.additionalInformation;
    case "Не удалось изменить статус. Повторите попытку.":
      return s.changeStatusFailed;
    case "Не удалось отправить отчёт. Повторите попытку.":
      return s.submitReportFailed;
    case "Наряд выдан":
      return s.orderIssuedLabel;
    case "Слесарь":
      return s.mechanicSpecialty;
    case "Электрик":
      return s.electricianSpecialty;
    case "Сварщик":
      return s.welderSpecialty;
    case "Дробление":
      return s.crushingArea;
    case "Обогащение":
      return s.beneficiationArea;
    case "Ремонтный цех":
      return s.repairArea;
    case "Транспортный участок":
      return s.transportArea;
    case "Подшипник · шт":
      return s.bearingMaterial;
    case "Уплотнение · шт":
      return s.sealMaterial;
    case "Кабель · м":
      return s.cableMaterial;
    case "Масло · л":
      return s.oilMaterial;
    case "Смазка · кг":
      return s.greaseMaterial;
    case "Пример вывода: конвейер К-3 часто останавливается из-за подшипников. Рекомендация: проверить соосность привода и скорректировать план ППР.":
      return s.anomalyExample;
    case "М-02 · Подшипник":
      return s.faultBearing;
    case "Г-01 · Течь масла":
      return s.faultOilLeak;
    case "Э-03 · Обрыв кабеля":
      return s.faultCableBreak;
    case "С-01 · Недостаток смазки":
      return s.faultGreaseLack;
    case "П-02 · Утечка воздуха":
      return s.faultAirLeak;
    case "Дробилка КМД-1750":
      return s.crusherEquipment;
    case "Конвейер К-3":
      return s.conveyorEquipment;
    case "Грохот ГИС-52":
      return s.screenEquipment;
    case "Насос Н-12":
      return s.pumpEquipment;
    case "Мельница МШР-3":
      return s.millEquipment;
    case "Сепаратор С-4":
      return s.separatorEquipment;
    case "Станок Т-16":
      return s.machineEquipment;
    case "Кран-балка КБ-2":
      return s.craneEquipment;
    case "Погрузчик П-7":
      return s.loaderEquipment;
    case "Компрессор ВК-22":
      return s.compressorEquipment;
    case "Замена подшипника привода":
      return s.demoBearingWork;
    case "Устранение течи масла":
      return s.demoOilLeakWork;
    case "Проверка питания двигателя":
      return s.demoPowerWork;
    case "Плановая смазка узлов":
      return s.demoLubricationWork;
    case "Замена уплотнения вала":
      return s.demoSealWork;
    case "Восстановление защитного кожуха":
      return s.demoGuardWork;
    case "Плановая смазка и проверка узлов":
      return s.demoLubricationCheckWork;
    case "Проверить состояние оборудования, устранить неисправность и выполнить контрольный запуск.":
      return s.demoOrderDescription;
    case "Заменено уплотнение. Соединения проверены. При контрольном запуске течь отсутствует.":
      return s.demoSealReport;
    case "Подшипник заменён. Проверены крепления и выполнен контрольный запуск. Посторонний шум устранён.":
      return s.demoBearingReport;
    case "Выполнена смазка узлов. Проверены крепления и работа оборудования под нагрузкой.":
      return s.demoLubricationReport;
    case "Ждём подшипник со склада":
      return s.demoWaitingBearing;
    case "Уплотнение 40×60 — 1 шт.":
      return s.demoSealMaterial;
    case "Масло И-40 — 0,5 л":
      return s.demoOilMaterial;
    case "Подшипник — 1 шт.":
      return s.demoBearingMaterial;
    case "Смазка — 0,2 кг":
      return s.demoGreaseSmall;
    case "Смазка — 0,5 кг":
      return s.demoGreaseHalf;
    case "Ожидает проверки":
      return s.awaitingCheck;
    case "Отчёт отправлен. Проверка ИИ ещё не выполнена.":
      return s.reportAiPending;
  }
  if (source == 'свободен') return s.available;
  if (source == 'не на смене') return uiText(context, 'Не на смене');
  RegExpMatch? match;
  match = RegExp(
    r'^выполняет наряд №(.+), в очереди (\d+)$',
  ).firstMatch(source);
  if (match != null) return s.executorCurrentOrderQueue(match[1]!, match[2]!);
  match = RegExp(r'^в очереди (\d+) наряд(?:а|ов)?$').firstMatch(source);
  if (match != null) return s.executorQueuedOrders(match[1]!);
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
  if (match != null) {
    return s.employeeGrade(uiText(context, match[1]!), match[2]!);
  }
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
  match = RegExp(r'^Бригада №(\d+)$').firstMatch(source);
  if (match != null) return s.brigadeNumber(match[1]!);
  match = RegExp(
    r'^Демо-ответ: здесь появятся рекомендации по запросу «([\s\S]*)»\. Для анализа необходимо подключить backend и ИИ\.$',
  ).firstMatch(source);
  if (match != null) return s.masterDemoAnswer(match[1]!);
  match = RegExp(r'^(.+): ([\d.,]+)$').firstMatch(source);
  if (match != null) return '${uiText(context, match[1]!)}: ${match[2]}';
  match = RegExp(r'^(.+) — ([\d.,]+) (шт\.|кг|л|м)$').firstMatch(source);
  if (match != null) {
    return '${uiText(context, match[1]!)} — ${match[2]} ${uiText(context, match[3]!)}';
  }
  match = RegExp(r'^(.+) ч\.$').firstMatch(source);
  if (match != null) return '${uiText(context, match[1]!)} ${s.hourUnit}';
  match = RegExp(
    r'^(Оценка ИИ|Оценка мастера|Уверенность|Оценка времени|Очередь|Рейтинг): (.+)$',
  ).firstMatch(source);
  if (match != null) {
    return '${uiText(context, match[1]!)}: ${uiText(context, match[2]!)}';
  }
  match = RegExp(r'^Материал #(\d+)$').firstMatch(source);
  if (match != null) return '${s.material} #${match[1]}';
  // Translate catalog labels within composed display values without changing IDs.
  if (source.contains('\n')) {
    return source.split('\n').map((line) => uiText(context, line)).join('\n');
  }
  if (source.contains(' · ')) {
    return source.split(' · ').map((part) => uiText(context, part)).join(' · ');
  }
  return s.localeName.startsWith('kk')
      ? backendUiLabels[source] ?? source
      : source;
}

String executorStatusText(BuildContext context, WorkOrder order) {
  final s = strings(context);

  return switch (order.apiStatus) {
    'COMPLETED' => s.statusAiChecking,
    'AI_REVIEW' => s.statusMasterReview,
    _ => uiText(context, order.status.label),
  };
}

String eventText(BuildContext context, OrderEvent event) {
  final s = strings(context);
  final value = event.value ?? '';
  switch (event.kind) {
    case OrderEventKind.issued:
      return s.eventIssued(uiText(context, value));
    case OrderEventKind.reassigned:
      return s.eventReassigned(uiText(context, value));
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
          : uiText(context, event.reason);
      return reason.isEmpty ? label : s.eventReason(label, reason);
    case null:
      return event.status != null
          ? uiText(context, event.status!.label)
          : uiText(context, event.title);
  }
}

String eventAuthor(BuildContext context, OrderEvent event) {
  if (event.kind == null) return uiText(context, event.author);
  return event.author.replaceFirst(
    'Мастер · ',
    '${strings(context).master} · ',
  );
}
