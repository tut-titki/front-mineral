import 'package:flutter/material.dart';

import 'package:mineral/shared/models/models.dart';

class DemoStore extends ChangeNotifier {
  DemoStore({DateTime Function()? clock, this.onOrderChanged})
    : _clock = clock ?? DateTime.now;

  final void Function(OrderEventKind kind)? onOrderChanged;

  void _orderChanged(OrderEventKind kind) {
    notifyListeners();
    onOrderChanged?.call(kind);
  }

  final DateTime Function() _clock;
  DateTime get now => _clock();

  static const masterName = 'Серик Омаров';
  static const areas = {
    'Дробление': ['Дробилка КМД-1750', 'Конвейер К-3', 'Грохот ГИС-52'],
    'Обогащение': ['Насос Н-12', 'Мельница МШР-3', 'Сепаратор С-4'],
    'Ремонтный цех': ['Станок Т-16', 'Кран-балка КБ-2'],
    'Транспортный участок': ['Погрузчик П-7', 'Компрессор ВК-22'],
  };

  static const priorities = ['Аварийный', 'Высокий', 'Обычный', 'Плановый'];
  static const priorityLabels = {
    'Аварийный': 'Аварийный — срочно в работу',
    'Высокий': 'Высокий',
    'Обычный': 'Обычный — в порядке очереди',
    'Плановый': 'Плановый',
  };
  static const faultCodes = [
    'М-02 · Подшипник',
    'Г-01 · Течь масла',
    'Э-03 · Обрыв кабеля',
    'С-01 · Недостаток смазки',
    'П-02 · Утечка воздуха',
  ];

  List<String> get brigades => employees.map((e) => e.brigade).toSet().toList();
  List<Employee> brigadeMembers(String brigade) =>
      employees.where((e) => e.brigade == brigade).toList();
  String assignmentLabel(WorkOrder order) =>
      order.brigade ?? employee(order.employeeId).name;

  DateTime get shiftStart {
    final current = now;
    if (current.hour >= 20) {
      return DateTime(current.year, current.month, current.day, 20);
    }
    if (current.hour >= 8) {
      return DateTime(current.year, current.month, current.day, 8);
    }
    return DateTime(current.year, current.month, current.day - 1, 20);
  }

  List<WorkOrder> get shiftOrders => orders
      .where(
        (o) => !o.createdAt.isBefore(shiftStart) && !o.createdAt.isAfter(now),
      )
      .toList();
  int get completedThisShift => orders
      .where(
        (o) =>
            [OrderStatus.review, OrderStatus.closed].contains(o.status) &&
            o.history.any(
              (event) =>
                  !event.time.isBefore(shiftStart) &&
                  (event.title.startsWith(OrderStatus.review.label) ||
                      event.title.startsWith(OrderStatus.closed.label)),
            ),
      )
      .length;
  int get stoppedEquipmentCount => orders
      .where(
        (o) =>
            o.equipmentStopped &&
            ![
              OrderStatus.closed,
              OrderStatus.cancelled,
              OrderStatus.rejected,
            ].contains(o.status),
      )
      .map((o) => '${o.area}/${o.equipment}')
      .toSet()
      .length;

  final employees = const [
    Employee(
      id: 1,
      name: 'Ерлан Ахметов',
      specialty: 'Слесарь',
      grade: 5,
      brigade: 'Бригада №1',
      rating: 4.8,
    ),
    Employee(
      id: 2,
      name: 'Данияр Садыков',
      specialty: 'Электрик',
      grade: 6,
      brigade: 'Бригада №2',
      rating: 4.9,
    ),
    Employee(
      id: 3,
      name: 'Алексей Ким',
      specialty: 'Сварщик',
      grade: 5,
      brigade: 'Бригада №1',
      rating: 4.7,
    ),
    Employee(
      id: 4,
      name: 'Марат Нурланов',
      specialty: 'Слесарь',
      grade: 4,
      brigade: 'Бригада №3',
      rating: 4.6,
    ),
    Employee(
      id: 5,
      name: 'Иван Петров',
      specialty: 'Электрик',
      grade: 5,
      brigade: 'Бригада №2',
      rating: 4.5,
      onShift: false,
    ),
  ];

  late final List<WorkOrder> orders = _seed();

