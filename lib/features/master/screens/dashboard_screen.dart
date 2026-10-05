import 'package:flutter/material.dart';
import 'package:mineral/features/orders/widgets/order_filters.dart';
import 'package:mineral/features/orders/widgets/kanban_column.dart';
export 'package:mineral/features/reports/screens/reports_screen.dart';
import 'package:mineral/features/team/screens/brigade_screen.dart';
import 'package:mineral/l10n/ui_localization.dart';

import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/shared/widgets/ui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    required this.onOrder,
    required this.onCreate,
    required this.onTeam,
  });

  final DemoStore store;
  final ValueChanged<WorkOrder> onOrder;
  final VoidCallback onCreate;
  final VoidCallback onTeam;

  @override
  Widget build(BuildContext context) {
    final urgent = store.orders
        .where(
          (order) =>
              order.overdue ||
              order.status == OrderStatus.review ||
              (order.emergency && order.status == OrderStatus.issued),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          'Обзор смены',
          subtitle: 'Здравствуйте, Серик. Вот что происходит на участке.',
          action: FilledButton.icon(
            onPressed: onCreate,
            icon: Icon(Icons.add),
            label: Text(uiText(context, 'Создать наряд')),
          ),
        ),
        AdaptiveGrid(
          minWidth: 190,
          children: [
            MetricCard(
              title: 'Выдано нарядов',
              value: '${store.shiftOrders.length}',
              icon: Icons.assignment_outlined,
            ),
            MetricCard(
              title: 'Выполнено',
              value: '${store.completedThisShift}',
              icon: Icons.task_alt,
              color: Color(0xFF059669),
            ),
            MetricCard(
              title: 'Просрочено',
              value: '${store.orders.where((o) => o.overdue).length}',
              icon: Icons.schedule,
              color: Colors.red,
            ),
            MetricCard(
              title: 'На приёмке',
              value: '${store.count(OrderStatus.review)}',
              icon: Icons.fact_check_outlined,
              color: Color(0xFF0284C7),
            ),
            MetricCard(
              title: 'Оборудование в простое',
              value: '${store.stoppedEquipmentCount}',
              icon: Icons.factory_outlined,
              color: Colors.orange,
            ),
          ],
        ),
        SizedBox(height: 28),
        SectionHeading('Требуют внимания'),
        if (urgent.isEmpty)
          Panel(
            child: Text(uiText(context, 'Нет нарядов, требующих внимания')),
          ),
        for (final order in urgent)
          OrderCard(order: order, store: store, onTap: () => onOrder(order)),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: SectionHeading('Команда на смене')),
            TextButton(
              onPressed: onTeam,
              child: Text(uiText(context, 'Вся команда →')),
            ),
          ],
        ),
        AdaptiveGrid(
          minWidth: 260,
          children: [
            for (final employee in store.employees.where(
              (item) => item.onShift,
            ))
              EmployeeCard(employee: employee, store: store),
          ],
        ),
      ],
    );
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
    required this.store,
    required this.onOrder,
    required this.onCreate,
  });

  final DemoStore store;
  final ValueChanged<WorkOrder> onOrder;
  final VoidCallback onCreate;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final searchController = TextEditingController();
  OrderFilters filters = OrderFilters();
  bool board = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> openFilters() async {
    final selected = await showModalBottomSheet<OrderFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => OrderFilterPanel(store: widget.store, filters: filters),
    );
    if (selected != null && mounted) setState(() => filters = selected);
  }

  List<WorkOrder> get filtered {
    final query = searchController.text.trim().toLowerCase();
    return widget.store.orders.where((order) {
      final text =
          '${order.number} ${order.title} ${order.description} '
          '${order.area} ${order.equipment} ${widget.store.assignmentLabel(order)}';
      return text.toLowerCase().contains(query) &&
          filters.matches(order, widget.store);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orders = filtered;
    List<(String, List<OrderStatus>)> columns = [
      ('Выданные', [OrderStatus.issued]),
      ('Принятые', [OrderStatus.accepted]),
      ('В работе', [OrderStatus.working]),
      ('В очереди', [OrderStatus.queued]),
      ('Выполненные', [OrderStatus.review, OrderStatus.closed]),
      ('Приостановлены', [OrderStatus.paused]),
      ('На доработке', [OrderStatus.rework]),
      ('Отклонены', [OrderStatus.rejected]),
      ('Отменены', [OrderStatus.cancelled]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          'Наряды',
          subtitle: 'Назначения, сроки и текущие статусы работ',
          action: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: widget.onCreate,
                icon: Icon(Icons.add),
                label: Text(uiText(context, 'Новый наряд')),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => board = !board),
                icon: Icon(
                  board ? Icons.view_list : Icons.view_kanban_outlined,
                ),
                label: Text(uiText(context, board ? 'Список' : 'Канбан')),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: uiText(context, 'Номер, работа или оборудование'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: strings(context).clearSearch,
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => searchController.clear()),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Badge(
              isLabelVisible: filters.count > 0,
              label: Text('${filters.count}'),
              child: IconButton.outlined(
                tooltip: strings(context).filters,
                onPressed: openFilters,
                style: IconButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  foregroundColor: filters.count > 0 ? brand : muted,
                  backgroundColor: filters.count > 0 ? lightBlue : Colors.white,
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
            ),
          ],
        ),
        if (filters.count > 0) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in filters.areas)
                InputChip(
                  label: Text(value),
                  onDeleted: () => setState(() => filters.areas.remove(value)),
                ),
              for (final id in filters.employees)
                InputChip(
                  label: Text(widget.store.employee(id).name),
                  onDeleted: () => setState(() => filters.employees.remove(id)),
                ),
              for (final value in filters.statuses)
                InputChip(
                  label: Text(uiText(context, value.label)),
                  onDeleted: () =>
                      setState(() => filters.statuses.remove(value)),
                ),
              TextButton(
                onPressed: () => setState(() => filters = OrderFilters()),
                child: Text(strings(context).resetFilters),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        if (orders.isEmpty)
          Panel(
            child: Text(uiText(context, 'По выбранным фильтрам нарядов нет')),
          )
        else if (!board)
          ...orders.map(
            (order) => OrderCard(
              order: order,
              store: widget.store,
              onTap: () => widget.onOrder(order),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final column in columns)
                  KanbanColumn(
                    title: column.$1,
                    color: column.$2.contains(OrderStatus.closed)
                        ? OrderStatus.closed.color
                        : column.$2.first.color,
                    orders: orders
                        .where((order) => column.$2.contains(order.status))
                        .toList(),
                    store: widget.store,
                    onOrder: widget.onOrder,
                  ),
                KanbanColumn(
                  title: 'Просроченные',
                  color: const Color(0xFFDC2626),
                  orders: orders.where((order) => order.overdue).toList(),
                  store: widget.store,
                  onOrder: widget.onOrder,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key, required this.employee, required this.store});

  final Employee employee;
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: lightBlue,
                child: Text(
                  employee.initials,
                  style: TextStyle(color: brand, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  employee.name,
                  style: TextStyle(fontWeight: FontWeight.w700, color: ink),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            uiText(context, '${employee.specialty} · ${employee.grade} разряд'),
            style: TextStyle(color: muted, fontSize: 13),
          ),
          SizedBox(height: 6),
          Text(
            uiText(context, employee.brigade),
            style: TextStyle(color: muted, fontSize: 13),
          ),
          SizedBox(height: 16),
          StatusTag(
            store.employeeStatus(employee),
            color: store.employeeColor(employee),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 5),
              Text(
                uiText(context, '${employee.rating} / 5'),
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  uiText(context, 'Демо-рейтинг'),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.store});

  final DemoStore store;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  String search = '';
  bool onlyFree = false;

  @override
  Widget build(BuildContext context) {
    final employees = widget.store.employees.where((employee) {
      return '${employee.brigade} ${employee.name} ${employee.specialty}'
              .toLowerCase()
              .contains(search.toLowerCase()) &&
          (!onlyFree || widget.store.employeeStatus(employee) == 'Свободен');
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          'Команда',
          subtitle: 'Загрузка исполнителей, специальности и доступность',
        ),
        TextField(
          onChanged: (value) => setState(() => search = value),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: strings(context).teamBrigadeSearch,
          ),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilterChip(
            label: Text(uiText(context, 'Только свободные')),
            selected: onlyFree,
            onSelected: (value) => setState(() => onlyFree = value),
          ),
        ),
        SizedBox(height: 16),
        if (employees.isEmpty)
          Text(uiText(context, 'Исполнители не найдены'))
        else
          for (final brigade in employees.map((e) => e.brigade).toSet())
            Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: lightBlue,
                    child: Icon(Icons.groups_outlined, color: brand),
                  ),
                  title: BrigadeChoice(brigade: brigade, store: widget.store),
                  trailing: const Icon(Icons.chevron_right, color: muted),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BrigadeMembersScreen(
                        store: widget.store,
                        brigade: brigade,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: border),
              ],
            ),
      ],
    );
  }
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key, required this.store, required this.onOrder});

  final DemoStore store;
  final ValueChanged<WorkOrder> onOrder;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final controller = TextEditingController();
  String? answer;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.store.orders
        .where((order) => order.status == OrderStatus.review)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          'ИИ-контроль',
          subtitle:
              'Рекомендации цифрового контролёра. '
              'Финальное решение принимает мастер.',
        ),
        AiCard(
          title: 'Контроль сроков',
          text:
              'Напоминание за 30 минут до срока. Эскалация, если '
              'обычный наряд не принят за 10 минут, аварийный — за 3 минуты.',
        ),
        SizedBox(height: 14),
        for (final order in widget.store.orders.where((order) => order.overdue))
          OrderCard(
            order: order,
            store: widget.store,
            onTap: () => widget.onOrder(order),
          ),
        SizedBox(height: 10),
        SectionHeading('Проверка выполнения'),
        for (final order in review)
          OrderCard(
            order: order,
            store: widget.store,
            onTap: () => widget.onOrder(order),
          ),
        if (review.isEmpty)
          Panel(child: Text(uiText(context, 'Нет нарядов на проверке'))),
        SizedBox(height: 24),
        AdaptiveGrid(
          minWidth: 300,
          children: [
            AiCard(
              title: 'Анализ фото до / после',
              text:
                  'Проверка наличия и актуальности фото, сравнение '
                  'оборудования и видимых дефектов. При низкой уверенности '
                  'потребуется проверка мастера.',
            ),
            AiCard(
              title: 'Отчёт по наряду',
              text:
                  'Работы, материалы, хронология, соблюдение срока '
                  'и объяснение оценки собраны в карточке наряда.',
            ),
            AiCard(
              title: 'Аномалии оборудования',
              text:
                  'Пример вывода: конвейер К-3 часто останавливается '
                  'из-за подшипников. Рекомендация: проверить соосность '
                  'привода и скорректировать план ППР.',
              warning: true,
            ),
            AiCard(
              title: 'Рейтинг исполнителей',
              text:
                  'Качество, выполнение в срок, доработки, сложность '
                  'работ и обоснованность отказов формируют оценку.',
            ),
          ],
        ),
        SizedBox(height: 24),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading('Ассистент мастера'),
              Text(
                uiText(context, 'Макет чата. Ответы демонстрационные.'),
                style: TextStyle(color: muted),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: uiText(context, 'Например: кто сейчас свободен?'),
                  prefixIcon: Icon(Icons.chat_bubble_outline),
                ),
              ),
              SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;

                  setState(() {
                    answer =
                        'Демо-ответ: здесь появятся рекомендации '
                        'по запросу «${controller.text.trim()}». '
                        'Для анализа необходимо подключить backend и ИИ.';
                  });
                },
                child: Text(uiText(context, 'Показать демо-ответ')),
              ),
              if (answer != null) ...[
                SizedBox(height: 16),
                Text(uiText(context, answer!), style: TextStyle(height: 1.6)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.store,
    required this.onOrder,
  });

  final DemoStore store;
  final ValueChanged<WorkOrder> onOrder;

  @override
  Widget build(BuildContext context) {
    final orders = store.orders.where(
      (order) =>
          order.overdue ||
          order.status == OrderStatus.review ||
          (order.emergency && order.status == OrderStatus.issued),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          'Центр уведомлений',
          subtitle: 'Локальные уведомления прототипа. Push не подключён.',
        ),
        if (orders.isEmpty)
          Panel(child: Text(uiText(context, 'Новых уведомлений нет'))),
        for (final order in orders) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              uiText(
                context,
                order.overdue
                    ? 'Просрочка · ${DateTime.now().difference(order.deadline).inMinutes} мин.'
                    : order.status == OrderStatus.review
                    ? 'Работа ожидает приёмки'
                    : 'Аварийный наряд ожидает ответа',
              ),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: order.overdue ? Colors.red : brand,
              ),
            ),
          ),
          OrderCard(order: order, store: store, onTap: () => onOrder(order)),
        ],
      ],
    );
  }
}
