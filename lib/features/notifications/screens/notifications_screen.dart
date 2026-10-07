import 'package:flutter/material.dart';
import '../../../core/api/api_services.dart';
import '../../../l10n/ui_localization.dart';
import '../../../shared/widgets/backend_section.dart';
import '../../../shared/widgets/ui.dart';
import '../data/notifications_api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.api,
    required this.onOrder,
  });
  final ApiServices api;
  final ValueChanged<int> onOrder;
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final pending = <int>{};
  Future<void> _open(NotificationApiModel notification) async {
    if (pending.contains(notification.id)) return;
    setState(() => pending.add(notification.id));
    try {
      if (!notification.isRead) {
        await widget.api.notifications.markRead(notification.id);
        widget.api.realtime.invalidate();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(backendError(context, error))));
      }
    } finally {
      if (mounted) setState(() => pending.remove(notification.id));
    }
    if (mounted && notification.workOrderId != null) {
      widget.onOrder(notification.workOrderId!);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PageHeading(
        'Центр уведомлений',
        subtitle: backendText(
          context,
          'Последние уведомления смены',
          'Ауысымның соңғы хабарландырулары',
        ),
      ),
      BackendSection<List<NotificationApiModel>>(
        load: widget.api.notifications.getNotifications,
        changes: widget.api.realtime.changes,
        builder: (context, items) => items.isEmpty
            ? Panel(child: Text(uiText(context, 'Новых уведомлений нет')))
            : Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Panel(
                        color: item.isRead ? Colors.white : lightBlue,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: pending.contains(item.id)
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  item.isOverdue
                                      ? Icons.warning_amber
                                      : Icons.notifications_outlined,
                                  color: item.isOverdue ? Colors.red : brand,
                                ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w800,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.message),
                              const SizedBox(height: 8),
                              Text(
                                item.createdAt.toLocal().toString(),
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: item.workOrderId == null
                              ? null
                              : const Icon(Icons.chevron_right),
                          onTap: pending.contains(item.id)
                              ? null
                              : () => _open(item),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    ],
  );
}
