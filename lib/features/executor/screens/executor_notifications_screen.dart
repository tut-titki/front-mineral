import 'package:mineral/l10n/ui_localization.dart';
import 'package:flutter/material.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/shared/models/models.dart';
import 'executor_order_screen.dart';
import 'executor_result_screen.dart';

class ExecutorNotificationsScreen extends StatelessWidget {
  const ExecutorNotificationsScreen({
    super.key,
    required this.store,
    required this.employeeId,
  });
  final ExecutorRepository store;
  final int employeeId;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FB),
    appBar: AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      title: Text(uiText(context, 'Уведомления')),
    ),
    body: ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final notices = <(WorkOrder, String, IconData, Color)>[];
        for (final order in store.assignedTo(employeeId)) {
          if (order.status == OrderStatus.issued) {
            notices.add((
              order,
              order.emergency
                  ? uiText(context, 'Аварийный наряд — требуется ответ')
                  : uiText(context, 'Вам назначен новый наряд'),
              Icons.assignment_outlined,
              order.emergency ? Colors.red : const Color(0xFF01408B),
            ));
          }
          if (order.status == OrderStatus.rework) {
            notices.add((
              order,
              uiText(context, 'Наряд возвращён на доработку'),
              Icons.edit_note,
              Colors.orange,
            ));
          }
          if (order.status == OrderStatus.closed) {
            notices.add((
              order,
              uiText(context, 'Мастер закрыл наряд'),
              Icons.task_alt,
              Colors.green,
            ));
          }
          if (!{
            OrderStatus.review,
            OrderStatus.closed,
            OrderStatus.cancelled,
            OrderStatus.rejected,
          }.contains(order.status)) {
            final left = order.deadline.difference(store.now);
            if (left.isNegative) {
              notices.add((
                order,
                uiText(context, 'Срок выполнения истёк'),
                Icons.timer_outlined,
                Colors.red,
              ));
            } else if (left <= const Duration(minutes: 30)) {
              notices.add((
                order,
                strings(context).deadlineMinutesLeft('${left.inMinutes}'),
                Icons.schedule,
                Colors.orange,
              ));
            }
          }
        }
        if (notices.isEmpty) {
          return Center(child: Text(uiText(context, 'Уведомлений пока нет')));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notices.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final (order, title, icon, color) = notices[i];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: .09),
                  child: Icon(icon, color: color, size: 21),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '№${order.number} · ${uiText(context, order.equipment)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        {
                          OrderStatus.closed,
                          OrderStatus.rework,
                          OrderStatus.review,
                        }.contains(order.status)
                        ? ExecutorResultScreen(
                            store: store,
                            order: order,
                            employeeId: employeeId,
                          )
                        : ExecutorOrderScreen(
                            store: store,
                            order: order,
                            employeeId: employeeId,
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
