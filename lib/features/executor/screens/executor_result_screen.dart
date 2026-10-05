import 'package:flutter/material.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/orders/widgets/photo_attachments.dart';
import 'executor_order_screen.dart';

class ExecutorResultScreen extends StatelessWidget {
  const ExecutorResultScreen({
    super.key,
    required this.store,
    required this.order,
    required this.employeeId,
  });
  final DemoStore store;
  final WorkOrder order;
  final int employeeId;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Результат · №${order.number}')),
    body: ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final reason = order.history
            .where((e) => e.status == OrderStatus.rework)
            .lastOrNull
            ?.reason;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              order.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(
              order.status.label,
              style: TextStyle(color: order.status.color),
            ),
            const SizedBox(height: 24),
            Text(
              order.masterScore == null
                  ? 'Оценка мастера пока не выставлена'
                  : 'Оценка мастера: ${order.masterScore} / 5',
            ),
            const SizedBox(height: 16),
            const Text(
              'ИИ будет подключён позже. Автоматического заключения пока нет.',
            ),
            if (order.status == OrderStatus.review)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Отчёт отправлен. Ожидает проверки мастером.'),
              ),
            if (order.status == OrderStatus.rework)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Доработка: ${reason == null || reason.isEmpty ? 'Уточните замечания у мастера' : reason}',
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Ваш отчёт',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              order.completedWork.isEmpty
                  ? 'Работы не указаны'
                  : order.completedWork,
            ),
            const SizedBox(height: 12),
            Text('Шифр: ${order.faultCode}'),
            const SizedBox(height: 12),
            Text(order.materials),
            if (order.afterImages.isNotEmpty)
              PhotoAttachments(
                title: 'Фото после',
                photos: order.afterImages,
                framed: false,
              ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ExecutorOrderScreen(
                    store: store,
                    order: order,
                    employeeId: employeeId,
                  ),
                ),
              ),
              child: Text(
                order.status == OrderStatus.rework
                    ? 'Перейти к доработке'
                    : 'Открыть наряд',
              ),
            ),
          ],
        );
      },
    ),
  );
}
