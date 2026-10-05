import 'package:flutter/material.dart';

import '../l10n/ui_localization.dart';
import 'demo_store.dart';
import 'models.dart';
import 'ui.dart';

class OrderFilters {
  OrderFilters({
    Set<String>? areas,
    Set<int>? employees,
    Set<OrderStatus>? statuses,
  }) : areas = Set.of(areas ?? {}),
       employees = Set.of(employees ?? {}),
       statuses = Set.of(statuses ?? {});

  final Set<String> areas;
  final Set<int> employees;
  final Set<OrderStatus> statuses;

  int get count => areas.length + employees.length + statuses.length;

  OrderFilters copy() =>
      OrderFilters(areas: areas, employees: employees, statuses: statuses);

  bool matches(WorkOrder order, DemoStore store) =>
      (areas.isEmpty || areas.contains(order.area)) &&
      (employees.isEmpty ||
          employees.any((id) => store.assignedTo(id).contains(order))) &&
      (statuses.isEmpty || statuses.contains(order.status));
}

class OrderFilterPanel extends StatefulWidget {
  const OrderFilterPanel({
    super.key,
    required this.store,
    required this.filters,
  });
  final DemoStore store;
  final OrderFilters filters;

  @override
  State<OrderFilterPanel> createState() => _OrderFilterPanelState();
}

class _OrderFilterPanelState extends State<OrderFilterPanel> {
  late OrderFilters draft = widget.filters.copy();

  Widget group<T>(
    String label,
    Iterable<T> values,
    Set<T> selected,
    String Function(T) title, {
    VoidCallback? afterChange,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          uiText(context, label),
          style: const TextStyle(fontWeight: FontWeight.w700, color: ink),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              FilterChip(
                label: Text(title(value)),
                selected: selected.contains(value),
                onSelected: (enabled) => setState(() {
                  if (enabled) {
                    selected.add(value);
                  } else {
                    selected.remove(value);
                  }
                  afterChange?.call();
                }),
              ),
          ],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .82,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: brand),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.filters,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: s.closeFilters,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  group(
                    'Участок',
                    DemoStore.areas.keys,
                    draft.areas,
                    (value) => value,
                  ),
                  group(
                    'Исполнитель',
                    widget.store.employees.map((e) => e.id),
                    draft.employees,
                    (id) => widget.store.employee(id).name,
                  ),
                  group(
                    s.statusFilter,
                    OrderStatus.values,
                    draft.statuses,
                    (value) => uiText(context, value.label),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() => draft = OrderFilters()),
                    child: Text(s.resetFilters),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, draft),
                      child: Text(s.applyFilters),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