  List<WorkOrder> _seed() {
    final now = this.now;

    WorkOrder order({
      required int number,
      required String title,
      required String equipment,
      required String area,
      required int employeeId,
      required String priority,
      required OrderStatus status,
      required int deadlineMinutes,
      bool planned = false,
    }) {
      final created = now.subtract(Duration(minutes: 15 + (number % 6) * 12));

      return WorkOrder(
        number: number,
        title: title,
        description:
            'Проверить состояние оборудования, устранить неисправность '
            'и выполнить контрольный запуск.',
        area: area,
        equipment: equipment,
        employeeId: employeeId,
        priority: priority,
        deadline: now.add(Duration(minutes: deadlineMinutes)),
        createdAt: created,
        planned: planned,
        status: status,
        equipmentStopped: number == 147 || number == 148,
        beforePhotos: 1,
        afterPhotos: status == OrderStatus.review ? 1 : 0,
        completedWork: status == OrderStatus.review
            ? 'Заменено уплотнение. Соединения проверены. '
                  'При контрольном запуске течь отсутствует.'
            : '',
        faultCode: status == OrderStatus.review ? 'Г-01 · Течь масла' : '',
        materials: status == OrderStatus.review
            ? 'Уплотнение 40×60 — 1 шт.\nМасло И-40 — 0,5 л'
            : '',
        comment: number == 147 ? 'Ждём подшипник со склада' : '',
        history: [
          OrderEvent(title: 'Наряд выдан', author: 'С. Омаров', time: created),
          if (status != OrderStatus.issued)
            OrderEvent(
              title: status.label,
              author: employee(employeeId).name,
              time: created.add(const Duration(minutes: 12)),
            ),
        ],
      );
    }

    return [
      order(
        number: 147,
        title: 'Замена подшипника привода',
        equipment: 'Дробилка КМД-1750',
        area: 'Дробление',
        employeeId: 1,
        priority: 'Высокий',
        status: OrderStatus.working,
        deadlineMinutes: -45,
      ),
      order(
        number: 148,
        title: 'Устранение течи масла',
        equipment: 'Насос Н-12',
        area: 'Обогащение',
        employeeId: 4,
        priority: 'Аварийный',
        status: OrderStatus.issued,
        deadlineMinutes: 50,
      ),
      order(
        number: 149,
        title: 'Проверка питания двигателя',
        equipment: 'Конвейер К-3',
        area: 'Дробление',
        employeeId: 2,
        priority: 'Высокий',
        status: OrderStatus.accepted,
        deadlineMinutes: 120,
      ),
      order(
        number: 150,
        title: 'Плановая смазка узлов',
        equipment: 'Грохот ГИС-52',
        area: 'Дробление',
        employeeId: 1,
        priority: 'Плановый',
        status: OrderStatus.queued,
        deadlineMinutes: 180,
        planned: true,
      ),
      order(
        number: 145,
        title: 'Замена уплотнения вала',
        equipment: 'Насос Н-12',
        area: 'Обогащение',
        employeeId: 4,
        priority: 'Обычный',
        status: OrderStatus.review,
        deadlineMinutes: 60,
      ),
      order(
        number: 143,
        title: 'Восстановление защитного кожуха',
        equipment: 'Конвейер К-3',
        area: 'Дробление',
        employeeId: 3,
        priority: 'Обычный',
        status: OrderStatus.closed,
        deadlineMinutes: -120,
      ),
    ];
  }

  Employee employee(int id) {
    return employees.firstWhere((item) => item.id == id);
  }

  int get nextNumber {
    return orders.fold<int>(
          0,
          (maximum, order) => order.number > maximum ? order.number : maximum,
        ) +
        1;
  }

  int count(OrderStatus status) {
    return orders.where((order) => order.status == status).length;
  }

  List<WorkOrder> assignedTo(int employeeId) {
    final member = employee(employeeId);
    return orders
        .where(
          (order) => order.brigade == null
              ? order.employeeId == employeeId
              : order.brigade == member.brigade,
        )
        .toList();
  }

  String employeeStatus(Employee employee) {
    if (!employee.onShift) return 'Не на смене';

    final assigned = assignedTo(employee.id);

    final working = assigned
        .where(
          (order) =>
              order.status == OrderStatus.working ||
              order.status == OrderStatus.paused ||
              order.status == OrderStatus.rework,
        )
        .firstOrNull;

    final queued = assigned
        .where((order) => order.status == OrderStatus.queued)
        .length;

    if (working != null) {
      return 'В работе · №${working.number}'
          '${queued > 0 ? ' · очередь $queued' : ''}';
    }

    if (queued > 0) return 'В очереди · $queued';

    final assignedOrder = assigned
        .where(
          (order) =>
              order.status == OrderStatus.issued ||
              order.status == OrderStatus.accepted,
        )
        .firstOrNull;
    if (assignedOrder != null) {
      return 'Занят · назначен №${assignedOrder.number}';
    }

    return 'Свободен';
  }

  Color employeeColor(Employee employee) {
    final status = employeeStatus(employee);

    if (!employee.onShift) return const Color(0xFF94A3B8);
    if (status == 'Свободен') return const Color(0xFF059669);
    if (status.startsWith('В очереди')) {
      return const Color(0xFF2563EB);
    }

    return const Color(0xFFD97706);
  }

  void addOrder(WorkOrder order) {
    if (order.history.isEmpty) {
      order.history.add(
        OrderEvent(
          title: 'Наряд выдан: ${assignmentLabel(order)}',
          kind: OrderEventKind.issued,
          value: assignmentLabel(order),
          author: masterName,
          time: order.createdAt,
        ),
      );
    }
    orders.insert(0, order);
    _orderChanged(OrderEventKind.issued);
  }

