import 'package:flutter/material.dart';
import 'package:mineral/shared/data/demo_store.dart';

class ExecutorProfileScreen extends StatelessWidget {
  const ExecutorProfileScreen({
    super.key,
    required this.store,
    required this.employeeId,
  });
  final DemoStore store;
  final int employeeId;
  @override
  Widget build(BuildContext context) {
    final employee = store.employee(employeeId);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          employee.name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        ListTile(
          title: const Text('Специальность'),
          subtitle: Text(employee.specialty),
        ),
        ListTile(
          title: const Text('Разряд'),
          subtitle: Text('${employee.grade}'),
        ),
        ListTile(
          title: const Text('Бригада'),
          subtitle: Text(employee.brigade),
        ),
        ListTile(
          title: const Text('Смена'),
          subtitle: Text(employee.onShift ? 'На смене' : 'Не на смене'),
        ),
        const Divider(height: 40),
        const Text(
          'Мой рейтинг',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Рейтинг пока не рассчитан. Здесь появятся показатели и пояснение.',
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () =>
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
          child: const Text('Выйти'),
        ),
      ],
    );
  }
}
