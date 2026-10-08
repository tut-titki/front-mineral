import 'package:flutter/material.dart';
import '../../../core/api/backend_document.dart';
import '../../../l10n/ui_localization.dart';
import '../../../shared/widgets/backend_section.dart';
import '../../../shared/widgets/ui.dart';
import '../../orders/data/references_api.dart';
import '../../orders/models/work_order_api_models.dart';

int compareAttentionOrders(WorkOrderApiModel a, WorkOrderApiModel b) {
  // Emergency work comes first, then overdue work, then work awaiting review.
  int urgency(WorkOrderApiModel order) =>
      order.isEmergency && order.status.isActive
      ? 0
      : order.isOverdue
      ? 1
      : 2;
  final urgent = urgency(a).compareTo(urgency(b));
  if (urgent != 0) return urgent;
  final priority = a.priority.index.compareTo(b.priority.index);
  if (priority != 0) return priority;
  final deadline = a.deadline.compareTo(b.deadline);
  return deadline != 0 ? deadline : a.id.compareTo(b.id);
}

List<Map> _items(BackendDocument document) => document.value is List
    ? (document.value as List).whereType<Map>().toList()
    : [];
String _number(Object? value) => value == null ? '—' : '$value';
Widget _empty(BuildContext context) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 12),
  child: Text(
    backendText(context, 'Нет данных', 'Деректер жоқ'),
    style: const TextStyle(color: muted),
  ),
);
Widget _rows(List<Widget> rows) => Column(
  children: [
    for (var i = 0; i < rows.length; i++) ...[
      if (i > 0) const Divider(height: 1, color: Color(0xFFE8EDF4)),
      rows[i],
    ],
  ],
);

class ShiftCounters extends StatelessWidget {
  const ShiftCounters({super.key, required this.counters});
  final Map<String, int> counters;
  @override
  Widget build(BuildContext context) => Row(
    key: const ValueKey('shift-counters'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in [
        (
          'issued',
          'Выдано',
          'Берілді',
          'Выдано за смену',
          Icons.assignment_outlined,
          brand,
        ),
        (
          'completed',
          'Выполнено',
          'Орындалды',
          'Выполнено за смену',
          Icons.task_alt,
          const Color(0xFF15803D),
        ),
        (
          'overdue',
          'Просрочено',
          'Мерзімі өтті',
          'Просрочено',
          Icons.schedule,
          const Color(0xFFB42318),
        ),
        (
          'equipmentInDowntime',
          'Простой',
          'Тоқтап тұр',
          'Оборудование в простое',
          Icons.factory_outlined,
          const Color(0xFFB45309),
        ),
      ]) ...[
        if (item.$1 != 'issued') const SizedBox(width: 6),
        Expanded(
          child: Tooltip(
            message: uiText(context, item.$4),
            child: Container(
              height: 76,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        Icon(item.$5, color: item.$6, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${counters[item.$1] ?? '—'}',
                              style: TextStyle(
                                fontSize: 22,
                                height: 1,
                                fontWeight: FontWeight.w800,
                                color: item.$6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 26,
                    child: Text(
                      backendText(context, item.$2, item.$3),
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.2,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

class EquipmentFailuresList extends StatelessWidget {
  const EquipmentFailuresList({super.key, required this.document});
  final BackendDocument document;
  @override
  Widget build(BuildContext context) {
    final items = _items(document);
    if (items.isEmpty) return _empty(context);
    return _rows([
      for (final item in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  uiText(context, '${item['name'] ?? '—'}'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _number(
                    item['_count'] is Map
                        ? item['_count']['orders']
                        : item['_count'],
                  ),
                  style: const TextStyle(
                    color: brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
    ]);
  }
}

class ExecutorRankingList extends StatelessWidget {
  const ExecutorRankingList({super.key, required this.document});
  final BackendDocument document;
  @override
  Widget build(BuildContext context) {
    final items = _items(document);
    if (items.isEmpty) return _empty(context);
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 62,
              child: Text(
                backendText(context, 'Оценка', 'Баға'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: muted),
              ),
            ),
            SizedBox(
              width: 62,
              child: Text(
                uiText(context, 'Наряды'),
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 11, color: muted),
              ),
            ),
          ],
        ),
        _rows([
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item['fullName'] ?? '—'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 62,
                    child: Text(
                      double.tryParse('${item['score']}')?.toStringAsFixed(1) ??
                          '—',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 62,
                    child: Text(
                      _number(item['closed']),
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
        ]),
      ],
    );
  }
}

class ShiftTeamList extends StatelessWidget {
  const ShiftTeamList({super.key, required this.executors});
  final List<ExecutorReference> executors;
  @override
  Widget build(BuildContext context) => Panel(
    padding: 16,
    child: _rows([
      for (final executor in executors)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: executor.employeeStatus.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      executor.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      uiText(context, executor.qualification),
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      uiText(context, executor.statusLabel),
                      style: TextStyle(
                        color: executor.employeeStatus.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ]),
  );
}

class DashboardInsights extends StatelessWidget {
  const DashboardInsights({
    super.key,
    required this.document,
    required this.forecast,
    this.maxItems,
  });
  final BackendDocument document;
  final bool forecast;
  final int? maxItems;
  @override
  Widget build(BuildContext context) {
    final items = _items(document);
    if (items.isEmpty) return _empty(context);
    return _rows([
      for (final item in maxItems == null ? items : items.take(maxItems!))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: forecast ? _forecast(context, item) : _anomaly(context, item),
        ),
    ]);
  }

  String _name(Object? value) =>
      value is Map ? '${value['name'] ?? '—'}' : '${value ?? '—'}';
  Widget _forecast(BuildContext context, Map item) {
    final probability = double.tryParse('${item['probability']}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                uiText(context, _name(item['equipment'])),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              probability == null ? '—' : '${(probability * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w700, color: brand),
            ),
          ],
        ),
        if (probability != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: probability.clamp(0, 1),
              minHeight: 5,
              color: brand,
              backgroundColor: lightBlue,
            ),
          ),
        ],
        if (item['recentFailures'] != null) ...[
          const SizedBox(height: 8),
          Text(
            backendText(
              context,
              'Последние отказы: ${item['recentFailures']}',
              'Соңғы ақаулар: ${item['recentFailures']}',
            ),
            style: const TextStyle(fontSize: 12, color: muted),
          ),
        ],
      ],
    );
  }

  Widget _anomaly(BuildContext context, Map item) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        '${item['title'] ?? '—'}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.35,
        ),
      ),
      if (item['description'] != null) ...[
        const SizedBox(height: 8),
        Text(
          '${item['description']}',
          style: const TextStyle(color: muted, fontSize: 13, height: 1.5),
        ),
      ],
      if (item['recommendation'] != null) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${item['recommendation']}',
            style: const TextStyle(color: brand, fontSize: 13, height: 1.5),
          ),
        ),
      ],
    ],
  );
}