  WorkOrder issueOrder({
    required String title,
    required String description,
    required String area,
    required String equipment,
    int? employeeId,
    String? brigade,
    required String priority,
    required bool planned,
    DateTime? deadline,
    double? normHours,
    String comment = '',
    String faultCode = '',
    bool equipmentStopped = false,
    List<OrderPhoto> photos = const [],
  }) {
    final issuedAt = now;
    if (normHours != null && (!normHours.isFinite || normHours <= 0)) {
      throw ArgumentError('Норматив должен быть больше нуля');
    }
    final assignee = brigade == null
        ? (employeeId == null ? null : employee(employeeId))
        : brigadeMembers(brigade).where((e) => e.onShift).firstOrNull;
    if (assignee == null || !assignee.onShift) {
      throw ArgumentError('Выберите исполнителя или бригаду на смене');
    }
    final dueAt = normHours == null
        ? deadline
        : issuedAt.add(Duration(minutes: (normHours * 60).round()));
    if (dueAt == null || !dueAt.isAfter(issuedAt)) {
      throw ArgumentError('Срок должен быть в будущем');
    }
    if (photos.length > 5) throw ArgumentError('Не более 5 фото');
    final order = WorkOrder(
      number: nextNumber,
      title: title,
      description: description,
      area: area,
      equipment: equipment,
      employeeId: assignee.id,
      brigade: brigade,
      priority: priority,
      planned: planned,
      createdAt: issuedAt,
      deadline: dueAt,
      normHours: normHours,
      comment: comment,
      faultCode: faultCode,
      equipmentStopped: equipmentStopped,
      beforePhotos: photos.length,
      beforeImages: photos,
    );
    addOrder(order);
    return order;
  }

  void changeStatus(
    WorkOrder order,
    OrderStatus status, {
    String reason = '',
    String author = 'Мастер · С. Омаров',
  }) {
    if (order.status == status) return;
    order.status = status;

    order.history.add(
      OrderEvent(
        title: '${status.label}${reason.isEmpty ? '' : ': $reason'}',
        kind: OrderEventKind.status,
        status: status,
        reason: reason,
        author: author,
        time: now,
      ),
    );

    _orderChanged(OrderEventKind.status);
  }

  void reassign(WorkOrder order, int employeeId) {
    if (!employee(employeeId).onShift) {
      throw ArgumentError('Сотрудник не на смене');
    }
    if (order.brigade == null && order.employeeId == employeeId) return;
    order.employeeId = employeeId;
    order.brigade = null;

    order.history.add(
      OrderEvent(
        title: 'Переназначен: ${employee(employeeId).name}',
        kind: OrderEventKind.reassigned,
        value: employee(employeeId).name,
        author: 'Мастер · С. Омаров',
        time: DateTime.now(),
      ),
    );

    _orderChanged(OrderEventKind.reassigned);
  }

  void changePriority(WorkOrder order, String priority) {
    if (order.priority == priority) return;
    order.priority = priority;

    order.history.add(
      OrderEvent(
        title: 'Приоритет изменён: $priority',
        kind: OrderEventKind.priority,
        value: priority,
        author: 'Мастер · С. Омаров',
        time: DateTime.now(),
      ),
    );

    _orderChanged(OrderEventKind.priority);
  }

  void reassignBrigade(WorkOrder order, String brigade) {
    final contact = brigadeMembers(brigade).where((e) => e.onShift).firstOrNull;
    if (contact == null) throw ArgumentError('Бригада не на смене');
    if (order.brigade == brigade) return;
    order.brigade = brigade;
    order.employeeId = contact.id;
    order.history.add(
      OrderEvent(
        title: 'Переназначен: $brigade',
        kind: OrderEventKind.reassigned,
        value: brigade,
        author: masterName,
        time: now,
      ),
    );
    _orderChanged(OrderEventKind.reassigned);
  }

  void setMasterScore(WorkOrder order, double score) {
    if (order.masterScore == score) return;
    order.masterScore = score;

    order.history.add(
      OrderEvent(
        title: 'Оценка мастера: ${score.toStringAsFixed(1)} / 5',
        kind: OrderEventKind.score,
        value: score.toStringAsFixed(1),
        author: 'Мастер · С. Омаров',
        time: DateTime.now(),
      ),
    );

    _orderChanged(OrderEventKind.score);
  }

  void changeDeadline(WorkOrder order, DateTime deadline) {
    if (!deadline.isAfter(now)) {
      throw ArgumentError('Срок должен быть в будущем');
    }
    if (order.deadline == deadline) return;
    if ([OrderStatus.closed, OrderStatus.cancelled].contains(order.status)) {
      throw StateError('Наряд завершён');
    }
    final previous =
        '${dateLabel(order.deadline)} ${timeLabel(order.deadline)}';
    final next = '${dateLabel(deadline)} ${timeLabel(deadline)}';
    order.deadline = deadline;
    order.normHours = null;
    order.history.add(
      OrderEvent(
        title: 'Срок изменён: $previous → $next',
        kind: OrderEventKind.deadline,
        value: '$previous → $next',
        author: masterName,
        time: now,
      ),
    );
    _orderChanged(OrderEventKind.deadline);
  }
}
