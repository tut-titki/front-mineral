import 'package:flutter/material.dart';
import '../../../l10n/ui_localization.dart';
import '../../../shared/models/models.dart';
import '../../executor/data/executor_repository.dart';
import 'notifications_api.dart';

class DemoNotifications {
  static final _demoRead = Expando<Set<int>>('demo notification reads');
  static List<NotificationApiModel> items(
    BuildContext context,
    ExecutorRepository store,
    int employeeId,
  ) {
    final items = <NotificationApiModel>[];
    final read = _demoRead[store] ??= <int>{};
    for (final order in store.assignedTo(employeeId)) {
      void add(int slot, String type, String title) {
        final id = order.number * 10 + slot;
        items.add(
          NotificationApiModel(
            id: id,
            userId: employeeId,
            workOrderId: order.number,
            type: type,
            title: title,
            message:
                '№${order.displayNumber} · ${uiText(context, order.equipment)}',
            isRead: read.contains(id),
            createdAt: order.history.isEmpty
                ? order.createdAt
                : order.history.last.time,
          ),
        );
      }

      if (order.status == OrderStatus.issued) {
        add(
          0,
          'NEW_ORDER',
          uiText(
            context,
            order.emergency
                ? 'Аварийный наряд — требуется ответ'
                : 'Вам назначен новый наряд',
          ),
        );
      }
      if (order.status == OrderStatus.rework) {
        add(1, 'REWORK', uiText(context, 'Наряд возвращён на доработку'));
      }
      if (order.status == OrderStatus.closed) {
        add(2, 'CLOSED', uiText(context, 'Мастер закрыл наряд'));
      }
      if (!{
        OrderStatus.closed,
        OrderStatus.cancelled,
        OrderStatus.rejected,
      }.contains(order.status)) {
        final left = order.deadline.difference(store.now);
        if (left.isNegative) {
          add(3, 'OVERDUE_0', uiText(context, 'Срок выполнения истёк'));
        } else if (left <= const Duration(minutes: 30)) {
          add(
            4,
            'DEADLINE_REMINDER',
            strings(context).deadlineMinutesLeft('${left.inMinutes}'),
          );
        }
      }
    }
    return items;
  }

  static Future<void> markRead(ExecutorRepository store, int id) async {
    (_demoRead[store] ??= <int>{}).add(id);
  }
}
