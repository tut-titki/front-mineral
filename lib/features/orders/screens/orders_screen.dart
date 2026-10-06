import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/widgets/backend_section.dart';
import 'package:mineral/core/api/api_client.dart';
import 'package:mineral/core/api/api_services.dart';
import 'package:mineral/features/orders/models/work_order_api_models.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/shared/widgets/ui.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
    required this.api,
    required this.onOrder,
    required this.onCreate,
  });

  final ApiServices api;
  final ValueChanged<WorkOrderApiModel> onOrder;
  final VoidCallback onCreate;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final searchController = TextEditingController();

  List<WorkOrderApiModel> orders = [];

  bool loading = true;
  bool refreshing = false;
  bool board = false;

  String? error;
  int generation = 0;
  StreamSubscription<void>? subscription;

  WorkOrderStatus? statusFilter;
  WorkOrderPriority? priorityFilter;

  bool overdueOnly = false;

  @override
  void initState() {
    super.initState();
    subscription = widget.api.realtime.changes.listen(
      (_) => loadOrders(refresh: true),
    );
    loadOrders();
  }

  @override
  void dispose() {
    subscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // MARK: Load

  Future<void> loadOrders({bool refresh = false}) async {
    final requestGeneration = ++generation;
    if (refresh) {
      setState(() {
        refreshing = true;
        error = null;
      });
    } else {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result = await widget.api.workOrders.getAllWorkOrders();

      if (!mounted || requestGeneration != generation) return;

      setState(() {
        orders = result;
        loading = false;
        refreshing = false;
      });
    } on ApiException catch (e) {
      if (!mounted || requestGeneration != generation) return;

      setState(() {
        error = e.message;
        loading = false;
        refreshing = false;
      });
    } catch (e) {
      if (!mounted || requestGeneration != generation) return;

      setState(() {
        error = backendError(context, e);
        loading = false;
        refreshing = false;
      });
    }
  }

  // MARK: Filter

  List<WorkOrderApiModel> get filteredOrders {
    final query = searchController.text.trim().toLowerCase();

    return orders.where((order) {
      if (statusFilter != null && order.status != statusFilter) {
        return false;
      }

      if (priorityFilter != null && order.priority != priorityFilter) {
        return false;
      }

      if (overdueOnly && !order.isOverdue) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchText = [
        order.number,
        order.description,
        order.area.name,
        order.equipment.name,
        order.equipment.inventoryNumber,
        order.assignee.fullName,
        order.faultCode?.code,
        order.faultCode?.name,
      ].whereType<String>().join(' ').toLowerCase();

      return searchText.contains(query);
    }).toList();
  }

  int get activeFilters {
    var count = 0;

    if (statusFilter != null) count++;
    if (priorityFilter != null) count++;
    if (overdueOnly) count++;

    return count;
  }

  // MARK: Filters

  Future<void> openFilters() async {
    WorkOrderStatus? tempStatus = statusFilter;
    WorkOrderPriority? tempPriority = priorityFilter;
    bool tempOverdue = overdueOnly;

    final apply = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    uiText(context, 'Фильтры'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),

                  const SizedBox(height: 22),

                  DropdownButtonFormField<WorkOrderStatus?>(
                    initialValue: tempStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: uiText(context, 'Статус'),
                    ),
                    items: [
                      DropdownMenuItem<WorkOrderStatus?>(
                        value: null,
                        child: Text(uiText(context, 'Все статусы')),
                      ),
                      for (final status in WorkOrderStatus.values)
                        DropdownMenuItem<WorkOrderStatus?>(
                          value: status,
                          child: Text(uiText(context, status.label)),
                        ),
                    ],
                    onChanged: (value) {
                      setSheetState(() {
                        tempStatus = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<WorkOrderPriority?>(
                    initialValue: tempPriority,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: uiText(context, 'Приоритет'),
                    ),
                    items: [
                      DropdownMenuItem<WorkOrderPriority?>(
                        value: null,
                        child: Text(uiText(context, 'Все приоритеты')),
                      ),
                      for (final priority in WorkOrderPriority.values)
                        DropdownMenuItem<WorkOrderPriority?>(
                          value: priority,
                          child: Text(uiText(context, priority.label)),
                        ),
                    ],
                    onChanged: (value) {
                      setSheetState(() {
                        tempPriority = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(uiText(context, 'Только просроченные')),
                    value: tempOverdue,
                    onChanged: (value) {
                      setSheetState(() {
                        tempOverdue = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempStatus = null;
                            tempPriority = null;
                            tempOverdue = false;
                          });
                        },
                        child: Text(strings(context).resetFilters),
                      ),

                      const Spacer(),

                      FilledButton(
                        onPressed: () {
                          Navigator.pop(sheetContext, true);
                        },
                        child: Text(uiText(context, 'Применить')),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (apply != true || !mounted) {
      return;
    }

    setState(() {
      statusFilter = tempStatus;
      priorityFilter = tempPriority;
      overdueOnly = tempOverdue;
    });
  }

  // MARK: UI

  @override
  Widget build(BuildContext context) {
    final filtered = filteredOrders;

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
                icon: const Icon(Icons.add),
                label: Text(uiText(context, 'Новый наряд')),
              ),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    board = !board;
                  });
                },
                icon: Icon(
                  board ? Icons.view_list : Icons.view_kanban_outlined,
                ),
                label: Text(uiText(context, board ? 'Список' : 'Канбан')),
              ),

              IconButton.outlined(
                tooltip: uiText(context, 'Обновить'),
                onPressed: refreshing ? null : () => loadOrders(refresh: true),
                icon: refreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
        ),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: uiText(context, 'Номер, работа или оборудование'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: strings(context).clearSearch,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                            });
                          },
                        ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Badge(
              isLabelVisible: activeFilters > 0,
              label: Text('$activeFilters'),
              child: IconButton.outlined(
                tooltip: strings(context).filters,
                onPressed: openFilters,
                style: IconButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  foregroundColor: activeFilters > 0 ? brand : muted,
                  backgroundColor: activeFilters > 0 ? lightBlue : Colors.white,
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
            ),
          ],
        ),

        if (activeFilters > 0) ...[
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (statusFilter != null)
                InputChip(
                  label: Text(uiText(context, statusFilter!.label)),
                  onDeleted: () {
                    setState(() {
                      statusFilter = null;
                    });
                  },
                ),

              if (priorityFilter != null)
                InputChip(
                  label: Text(uiText(context, priorityFilter!.label)),
                  onDeleted: () {
                    setState(() {
                      priorityFilter = null;
                    });
                  },
                ),

              if (overdueOnly)
                InputChip(
                  label: Text(uiText(context, 'Просроченные')),
                  onDeleted: () {
                    setState(() {
                      overdueOnly = false;
                    });
                  },
                ),

              TextButton(
                onPressed: () {
                  setState(() {
                    statusFilter = null;
                    priorityFilter = null;
                    overdueOnly = false;
                  });
                },
                child: Text(strings(context).resetFilters),
              ),
            ],
          ),
        ],

        const SizedBox(height: 18),

        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          _OrdersError(message: error!, onRetry: loadOrders)
        else if (filtered.isEmpty)
          Panel(
            child: Text(uiText(context, 'По выбранным фильтрам нарядов нет')),
          )
        else if (!board)
          ...filtered.map(
            (order) => ApiOrderCard(
              order: order,
              onTap: () {
                widget.onOrder(order);
              },
            ),
          )
        else
          _buildBoard(filtered),
      ],
    );
  }

  Widget _buildBoard(List<WorkOrderApiModel> filtered) {
    final columns = <(String, WorkOrderStatus)>[
      ('Выданные', WorkOrderStatus.issued),
      ('В очереди', WorkOrderStatus.queued),
      ('Принятые', WorkOrderStatus.accepted),
      ('В работе', WorkOrderStatus.inProgress),
      ('Приостановлены', WorkOrderStatus.paused),
      ('Выполненные', WorkOrderStatus.completed),
      ('На проверке', WorkOrderStatus.aiReview),
      ('На доработке', WorkOrderStatus.rework),
      ('Закрытые', WorkOrderStatus.closed),
      ('Отклонённые', WorkOrderStatus.rejected),
      ('Отменённые', WorkOrderStatus.cancelled),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final column in columns)
            _ApiKanbanColumn(
              title: column.$1,
              orders: filtered
                  .where((order) => order.status == column.$2)
                  .toList(),
              onOrder: widget.onOrder,
            ),

          _ApiKanbanColumn(
            title: 'Просроченные',
            orders: filtered.where((order) => order.isOverdue).toList(),
            onOrder: widget.onOrder,
            overdue: true,
          ),
        ],
      ),
    );
  }
}

