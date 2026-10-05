import 'package:mineral/l10n/ui_localization.dart';
import 'package:flutter/material.dart';
import 'package:mineral/shared/models/models.dart';

String greeting(DateTime time) => switch (time.hour) {
  >= 5 && < 12 => 'Доброе утро',
  >= 12 && < 18 => 'Добрый день',
  >= 18 && < 23 => 'Добрый вечер',
  _ => 'Доброй ночи',
};

class ExecutorGreeting extends StatelessWidget {
  const ExecutorGreeting({
    super.key,
    required this.employee,
    required this.time,
    required this.orders,
  });
  final Employee employee;
  final DateTime time;
  final List<WorkOrder> orders;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF01408B);
    final active = orders
        .where(
          (o) => !{
            OrderStatus.closed,
            OrderStatus.cancelled,
            OrderStatus.rejected,
          }.contains(o.status),
        )
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEAF1FA),
                  child: Text(
                    employee.initials,
                    style: const TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xFF17243B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${uiText(context, employee.specialty)} · ${uiText(context, employee.brigade)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF687385),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '● ${uiText(context, employee.onShift ? 'На смене' : 'Не на смене')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: employee.onShift
                              ? const Color(0xFF059669)
                              : const Color(0xFF687385),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth < 350 ||
                    MediaQuery.textScalerOf(context).scale(12) > 16
                ? 2
                : 4;
            final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _count(
                  uiText(context, 'Активных'),
                  active,
                  Icons.assignment,
                  blue,
                  width,
                ),
                _count(
                  uiText(context, 'В работе'),
                  orders.where((o) => o.status == OrderStatus.working).length,
                  Icons.play_arrow,
                  const Color(0xFFD97706),
                  width,
                ),
                _count(
                  uiText(context, 'В очереди'),
                  orders.where((o) => o.status == OrderStatus.queued).length,
                  Icons.format_list_numbered,
                  const Color(0xFF2563EB),
                  width,
                ),
                _count(
                  uiText(context, 'Завершено'),
                  orders.where((o) => o.status == OrderStatus.closed).length,
                  Icons.check_circle,
                  const Color(0xFF059669),
                  width,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _count(
    String label,
    int count,
    IconData icon,
    Color color,
    double width,
  ) => Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF687385),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
