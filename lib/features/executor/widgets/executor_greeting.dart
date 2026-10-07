import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/utils/enterprise_time.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:flutter/material.dart';
import 'package:mineral/shared/models/models.dart';

String greeting(DateTime time) => switch (enterpriseTime(time).hour) {
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
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5EEFC)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF3488FF),
                  child: Text(
                    employee.initials,
                    style: const TextStyle(
                      color: Colors.white,
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
                          fontSize: 14,
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
                  LucideIcons.clipboardList,
                  blue,
                  width,
                ),
                _count(
                  uiText(context, 'В работе'),
                  orders.where((o) => o.status == OrderStatus.working).length,
                  LucideIcons.play,
                  const Color(0xFFD97706),
                  width,
                ),
                _count(
                  uiText(context, 'В очереди'),
                  orders.where((o) => o.status == OrderStatus.queued).length,
                  LucideIcons.listOrdered,
                  const Color(0xFF2563EB),
                  width,
                ),
                _count(
                  uiText(context, 'Завершено'),
                  orders.where((o) => o.status == OrderStatus.closed).length,
                  LucideIcons.circleCheck,
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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEAF0F9)),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              color: Color(0xFF687385),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