// MARK: - API order card

class ApiOrderCard extends StatelessWidget {
  const ApiOrderCard({super.key, required this.order, required this.onTap});

  final WorkOrderApiModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final equipment = order.equipment.name;
    final area = order.area.name;
    final assignee = order.assignee.fullName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: order.isEmergency ? const Color(0xFFFECACA) : border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      'НАРЯД №${order.number}',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    _ApiStatusTag(
                      text: order.status.label,
                      color: _statusColor(order.status),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  order.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '$equipment · $area',
                  style: const TextStyle(fontSize: 13, color: muted),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: muted),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        assignee,
                        style: const TextStyle(fontSize: 13, color: muted),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ApiStatusTag(
                      text: order.priority.label,
                      color: _priorityColor(order.priority),
                    ),

                    Text(
                      'До ${dateLabel(order.deadline.toLocal())} '
                      '${timeLabel(order.deadline.toLocal())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: order.isOverdue ? Colors.red : muted,
                      ),
                    ),

                    if (order.isOverdue)
                      const _ApiStatusTag(text: 'Просрочен', color: Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: - API kanban

class _ApiKanbanColumn extends StatelessWidget {
  const _ApiKanbanColumn({
    required this.title,
    required this.orders,
    required this.onOrder,
    this.overdue = false,
  });

  final String title;
  final List<WorkOrderApiModel> orders;
  final ValueChanged<WorkOrderApiModel> onOrder;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: overdue ? Colors.red : brand,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  uiText(context, title),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),

              Text(
                '${orders.length}',
                style: const TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                uiText(context, 'Нет нарядов'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 13),
              ),
            )
          else
            for (final order in orders)
              ApiOrderCard(order: order, onTap: () => onOrder(order)),
        ],
      ),
    );
  }
}

