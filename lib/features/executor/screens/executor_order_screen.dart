import 'package:flutter/material.dart';
import 'completion_screen.dart';
import '../widgets/order_section.dart';
import '../widgets/work_timer.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/orders/widgets/photo_attachments.dart';

class ExecutorOrderScreen extends StatelessWidget {
  const ExecutorOrderScreen({
    super.key,
    required this.store,
    required this.order,
    required this.employeeId,
  });
  final DemoStore store;
  final WorkOrder order;
  final int employeeId;

  void _change(OrderStatus status, {String reason = ''}) {
    if (!store.assignedTo(employeeId).contains(order)) return;
    store.changeStatus(
      order,
      status,
      reason: reason,
      author: store.employee(employeeId).name,
    );
  }

  Future<void> _reason(BuildContext context, OrderStatus status) async {
    final controller = TextEditingController();
    final key = GlobalKey<FormState>();
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  status == OrderStatus.rejected
                      ? 'Причина отказа'
                      : 'Причина приостановки',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Form(
                  key: key,
                  child: TextFormField(
                    controller: controller,
                    autofocus: true,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Причина'),
                    validator: (value) =>
                        (value ?? '').trim().isEmpty ? 'Укажите причину' : null,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (key.currentState!.validate()) {
                      Navigator.pop(context, controller.text.trim());
                    }
                  },
                  child: const Text('Подтвердить'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // Wait for the closing sheet animation before disposing its controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (reason != null &&
        context.mounted &&
        order.status ==
            (status == OrderStatus.rejected
                ? OrderStatus.issued
                : OrderStatus.working)) {
      _change(status, reason: reason);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final assigned = store.assignedTo(employeeId).contains(order);
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Наряд №${order.number}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEF0F4))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!assigned)
                  const Text('Наряд переназначен другому исполнителю.'),
                if (assigned && order.status == OrderStatus.issued) ...[
                  FilledButton(
                    onPressed: () => _change(OrderStatus.accepted),
                    child: const Text('Принять в работу'),
                  ),
                  OutlinedButton(
                    onPressed: () => _change(OrderStatus.queued),
                    child: const Text('Поставить в очередь'),
                  ),
                  TextButton(
                    onPressed: () => _reason(context, OrderStatus.rejected),
                    child: const Text('Отклонить'),
                  ),
                ],
                if (assigned &&
                    {
                      OrderStatus.accepted,
                      OrderStatus.queued,
                      OrderStatus.paused,
                      OrderStatus.rework,
                    }.contains(order.status))
                  FilledButton(
                    onPressed: () => _change(OrderStatus.working),
                    child: Text(
                      order.status == OrderStatus.paused ||
                              order.status == OrderStatus.rework
                          ? 'Возобновить работу'
                          : 'Начать исполнение',
                    ),
                  ),
                if (assigned && order.status == OrderStatus.working) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reason(context, OrderStatus.paused),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            textStyle: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(fontSize: 13),
                            backgroundColor: const Color(0xFFFFE6A3),
                            foregroundColor: const Color(0xFF8F5100),
                            side: BorderSide.none,
                          ),
                          icon: const Icon(Icons.pause_rounded, size: 18),
                          label: const Text('Приостановить'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CompletionScreen(
                                store: store,
                                order: order,
                                employeeId: employeeId,
                              ),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            textStyle: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(fontSize: 13),
                            backgroundColor: const Color(0xFF08A45C),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: const Text('Исполнено'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: Color(0xFF01408B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      order.status.label,
                      style: const TextStyle(
                        color: Color(0xFF01408B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: Color(0xFF01408B),
                  ),
                  const SizedBox(width: 6),
                  WorkTimer(order: order, store: store),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              order.title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE6EAF0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: order.beforeImages.isNotEmpty
                        ? Image.memory(
                            order.beforeImages.first.bytes,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFFF0F4FA),
                            child: const Icon(
                              Icons.precision_manufacturing_outlined,
                              color: Color(0xFF65748B),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.equipment,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.area,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF65748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OrderSection(
              icon: Icons.schedule_outlined,
              title: 'Срок выполнения',
              child: Text(
                '${dateLabel(order.deadline)} · ${timeLabel(order.deadline)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: order.overdue
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF01408B),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Приоритет: ${order.priority}',
              style: TextStyle(
                color: order.emergency
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF65748B),
              ),
            ),
            const SizedBox(height: 24),
            OrderSection(
              icon: Icons.description_outlined,
              title: 'Описание неисправности',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.description,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ),
            if (order.comment.isNotEmpty) ...[
              const SizedBox(height: 20),
              OrderSection(
                icon: Icons.chat_bubble_outline,
                title: 'Комментарий',
                child: Text(order.comment),
              ),
            ],
            const SizedBox(height: 24),
            if (order.beforeImages.isNotEmpty)
              PhotoAttachments(
                title: 'Фото до начала работ',
                photos: order.beforeImages,
                framed: false,
              )
            else
              const OrderSection(
                icon: Icons.camera_alt_outlined,
                title: 'Фото до начала работ',
                child: Text(
                  'Мастер не добавил фотографии',
                  style: TextStyle(color: Color(0xFF65748B)),
                ),
              ),
            if (order.history.isNotEmpty) ...[
              const SizedBox(height: 24),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'История действий',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                children: [
                  for (final event in order.history.reversed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(event.title),
                      subtitle: Text(
                        '${event.author} · ${dateLabel(event.time)} ${timeLabel(event.time)}',
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}
