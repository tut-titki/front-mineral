// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'package:mineral/l10n/app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get exportReport => 'Экспорт';

  @override
  String get reportPeriodHint => 'Таңдалған кезеңде берілген нарядтар';

  @override
  String get todayPeriod => 'Бүгін';

  @override
  String get weekPeriod => '7 күн';

  @override
  String get monthPeriod => '30 күн';

  @override
  String get allTimePeriod => 'Барлық уақыт';

  @override
  String get noPeriodEmployees => 'Бұл кезеңде наряды бар орындаушылар жоқ';

  @override
  String get editOrder => 'Нарядты өңдеу';

  @override
  String get changeDeadline => 'Орындау мерзімін өзгерту';

  @override
  String get brigadeMembers => 'Бригада құрамы';

  @override
  String get brigades => 'Бригадалар';

  @override
  String get teamBrigadeSearch => 'Бригада, аты немесе мамандығы';

  @override
  String eventDeadline(String value) {
    return 'Мерзім өзгертілді: $value';
  }

  @override
  String get filters => 'Сүзгілер';

  @override
  String get applyFilters => 'Қолдану';

  @override
  String get resetFilters => 'Қалпына келтіру';

  @override
  String get closeFilters => 'Сүзгілерді жабу';

  @override
  String get statusFilter => 'Күйі';

  @override
  String get onlyOverdue => 'Тек мерзімі өткендер';

  @override
  String get clearSearch => 'Іздеуді тазарту';

  @override
  String get attachPhoto => 'Фото тіркеу';

  @override
  String get choosePhotoSource => 'Фото көзін таңдаңыз';

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

  @override
  String get dashboard => 'Ауысымға шолу';

  @override
  String get greeting => 'Сәлеметсіз бе, Серик. Учаскедегі ағымдағы жағдай.';

  @override
  String get createOrder => 'Наряд жасау';

  @override
  String get issuedOrders => 'Берілген нарядтар';

  @override
  String get completed => 'Орындалды';

  @override
  String get overdue => 'Мерзімі өтті';

  @override
  String get awaitingAcceptance => 'Қабылдауда';

  @override
  String get equipmentStopped => 'Жабдық тоқтап тұр';

  @override
  String get needsAttention => 'Назар аудару қажет';

  @override
  String get noAttention => 'Назар аударуды қажет ететін нарядтар жоқ';

  @override
  String get shiftTeam => 'Ауысымдағы команда';

  @override
  String get allTeam => 'Барлық команда →';

  @override
  String get allAreas => 'Барлық учаскелер';

  @override
  String get allEquipment => 'Барлық жабдық';

  @override
  String get allPriorities => 'Барлық басымдықтар';

  @override
  String get all => 'Барлығы';

  @override
  String get overduePlural => 'Мерзімі өткен';

  @override
  String get issuedPlural => 'Берілген';

  @override
  String get acceptedPlural => 'Қабылданған';

  @override
  String get working => 'Орындалуда';

  @override
  String get queued => 'Кезекте';

  @override
  String get completedPlural => 'Орындалған';

  @override
  String get pausedPlural => 'Уақытша тоқтатылған';

  @override
  String get rework => 'Қайта өңдеуде';

  @override
  String get rejectedPlural => 'Қабылданбаған';

  @override
  String get cancelledPlural => 'Күші жойылған';

  @override
  String get orders => 'Нарядтар';

  @override
  String get ordersSubtitle =>
      'Тапсырмалар, мерзімдер және жұмыстардың ағымдағы күйлері';

  @override
  String get newOrder => 'Жаңа наряд';

  @override
  String get listView => 'Тізім';

  @override
  String get kanban => 'Канбан';

  @override
  String get orderSearch => 'Нөмір, жұмыс немесе жабдық';

  @override
  String get area => 'Учаске';

  @override
  String get equipment => 'Жабдық';

  @override
  String get employee => 'Орындаушы';

  @override
  String get allEmployees => 'Барлық орындаушылар';

  @override
  String get priority => 'Басымдық';

  @override
  String get noFilteredOrders => 'Таңдалған сүзгілер бойынша нарядтар жоқ';

  @override
  String get overdueOrders => 'Мерзімі өткен нарядтар';

  @override
  String get demoRating => 'Демо-рейтинг';

  @override
  String get available => 'Бос';

  @override
  String get team => 'Команда';

  @override
  String get teamSubtitle =>
      'Орындаушылардың жүктемесі, мамандықтары және қолжетімділігі';

  @override
  String get employeeSearch => 'Аты немесе мамандығы';

  @override
  String get onlyAvailable => 'Тек бос орындаушылар';

  @override
  String get noEmployees => 'Орындаушылар табылмады';

  @override
  String get aiControl => 'ЖИ бақылауы';

  @override
  String get aiSubtitle =>
      'Цифрлық бақылаушының ұсыныстары. Соңғы шешімді шебер қабылдайды.';

  @override
  String get deadlineControl => 'Мерзімдерді бақылау';

  @override
  String get deadlineHelp =>
      'Мерзімге 30 минут қалғанда еске салу. Қалыпты наряд 10 минутта, апаттық наряд 3 минутта қабылданбаса, шеберге хабарлау.';

  @override
  String get completionCheck => 'Орындалуын тексеру';

  @override
  String get noReviewOrders => 'Тексерілетін нарядтар жоқ';

  @override
  String get photoAnalysis => 'Дейінгі және кейінгі фотоларды талдау';

  @override
  String get photoAnalysisHelp =>
      'Фотолардың бар-жоғын және өзектілігін тексеру, жабдық пен көрінетін ақауларды салыстыру. Сенімділік төмен болса, шебердің тексеруі қажет.';

  @override
  String get orderReport => 'Наряд бойынша есеп';

  @override
  String get orderReportHelp =>
      'Жұмыстар, материалдар, оқиғалар реті, мерзімнің сақталуы және баға түсіндірмесі наряд карточкасында жиналған.';

  @override
  String get equipmentAnomalies => 'Жабдық ауытқулары';

  @override
  String get employeeRating => 'Орындаушылар рейтингі';

  @override
  String get ratingHelp =>
      'Баға сапаға, уақытында орындалуға, қайта өңдеуге, жұмыс күрделілігіне және бас тартудың негізділігіне байланысты қалыптасады.';

  @override
  String get masterAssistant => 'Шебер көмекшісі';

  @override
  String get chatHelp => 'Чат үлгісі. Жауаптар демонстрациялық.';

  @override
  String get chatHint => 'Мысалы: қазір кім бос?';

  @override
  String get showDemoAnswer => 'Демо-жауапты көрсету';

  @override
  String get reportsRating => 'Есептер мен рейтинг';

  @override
  String get reportsSubtitle =>
      'Ағымдағы демонстрациялық ауысымның қорытындысы';

  @override
  String get pdfNotReady => 'PDF экспортын сервермен бірге қосамыз';

  @override
  String get exportPdf => 'PDF экспорты';

  @override
  String get excelNotReady => 'Excel экспортын сервермен бірге қосамыз';

  @override
  String get exportExcel => 'Excel экспорты';

  @override
  String get periodNotReady =>
      'Кез келген кезең бойынша есептерді серверге тарих қосылғаннан кейін қосамыз';

  @override
  String get selectPeriod => 'Кезеңді таңдау';

  @override
  String get totalOrders => 'Барлық нарядтар';

  @override
  String get closed => 'Жабылды';

  @override
  String get rejected => 'Қабылданбады';

  @override
  String get equipmentDowntime => 'Жабдықтың тоқтап тұруы';

  @override
  String get downtimeReportHelp =>
      'Есеп үлгісі: жабдықтың тоқтау уақыты, себептері және жоспарлы / жоспардан тыс жұмыстардың үлесі.';

  @override
  String get usedMaterials => 'Есептен шығарылған материалдар';

  @override
  String get materialsReportHelp =>
      'Есеп үлгісі: материалдар, учаскелер және орындаушылар бойынша шығын, нормативтермен салыстыру.';

  @override
  String get notificationCenter => 'Хабарландырулар орталығы';

  @override
  String get notificationsSubtitle =>
      'Прототиптің жергілікті хабарландырулары. Push қосылмаған.';

  @override
  String get noNotifications => 'Жаңа хабарландырулар жоқ';

  @override
  String get awaitingReview => 'Жұмыс қабылдауды күтуде';

  @override
  String get emergencyAwaiting => 'Апаттық наряд жауап күтуде';

  @override
  String get normalPriority => 'Қалыпты';

  @override
  String get permissionDenied =>
      'Қолданба баптауларында камераға немесе фотоларға қолжетімділік беріңіз.';

  @override
  String get pickerFailed =>
      'Камераны немесе галереяны ашу мүмкін болмады. Қайта көріңіз.';

  @override
  String get photoLoadFailed =>
      'Фотоны жүктеу мүмкін болмады. Басқа суретті таңдаңыз.';

  @override
  String get deadline => 'Орындау мерзімі';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get select => 'Таңдау';

  @override
  String get executionTime => 'Орындау уақыты';

  @override
  String get futureDeadline => 'Болашақтағы мерзімді таңдаңыз.';

  @override
  String get createOrderTitle => 'Наряд жасау';

  @override
  String get workDescription => 'Жұмыс сипаттамасы';

  @override
  String get unplanned => 'Жоспардан тыс';

  @override
  String get planned => 'Жоспарлы';

  @override
  String get optionalWorkTitle => 'Жұмыс атауы (міндетті емес)';

  @override
  String get problemWorks => 'Мәселе және қажетті жұмыстар';

  @override
  String get voiceInput => 'Дауыспен енгізу';

  @override
  String get voiceNotReady => 'Дауыспен енгізуді кейін қосамыз.';

  @override
  String get describeProblem => 'Мәселені сипаттаңыз';

  @override
  String get locationAssignee => 'Орын және орындаушы';

  @override
  String get brigade => 'Бригада';

  @override
  String get selectEmployee => 'Орындаушыны таңдаңыз';

  @override
  String get selectBrigade => 'Бригаданы таңдаңыз';

  @override
  String get deadlinePriority => 'Мерзім және басымдық';

  @override
  String get emergencyPriority => 'Апаттық';

  @override
  String get highPriority => 'Жоғары';

  @override
  String get normHoursShort => 'Норматив, сағ';

  @override
  String get dateTime => 'Күн мен уақыт';

  @override
  String get normHours => 'Сағатпен берілген норматив';

  @override
  String get normRange => '1 минуттан 8760 сағатқа дейін көрсетіңіз';

  @override
  String get optionalFaultCode => 'Ақау коды (міндетті емес)';

  @override
  String get notSpecified => 'Көрсетілмеген';

  @override
  String get comment => 'Түсініктеме';

  @override
  String get faultPhotos => 'Ақау фотолары · 5-ке дейін';

  @override
  String get issueOrder => 'Наряд беру';

  @override
  String get reason => 'Себеп';

  @override
  String get specifyReason => 'Себебін көрсетіңіз';

  @override
  String get confirm => 'Растау';

  @override
  String get employeeOrBrigade => 'Орындаушы немесе бригада';

  @override
  String get orderPriority => 'Наряд басымдығы';

  @override
  String get masterScore => 'Шебер бағасы';

  @override
  String get overdueSingular => 'Мерзімі өткен';

  @override
  String get orderInformation => 'Наряд туралы ақпарат';

  @override
  String get workType => 'Жұмыс түрі';

  @override
  String get description => 'Сипаттама';

  @override
  String get issueDate => 'Берілген күні';

  @override
  String get norm => 'Норматив';

  @override
  String get faultCode => 'Ақау коды';

  @override
  String get master => 'Шебер';

  @override
  String get orderDowntime => 'Жабдықтың тоқтап тұруы';

  @override
  String get stopped => 'Жабдық тоқтатылған';

  @override
  String get noDowntime => 'Жабдық тоқтап тұрған жоқ';

  @override
  String get beforeWork => 'Орындалғанға дейін';

  @override
  String get afterWork => 'Орындалғаннан кейін';

  @override
  String get reassign => 'Қайта тағайындау';

  @override
  String get changePriority => 'Басымдықты өзгерту';

  @override
  String get cancelOrderTitle => 'Нарядтан бас тарту';

  @override
  String get cancelOrder => 'Нарядтың күшін жою';

  @override
  String get workerReport => 'Орындаушы есебі';

  @override
  String get completedWorks => 'Орындалған жұмыстар';

  @override
  String get materials => 'Материалдар';

  @override
  String get notSpecifiedPlural => 'Көрсетілмеген';

  @override
  String get changeScore => 'Бағаны өзгерту';

  @override
  String get acceptedByMaster => 'Жұмыстарды шебер қабылдады';

  @override
  String get acceptClose => 'Қабылдау және жабу';

  @override
  String get returnRework => 'Қайта өңдеуге қайтару';

  @override
  String get toRework => 'Қайта өңдеуге';

  @override
  String get actionHistory => 'Әрекеттер тарихы';

  @override
  String get reports => 'Есептер';

  @override
  String get notifications => 'Хабарландырулар';

  @override
  String get shift => 'Ауысым';

  @override
  String get shiftManagement => 'АУЫСЫМДЫ БАСҚАРУ';

  @override
  String get masterRole => 'Ауысым шебері';

  @override
  String get offShift => 'Ауысымда емес';

  @override
  String get aiDemoLabel => 'Демонстрациялық деректер · ЖИ қосылмаған';

  @override
  String get photoOpenFailed => 'Фотоны ашу мүмкін болмады';

  @override
  String get noPhotos => 'Фотолар тіркелмеген';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get statusIssued => 'Берілді';

  @override
  String get statusAccepted => 'Қабылданды';

  @override
  String get statusPaused => 'Уақытша тоқтатылды';

  @override
  String get statusReview => 'Тексерілуде';

  @override
  String get statusClosed => 'Жабылды';

  @override
  String get statusRejected => 'Қабылданбады';

  @override
  String get statusCancelled => 'Күші жойылды';

  @override
  String get emergencyFull => 'Апаттық — шұғыл орындау';

  @override
  String get normalFull => 'Қалыпты — кезек тәртібімен';

  @override
  String get noAiVerdict => 'Қорытынды жоқ';

  @override
  String get aiUnavailable => 'ЖИ әлі қосылмаған.';

  @override
  String get positiveNorm => 'Норматив нөлден үлкен болуы керек';

  @override
  String get onShiftAssignee =>
      'Ауысымдағы орындаушыны немесе бригаданы таңдаңыз';

  @override
  String get futureDeadlineError => 'Мерзім болашақта болуы керек';

  @override
  String get fivePhotos => '5 фотодан артық емес';

  @override
  String get employeeOffShift => 'Қызметкер ауысымда емес';

  @override
  String get brigadeOffShift => 'Бригада ауысымда емес';

  @override
  String get language => 'Тіл';

  @override
  String get complex => 'Минералдық кешен';

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
    return 'Берілетін уақыт: $date';
  }

  @override
  String issuedAt(String date) {
    return 'Берілді: $date';
  }

  @override
  String dueAt(String date) {
    return 'Мерзімі: $date';
  }

  @override
  String hoursValue(String hours) {
    return '$hours сағ';
  }

  @override
  String scoreValue(String score) {
    return '5-тен $score';
  }

  @override
  String employeeGrade(String specialty, String grade) {
    return '$specialty · $grade разряд';
  }

  @override
  String workingOrder(String number) {
    return 'Орындалуда · №$number';
  }

  @override
  String workingQueue(String number, String count) {
    return 'Орындалуда · №$number · кезекте $count';
  }

  @override
  String queuedCount(String count) {
    return 'Кезекте · $count';
  }

  @override
  String assignedOrder(String number) {
    return 'Бос емес · №$number тағайындалған';
  }

  @override
  String brigadeAvailability(String total, String free, String busy) {
    return 'Ауысымда: $total · бос: $free · бос емес: $busy';
  }

  @override
  String overdueMinutes(String minutes) {
    return 'Кешігу · $minutes мин.';
  }

  @override
  String removePhoto(String number) {
    return '$number-фотоны жою';
  }

  @override
  String boardCount(String label, String count) {
    return '$label · $count';
  }

  @override
  String shiftTime(String number, String time) {
    return 'Ауысым №$number · $time';
  }

  @override
  String aiVerdict(String verdict) {
    return 'ЖИ қорытындысы: $verdict';
  }

  @override
  String aiSummary(String explanation, String aiScore, String score) {
    return '$explanation\nЖИ бағасы: $aiScore / 5.\nҚорытынды баға: $score / 5.\nСоңғы шешімді шебер қабылдайды.';
  }

  @override
  String eventIssued(String assignee) {
    return 'Наряд берілді: $assignee';
  }

  @override
  String eventReassigned(String assignee) {
    return 'Қайта тағайындалды: $assignee';
  }

  @override
  String eventPriority(String priority) {
    return 'Басымдық өзгертілді: $priority';
  }

  @override
  String eventScore(String score) {
    return 'Шебер бағасы: $score / 5';
  }

  @override
  String eventReason(String status, String reason) {
    return '$status: $reason';
  }
}