// MARK: - Orders error

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 38, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(uiText(context, 'Повторить')),
          ),
        ],
      ),
    );
  }
}

// MARK: - API helpers

class _ApiStatusTag extends StatelessWidget {
  const _ApiStatusTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        uiText(context, text),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color _statusColor(WorkOrderStatus status) {
  return switch (status) {
    WorkOrderStatus.issued => const Color(0xFF2563EB),
    WorkOrderStatus.queued => const Color(0xFF7C3AED),
    WorkOrderStatus.accepted => const Color(0xFF0284C7),
    WorkOrderStatus.inProgress => const Color(0xFFF59E0B),
    WorkOrderStatus.paused => const Color(0xFF64748B),
    WorkOrderStatus.completed => const Color(0xFF0D9488),
    WorkOrderStatus.aiReview => const Color(0xFF7C3AED),
    WorkOrderStatus.rework => const Color(0xFFEA580C),
    WorkOrderStatus.closed => const Color(0xFF059669),
    WorkOrderStatus.rejected => const Color(0xFFDC2626),
    WorkOrderStatus.cancelled => const Color(0xFF64748B),
  };
}

Color _priorityColor(WorkOrderPriority priority) {
  return switch (priority) {
    WorkOrderPriority.emergency => const Color(0xFFDC2626),
    WorkOrderPriority.high => const Color(0xFFEA580C),
    WorkOrderPriority.normal => const Color(0xFF2563EB),
    WorkOrderPriority.planned => const Color(0xFF64748B),
  };
}
