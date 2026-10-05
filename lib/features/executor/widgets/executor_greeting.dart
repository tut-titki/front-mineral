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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting(time),
          style: const TextStyle(fontSize: 16, color: Color(0xFF687385)),
        ),
        const SizedBox(height: 6),
        Text(
          employee.name,
          style: const TextStyle(
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: blue,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${employee.specialty} · ${employee.brigade}',
          style: const TextStyle(color: Color(0xFF687385)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _count('Активных', orders.length),
            _count(
              'В работе',
              orders.where((o) => o.status == OrderStatus.working).length,
            ),
            _count(
              'В очереди',
              orders.where((o) => o.status == OrderStatus.queued).length,
            ),
          ],
        ),
      ],
    );
  }

  Widget _count(String label, int count) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFEDF4FC),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      '$label · $count',
      style: const TextStyle(
        color: Color(0xFF01408B),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
